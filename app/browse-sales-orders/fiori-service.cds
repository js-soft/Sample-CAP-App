using { SalesService } from '../../srv/sales-service.cds';

////////////////////////////////////////////////////////////////////////////
//
//	SalesOrders Object Page
//
annotate SalesService.SalesOrders with @(UI : {
    HeaderInfo: {
        TypeName      : '{i18n>SalesOrder}',
        TypeNamePlural: '{i18n>SalesOrders}',
        Title         : {Value: orderNumber},
        Description   : {Value : customerName}
    },
    HeaderFacets: [{
        $Type : 'UI.ReferenceFacet',
        Label : '{i18n>OrderSummary}',
        Target: '@UI.FieldGroup#Summary'
    }, {
        $Type : 'UI.ReferenceFacet',
        Label : '{i18n>CustomerInfo}',
        Target: '@UI.FieldGroup#Customer'
    }],
    Facets: [{
        $Type : 'UI.ReferenceFacet',
        Label : '{i18n>OrderDetails}',
        Target: '@UI.FieldGroup#Order'
    }, {
        $Type : 'UI.ReferenceFacet',
        Label : '{i18n>Items}',
        Target: 'items/@UI.LineItem'
    }],
    FieldGroup #Summary: {Data : [
        {Value: orderNumber},
        {Value: orderDate},
        {Value: status},
        {Value: totalAmount},
        {Value: currency.symbol}
    ]},
    FieldGroup #Customer: {Data : [
        {Value: customerName},
        {Value: customerEmail},
        {Value: customerPhone},
        {Value: deliveryAddress}
    ]},
    FieldGroup #Order: {Data : [
        {Value: orderDate},
        {Value: totalAmount},
        {Value: currency.symbol},
        {Value: status},
        {Value: notes}
    ]}
}) {
    items @UI.LineItem: [
        {
            Value: itemNumber,
            Label: '{i18n>ItemNumber}'
        },
        {
            Value: book.title,
            Label: '{i18n>Book}'
        },
        {
            Value: productName,
            Label: '{i18n>ProductName}'
        },
        {
            Value: productCode,
            Label: '{i18n>ProductCode}'
        },
        {
            Value: quantity,
            Label: '{i18n>Quantity}'
        },
        {
            Value: unitPrice,
            Label: '{i18n>UnitPrice}'
        },
        {
            Value: totalPrice,
            Label: '{i18n>TotalPrice}'
        },
        {
            Value: currency.symbol,
            Label: '{i18n>Currency}'
        }
    ];
};

////////////////////////////////////////////////////////////////////////////
//
//	SalesOrders List Page
//
annotate SalesService.SalesOrders with @(UI : {
    SelectionFields: [
        orderNumber,
        customerName,
        status,
        orderDate
    ],
    LineItem: [
        {
            Value: orderNumber,
            Label: '{i18n>OrderNumber}'
        },
        {
            Value: customerName,
            Label: '{i18n>CustomerName}'
        },
        {
            Value: orderDate,
            Label: '{i18n>OrderDate}'
        },
        {
            Value: totalAmount,
            Label: '{i18n>TotalAmount}'
        },
        {
            Value: currency.symbol,
            Label: '{i18n>Currency}'
        },
        {
            Value: status,
            Label: '{i18n>Status}'
        }
    ]
}) {
    ID @UI.Hidden;
};

////////////////////////////////////////////////////////////////////////////
//
//	SalesOrderItems Table
//
annotate SalesService.SalesOrderItems with @(UI : {
    LineItem: [
        {
            Value: itemNumber,
            Label: '{i18n>ItemNumber}'
        },
        {
            Value: book.title,
            Label: '{i18n>Book}'
        },
        {
            Value: productName,
            Label: '{i18n>ProductName}'
        },
        {
            Value: productCode,
            Label: '{i18n>ProductCode}'
        },
        {
            Value: quantity,
            Label: '{i18n>Quantity}'
        },
        {
            Value: unitPrice,
            Label: '{i18n>UnitPrice}'
        },
        {
            Value: totalPrice,
            Label: '{i18n>TotalPrice}'
        },
        {
            Value: currency.symbol,
            Label: '{i18n>Currency}'
        }
    ]
}) {
    book @ValueList.entity: 'Books';
};

////////////////////////////////////////////////////////////////////////////
//
//	Books Entity for Value List
//
annotate SalesService.Books with @(UI : {
    SelectionFields: [
        title,
        author.name,
        genre.name,
        price
    ],
    LineItem: [
        {
            Value: ID,
            Label: '{i18n>ID}'
        },
        {
            Value: title,
            Label: '{i18n>Title}'
        },
        {
            Value: author.name,
            Label: '{i18n>Author}'
        },
        {
            Value: genre.name,
            Label: '{i18n>Genre}'
        },
        {
            Value: price,
            Label: '{i18n>Price}'
        },
        {
            Value: currency.symbol,
            Label: '{i18n>Currency}'
        },
        {
            Value: stock,
            Label: '{i18n>Stock}'
        }
    ]
}) {
    ID @Common: {
        SemanticObject: 'Books',
        Text: title,
        TextArrangement: #TextOnly
    };
    title @title: '{i18n>Title}';
    author @title: '{i18n>Author}';
    genre @title: '{i18n>Genre}';
    price @title: '{i18n>Price}';
    currency @title: '{i18n>Currency}';
    stock @title: '{i18n>Stock}';
};
