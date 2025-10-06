sap.ui.define(["sap/ui/core/mvc/Controller"], function (Controller) {
  "use strict";
  return Controller.extend("overview.controller.App", {
    onInit: function () {
      const toUrl = sap.ui.require.toUrl; // resolves module paths using resourceroots

      this.byId("cardRevenue").setManifest(
        toUrl("overview/cards/revenueByDay.card.json")
      );
      this.byId("cardTopCust").setManifest(
        toUrl("overview/cards/topCustomers.card.json")
      );
      this.byId("cardByGenre").setManifest(
        toUrl("overview/cards/ordersByGenre.card.json")
      );
    },
  });
});

// sap.ui.define(["sap/ui/core/mvc/Controller"], function (Controller) {
//   "use strict";
//   return Controller.extend("overview.controller.App", {
//     onInit: function () {
//       const toUrl = sap.ui.require.toUrl;

//       // Only set ONE card first to prove it works
//       const card = this.byId("cardTopCust");
//       const url = toUrl("overview/cards/topCustomers.card.json");

//       card.setManifest(url);

//       // // Helpful signals
//       // card.attachManifestReady(() => console.log("[Card ready]", url));
//       // card.attachDataReady(() => console.log("[Card data ready]"));
//       // card.attachError((e) => console.error("[Card error]", e.getParameters()));
//     },
//   });
// });
