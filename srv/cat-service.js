// srv/cat-service.js
const cds = require("@sap/cds");
const { SELECT, INSERT, UPDATE } = cds.ql;

module.exports = class CatalogService extends cds.ApplicationService {
  init() {
    const { Books, SalesOrders, SalesOrderItems, Customers, Inventory } =
      cds.entities("sap.capire.bookshop");
    const { ListOfBooks } = this.entities;

    this.on("submitOrder", async (req) => {
      let { book: id, quantity } = req.data;
      let book = await SELECT.one.from(Books, id, (b) => b.stock);

      if (!book) return req.error(404, `Book #${id} doesn't exist`);
      if (quantity < 1) return req.error(400, `quantity has to be 1 or more`);
      if (!book.stock || quantity > book.stock)
        return req.error(409, `${quantity} exceeds stock for book #${id}`);

      await UPDATE(Books, id).with({ stock: (book.stock -= quantity) });
      return book;
    });

    this.after("submitOrder", async (_, req) => {
      let { book, quantity } = req.data;
      await this.emit("OrderedBook", { book, quantity, buyer: req.user.id });
    });

    // --- Place a sales order + allocate from warehouses ---
    this.on("placeOrder", "Books", async (req) => {
      try {
        const { ID } = req.params?.[0] || {};
        if (ID == null) return req.error(400, "Missing Book ID from context");
        if (!req.user || req.user.is?.("anonymous")) {
          return req.error(401, "You must be logged in to place an order");
        }

        const quantity = Number(req.data.quantity);
        if (!Number.isFinite(quantity) || quantity <= 0) {
          return req.error(400, "Provide a positive quantity");
        }

        const book = await SELECT.one
          .from(Books)
          .columns("ID", "title", "price", "currency_code", "stock")
          .where({ ID });
        if (!book) return req.error(404, `Book ${ID} not found`);

        const price = Number(book.price);
        if (!Number.isFinite(price))
          return req.error(409, `Book ${ID} has no valid price`);
        const currency = book.currency_code || "EUR";
        const total = Number((price * quantity).toFixed(2));

        const invRows = await SELECT.from(Inventory)
          .columns("book_ID", "warehouse_ID", "quantity")
          .where({ book_ID: ID })
          .orderBy({ quantity: "desc" });

        const totalAvailable = invRows.reduce(
          (s, r) => s + (r.quantity || 0),
          0
        );
        if (totalAvailable < quantity) {
          return req.error(
            409,
            `Requested ${quantity} exceeds total available stock (${totalAvailable}) for book ${ID}`
          );
        }

        const userId = req.user?.id;
        const userName =
          req.user?.attr?.displayname ||
          req.user?.displayname ||
          req.user?.name ||
          userId ||
          "Unknown";
        const userMail = req.user?.attr?.email || req.user?.email || null;

        let customer = await SELECT.one
          .from(Customers)
          .columns("ID")
          .where({ userId });
        if (!customer) {
          const customerId = cds.utils.uuid();
          await INSERT.into(Customers).entries({
            ID: customerId,
            userId,
            name: userName,
            email: userMail,
          });
          customer = { ID: customerId };
        } else {
          await UPDATE(Customers)
            .set({ name: userName, email: userMail })
            .where({ userId });
        }

        const orderId = cds.utils.uuid();
        const today = new Date().toISOString().slice(0, 10);

        await INSERT.into(SalesOrders).entries({
          ID: orderId,
          orderNumber: `SO-${Math.floor(Math.random() * 90000 + 10000)}`,
          orderDate: today,
          totalAmount: total,
          currency_code: currency,
          status: "NEW",
          customer_ID: customer.ID,
        });

        await INSERT.into(SalesOrderItems).entries({
          ID: cds.utils.uuid(),
          itemNumber: 10,
          productName: book.title,
          productCode: String(ID),
          quantity,
          unitPrice: price,
          totalPrice: Number((price * quantity).toFixed(2)),
          currency_code: currency,
          salesOrder_ID: orderId,
          book_ID: ID,
        });

        let remaining = quantity;

        for (const row of invRows) {
          if (remaining <= 0) break;
          const take = Math.min(remaining, row.quantity);

          if (take > 0) {
            const affected = await UPDATE(Inventory)
              .set({ quantity: { "-=": take } })
              .where({
                book_ID: ID,
                warehouse_ID: row.warehouse_ID,
                quantity: { ">=": take },
              });

            if (affected === 0) {
              const fresh = await SELECT.one
                .from(Inventory)
                .columns("quantity")
                .where({ book_ID: ID, warehouse_ID: row.warehouse_ID });

              const canTake = Math.min(remaining, fresh?.quantity ?? 0);
              if (canTake > 0) {
                const affected2 = await UPDATE(Inventory)
                  .set({ quantity: { "-=": canTake } })
                  .where({
                    book_ID: ID,
                    warehouse_ID: row.warehouse_ID,
                    quantity: { ">=": canTake },
                  });

                if (affected2 > 0) remaining -= canTake;
              }
            } else {
              remaining -= take;
            }
          }
        }

        if (remaining > 0) {
          return req.error(
            500,
            `Failed to allocate ${remaining} items from warehouses`
          );
        }

        const [{ sum }] = await SELECT.from(Inventory)
          .columns(`sum(quantity) as sum`)
          .where({ book_ID: ID });
        await UPDATE(Books, ID).with({ stock: Number(sum || 0) });

        req.info(
          `Order placed: ${quantity} × "${book.title}". Total ${total.toFixed(
            2
          )} ${currency}.`
        );
        return orderId;
      } catch (e) {
        console.error("placeOrder failed:", e);
        return req.error(500, e.message || "Failed to place order");
      }
    });

    return super.init();
  }
};
