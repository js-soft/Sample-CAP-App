using {WarehouseService} from '../../srv/warehouse-service.cds';

annotate WarehouseService.Warehouses with @(UI: {
  HeaderInfo               : {
    TypeName      : '{i18n>Warehouse}',
    TypeNamePlural: '{i18n>Warehouses}',
    Title         : {Value: name},
    Description   : {Value: city}
  },

  SelectionFields          : [
    name,
    city,
    email
  ],

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

  Facets                   : [
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Details}',
      Target: '@UI.FieldGroup#WarehouseInfo'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Inventory}',
      Target: 'stocks/@UI.LineItem'
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

annotate WarehouseService.Availabilities with @(UI: {LineItem: [
  {
    Value: bookTitle,
    Label: '{i18n>Book}'
  },
  {
    Value: warehouseName,
    Label: '{i18n>Warehouse}'
  },
  {
    Value: quantity,
    Label: '{i18n>Quantity}'
  },
  {
    $Type          : 'UI.DataFieldForAction',
    Action         : 'WarehouseService.decreaseQuantity',
    Label          : '−',
    Inline         : true,
    RequiresContext: true
  },
  {
    $Type          : 'UI.DataFieldForAction',
    Action         : 'WarehouseService.increaseQuantity',
    Label          : '+',
    Inline         : true,
    RequiresContext: true
  }
]});
