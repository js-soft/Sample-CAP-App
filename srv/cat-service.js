const cds = require('@sap/cds')

module.exports = class CatalogService extends cds.ApplicationService { init() {

  const { Books } = cds.entities('sap.capire.bookshop')
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

  // Delegate requests to the underlying generic service
  return super.init()
}}
