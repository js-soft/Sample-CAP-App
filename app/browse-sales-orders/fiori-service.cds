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
        Label : '{i18n>CustomerInfo}',
        Target: '@UI.FieldGroup#Customer'
    }, {
        $Type : 'UI.ReferenceFacet',
        Label : '{i18n>OrderDetails}',
        Target: '@UI.FieldGroup#Order'
    }],
    Facets: [{
        $Type : 'UI.ReferenceFacet',
        Label : '{i18n>Items}',
        Target: '@UI.FieldGroup#Items'
    }],
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
    ]},
    FieldGroup #Items: {Data : []}
});

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
});

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
});
