import 'package:drift/drift.dart';

import '../data/local_db.dart';

class BatchFinanceBreakdown {
  const BatchFinanceBreakdown({
    required this.batchId,
    required this.batchLabel,
    required this.initial,
    required this.operating,
    required this.consumption,
    required this.general,
    required this.revenue,
  });

  final String batchId;
  final String batchLabel;
  final double initial;
  final double operating;
  final double consumption;
  final double general;
  final double revenue;

  double get totalExpense => initial + operating + consumption + general;
  double get netProfit => revenue - totalExpense;
}

class BatchFinanceService {
  BatchFinanceService(this._db);

  final AppDatabase _db;

  Future<List<BatchFinanceBreakdown>> computeFarmBreakdown(String farmId) async {
    final batches = await (_db.select(_db.batches)
          ..where((t) => t.farmId.equals(farmId))
          ..where((t) => t.status.equals('active')))
        .get();
    if (batches.isEmpty) {
      return const [];
    }

    final expenses = await (_db.select(_db.expenses)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final feedingLogs = await (_db.select(_db.feedingLogs)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final vaccinations = await (_db.select(_db.vaccinationSchedules)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final medications = await (_db.select(_db.medicationSchedules)
          ..where((t) => t.farmId.equals(farmId)))
        .get();
    final inventory = await (_db.select(_db.inventory)
          ..where((t) => t.farmId.equals(farmId)))
        .get();

    final batchIds = batches.map((batch) => batch.id).toSet();
    final totals = {
      for (final batch in batches)
        batch.id: _BatchAccumulator(
          batchId: batch.id,
          batchLabel: batch.batchName,
          initial: _initialInvestment(batch),
        ),
    };

    for (final expense in expenses) {
      final description = expense.description ?? '';
      if (_isBatchInitialExpense(description)) {
        continue;
      }

      final batchId = expense.batchId;
      if (batchId != null && batchIds.contains(batchId)) {
        totals[batchId]!.operating += expense.amount;
        continue;
      }

      if (_isConsumptionBasedExpense(expense.category, description)) {
        _allocateConsumption(
          expense: expense,
          inventory: inventory,
          feedingLogs: feedingLogs,
          vaccinations: vaccinations,
          medications: medications,
          batches: batches,
          batchIds: batchIds,
          totals: totals,
        );
        continue;
      }

      if (batchId == null || batchId.isEmpty) {
        _splitByHeadcount(batches, expense.amount, (id, share) {
          totals[id]!.general += share;
        });
      }
    }

    final saleItemRows = await _db.customSelect(
      'SELECT * FROM sale_items WHERE farm_id = ?',
      variables: [Variable.withString(farmId)],
    ).get();
    final batchAllocationRows = await _db.customSelect(
      'SELECT * FROM order_item_batch_allocations WHERE farm_id = ?',
      variables: [Variable.withString(farmId)],
    ).get();
    final orderRows = await _db.customSelect(
      "SELECT id FROM orders WHERE farm_id = ? AND COALESCE(is_deleted, 0) = 0 AND upper(status) = 'CANCELLED'",
      variables: [Variable.withString(farmId)],
    ).get();
    final cancelledOrderIds = orderRows
        .map((row) => row.read<String>('id'))
        .toSet();

    _allocateRevenue(
      batches: batches,
      batchIds: batchIds,
      totals: totals,
      saleItems: saleItemRows,
      batchAllocations: batchAllocationRows,
      cancelledOrderIds: cancelledOrderIds,
    );

    return totals.values
        .map(
          (item) => BatchFinanceBreakdown(
            batchId: item.batchId,
            batchLabel: item.batchLabel,
            initial: item.initial,
            operating: item.operating,
            consumption: item.consumption,
            general: item.general,
            revenue: item.revenue,
          ),
        )
        .toList()
      ..sort((a, b) => a.batchLabel.compareTo(b.batchLabel));
  }

  void _allocateConsumption({
    required Expense expense,
    required List<InventoryItem> inventory,
    required List<FeedingLog> feedingLogs,
    required List<VaccinationSchedule> vaccinations,
    required List<MedicationSchedule> medications,
    required List<Batch> batches,
    required Set<String> batchIds,
    required Map<String, _BatchAccumulator> totals,
  }) {
    final description = expense.description ?? '';
    final category = expense.category.toUpperCase();
    final inventoryPurchase = _parseInventoryPurchaseExpense(description);
    final healthStock = _parseHealthStockExpense(description);
    final itemName = inventoryPurchase?.itemName ?? healthStock?.itemName;
    final usageByBatch = <String, double>{};

    if (inventoryPurchase != null && category == 'FEED') {
      final inventoryId = _inventoryIdForName(itemName, inventory);
      for (final log in feedingLogs) {
        final batchId = log.batchId;
        if (batchId == null ||
            !batchIds.contains(batchId) ||
            (inventoryId != null && log.feedTypeId != inventoryId)) {
          continue;
        }
        usageByBatch[batchId] =
            (usageByBatch[batchId] ?? 0) + log.amountConsumed;
      }
    } else if ((inventoryPurchase != null && category == 'MEDICATION') ||
        healthStock != null) {
      final normalizedName = _normalizeName(itemName ?? '');
      for (final schedule in vaccinations) {
        if (!_isCompleted(schedule.status)) {
          continue;
        }
        if (_normalizeName(schedule.vaccineName) != normalizedName) {
          continue;
        }
        if (!batchIds.contains(schedule.batchId)) {
          continue;
        }
        usageByBatch[schedule.batchId] =
            (usageByBatch[schedule.batchId] ?? 0) + schedule.quantity;
      }
      for (final schedule in medications) {
        if (!_isCompleted(schedule.status)) {
          continue;
        }
        if (_normalizeName(schedule.medicationName) != normalizedName) {
          continue;
        }
        if (!batchIds.contains(schedule.batchId)) {
          continue;
        }
        usageByBatch[schedule.batchId] =
            (usageByBatch[schedule.batchId] ?? 0) + schedule.quantity;
      }
    }

    final totalUsage = usageByBatch.values.fold<double>(0, (sum, v) => sum + v);
    if (totalUsage <= 0) {
      _splitByHeadcount(batches, expense.amount, (id, share) {
        totals[id]!.consumption += share;
      });
      return;
    }

    for (final entry in usageByBatch.entries) {
      totals[entry.key]!.consumption +=
          expense.amount * (entry.value / totalUsage);
    }
  }

  void _allocateRevenue({
    required List<Batch> batches,
    required Set<String> batchIds,
    required Map<String, _BatchAccumulator> totals,
    required List<QueryRow> saleItems,
    required List<QueryRow> batchAllocations,
    required Set<String> cancelledOrderIds,
  }) {
    final allocatedItemIds = <String>{};
    for (final row in batchAllocations) {
      final batchId = row.read<String?>('batch_id') ?? '';
      if (batchId.isEmpty || !batchIds.contains(batchId)) {
        continue;
      }
      totals[batchId]!.revenue += row.read<double>('revenue_amount');
      final orderItemId = row.read<String?>('order_item_id') ?? '';
      if (orderItemId.isNotEmpty) {
        allocatedItemIds.add(orderItemId);
      }
    }

    final linked = <String, double>{};
    var unlinked = 0.0;
    for (final item in saleItems) {
      final saleId = item.read<String?>('sale_id') ?? '';
      if (cancelledOrderIds.contains(saleId)) {
        continue;
      }
      final itemId = item.read<String?>('id') ?? '';
      if (allocatedItemIds.contains(itemId)) {
        continue;
      }
      final total = item.read<double>('total_price');
      final eggMode = item.read<String?>('egg_allocation_mode') ?? '';
      final eggBatchId = item.read<String?>('egg_batch_id') ?? '';
      if (eggMode == 'batch' &&
          eggBatchId.isNotEmpty &&
          batchIds.contains(eggBatchId)) {
        linked[eggBatchId] = (linked[eggBatchId] ?? 0) + total;
        continue;
      }
      final batchId = item.read<String?>('livestock_id') ?? '';
      if (batchId.isNotEmpty && batchIds.contains(batchId)) {
        linked[batchId] = (linked[batchId] ?? 0) + total;
      } else {
        unlinked += total;
      }
    }

    for (final entry in linked.entries) {
      totals[entry.key]!.revenue += entry.value;
    }
    if (unlinked > 0) {
      _splitByHeadcount(batches, unlinked, (id, share) {
        totals[id]!.revenue += share;
      });
    }
  }

  void _splitByHeadcount(
    List<Batch> batches,
    double amount,
    void Function(String batchId, double share) apply,
  ) {
    final totalHeadcount = batches.fold<int>(
      0,
      (sum, batch) => sum + batch.currentCount,
    );
    if (totalHeadcount <= 0) {
      final share = amount / batches.length;
      for (final batch in batches) {
        apply(batch.id, share);
      }
      return;
    }

    for (final batch in batches) {
      apply(
        batch.id,
        amount * (batch.currentCount / totalHeadcount),
      );
    }
  }

  bool _isBatchInitialExpense(String description) {
    return RegExp(r'^Initial cost for ', caseSensitive: false).hasMatch(description) ||
        RegExp(r'^Carriage for ', caseSensitive: false).hasMatch(description) ||
        RegExp(r'\(Initial for ', caseSensitive: false).hasMatch(description);
  }

  bool _isConsumptionBasedExpense(String category, String description) {
    final normalized = category.toUpperCase();
    if (_parseInventoryPurchaseExpense(description) != null) {
      return normalized == 'FEED' || normalized == 'MEDICATION';
    }
    if (_parseHealthStockExpense(description) != null) {
      return normalized == 'MEDICATION';
    }
    return false;
  }

  ({String itemName, double purchasedQty})? _parseInventoryPurchaseExpense(
    String description,
  ) {
    final match = RegExp(
      r'^Inventory Purchase:\s*(.+?)\s*\(([0-9.]+)\s',
      caseSensitive: false,
    ).firstMatch(description);
    if (match == null) {
      return null;
    }
    return (
      itemName: match.group(1)!.trim(),
      purchasedQty: double.tryParse(match.group(2)!) ?? 0,
    );
  }

  ({String itemName, double stockQty})? _parseHealthStockExpense(
    String description,
  ) {
    final match = RegExp(
      r'^Health stock cost:\s*(.+?)\s*\(([0-9.]+)\s',
      caseSensitive: false,
    ).firstMatch(description);
    if (match == null) {
      return null;
    }
    return (
      itemName: match.group(1)!.trim(),
      stockQty: double.tryParse(match.group(2)!) ?? 0,
    );
  }

  String? _inventoryIdForName(String? itemName, List<InventoryItem> inventory) {
    if (itemName == null || itemName.isEmpty) {
      return null;
    }
    final normalized = _normalizeName(itemName);
    for (final item in inventory) {
      if (_normalizeName(item.itemName) == normalized) {
        return item.id;
      }
    }
    return null;
  }

  String _normalizeName(String value) => value.trim().toLowerCase();

  bool _isCompleted(String? status) {
    final normalized = status?.toUpperCase() ?? '';
    return normalized == 'COMPLETED' || normalized == 'DONE';
  }

  double _initialInvestment(Batch batch) => batch.initialActualCost ?? 0;
}

class _BatchAccumulator {
  _BatchAccumulator({
    required this.batchId,
    required this.batchLabel,
    required this.initial,
  });

  final String batchId;
  final String batchLabel;
  final double initial;
  double operating = 0;
  double consumption = 0;
  double general = 0;
  double revenue = 0;
}
