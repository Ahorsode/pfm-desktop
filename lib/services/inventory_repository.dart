import 'package:drift/drift.dart';

import '../data/local_db.dart';
import '../utils/health_constants.dart';

enum InventoryListFilter { active, usedUp }

enum InventoryUsageKind { feed, vaccination, medication }

class InventoryUsageEvent {
  const InventoryUsageEvent({
    required this.id,
    required this.date,
    required this.quantity,
    required this.unit,
    required this.batchId,
    required this.batchName,
    required this.kind,
    this.status,
  });

  final String id;
  final DateTime date;
  final double quantity;
  final String unit;
  final String? batchId;
  final String batchName;
  final InventoryUsageKind kind;
  final String? status;
}

class InventoryItemDetail {
  const InventoryItemDetail({
    required this.item,
    required this.usageEvents,
    required this.isUsedUp,
  });

  final InventoryItem item;
  final List<InventoryUsageEvent> usageEvents;
  final bool isUsedUp;
}

class InventoryRepository {
  InventoryRepository(this._db);

  final AppDatabase _db;

  Future<List<InventoryItem>> getAllInventory({
    required String farmId,
    InventoryListFilter filter = InventoryListFilter.active,
  }) async {
    final rows = await (_db.select(_db.inventory)
          ..where((t) => t.farmId.equals(farmId)))
        .get();

    final filtered = <InventoryItem>[];
    for (final row in rows) {
      final usedUp = await isItemUsedUp(row, farmId);
      if (filter == InventoryListFilter.active && !usedUp) {
        filtered.add(row);
      } else if (filter == InventoryListFilter.usedUp && usedUp) {
        filtered.add(row);
      }
    }

    filtered.sort((a, b) => a.itemName.compareTo(b.itemName));
    return filtered;
  }

  Future<int> getUsedUpInventoryCount(String farmId) async {
    final rows = await (_db.select(_db.inventory)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    var count = 0;
    for (final row in rows) {
      if (await isItemUsedUp(row, farmId)) {
        count++;
      }
    }
    return count;
  }

  Future<List<InventoryItem>> getHealthInventory(String farmId) async {
    final rows = await getAllInventory(
      farmId: farmId,
      filter: InventoryListFilter.active,
    );
    return rows.where((row) {
      if (!isHealthInventoryCategory(row.category)) {
        return false;
      }
      if (normalizeHealthUsageType(row.usageType) == HealthUsageType.oneTime &&
          row.stockLevel <= 0) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<InventoryItemDetail?> getInventoryItemWithUsage(
    String farmId,
    String itemId,
  ) async {
    final item = await (_db.select(_db.inventory)
          ..where((t) => t.id.equals(itemId) & t.farmId.equals(farmId)))
        .getSingleOrNull();
    if (item == null) {
      return null;
    }

    final events = await _loadUsageEvents(farmId, item);
    final usedUp = await isItemUsedUp(item, farmId);
    return InventoryItemDetail(
      item: item,
      usageEvents: events,
      isUsedUp: usedUp,
    );
  }

  Future<bool> isItemUsedUp(InventoryItem item, String farmId) async {
    if (item.stockLevel <= 0) {
      return true;
    }

    if (normalizeHealthUsageType(item.usageType) != HealthUsageType.oneTime) {
      return false;
    }

    final completed = await _completedScheduleCount(
      farmId,
      item.id,
      item.itemName,
    );
    return completed > 0;
  }

  Future<int> _completedScheduleCount(
    String farmId,
    String itemId,
    String itemName,
  ) async {
    final vaccinations = await (_db.select(_db.vaccinationSchedules)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final medications = await (_db.select(_db.medicationSchedules)
          ..where((t) => t.farmId.equals(farmId)))
        .get();

    var count = 0;
    for (final row in vaccinations) {
      if (!isHealthScheduleCompleted(row.status)) {
        continue;
      }
      if (_namesMatch(row.vaccineName, itemName)) {
        count++;
      }
    }
    for (final row in medications) {
      if (!isHealthScheduleCompleted(row.status)) {
        continue;
      }
      if (_namesMatch(row.medicationName, itemName)) {
        count++;
      }
    }
    return count;
  }

  Future<List<InventoryUsageEvent>> _loadUsageEvents(
    String farmId,
    InventoryItem item,
  ) async {
    final events = <InventoryUsageEvent>[];
    final category = item.category?.toUpperCase() ?? '';

    if (category == 'FEED') {
      final logs = await (_db.select(_db.feedingLogs)
            ..where(
              (t) =>
                  t.farmId.equals(farmId) & t.feedTypeId.equals(item.id),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.logDate)]))
          .get();
      for (final log in logs) {
        events.add(
          InventoryUsageEvent(
            id: log.id,
            date: log.logDate,
            quantity: log.amountConsumed,
            unit: item.unit,
            batchId: log.batchId,
            batchName: await _batchName(log.batchId),
            kind: InventoryUsageKind.feed,
          ),
        );
      }
    }

    if (isHealthInventoryCategory(category)) {
      final vaccinations = await (_db.select(_db.vaccinationSchedules)
            ..where((t) => t.farmId.equals(farmId))
            ..orderBy([(t) => OrderingTerm.desc(t.scheduledDate)]))
          .get();
      for (final row in vaccinations) {
        if (_isCancelled(row.status)) {
          continue;
        }
        if (!_namesMatch(row.vaccineName, item.itemName)) {
          continue;
        }
        events.add(
          InventoryUsageEvent(
            id: row.id,
            date: row.scheduledDate,
            quantity: row.quantity,
            unit: row.unit ?? item.unit,
            batchId: row.batchId,
            batchName: await _batchName(row.batchId),
            kind: InventoryUsageKind.vaccination,
            status: row.status,
          ),
        );
      }

      final medications = await (_db.select(_db.medicationSchedules)
            ..where((t) => t.farmId.equals(farmId))
            ..orderBy([(t) => OrderingTerm.desc(t.scheduledDate)]))
          .get();
      for (final row in medications) {
        if (_isCancelled(row.status)) {
          continue;
        }
        if (!_namesMatch(row.medicationName, item.itemName)) {
          continue;
        }
        events.add(
          InventoryUsageEvent(
            id: row.id,
            date: row.scheduledDate,
            quantity: row.quantity,
            unit: row.unit ?? item.unit,
            batchId: row.batchId,
            batchName: await _batchName(row.batchId),
            kind: InventoryUsageKind.medication,
            status: row.status,
          ),
        );
      }
    }

    events.sort((a, b) => b.date.compareTo(a.date));
    return events;
  }

  Future<String> _batchName(String? batchId) async {
    if (batchId == null || batchId.isEmpty) {
      return '-';
    }
    final batch = await (_db.select(_db.batches)
          ..where((t) => t.id.equals(batchId)))
        .getSingleOrNull();
    if (batch == null) {
      return batchId;
    }
    return batch.batchName.isNotEmpty ? batch.batchName : batchId;
  }

  bool _isCancelled(String status) {
    return status.toUpperCase() == 'CANCELLED';
  }

  bool _namesMatch(String left, String right) {
    return left.trim().toLowerCase() == right.trim().toLowerCase();
  }
}
