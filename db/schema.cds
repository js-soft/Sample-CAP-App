using {
  Currency,
  managed,
  sap
} from '@sap/cds/common';

namespace sap.capire.bookshop;

entity BookAuthors {
  key book   : Association to Books;
  key author : Association to Authors;
}

entity Books : managed {
  key ID                : Integer;
      @mandatory title  : localized String(111);
      descr             : localized String(1111);
      genre             : Association to Genres;
      stock             : Integer;
      price             : Decimal;
      currency          : Currency;
      image             : LargeBinary @Core.MediaType: 'image/png';
      reviews           : Association to many Reviews
                            on reviews.book = $self;
      authors           : Association to many BookAuthors
                            on authors.book = $self;
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
      books           : Association to many BookAuthors on books.author = $self;
}

/** Hierarchically organized Code List for Genres */
entity Genres : sap.common.CodeList {
  key ID       : Integer;
      parent   : Association to Genres;
      children : Composition of many Genres
                   on children.parent = $self;
}
