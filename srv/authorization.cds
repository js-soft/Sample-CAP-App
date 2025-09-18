using {CatalogService} from './cat-service';
using {SalesService} from './sales-service';

/* Service-level: users can READ data from CatalogService */
annotate CatalogService with @restrict: [{
  grant: 'READ',
  to   : [
    'user',
    'admin'
  ]
}];

/* Entity-level: (optional to keep) */
annotate CatalogService.Books with @restrict: [{
  grant  : 'EXECUTE',
  to     : [
    'user',
    'admin'
  ],
  actions: ['placeOrder']
}];

/* 🔒 Action-level: explicitly allow EXECUTE on the bound action */
annotate CatalogService.Books with actions {
  placeOrder @restrict: [{
    grant: 'EXECUTE',
    to   : [
      'user',
      'admin'
    ]
  }];
};

/* Admin-only SalesService */
annotate SalesService with @restrict: [{
  grant: [
    'READ',
    'WRITE',
    'EXECUTE'
  ],
  to   : ['admin']
}];

/* Admin-only Warehouses */
annotate CatalogService.Warehouses with @restrict: [{
  grant: [
    'READ',
    'WRITE',
    'EXECUTE'
  ],
  to   : ['admin']
}];

// // Authorization annotations for entities
annotate Books with @restrict: [
  { grant: 'READ', to: 'authenticated-user' },
  { grant: ['CREATE', 'UPDATE', 'DELETE'], to: 'admin' }
];

annotate Authors with @restrict: [
  { grant: 'READ', to: 'authenticated-user' },
  { grant: ['CREATE', 'UPDATE', 'DELETE'], to: 'admin' }
];

annotate Publishers with @restrict: [
  { grant: 'READ', to: 'authenticated-user' },
  { grant: ['CREATE', 'UPDATE', 'DELETE'], to: 'admin' }
];

annotate Genres with @restrict: [
  { grant: 'READ', to: 'authenticated-user' },
  { grant: ['CREATE', 'UPDATE', 'DELETE'], to: 'admin' }
];

annotate SalesOrders with @restrict: [
  { grant: 'READ', where: 'customer.user = $user' },
  { grant: ['CREATE', 'UPDATE'], where: 'customer.user = $user' },
  { grant: '*', to: 'admin' }
];

annotate Customers with @restrict: [
  { grant: 'READ', where: 'user = $user' },
  { grant: '*', to: 'admin' }
];

annotate Warehouses with @restrict: [
  { grant: 'READ', to: 'authenticated-user' },
  { grant: '*', to: 'admin' }
];

annotate Inventory with @restrict: [
  { grant: 'READ', to: 'authenticated-user' },
  { grant: '*', to: 'admin' }
];
