using {AnalyticsService as AS} from '../../srv/analytics-service';

annotate AS with @(UI.HeaderInfo: {
  TypeName      : 'Bookshop Overview',
  TypeNamePlural: 'Bookshop Overviews',
  Title         : {Value: 'Bookshop Performance'},
  Description   : {Value: 'Key Analytical Data'}
});

annotate AS.OrdersByGenre with @(UI: {
  Chart #ByGenre     : {
    Title              : '{i18n>ByGenre}',
    Description        : '{i18n>OrdersByGenreDesc}',
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
  },
  // OVP CARD Annotations
  PresentationVariant: {
    SortOrder: [{
      Property  : 'quantity',
      Descending: true
    }],
    MaxItems : 10
  },
  DataPoint          : {Title: '{i18n>OrdersByGenreDesc}'}
});

annotate AS.RevenueByDay with @(UI: {
  Chart #RevenueDaily: {
    Title              : '{i18n>RevenueByDay}',
    Description        : '{i18n>RevenueByDayDesc}',
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
  },
  // OVP CARD Annotations
  PresentationVariant: {
    SortOrder: [{
      Property  : 'orderDate',
      Descending: false
    }],
    MaxItems : 7
  },
  DataPoint          : {Title: '{i18n>RevenueByDayDesc}'}
});

annotate AS.TopBooks with @(UI: {
  Chart #TopBooks    : {
    Title              : '{i18n>TopBooks}',
    Description        : '{i18n>TopBooksDesc}',
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
  },
  // OVP CARD Annotations
  PresentationVariant: {
    SortOrder: [{
      Property  : 'quantity',
      Descending: true
    }],
    MaxItems : 5
  },
  DataPoint          : {Title: '{i18n>TopBooksDesc}'}
});

annotate AS.TopCustomers with @(UI: {
  Chart #TopCustomers: {
    Title              : '{i18n>TopCustomers}',
    Description        : '{i18n>TopCustomersDesc}',
    ChartType          : #Donut,
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
  },
  // OVP CARD Annotations
  PresentationVariant: {
    SortOrder: [{
      Property  : 'revenue',
      Descending: true
    }],
    MaxItems : 5
  },
  DataPoint          : {Title: '{i18n>TopCustomersDesc}'}
});
