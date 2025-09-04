using {sap.capire.bookshop as my} from '../db/schema';

service AdminService @(requires: 'admin') {
  entity Books           as projection on my.Books;
  entity Authors         as projection on my.Authors;
  entity Reviews         as projection on my.Reviews;
  entity SalesOrders     as projection on my.SalesOrders;
  entity SalesOrderItems as projection on my.SalesOrderItems;
  entity Publishers      as projection on my.Publishers
}
