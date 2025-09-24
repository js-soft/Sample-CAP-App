using {sap.capire.bookshop as my} from '../db/schema';

service CatalogService {

  @readonly
  entity Warehouses     as
    projection on my.Warehouses {
      ID,
      name
    };

  @readonly
  entity Availabilities as
    projection on my.Inventory {
      book,
      warehouse,
      quantity
    };

  @readonly
  entity ListOfBooks    as
    projection on Books
    excluding {
      descr
    };

  @readonly
  entity Books          as
    projection on my.Books {
      *,
      author.name as author,
      availabilities
    }
    excluding {
      createdBy,
      modifiedBy
    }
    actions {
      action placeOrder(quantity: Integer @title: '{i18n>Quantity}' ) returns UUID;
    };

  @readonly
  entity Publishers     as
    projection on my.Publishers {
      *,
      books
    };

  @requires: 'authenticated-user'
  action submitOrder(book: Books:ID @mandatory,
                     quantity: Integer @mandatory
  ) returns {
    stock : Integer
  };

  event OrderedBook : {
    book     : Books:ID;
    quantity : Integer;
    buyer    : String;
  };
}

annotate CatalogService.Books with @(UI: {
  Facets           : [
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>OrderDetails}',
      Target: '@UI.FieldGroup#Order'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Inventory}',
      Target: 'availabilities/@UI.LineItem'
    }
  ],
  FieldGroup #Order: {Data: [
    {
      Value: orderDate,
      ![unknown]
    }, // harmless if not present; FE ignores
    {
      Value: totalAmount,
      ![unknown]
    },
    {
      Value: currency_code,
      ![unknown]
    },
    {
      Value: status,
      ![unknown]
    }
  ]}
});

/** Define how to render rows of Availabilities (Book × Warehouse × Quantity) */
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
  }
]});
