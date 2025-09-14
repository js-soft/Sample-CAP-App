using {sap.capire.bookshop as my} from '../db/schema';

service AdminService @(requires: 'admin') {
  entity Books           as projection on my.Books;
  entity Authors         as projection on my.Authors;
  entity Reviews         as projection on my.Reviews;
  entity SalesOrders     as projection on my.SalesOrders;
  entity SalesOrderItems as projection on my.SalesOrderItems;
  entity Publishers      as projection on my.Publishers;
  entity Users           as projection on my.Users;
  entity Customers       as projection on my.Customers;
  entity Warehouses      as projection on my.Warehouses;
  entity Inventory       as projection on my.Inventory
}
