using {sap.capire.bookshop as my} from '../db/schema';

service CatalogService {

  /** For displaying lists of Books */
  @readonly
  entity ListOfBooks as
    projection on Books
    excluding {
      descr
    };

  /** For display in details pages */
  @readonly
  entity Books       as
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
  entity Publishers  as
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
}
