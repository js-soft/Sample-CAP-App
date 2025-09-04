const cds = require("@sap/cds");

module.exports = class SalesService extends cds.ApplicationService {
  init() {
    const { SalesOrders, SalesOrderItems, Books } = this.entities;

    // Auto-generate ID and set default values for new sales orders
    this.before("CREATE", SalesOrders, async (req) => {
      const { data } = req;
      if (!data.ID) data.ID = cds.utils.uuid();
      if (!data.orderDate) data.orderDate = new Date().toISOString().slice(0, 10);
      if (!data.status) data.status = "NEW";
      if (!data.orderNumber) {
        data.orderNumber = `SO-${Math.floor(Math.random() * 90000 + 10000)}`;
      }
    });

    // Auto-generate ID and calculate totals for new sales order items
    this.before("CREATE", SalesOrderItems, async (req) => {
      const { data } = req;
      if (!data.ID) data.ID = cds.utils.uuid();
      
      // Calculate total price
      if (data.quantity && data.unitPrice) {
        data.totalPrice = Number((data.quantity * data.unitPrice).toFixed(2));
      }
    });

    // Update totals when sales order items are modified
    this.before("UPDATE", SalesOrderItems, async (req) => {
      const { data } = req;
      
      // Recalculate total price if quantity or unit price changed
      if (data.quantity && data.unitPrice) {
        data.totalPrice = Number((data.quantity * data.unitPrice).toFixed(2));
      }
    });

    // Update sales order total when items change
    this.after("CREATE", SalesOrderItems, async (item) => {
      await this.updateSalesOrderTotal(item.salesOrder_ID);
    });

    this.after("UPDATE", SalesOrderItems, async (item) => {
      await this.updateSalesOrderTotal(item.salesOrder_ID);
    });

    this.after("DELETE", SalesOrderItems, async (item) => {
      await this.updateSalesOrderTotal(item.salesOrder_ID);
    });

    // Delegate requests to the underlying generic service
    return super.init();
  }

  // Helper method to update sales order total
  async updateSalesOrderTotal(salesOrderId) {
    const tx = cds.tx();
    const items = await tx.read(SalesOrderItems).where({ salesOrder_ID: salesOrderId });
    
    if (items.length > 0) {
      const totalAmount = items.reduce((sum, item) => sum + (item.totalPrice || 0), 0);
      await tx.update(SalesOrders).where({ ID: salesOrderId }).with({ totalAmount });
    }
  }
};
