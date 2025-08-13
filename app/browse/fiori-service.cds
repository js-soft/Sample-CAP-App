using { CatalogService } from '../../srv/cat-service.cds';

////////////////////////////////////////////////////////////////////////////
//
//	Books Object Page
//
annotate CatalogService.Books with @(UI : {
    HeaderInfo: {
        TypeName      : '{i18n>Book}',
        TypeNamePlural: '{i18n>Books}',
        Title         : {Value: title},
        Description   : {Value : author}
    },
    HeaderFacets: [{
        $Type : 'UI.ReferenceFacet',
        Label : '{i18n>Description}',
        Target: '@UI.FieldGroup#Descr'
    }, ],
    Facets: [{ 
        $Type: 'UI.ReferenceFacet', 
        Label: '{i18n>Description}', 
        Target: '@UI.FieldGroup#Descr' 
    },
    { 
        $Type: 'UI.ReferenceFacet', 
        Label: '{i18n>Details}',     
        Target: '@UI.FieldGroup#Price' 
    },
    { 
        $Type: 'UI.ReferenceFacet', 
        Label: '{i18n>Publication}', 
        Target: '@UI.FieldGroup#Publication' 
    },

    // hint: new facet -> navigates to the reviews entity of this book
    { 
        $Type: 'UI.ReferenceFacet', 
        Label: '{i18n>Reviews}',     
        Target: 'reviews/@UI.LineItem' 
    }, ],
    FieldGroup #Descr: {Data : [{Value : descr}, ]},
    FieldGroup #Price: {Data : [
        {Value: price},
        {
            Value: currency.symbol,
            Label: '{i18n>Currency}'
        },
    ]},

  // hint: shows pages & isbn on the object page
  FieldGroup #Publication: { Data: [
    { Value: pages, Label: '{i18n>Pages}' },
    { Value: isbn,  Label: '{i18n>ISBN}'  }
  ]}
});

////////////////////////////////////////////////////////////////////////////
//
//	Books List Page
//
annotate CatalogService.Books with @(UI : {
    SelectionFields: [
        ID,
        price,
        currency_code,
        // hint: adds isbn search field
        isbn
    ],
    LineItem: [
        { 
            Value: ID,         
            Label: '{i18n>Title}' 
        },
        { 
            Value: author,
            Label: '{i18n>Author}' 
        },
        { Value: genre.name },
        { Value: price },
        // hint: adds Pages
        { Value: pages,      Label: '{i18n>Pages}' },
        // hint: adds ISBN
        { Value: isbn,       Label: '{i18n>ISBN}' }
    ]
});

// hint: adding this removes the `Path does not exist.CDS (annotations)` error
annotate CatalogService.Reviews with @(UI: {
  LineItem: [
    { Value: rating,    Label: '{i18n>Rating}' },
    { Value: text,      Label: '{i18n>Review}' },
    { Value: createdAt, Label: '{i18n>Date}' }
  ]
});
