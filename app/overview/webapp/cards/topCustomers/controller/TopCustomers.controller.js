sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/suite/ui/microchart/ColumnMicroChartData",
  ],
  function (Controller, ColumnMicroChartData) {
    "use strict";

    return Controller.extend(
      "overview.cards.topCustomers.controller.TopCustomers",
      {
        onInit: function () {
          const oChart = this.byId("topCustChart");

          // Bind the 'columns' aggregation to the default model root (array)
          oChart.bindAggregation("columns", {
            path: "/",
            template: new ColumnMicroChartData({
              value: "{revenue}", // numeric
              label: "{customer}", // dimension label
            }),
          });
        },
      }
    );
  }
);
