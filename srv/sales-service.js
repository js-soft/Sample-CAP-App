const cds = require('@sap/cds')

module.exports = cds.service.impl(async function () {
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
        return data
    })

    this.on('UPDATE', SalesOrderItems, async (req) => {
        const { data } = req
        if (data.quantity && data.unitPrice) {
            data.totalPrice = data.quantity * data.unitPrice
        }
        return data
    })
})
