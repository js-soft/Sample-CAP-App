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
      @UI.Identification: [{ position: 10 }]
      orderNumber       : String(20);
      @UI.Identification: [{ position: 20 }]
      customerName      : String(100);
      @UI.Identification: [{ position: 30 }]
      orderDate         : Date;
      @UI.Identification: [{ position: 40 }]
      totalAmount       : Decimal(15,2);
      @UI.Identification: [{ position: 50 }]
      currency          : Currency;
      @UI.Identification: [{ position: 60 }]
      status            : String(20);
      customerEmail     : String(255);
      customerPhone     : String(20);
      deliveryAddress   : String(500);
      notes             : String(1000);
      items             : Composition of many SalesOrderItems on items.salesOrder = $self;
}

entity SalesOrderItems : managed {
  key ID                : UUID;
      @UI.Identification: [{ position: 10 }]
      itemNumber        : Integer;
      @UI.Identification: [{ position: 20 }]
      productName       : String(100);
      @UI.Identification: [{ position: 30 }]
      productCode       : String(50);
      @UI.Identification: [{ position: 40 }]
      quantity          : Integer;
      @UI.Identification: [{ position: 50 }]
      unitPrice         : Decimal(15,2);
      @UI.Identification: [{ position: 60 }]
      totalPrice        : Decimal(15,2);
      @UI.Identification: [{ position: 70 }]
      currency          : Currency;
      salesOrder        : Association to SalesOrders;
      book              : Association to Books;
}
