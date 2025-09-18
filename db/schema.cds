using {
  Currency,
  managed,
  sap
} from '@sap/cds/common';

namespace sap.capire.bookshop;

entity Books : managed {
  key ID                : Integer;
      @mandatory title  : localized String(111);
      descr             : localized String(1111);
      @mandatory author : Association to Authors;
      genre             : Association to Genres;
      price             : Decimal;
      currency          : Currency;
      image             : LargeBinary @Core.MediaType: 'image/png';
      publisher         : Association to Publishers;
      reviews           : Association to many Reviews
                            on reviews.book = $self;
}

entity Publishers : managed {
  key ID              : Integer;
      @mandatory name : String(111);
      location        : String(111);
      foundedYear     : Integer;
      website         : String(255);
      books           : Association to many Books
                          on books.publisher = $self;
}

entity Reviews : managed {
  key ID     : Integer;
      text   : String(1111);
      rating : Integer;
      book   : Association to Books;
}

entity Authors : managed {
  key ID              : Integer;
      @mandatory name : String(111);
      dateOfBirth     : Date;
      dateOfDeath     : Date;
      placeOfBirth    : String;
      placeOfDeath    : String;
      books           : Association to many Books
                          on books.author = $self;
}

/** Hierarchically organized Code List for Genres */
entity Genres : sap.common.CodeList {
  key ID       : Integer;
      parent   : Association to Genres;
      children : Composition of many Genres
                   on children.parent = $self;
}

/** Inventory */
entity Warehouses : managed {
  key ID      : Integer;
      name    : String(111);
      address : String(255);
      city    : String(111);
      email   : String(111);
}

entity Inventory : managed {
  key book      : Association to Books;
  key warehouse : Association to Warehouses;
      quantity  : Integer;
}

extend Books with {
  availabilities : Association to many Inventory
                     on availabilities.book = $self;
  stock          : Integer @title: 'Total Stock' @readonly;
}

extend Warehouses with {
  stocks : Association to many Inventory
             on stocks.warehouse = $self;
}

/** Sales Orders */
entity SalesOrders : managed {
  key ID              : UUID;

      @UI.Identification: [{position: 10}]
      @UI.LineItem      : [{position: 10}]
      orderNumber     : String(20);

      @UI.Identification: [{position: 20}]
      @UI.LineItem      : [{position: 20}]
      customerName    : String(100);

      @UI.Identification: [{position: 30}]
      @UI.LineItem      : [{position: 30}]
      orderDate       : Date;

      @UI.Identification: [{position: 40}]
      @UI.LineItem      : [{position: 40}]
      totalAmount     : Decimal(15, 2);

      @UI.Identification: [{position: 50}]
      @UI.LineItem      : [{position: 50}]
      currency        : Currency;

      @UI.Identification: [{position: 60}]
      @UI.LineItem      : [{position: 60}]
      status          : String(20);
      customerEmail   : String(255);
      customerPhone   : String(20);
      deliveryAddress : String(500);
      notes           : String(1000);
      items           : Composition of many SalesOrderItems
                          on items.salesOrder = $self;
      customer        : Association to Customers;
}

entity SalesOrderItems : managed {
  key ID          : UUID;

      @UI.Identification: [{position: 10}]
      itemNumber  : Integer;

      @UI.Identification: [{position: 20}]
      productName : String(100);

      @UI.Identification: [{position: 30}]
      productCode : String(50);

      @UI.Identification: [{position: 40}]
      quantity    : Integer;

      @UI.Identification: [{position: 50}]
      unitPrice   : Decimal(15, 2);

      @UI.Identification: [{position: 60}]
      totalPrice  : Decimal(15, 2);

      @UI.Identification: [{position: 70}]
      currency    : Currency;
      salesOrder  : Association to SalesOrders;
      book        : Association to Books;
}

entity Customers : managed {
  key ID     : UUID;
      userId : String(255) @title: 'User ID';
      name   : String(100);
      email  : String(255);
}
