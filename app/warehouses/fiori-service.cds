using {CatalogService} from '../../srv/cat-service.cds';

// =-=-=-= warehouses list page
annotate CatalogService.Warehouses with @(UI: {
  HeaderInfo     : {
    TypeName      : '{i18n>Warehouse}',
    TypeNamePlural: '{i18n>Warehouses}',
    Title         : {Value: name},
    Description   : {Value: city}
  },

  // search field filters
  SelectionFields: [
    name,
    city,
    email
  ],

  // columns in warehous list
  LineItem       : [
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
    }
  ]
});

// =-=-=-= individual warehouse object page
annotate CatalogService.Warehouses with @(UI: {
  // page sections
  Facets                   : [
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Details}',
      Target: '@UI.FieldGroup#WarehouseInfo'
    },
    // Pek til den ukvalifiserte LineItem-annotasjonen på navigasjonen:
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

// (valgfritt) – fint å ha, men ikke nødvendig når du peker via navigasjonen:
annotate CatalogService.Availabilities with @(UI: {LineItem: [
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
    Action: 'CatalogService.decreaseQuantity',
    Label : '−',
    Inline: true
  },
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'CatalogService.increaseQuantity',
    Label : '+',
    Inline: true
  }
]});
