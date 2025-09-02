using {sap.capire.bookshop as my} from '../db/schema';

service CatalogService {

  /** For display in details pages */
  @readonly
  entity Books       as
    projection on my.Books {
      *,
      author.name as author
    }
    excluding {
      createdBy,
      modifiedBy
    }
    actions {
      action placeOrder(quantity: Integer,
                        customerName: String,
                        customerEmail: String) returns UUID;
    };

  /** For displaying lists of Books */
  @readonly
  entity ListOfBooks as
    projection on Books
    excluding {
      descr
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
