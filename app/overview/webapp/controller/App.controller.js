// app.controller.js
sap.ui.define(
  ["sap/ui/core/mvc/Controller", "sap/m/MessageToast"],
  function (Controller, MessageToast) {
    "use strict";
    return Controller.extend("overview.controller.App", {
      onInit: function () {},

      onBookSliceSelect: function (oEvent) {
        const aData = oEvent.getParameter("data");
        if (!aData || !aData.length) return;
        const dp = aData[0];
        // Dimension name is "Book"; its value is bookID thanks to value="{bookID}"
        const bookID = dp?.data?.Book;
        if (bookID == null) {
          MessageToast.show("Cannot navigate: missing Book ID.");
          return;
        }

        const getSvc = sap.ushell?.Container?.getServiceAsync;
        if (getSvc) {
          getSvc("CrossApplicationNavigation").then(function (oCANav) {
            const sHash = oCANav.hrefForExternal({
              target: { semanticObject: "Books", action: "display" },
              params: { ID: [String(bookID)] },
            });
            oCANav.toExternal({ target: { shellHash: sHash } });
          });
        } else {
          // Fallback: hash nav when running standalone (adapt if your Books app is separate)
          sap.m.URLHelper.redirect(
            "#Books-display?ID=" + encodeURIComponent(String(bookID)),
            false
          );
        }
      },
    });
  }
);
