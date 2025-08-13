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

      pages  : Integer @assert.range: [(0),_]; // hint: adds validation, must be > 0
      isbn   : String(20) @assert.format: '^(?=(?:\D*\d){10}(?:(?:\D*\d){3})?$)[\d-]+$'; // hint: https://stackoverflow.com/questions/41271613/use-regex-to-verify-an-isbn-number
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
