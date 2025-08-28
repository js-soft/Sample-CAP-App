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
      stock             : Integer;
      price             : Decimal;
      currency          : Currency;
      image             : LargeBinary @Core.MediaType: 'image/png';
      reviews           : Association to many Reviews
                            on reviews.book = $self;
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

entity SalesOrders : managed {
  key ID                : UUID;
      orderNumber       : String(20);
      orderDate         : Date;
      customerName      : String(100);
      customerEmail     : String(255);
      customerPhone     : String(20);
      deliveryAddress   : String(500);
      totalAmount       : Decimal(15,2);
      currency          : Currency;
      status            : String(20);
      notes             : String(1000);
      items             : Composition of many SalesOrderItems on items.salesOrder = $self;
}

entity SalesOrderItems : managed {
  key ID                : UUID;
      itemNumber        : Integer;
      productName       : String(100);
      productCode       : String(50);
      quantity          : Integer;
      unitPrice         : Decimal(15,2);
      totalPrice        : Decimal(15,2);
      currency          : Currency;
      salesOrder        : Association to SalesOrders;
}
