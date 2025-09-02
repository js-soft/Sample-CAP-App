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

    // === BOUND action: Books.placeOrder ===
    // Declared INSIDE CatalogService.Books in cat-service.cds
    this.on("placeOrder", "Books", async (req) => {
      try {
        const { ID } = req.params?.[0] || {};
        if (ID == null) return req.error(400, "Missing Book ID from context");

        const quantity = Number(req.data.quantity);
        const customerName = req.data.customerName;
        const customerEmail = req.data.customerEmail;

        if (!Number.isFinite(quantity) || quantity <= 0) {
          return req.error(400, "Provide a positive quantity");
        }
        if (!customerName || !customerEmail) {
          return req.error(400, "Customer name and email are required");
        }

        const tx = cds.tx(req);

        const book = await tx
          .read(Books)
          .where({ ID })
          .columns("ID", "title", "price", "currency_code")
          .then((rows) => rows?.[0]);

        if (!book) return req.error(404, `Book ${ID} not found`);
        if (book.price == null)
          return req.error(409, `Book ${ID} has no price set`);

        const price = Number(book.price);
        if (!Number.isFinite(price))
          return req.error(409, `Invalid price for Book ${ID}`);

        const total = Number((price * quantity).toFixed(2));
        const curr = book.currency_code || "EUR";

        const orderId = cds.utils.uuid();
        const itemId = cds.utils.uuid();
        const today = new Date().toISOString().slice(0, 10);

        await tx.run([
          INSERT.into(SalesOrders).entries({
            ID: orderId,
            orderNumber: `SO-${Math.floor(Math.random() * 90000 + 10000)}`,
            orderDate: today,
            customerName,
            customerEmail,
            customerPhone: null,
            deliveryAddress: null,
            totalAmount: total,
            currency_code: curr,
            status: "NEW",
            notes: `Auto-created from Books.placeOrder for Book ID ${ID}`,
          }),
          INSERT.into(SalesOrderItems).entries({
            ID: itemId,
            itemNumber: 10,
            productName: book.title,
            productCode: String(ID),
            quantity,
            unitPrice: price,
            totalPrice: total,
            currency_code: curr,
            salesOrder_ID: orderId,
          }),
        ]);

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
