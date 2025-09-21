// srv/cat-service.js
const cds = require("@sap/cds");
const { SELECT, INSERT, UPDATE } = cds.ql;

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

    // Place a sales order
    this.on("placeOrder", "Books", async (req) => {
      try {
        const { ID } = req.params?.[0] || {};
        if (ID == null) return req.error(400, "Missing Book ID from context");
        if (!req.user || req.user.is?.("anonymous"))
          return req.error(401, "You must be logged in to place an order");

        const quantity = Number(req.data.quantity);
        if (!Number.isFinite(quantity) || quantity <= 0)
          return req.error(400, "Provide a positive quantity");

        const { Books, SalesOrders, SalesOrderItems, Customers } = cds.entities(
          "sap.capire.bookshop"
        );

        const book = await SELECT.one
          .from(Books)
          .columns("ID", "title", "price", "currency_code")
          .where({ ID });
        if (!book) return req.error(404, `Book ${ID} not found`);

        const price = Number(book.price);
        if (!Number.isFinite(price))
          return req.error(409, `Book ${ID} has no valid price`);
        const currency = book.currency_code || "EUR";
        const total = Number((price * quantity).toFixed(2));

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

        const orderItem = {
          ID: cds.utils.uuid(),
          itemNumber: 10,
          productName: book.title,
          productCode: String(ID),
          quantity,
          unitPrice: price,
          totalPrice: Number((price * quantity).toFixed(2)),
          currency_code: currency,
          salesOrder_ID: orderId,
        };

        await INSERT.into(SalesOrders).entries({
          ID: orderId,
          orderNumber: `SO-${Math.floor(Math.random() * 90000 + 10000)}`,
          orderDate: today,
          totalAmount: total,
          currency_code: currency,
          status: "NEW",
          customer_ID: customer.ID,
        });

        await INSERT.into(SalesOrderItems).entries(orderItem);

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

    // Delegate requests to the underlying generic service
    return super.init();
  }
};
