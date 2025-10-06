sap.ui.define(
  ["sap/ui/core/UIComponent", "sap/ui/model/json/JSONModel"],
  function (UIComponent, JSONModel) {
    "use strict";

    return UIComponent.extend("overview.cards.topCustomers.Component", {
      metadata: { manifest: "json" },

      init: function () {
        UIComponent.prototype.init.apply(this, arguments);

        // Card passes resolved data in componentData.card.data
        const compData =
          (this.getComponentData && this.getComponentData()) || {};
        const cardData = compData.card && compData.card.data; // expected: array [{customer, revenue}, ...]

        if (cardData) {
          const oModel = new JSONModel(cardData);
          this.setModel(oModel); // default model available to the root view
        }
      },
    });
  }
);
