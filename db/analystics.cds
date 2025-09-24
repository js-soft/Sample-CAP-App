using {sap.capire.bookshop as my} from './schema';

namespace analytics;

/** Orders & quantity per Genre */
@readonly
entity OrdersByGenre as
  select from my.SalesOrderItems as i {
    key i.book.genre.name as genre,
        sum(i.quantity)   as quantity : Integer,
        sum(i.totalPrice) as revenue  : Decimal(15, 2)
  }
  group by
    i.book.genre.name;

/** Revenue per day */
@readonly
entity RevenueByDay  as
  select from my.SalesOrders {
    key orderDate,
        sum(totalAmount) as revenue : Decimal(15, 2)
  }
  group by
    orderDate;

/** Top books by quantity sold */
@readonly
entity TopBooks      as
  select from my.SalesOrderItems as i {
    key i.book.ID         as bookID   : Integer, // stable key
        i.book.title      as title, // non-key, may be localized
        sum(i.quantity)   as quantity : Integer,
        sum(i.totalPrice) as revenue  : Decimal(15, 2)
  }
  group by
    i.book.ID,
    i.book.title;

/** Top customers by revenue */
@readonly
entity TopCustomers  as
  select from my.SalesOrders as so {
    key so.customer.ID      as customerID : UUID, // stable key
        so.customer.name    as customer, // non-key
        sum(so.totalAmount) as revenue    : Decimal(15, 2)
  }
  group by
    so.customer.ID,
    so.customer.name;
