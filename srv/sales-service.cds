using { sap.capire.bookshop as my } from '../db/schema';

service SalesService {
    entity SalesOrders as projection on my.SalesOrders;
    entity SalesOrderItems as projection on my.SalesOrderItems;
    entity Books as projection on my.Books;
}
