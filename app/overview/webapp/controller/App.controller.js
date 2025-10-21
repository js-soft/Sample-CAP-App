sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/m/MessageToast",
    "sap/ui/core/UIComponent",
  ],
  function (Controller, MessageToast, UIComponent) {
    "use strict";
    return Controller.extend("overview.controller.App", {
      onInit: function () {},

      onBookSliceSelect: function (oEvent) {
        const aData = oEvent.getParameter("data");
        if (!aData || !aData.length) return;

        const dp = aData[0];
        const bookID = dp && dp.data && dp.data.Book;
        if (bookID == null) {
          MessageToast.show("Cannot navigate: missing Book ID.");
          return;
        }

        let oRouter;
        try {
          oRouter = UIComponent.getRouterFor(this);
        } catch (_) {
          const oc = this.getOwnerComponent && this.getOwnerComponent();
          oRouter = oc && oc.getRouter && oc.getRouter();
        }

        if (oRouter && oRouter.navTo) {
          oRouter.navTo("ObjectPage", { ID: Number(bookID) }, true /*replace*/);
          return;
        }

        const getSvc =
          sap.ushell &&
          sap.ushell.Container &&
          sap.ushell.Container.getServiceAsync;

        if (getSvc) {
          getSvc("CrossApplicationNavigation").then(function (oCANav) {
            const idStr = String(bookID);
            const appRoute = "Books(" + encodeURIComponent(idStr) + ")";

            oCANav.toExternal({
              target: { semanticObject: "Books", action: "display" },
              params: { ID: [idStr] },
              appSpecificRoute: "&/" + appRoute,
            });
          });
          return;
        }

        sap.m.URLHelper.redirect(
          "#Books(" + encodeURIComponent(String(bookID)) + ")",
          false
        );
      },
    });
  }
);
