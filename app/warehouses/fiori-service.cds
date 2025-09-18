using {WarehouseService} from '../../srv/warehouse-service.cds';

// =-=-=-= Warehouses: List + Object page
annotate WarehouseService.Warehouses with @(UI: {
  HeaderInfo               : {
    TypeName      : '{i18n>Warehouse}',
    TypeNamePlural: '{i18n>Warehouses}',
    Title         : {Value: name},
    Description   : {Value: city}
  },

  // Search bar filters
  SelectionFields          : [
    name,
    city,
    email
  ],

  // Columns in the warehouse list
  LineItem                 : [
    {
      Value         : ID,
      Label         : '{i18n>ID}',
      @UI.Importance: #High
    },
    {
      Value         : name,
      Label         : '{i18n>Name}',
      @UI.Importance: #High
    },
    {
      Value         : address,
      Label         : '{i18n>Address}',
      @UI.Importance: #Medium
    },
    {
      Value         : city,
      Label         : '{i18n>City}',
      @UI.Importance: #Medium
    },
    {
      Value         : email,
      Label         : '{i18n>Email}',
      @UI.Importance: #Low
    },
    {
      $Type          : 'UI.DataFieldForAction',
      Action         : 'WarehouseService.createWarehouse',
      Label          : '{i18n>Add Warehouse}',
      RequiresContext: false
    }
  ],

  // Object page sections
  Facets                   : [
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Details}',
      Target: '@UI.FieldGroup#WarehouseInfo'
    },
    // If your navigation is named 'stocks', change Target to 'stocks/@UI.LineItem'
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Inventory}',
      Target: 'availabilities/@UI.LineItem'
    }
  ],

  FieldGroup #WarehouseInfo: {Data: [
    {
      Value: name,
      Label: '{i18n>Name}'
    },
    {
      Value: address,
      Label: '{i18n>Address}'
    },
    {
      Value: city,
      Label: '{i18n>City}'
    },
    {
      Value: email,
      Label: '{i18n>Email}'
    }
  ]}
});

// =-=-=-= Availabilities (inventory list on the nav)
annotate WarehouseService.Availabilities with @(UI: {LineItem: [
  {
    Value: book.title,
    Label: '{i18n>Book}'
  },
  {
    Value: warehouse.name,
    Label: '{i18n>Warehouse}'
  },
  {
    Value: quantity,
    Label: '{i18n>Quantity}'
  },
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'WarehouseService.decreaseQuantity',
    Label : '−',
    Inline: true
  },
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'WarehouseService.increaseQuantity',
    Label : '+',
    Inline: true
  }
]});
