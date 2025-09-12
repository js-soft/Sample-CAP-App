const cds = require("@sap/cds");

module.exports = class CatalogService extends cds.ApplicationService {
  init() {
    const { Books, SalesOrders, SalesOrderItems } = cds.entities(
      "sap.capire.bookshop"
    );
    const { ListOfBooks } = this.entities;

    // Add some discount for overstocked books
    this.after("each", ListOfBooks, (book) => {
      if (book.stock > 111) book.title += ` -- 11% discount!`;
    });

    // Reduce stock of ordered books if available stock suffices
    this.on("submitOrder", async (req) => {
      let { book: id, quantity } = req.data;
      let book = await SELECT.one.from(Books, id, (b) => b.stock);

      // Validate input data
      if (!book) return req.error(404, `Book #${id} doesn't exist`);
      if (quantity < 1) return req.error(400, `quantity has to be 1 or more`);
      if (!book.stock || quantity > book.stock)
        return req.error(409, `${quantity} exceeds stock for book #${id}`);

      // Reduce stock in database and return updated stock value
      await UPDATE(Books, id).with({ stock: (book.stock -= quantity) });
      return book;
    });

    // Emit event when an order has been submitted
    this.after("submitOrder", async (_, req) => {
      let { book, quantity } = req.data;
      await this.emit("OrderedBook", { book, quantity, buyer: req.user.id });
    });

    // Warehouse & inventory
    const { Inventory } = cds.entities("sap.capire.bookshop");

    const getKeys = (req) => {
      const segs = Array.isArray(req.params) ? req.params : [req.params || {}];
      const last = segs[segs.length - 1] || {};
      const prev = segs.length > 1 ? segs[segs.length - 2] : {};

      const book_ID =
        last.book_ID ?? last.book?.ID ?? req.data?.bookId ?? req.data?.book_ID;

      const warehouse_ID =
        last.warehouse_ID ??
        last.warehouse?.ID ??
        prev.ID ?? // parent Warehouses(1)
        req.data?.warehouseId ??
        req.data?.warehouse_ID;

      return { book_ID, warehouse_ID };
    };

    this.on("increaseQuantity", "Availabilities", async (req) => {
      const { book_ID, warehouse_ID } = getKeys(req);
      const by = Number(req.data?.by ?? 1) || 1;

      if (book_ID == null || warehouse_ID == null) {
        return req.error(
          400,
          "Missing keys: book_ID and warehouse_ID are required"
        );
      }

      const row = await SELECT.one
        .from(Inventory)
        .where({ book_ID, warehouse_ID });
      if (!row) {
        await INSERT.into(Inventory).entries({
          book_ID,
          warehouse_ID,
          quantity: by,
        });
      } else {
        await UPDATE(Inventory)
          .set({ quantity: { "+=": by } })
          .where({ book_ID, warehouse_ID });
      }
      return SELECT.one.from(Inventory).where({ book_ID, warehouse_ID });
    });

    this.on("decreaseQuantity", "Availabilities", async (req) => {
      const { book_ID, warehouse_ID } = getKeys(req);
      const by = Number(req.data?.by ?? 1) || 1;

      if (book_ID == null || warehouse_ID == null) {
        return req.error(
          400,
          "Missing keys: book_ID and warehouse_ID are required"
        );
      }

      const row = await SELECT.one
        .from(Inventory)
        .where({ book_ID, warehouse_ID });
      const curr = row?.quantity ?? 0;
      const next = Math.max(0, curr - by);

      if (!row) {
        await INSERT.into(Inventory).entries({
          book_ID,
          warehouse_ID,
          quantity: 0,
        });
        return { book_ID, warehouse_ID, quantity: 0 };
      }

      await UPDATE(Inventory)
        .set({ quantity: next })
        .where({ book_ID, warehouse_ID });
      return SELECT.one.from(Inventory).where({ book_ID, warehouse_ID });
    });

    // Sales orders
    // === BOUND action: Books.placeOrder ===
    // Declared INSIDE CatalogService.Books in cat-service.cds
    this.on("placeOrder", "Books", async (req) => {
      const tx = cds.tx(req);
      try {
        // 1) Guard rails
        const { ID } = req.params?.[0] || {};
        if (ID == null) return req.error(400, "Missing Book ID from context");
        if (!req.user || req.user.is?.("anonymous")) {
          return req.error(401, "You must be logged in to place an order");
        }

        const quantity = Number(req.data.quantity);
        if (!Number.isFinite(quantity) || quantity <= 0) {
          return req.error(400, "Provide a positive quantity");
        }

        const {
          Books,
          Inventory,
          Warehouses,
          SalesOrders,
          SalesOrderItems,
          Customers,
        } = cds.entities("sap.capire.bookshop");

        // 2) Load book (+price/currency)
        const book = await tx
          .read(Books)
          .where({ ID })
          .columns("ID", "title", "price", "currency_code")
          .then((r) => r?.[0]);

        if (!book) return req.error(404, `Book ${ID} not found`);
        const price = Number(book.price);
        if (!Number.isFinite(price))
          return req.error(409, `Book ${ID} has no valid price`);

        const curr = book.currency_code || "EUR";
        const total = Number((price * quantity).toFixed(2)); // consider storing raw decimal instead

        // 3) Resolve logged-in user → upsert Customer
        const userId = req.user?.id;
        const userName =
          req.user?.attr?.displayname ||
          req.user?.displayname ||
          req.user?.name ||
          userId ||
          "Unknown";
        const userMail = req.user?.attr?.email || req.user?.email || null;

        let customer = await tx
          .read(Customers)
          .where({ userId })
          .columns("ID")
          .then((r) => r?.[0]);
        if (!customer) {
          const customerId = cds.utils.uuid();
          await tx.run(
            INSERT.into(Customers).entries({
              ID: customerId,
              userId,
              name: userName,
              email: userMail,
            })
          );
          customer = { ID: customerId };
        } else {
          await tx.run(
            UPDATE(Customers)
              .set({ name: userName, email: userMail })
              .where({ userId })
          );
        }

        // 4) Find available warehouse and allocate across multiple warehouses (full coverage required)
        const invRows = await tx
          .read(Inventory)
          .where({ book_ID: ID })
          .columns("book_ID", "warehouse_ID", "quantity")
          // Strategy: take from warehouses with the most first (minimizes number of splits)
          .orderBy({ quantity: "desc" }, { warehouse_ID: "asc" });

        const availableTotal = invRows.reduce(
          (s, r) => s + Number(r.quantity ?? 0),
          0
        );
        if (availableTotal < quantity) {
          return req.error(
            409,
            `Only ${availableTotal} unit(s) of Book ${ID} available across all warehouses`
          );
        }

        let remaining = quantity;
        const allocations = []; // { warehouse_ID, take }

        // Allocate in the same transaction – each update is conditional (concurrency-safe)
        for (const r of invRows) {
          if (remaining <= 0) break;
          const avail = Number(r.quantity ?? 0);
          if (avail <= 0) continue;

          const take = Math.min(remaining, avail);
          // Atomic decrement only if enough remains right now
          const affected = await tx
            .update(Inventory)
            .set({ quantity: { "-=": take } })
            .where({
              book_ID: ID,
              warehouse_ID: r.warehouse_ID,
              quantity: { ">=": take },
            });

          if (affected === 1) {
            allocations.push({ warehouse_ID: r.warehouse_ID, take });
            remaining -= take;
          }
          // If affected === 0, we were "run past" – skip to the next layer
        }

        if (remaining > 0) {
          // Not enough after attempts → abort; all decrements are rolled back due to tx + req.error
          return req.error(
            409,
            `Concurrent update: could only reserve ${
              quantity - remaining
            }/${quantity}. Please try again.`
          );
        }

        // Get info about the storage for notes / nice UI
        const whIds = [...new Set(allocations.map((a) => a.warehouse_ID))];
        const whList = await tx
          .read(Warehouses)
          .where({ ID: { in: whIds } })
          .columns("ID", "name", "city");
        const whMap = new Map(whList.map((w) => [w.ID, w]));

        // 5) Create order + one order line per allocated warehouse
        const orderId = cds.utils.uuid();
        const today = new Date().toISOString().slice(0, 10);

        const items = allocations.map((a, idx) => ({
          ID: cds.utils.uuid(),
          itemNumber: (idx + 1) * 10,
          productName: book.title,
          productCode: String(ID),
          quantity: a.take,
          unitPrice: price,
          totalPrice: Number((price * a.take).toFixed(2)),
          currency_code: curr,
          salesOrder_ID: orderId,
          // optional: enter the warehouse ID in the product code/text if you wish
        }));

        const notes =
          `Reserved ${quantity} across ${allocations.length} warehouse(s): ` +
          allocations
            .map((a) => {
              const w = whMap.get(a.warehouse_ID);
              return `${a.take}@${a.warehouse_ID}${
                w ? `(${w.name}, ${w.city})` : ""
              }`;
            })
            .join(", ") +
          ".";

        await tx.run([
          INSERT.into(SalesOrders).entries({
            ID: orderId,
            orderNumber: `SO-${Math.floor(Math.random() * 90000 + 10000)}`,
            orderDate: today,
            totalAmount: total,
            currency_code: curr,
            status: "NEW",
            notes,
            customer_ID: customer.ID,
            // Backward-compat columns if still present:
            customerName: userName,
            customerEmail: userMail,
          }),
          ...items.map((it) => INSERT.into(SalesOrderItems).entries(it)),
        ]);

        req.info(
          `Order placed: ${quantity} × "${book.title}" from ${
            allocations.length
          } warehouse(s). Total ${total.toFixed(2)} ${curr}.`
        );
        return orderId;
      } catch (e) {
        console.error("placeOrder failed:", e);
        return req.error(500, e.message || "Failed to place order");
      }
    });

    this.on("createWarehouse", async (req) => {
      const { Warehouses } = this.entities;
      const tx = cds.transaction(req);
      const { name, address, city, email } = req.data || {};

      // Ikke angi ID her!
      await tx.run(
        INSERT.into(Warehouses).entries({ name, address, city, email })
      );

      // Hent tilbake raden (SQLite støtter ikke RETURNING i CAP out-of-the-box)
      const created = await tx.run(
        SELECT.one
          .from(Warehouses)
          .where({ name, address, city, email })
          .orderBy("ID desc")
      );
      return created;
    });

    // Delegate requests to the underlying generic service
    return super.init();
  }
};
