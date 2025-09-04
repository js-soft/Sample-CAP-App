const cds = require('@sap/cds')

module.exports = class CatalogService extends cds.ApplicationService { init() {

  const { Books, SalesOrders, SalesOrderItems } = cds.entities("sap.capire.bookshop");
  const { ListOfBooks } = this.entities

  // Add some discount for overstocked books
  this.after('each', ListOfBooks, book => {
    if (book.stock > 111) book.title += ` -- 11% discount!`
  })

  // Reduce stock of ordered books if available stock suffices
  this.on('submitOrder', async req => {
    let { book:id, quantity } = req.data
    let book = await SELECT.one.from (Books, id, b => b.stock)

    // Validate input data
    if (!book) return req.error (404, `Book #${id} doesn't exist`)
    if (quantity < 1) return req.error (400, `quantity has to be 1 or more`)
    if (!book.stock || quantity > book.stock) return req.error (409, `${quantity} exceeds stock for book #${id}`)

    // Reduce stock in database and return updated stock value
    await UPDATE (Books, id) .with ({ stock: book.stock -= quantity })
    return book
  })

  // Emit event when an order has been submitted
  this.after('submitOrder', async (_,req) => {
    let { book, quantity } = req.data
    await this.emit('OrderedBook', { book, quantity, buyer: req.user.id })
  })

  // Warehouse & inventory
  const { Inventory } = cds.entities('sap.capire.bookshop')

  const getKeys = (req) => {
    const segs = Array.isArray(req.params) ? req.params : [ req.params || {} ]
    const last = segs[segs.length - 1] || {}
    const prev = segs.length > 1 ? segs[segs.length - 2] : {}

    const book_ID =
      last.book_ID ??
      last.book?.ID ??
      req.data?.bookId ??
      req.data?.book_ID

    const warehouse_ID =
      last.warehouse_ID ??
      last.warehouse?.ID ??
      prev.ID ??                   // parent Warehouses(1)
      req.data?.warehouseId ??
      req.data?.warehouse_ID

    return { book_ID, warehouse_ID }
  }

  this.on('increaseQuantity', 'Availabilities', async req => {
    const { book_ID, warehouse_ID } = getKeys(req)
    const by = Number(req.data?.by ?? 1) || 1

    if (book_ID == null || warehouse_ID == null) {
      return req.error(400, 'Missing keys: book_ID and warehouse_ID are required')
    }

    const row = await SELECT.one.from(Inventory).where({ book_ID, warehouse_ID })
    if (!row) {
      await INSERT.into(Inventory).entries({ book_ID, warehouse_ID, quantity: by })
    } else {
      await UPDATE(Inventory).set({ quantity: { '+=': by } }).where({ book_ID, warehouse_ID })
    }
    return SELECT.one.from(Inventory).where({ book_ID, warehouse_ID })
  })

  this.on('decreaseQuantity', 'Availabilities', async req => {
    const { book_ID, warehouse_ID } = getKeys(req)
    const by = Number(req.data?.by ?? 1) || 1

    if (book_ID == null || warehouse_ID == null) {
      return req.error(400, 'Missing keys: book_ID and warehouse_ID are required')
    }

    const row = await SELECT.one.from(Inventory).where({ book_ID, warehouse_ID })
    const curr = row?.quantity ?? 0
    const next = Math.max(0, curr - by)

    if (!row) {
      await INSERT.into(Inventory).entries({ book_ID, warehouse_ID, quantity: 0 })
      return { book_ID, warehouse_ID, quantity: 0 }
    }

    await UPDATE(Inventory).set({ quantity: next }).where({ book_ID, warehouse_ID })
    return SELECT.one.from(Inventory).where({ book_ID, warehouse_ID })
  })

  // Sales orders
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
      const { Books, Inventory, Warehouses } = cds.entities("sap.capire.bookshop");

      // Fetch book (price/currency)
      const book = await tx.read(Books).where({ ID }).columns("ID", "title", "price", "currency_code").then(r => r?.[0]);
      if (!book) return req.error(404, `Book ${ID} not found`);
      if (book.price == null) return req.error(409, `Book ${ID} has no price set`);
      const price = Number(book.price);
      if (!Number.isFinite(price)) return req.error(409, `Invalid price for Book ${ID}`);

      // Find first warehouse which has at least 1 requested book
      const invRows = await tx.read(Inventory)
        .where({ book_ID: ID })
        .columns("book_ID", "warehouse_ID", "quantity")
        .orderBy({ warehouse_ID: "asc" }); // "first" is the lowest warehouse_ID

      const firstWithStock = invRows.find(r => (r.quantity ?? 0) > 0);
      if (!firstWithStock) return req.error(409, `Book ${ID} is out of stock in all warehouses`);

      // How many do we take from the warehouse
      const take = Math.min(quantity, firstWithStock.quantity);
      const chosenWarehouseId = firstWithStock.warehouse_ID;

      // Atomisk reduksjon av inventory
      await tx.update(Inventory)
        .set({ quantity: { "-=": take } })
        .where({ book_ID: ID, warehouse_ID: chosenWarehouseId });

      // Fetch warehouse details for notice
      const wh = await tx.read(Warehouses)
        .where({ ID: chosenWarehouseId })
        .columns("ID", "name", "city")
        .then(r => r?.[0]);

      // Calculate total
      const total = Number((price * quantity).toFixed(2));
      const curr = book.currency_code || "EUR";

      // Create order
      const orderId = cds.utils.uuid();
      const itemId  = cds.utils.uuid();
      const today   = new Date().toISOString().slice(0, 10);

      await tx.run([
        INSERT.into("sap.capire.bookshop.SalesOrders").entries({
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
          notes: `Auto-created from Books.placeOrder for Book ID ${ID}. Fulfilled from warehouse ${chosenWarehouseId}${wh ? ` (${wh.name}, ${wh.city})` : ""}. Reserved ${take}/${quantity}.`
        }),
        INSERT.into("sap.capire.bookshop.SalesOrderItems").entries({
          ID: itemId,
          itemNumber: 10,
          productName: book.title,
          productCode: String(ID),
          quantity,
          unitPrice: price,
          totalPrice: total,
          currency_code: curr,
          salesOrder_ID: orderId
        })
      ]);

      // Status/info
      const msg = (take === quantity)
        ? `Order placed: ${quantity} x "${book.title}" from warehouse ${chosenWarehouseId}.`
        : `Order placed: requested ${quantity}, reserved ${take} from warehouse ${chosenWarehouseId} (partial).`;

      req.info(`${msg} Total ${total.toFixed(2)} ${curr}.`);
      return orderId;

    } catch (e) {
      console.error("placeOrder failed:", e);
      return req.error(500, e.message || "Failed to place order");
    }
  });

  // Delegate requests to the underlying generic service
  return super.init()
}}