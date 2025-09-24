// srv/warehouse-service.js
const cds = require("@sap/cds");
const { SELECT, INSERT, UPDATE } = cds.ql;

module.exports = class WarehouseService extends cds.ApplicationService {
  init() {
    const { Warehouses } = this.entities;
    const { Inventory } = cds.entities("sap.capire.bookshop");

    const getKeys = (req) => {
      const segs = Array.isArray(req.params) ? req.params : [req.params || {}];
      const last = segs[segs.length - 1] || {};
      const prev = segs.length > 1 ? segs[segs.length - 2] : {};

      const book_ID =
        last.book_ID ?? last.book?.ID ?? req.data?.bookId ?? req.data?.book_ID;

      const warehouse_ID =
        last.warehouse_ID ??
        last.warehouse?.ID ??
        prev.ID ??
        req.data?.warehouseId ??
        req.data?.warehouse_ID;

      return { book_ID, warehouse_ID };
    };

    this.on("increaseQuantity", "Availabilities", async (req) => {
      const { book_ID, warehouse_ID } = getKeys(req);
      const by = Number(req.data?.by ?? 1) || 1;

      if (book_ID == null || warehouse_ID == null) {
        return req.error(
          400,
          "Missing keys: book_ID and warehouse_ID are required"
        );
      }

      const row = (
        await SELECT.from(Inventory).where({ book_ID, warehouse_ID }).limit(1)
      )?.[0];

      if (!row) {
        await INSERT.into(Inventory).entries({
          book_ID,
          warehouse_ID,
          quantity: by,
        });
      } else {
        await UPDATE(Inventory)
          .set({ quantity: { "+=": by } })
          .where({ book_ID, warehouse_ID });
      }

      return (
        await SELECT.from(Inventory).where({ book_ID, warehouse_ID }).limit(1)
      )?.[0];
    });

    this.on("decreaseQuantity", "Availabilities", async (req) => {
      const { book_ID, warehouse_ID } = getKeys(req);
      const by = Number(req.data?.by ?? 1) || 1;

      if (book_ID == null || warehouse_ID == null) {
        return req.error(
          400,
          "Missing keys: book_ID and warehouse_ID are required"
        );
      }

      const row = (
        await SELECT.from(Inventory).where({ book_ID, warehouse_ID }).limit(1)
      )?.[0];
      const curr = row?.quantity ?? 0;
      const next = Math.max(0, curr - by);

      if (!row) {
        await INSERT.into(Inventory).entries({
          book_ID,
          warehouse_ID,
          quantity: 0,
        });
        return { book_ID, warehouse_ID, quantity: 0 };
      }

      await UPDATE(Inventory)
        .set({ quantity: next })
        .where({ book_ID, warehouse_ID });
      return (
        await SELECT.from(Inventory).where({ book_ID, warehouse_ID }).limit(1)
      )?.[0];
    });

    this.on("createWarehouse", async (req) => {
      const { name, address, city, email } = req.data || {};

      await INSERT.into(Warehouses).entries({ name, address, city, email });

      const created = (
        await SELECT.from(Warehouses)
          .where({ name, address, city, email })
          .orderBy("ID desc")
          .limit(1)
      )?.[0];

      return created;
    });

    return super.init();
  }
};
