using { sap.capire.bookshop as my } from '../db/schema';

service SalesService {
    // Main sales orders entity with proper projections
    entity SalesOrders as projection on my.SalesOrders {
        *  // items is already included from the schema
    };

    // Sales order items with associations
    entity SalesOrderItems as projection on my.SalesOrderItems {
        *  // salesOrder is already included from the schema
    };

    // Books entity for value lists and associations
    entity Books as projection on my.Books {
        *,
        author.name as author_name
    };
}
