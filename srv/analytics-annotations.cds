using {AnalyticsService as An} from './analytics-service';

annotate An.OrdersByGenre with @(UI: {Chart #ByGenre: {
  Title              : 'Orders by Genre',
  ChartType          : #Bar,
  Dimensions         : ['genre'],
  Measures           : ['quantity'],
  DimensionAttributes: [{
    Dimension: 'genre',
    Role     : #Category
  }],
  MeasureAttributes  : [{
    Measure: 'quantity',
    Role   : #Axis1
  }]
}});

annotate An.RevenueByDay with @(UI: {Chart #RevenueDaily: {
  Title              : 'Revenue by Day',
  ChartType          : #Line,
  Dimensions         : ['orderDate'],
  Measures           : ['revenue'],
  DimensionAttributes: [{
    Dimension: 'orderDate',
    Role     : #Category
  }],
  MeasureAttributes  : [{
    Measure: 'revenue',
    Role   : #Axis1
  }]
}});

annotate An.TopBooks with @(UI: {Chart #TopBooks: {
  Title              : 'Top Books',
  ChartType          : #Bar,
  Dimensions         : ['title'],
  Measures           : ['quantity'],
  DimensionAttributes: [{
    Dimension: 'title',
    Role     : #Category
  }],
  MeasureAttributes  : [{
    Measure: 'quantity',
    Role   : #Axis1
  }]
}});

annotate An.TopCustomers with @(UI: {Chart #TopCustomers: {
  Title              : 'Top Customers',
  ChartType          : #Column,
  Dimensions         : ['customer'],
  Measures           : ['revenue'],
  DimensionAttributes: [{
    Dimension: 'customer',
    Role     : #Category
  }],
  MeasureAttributes  : [{
    Measure: 'revenue',
    Role   : #Axis1
  }]
}});
