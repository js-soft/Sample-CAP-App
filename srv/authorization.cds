using {CatalogService} from './cat-service';
using {SalesService} from './sales-service';
using {UserService} from './user-service';
using {WarehouseService} from './warehouse-service';

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


/* Admin-only UserService */
annotate UserService with @restrict: [{
  grant: [
    'READ',
    'WRITE',
    'EXECUTE'
  ],
  to   : ['admin']
}];

/* UserProfiles - Read-only for authenticated users */
annotate UserService.UserProfiles with @restrict: [{
  grant: 'READ',
  to   : [
    'user',
    'admin'
  ]
}];

/* Admin-only WarehouseService */
annotate WarehouseService with @restrict: [{
  grant: [
    'READ',
    'WRITE',
    'EXECUTE'
  ],
  to   : ['admin']
}];
