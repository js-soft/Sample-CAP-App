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
  });
});
