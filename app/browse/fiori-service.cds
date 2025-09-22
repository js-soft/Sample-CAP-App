using {CatalogService} from '../../srv/cat-service.cds';

////////////////////////////////////////////////////////////////////////////
//
//	Books Object Page
//
annotate CatalogService.Books with @(UI: {
    HeaderInfo       : {
        TypeName      : '{i18n>Book}',
        TypeNamePlural: '{i18n>Books}',
        Title         : {Value: title},
        Description   : {Value: author},
        Publisher     : {Value: publisher}
    },
    HeaderFacets     : [{
        $Type : 'UI.ReferenceFacet',
        Label : '{i18n>Description}',
        Target: '@UI.FieldGroup#Descr'
    }, ],
    Facets           : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>Details}',
            Target: '@UI.FieldGroup#Price'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>InventoryByWarehouse}',
            Target: 'availabilities/@UI.LineItem'
        }
    ],
    FieldGroup #Descr: {Data: [{Value: descr}, ]},
    FieldGroup #Price: {Data: [
        {Value: price},
        {
            Value: currency.symbol,
            Label: '{i18n>Currency}'
        },
    ]},

    Identification   : [
        {Value: title},
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'CatalogService.placeOrder',
            Label : '{i18n>PlaceOrder}'
        },
        {
            // Intent Based Navigation to Sales Orders from Object Page
            $Type : 'UI.DataFieldForIntentBasedNavigation',
            Label : '{i18n>ViewSalesOrders}',
            SemanticObject : 'SalesOrders',
            Action : 'display',
            RequiresContext : false,
            IconUrl : 'sap-icon://sales-order'
        }
    ]
});

////////////////////////////////////////////////////////////////////////////
//
//	Books List Page
//
annotate CatalogService.Books with @(UI: {
    SelectionFields: [
        ID,
        price,
        currency_code,
        publisher
    ],
    LineItem       : [
        {
            Value: ID,
            Label: '{i18n>Title}'
        },
        {
            Value: author,
            Label: '{i18n>Author}'
        },
        {
            Value: publisher.name,
            Label: '{i18n>Publisher}'
        },
        {Value: genre.name},
        {Value: price},
        {Value: currency.symbol},
        {
            // Intent Based Navigation to Sales Orders
            $Type : 'UI.DataFieldForIntentBasedNavigation',
            Label : '{i18n>ViewSalesOrders}',
            SemanticObject : 'SalesOrders',
            Action : 'display',
            RequiresContext : false,
            Inline : true,
            IconUrl : 'sap-icon://sales-order'
        }
    ]
});
