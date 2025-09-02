const cds = require('@sap/cds')
const { SELECT } = cds.ql

module.exports = class SalesService extends cds.ApplicationService { init() {

  const { SalesOrders, SalesOrderItems } = this.entities

  this.on('CREATE', SalesOrders, async (req) => {
    const { data } = req
    data.ID = cds.utils.uuid()
    data.orderDate = new Date()
    data.status = 'New'
    return data
  })

  this.on('CREATE', SalesOrderItems, async (req) => {
    const { data } = req
    data.ID = cds.utils.uuid()
    data.totalPrice = data.quantity * data.unitPrice

    if (data.book_ID) {
      const book = await SELECT.one.from('Books').where({ ID: data.book_ID })
      if (book) {
        data.productName = book.title
        data.productCode = book.ID.toString()
        data.unitPrice = book.price
        data.currency = book.currency
        data.totalPrice = data.quantity * book.price
      }
    }

    return data
  })

  this.on('UPDATE', SalesOrderItems, async (req) => {
    const { data } = req

    if (data.book_ID) {
      const book = await SELECT.one.from('Books').where({ ID: data.book_ID })
      if (book) {
        data.productName = book.title
        data.productCode = book.ID.toString()
        data.unitPrice = book.price
        data.currency = book.currency
      }
    }

    if (data.quantity && data.unitPrice) {
      data.totalPrice = data.quantity * data.unitPrice
    }
    return data
  })

  return super.init()
}}
