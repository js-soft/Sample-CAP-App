using {sap.capire.bookshop as my} from '../db/schema';

service SalesService {
    // Main sales orders entity with proper projections
    entity SalesOrders     as
        projection on my.SalesOrders {
            *,
            items : redirected to SalesOrderItems,
            customer : redirected to Customers
        };

    // Sales order items with associations
    entity SalesOrderItems as
        projection on my.SalesOrderItems {
            *
        };

    // Books entity for value lists and associations
    entity Books           as
        projection on my.Books {
            *,
            author.name as author_name
        };

    // Customers entity for associations
    entity Customers       as projection on my.Customers {
        *
    };
}
