using {sap.capire.bookshop as my} from '../db/schema';

service SalesService {
    // Main sales orders entity with proper projections
    entity SalesOrders     as
        projection on my.SalesOrders {
            *,
            ID,
            orderNumber,
            orderDate,
            totalAmount,
            status,
            customer,
            // keep the association
            customer.name  as customerName, // <-- add this
            customer.email as customerEmail, // <-- add this
            items : redirected to SalesOrderItems
        };

    // Sales order items with associations
    entity SalesOrderItems as
        projection on my.SalesOrderItems {
            *,
            salesOrder.customer.name as customerName,
            salesOrder.customer.email as customerEmail
        };

    // Books entity for value lists and associations
    entity Books           as
        projection on my.Books {
            *,
            author.name as author_name
        };
}
