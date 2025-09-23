using {analytics as an} from '../db/analystics';

service AnalyticsService {
  @readonly
  entity OrdersByGenre as projection on an.OrdersByGenre;

  @readonly
  entity RevenueByDay  as projection on an.RevenueByDay;

  @readonly
  entity TopBooks      as projection on an.TopBooks;

  @readonly
  entity TopCustomers  as projection on an.TopCustomers;
}
