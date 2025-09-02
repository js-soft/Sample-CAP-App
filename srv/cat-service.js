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
      // For bound actions, the instance key is in req.params[0]
      const { ID } = req.params?.[0] || {};
      if (ID == null) return req.error(400, "Missing Book ID from context");

      const { quantity, customerName, customerEmail } = req.data;
      if (!quantity || quantity <= 0)
        return req.error(400, "Provide a positive quantity");

      const tx = cds.tx(req);

      // Load the book
      const book = await tx.read(Books).where({ ID });
      if (!book) return req.error(404, `Book ${ID} not found`);

      // Compute totals
      const price = book.price || 0;
      const total = price * quantity;
      // Depending on your model this may be currency_code or currency
      const curr = book.currency_code ?? book.currency ?? "EUR";

      const orderId = cds.utils.uuid();
      const itemId = cds.utils.uuid();

      // Create order + single item
      await tx.run([
        INSERT.into(SalesOrders).entries({
          ID: orderId,
          orderNumber: `SO-${Math.floor(Math.random() * 90000 + 10000)}`,
          orderDate: new Date(),
          customerName,
          customerEmail,
          customerPhone: null,
          deliveryAddress: null,
          totalAmount: total,
          currency: curr,
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
          currency: curr,
          salesOrder_ID: orderId,
        }),
      ]);

      return orderId;
    });

    // Delegate requests to the underlying generic service
    return super.init();
  }
};
