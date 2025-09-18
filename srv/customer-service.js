const cds = require('@sap/cds');

module.exports = cds.service.impl(async function() {
  const { Customers, SalesOrders, SalesOrderItems } = this.entities;

  // Before creating a sales order, ensure customer exists and is linked to current user
  this.before('CREATE', 'SalesOrders', async (req) => {
    const userId = req.user.id;
    const userName = req.user.attr?.name || 'Unknown User';
    const userEmail = req.user.attr?.email || '';

    // Find or create customer for current user
    let customer = await SELECT.one.from(Customers).where({ user: userId });
    
    if (!customer) {
      // Auto-create customer record for new user
      const customerData = {
        user: userId,
        customerNumber: `CUST-${Date.now()}`,
        isActive: true
      };
      
      const result = await INSERT.into(Customers).entries(customerData);
      customer = { ID: result.ID || result, ...customerData };
    }

    // Link the order to the customer
    req.data.customer_ID = customer.ID;
    req.data.customerName = userName;
    req.data.customerEmail = userEmail;
    
    // Set order date if not provided
    if (!req.data.orderDate) {
      req.data.orderDate = new Date().toISOString().split('T')[0];
    }
  });

  // Before reading orders, filter by current user
  this.before('READ', 'SalesOrders', async (req) => {
    const userId = req.user.id;
    
    // Add filter to only show orders for current user's customer
    if (!req.user.is('admin')) {
      req.query.where(`customer.user = '${userId}'`);
    }
  });

  // Custom action to get current user's customer profile
  this.on('getCurrentCustomer', async (req) => {
    const userId = req.user.id;
    
    let customer = await SELECT.one.from(Customers).where({ user: userId });
    
    if (!customer) {
      // Create customer if doesn't exist
      const customerData = {
        user: userId,
        customerNumber: `CUST-${Date.now()}`,
        isActive: true
      };
      
      await INSERT.into(Customers).entries(customerData);
      customer = customerData;
    }

    // Enrich with SAP user data
    return {
      ...customer,
      // Add SAP user information
      sapUser: {
        id: req.user.id,
        name: req.user.attr?.name,
        email: req.user.attr?.email,
        roles: req.user._roles || []
      }
    };
  });

  // Custom action to check user permissions
  this.on('checkUserPermissions', async (req) => {
    return {
      isAdmin: req.user.is('admin'),
      isCustomer: req.user.is('authenticated-user'),
      isWarehouseManager: req.user.is('warehouse-manager'),
      userId: req.user.id,
      userName: req.user.attr?.name
    };
  });
});
