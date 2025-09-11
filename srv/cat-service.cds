using {sap.capire.bookshop as my} from '../db/schema';

service CatalogService {

  /** For displaying lists of Books */
  @readonly
  entity ListOfBooks    as
    projection on Books
    excluding {
      descr
    };

  /** For display in details pages */
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

  /** Expose Publishers entity */
  @readonly
  entity Publishers     as
    projection on my.Publishers {
      *,
      books // include association for navigation
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
    buyer    : String
  };

  /** List of availabilities per warehouse */
  @readonly
  entity Availabilities as
    projection on my.Inventory {
      book,
      warehouse,
      quantity
    }
    actions {
      action increaseQuantity(by: Integer default 1) returns CatalogService.Availabilities;
      action decreaseQuantity(by: Integer default 1) returns CatalogService.Availabilities;
    };

  @readonly
  entity Warehouses     as
    projection on my.Warehouses {
      *,
      stocks
    };
}
