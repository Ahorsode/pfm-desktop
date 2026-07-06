import 'dart:math';

import 'package:drift/drift.dart';

import '../data/local_db.dart';
import '../utils/inventory_sale_utils.dart';

class EggFifoService {
  EggFifoService(this._db);

  final AppDatabase _db;

  Future<void> deductFromProductionLogs({
    required String farmId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      return;
    }
    var qtyToDeduct = quantity;
    final logs = await (_db.select(_db.eggProductions)
          ..where(
            (t) =>
                t.farmId.equals(farmId) &
                t.eggsRemaining.isBiggerThanValue(0),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.logDate)]))
        .get();

    for (final log in logs) {
      if (qtyToDeduct <= 0) {
        break;
      }
      final take = min(log.eggsRemaining, qtyToDeduct);
      await (_db.update(_db.eggProductions)..where((t) => t.id.equals(log.id)))
          .write(
        EggProductionsCompanion(
          eggsRemaining: Value(log.eggsRemaining - take),
          synced: const Value(false),
        ),
      );
      qtyToDeduct -= take;
    }
  }

  Future<void> deductForInventorySale({
    required String farmId,
    required String? inventoryId,
    required int quantity,
  }) async {
    if (inventoryId == null || inventoryId.isEmpty || quantity <= 0) {
      return;
    }
    final inventory = await (_db.select(_db.inventory)
          ..where((t) => t.id.equals(inventoryId)))
        .getSingleOrNull();
    if (inventory == null || !isEggInventoryItem(inventory)) {
      return;
    }
    await deductFromProductionLogs(farmId: farmId, quantity: quantity);
  }
}
