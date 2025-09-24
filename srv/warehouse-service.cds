using {sap.capire.bookshop as my} from '../db/schema';

service WarehouseService {
  @readonly
  entity Availabilities as
    projection on my.Inventory {
      book,
      book.title     as bookTitle,
      warehouse,
      warehouse.name as warehouseName,
      quantity
    }
    actions {
      action increaseQuantity(by: Integer default 1) returns WarehouseService.Availabilities;
      action decreaseQuantity(by: Integer default 1) returns WarehouseService.Availabilities;
    };

  entity Warehouses     as
    projection on my.Warehouses {
      *,
      stocks
    };

  action createWarehouse(name: String @title: '{i18n>Name}',
                         address: String @title: '{i18n>Address}',
                         city: String @title: '{i18n>City}',
                         email: String @title: '{i18n>Email}'
  ) returns WarehouseService.Warehouses;
}
