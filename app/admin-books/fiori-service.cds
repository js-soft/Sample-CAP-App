using {AdminService} from '../../srv/admin-service.cds';
using {sap.capire.bookshop} from '../../db/schema';

////////////////////////////////////////////////////////////////////////////
//
//	Books Object Page
//

annotate AdminService.Books with @(UI: {
  HeaderInfo         : {
    TypeName      : '{i18n>Book}',
    TypeNamePlural: '{i18n>Books}',
    Title         : {Value: title},
    Description   : {Value: author.name}
  },
  Facets             : [
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>General}',
      Target: '@UI.FieldGroup#General'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Translations}',
      Target: 'texts/@UI.LineItem'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Reviews}',
      Target: 'reviews/@UI.LineItem'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Details}',
      Target: '@UI.FieldGroup#Details'
    },
    {
      $Type : 'UI.ReferenceFacet',
      Label : '{i18n>Admin}',
      Target: '@UI.FieldGroup#Admin'
    },
    // hint: add Publication section to Manage Books app's page view
    { 
      $Type : 'UI.ReferenceFacet', 
      Label : '{i18n>Publication}',
      Target: '@UI.FieldGroup#Publication' 
    }
  ],
  FieldGroup #General: {Data: [
    {Value: title},
    {Value: author_ID},
    {Value: genre_ID},
    {Value: descr},
  ]},
  FieldGroup #Details: {Data: [
    {Value: stock},
    {Value: price},
    {
      Value: currency_code,
      Label: '{i18n>Currency}'
    },
  ]},
  FieldGroup #Admin  : {Data: [
    {Value: createdBy},
    {Value: createdAt},
    {Value: modifiedBy},
    {Value: modifiedAt}
  ]},
  // hint: adds Pages and ISBN display to the Publication section
  FieldGroup #Publication: {Data: [ 
    {Value: pages, Label:'{i18n>Pages}'}, 
    {Value: isbn, Label:'{i18n>ISBN}'} 
  ]}
});

// hint: define data that is displayed in the list display's extended row mode
annotate AdminService.Books with @(UI: {
  SelectionFields: [ title, author_ID, isbn ],
  LineItem: [
    { Value:title,           Label:'{i18n>Title}'    },
    { Value:author.name,     Label:'{i18n>Author}'   },
    { Value:genre.name,      Label:'{i18n>Genre}'    },
    { Value:pages,           Label:'{i18n>Pages}'    }, // hint: display Pages
    { Value:isbn,            Label:'{i18n>ISBN}'     }, // hint: display ISBN
    { Value:price,           Label:'{i18n>Price}'    },
    { Value:currency.symbol, Label:'{i18n>Currency}' },
    { Value:stock,           Label:'{i18n>Stock}'    }
  ]
});

////////////////////////////////////////////////////////////
//
//  Draft for Localized Data
//

annotate sap.capire.bookshop.Books with @fiori.draft.enabled;
annotate AdminService.Books with @odata.draft.enabled;

annotate AdminService.Books.texts with @(UI: {
  Identification : [{Value: title}],
  SelectionFields: [
    locale,
    title
  ],
  LineItem       : [
    {
      Value: locale,
      Label: 'Locale'
    },
    {
      Value: title,
      Label: 'Title'
    },
    {
      Value: descr,
      Label: 'Description'
    },
  ]
});

annotate AdminService.Books.texts with {
  ID       @UI.Hidden;
  ID_texts @UI.Hidden;
};

// Add Value Help for Locales
annotate AdminService.Books.texts {
  locale @(
    ValueList.entity: 'Languages',
    Common.ValueListWithFixedValues, //show as drop down, not a dialog
  )
};

// In addition we need to expose Languages through AdminService as a target for ValueList
using {sap} from '@sap/cds/common';

extend service AdminService {
  @readonly
  entity Languages as projection on sap.common.Languages;
}

// Workaround for Fiori popup for asking user to enter a new UUID on Create
annotate AdminService.Books with {
  ID @Core.Computed;
}

// Show Genre as drop down, not a dialog
annotate AdminService.Books with {
  genre @Common.ValueListWithFixedValues;
}

// hint: this was needed to make the path not found at 'reviews/@UI.LineItem' go away
annotate AdminService.Reviews with @(UI: {
  LineItem: [
    { Value: text,   Label: '{i18n>ReviewText}' },
    { Value: rating, Label: '{i18n>Rating}' }
  ]
});
