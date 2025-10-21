sap.ui.define(["sap/ui/core/UIComponent"], function (UIComponent) {
  "use strict";
  return UIComponent.extend("overview.Component", {
    metadata: {
      manifest: "json",
      rootView: {
        viewName: "overview.view.App",
        type: "XML",
        async: true,
      },
    },
    init: function () {
      UIComponent.prototype.init.apply(this, arguments);
      var oRouter = this.getRouter && this.getRouter();
      if (oRouter && oRouter.initialize) {
        oRouter.initialize();
      }
    },
  });
});
