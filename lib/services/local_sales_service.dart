import 'package:drift/drift.dart';

import '../data/local_db.dart';
import '../features/sales/sale_line_draft.dart';
import '../utils/id_utils.dart';
import 'egg_fifo_service.dart';

class LocalSalesService {
  LocalSalesService(this._db);

  final AppDatabase _db;

  static double roundMoney(double value) => (value * 100).roundToDouble() / 100;

  Future<String> recordMultiLineSale({
    required String farmId,
    required String userId,
    required List<SaleLineDraft> items,
    required DateTime orderDate,
    required double totalCashReceived,
    String? customerId,
    String? customerName,
    double discountAmount = 0,
    String paymentMethod = 'CASH',
    String? paymentReference,
    String? paymentAccountName,
    bool requireExactCashTotal = true,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('At least one sale line item is required.');
    }

    final subtotal = roundMoney(
      items.fold<double>(0, (sum, item) => sum + item.lineTotal),
    );
    final discount = roundMoney(discountAmount.clamp(0, subtotal));
    final computedTotal = roundMoney(
      (subtotal - discount).clamp(0, double.infinity),
    );
    final cashReceived = roundMoney(totalCashReceived);

    if (requireExactCashTotal && (cashReceived - computedTotal).abs() > 0.01) {
      throw ArgumentError(
        'Cash received must equal the locked sale total.',
      );
    }
    if (!requireExactCashTotal && cashReceived < 0) {
      throw ArgumentError('Cash received cannot be negative.');
    }
    if (!requireExactCashTotal &&
        paymentMethod != 'CREDIT' &&
        cashReceived <= 0 &&
        computedTotal > 0) {
      throw ArgumentError('Cash received must be greater than zero.');
    }

    final outstanding = roundMoney(
      (computedTotal - cashReceived).clamp(0, double.infinity),
    );
    final isPaid = outstanding <= 0.01;
    final paymentStatus = isPaid
        ? 'PAID'
        : (cashReceived > 0 ? 'PARTIALLY_PAID' : 'UNPAID');
    final resolvedCustomerName =
        (customerName == null || customerName.trim().isEmpty)
        ? 'Walk-in Customer'
        : customerName.trim();

    final saleId = newLocalId();
    final now = orderDate.toUtc();
    final firstLivestock = items
        .where((item) => item.livestockId != null && item.livestockId!.isNotEmpty)
        .map((item) => item.livestockId!)
        .firstOrNull;
    final lineQuantity = items.fold<int>(0, (sum, item) => sum + item.quantity);

    await _db.into(_db.sales).insert(
      SalesCompanion.insert(
        id: saleId,
        farmId: farmId,
        batchId: Value(firstLivestock),
        customerId: Value(customerId),
        quantity: lineQuantity <= 0 ? 1 : lineQuantity,
        unitPrice: lineQuantity <= 0
            ? computedTotal
            : roundMoney(computedTotal / lineQuantity),
        totalAmount: computedTotal,
        saleDate: Value(now),
        userId: Value(userId),
        synced: const Value(false),
      ),
    );

    for (var index = 0; index < items.length; index += 1) {
      final item = items[index];
      await _db.customStatement(
        '''
        INSERT INTO sale_items (
          id, sale_id, description, quantity, unit_price, total_price,
          farm_id, inventory_id, livestock_id, synced
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
        ''',
        [
          '${saleId}_item_$index',
          saleId,
          item.description,
          item.resolvedQuantityEggs,
          item.productType == SaleProductType.inventory
              ? item.resolvedUnitPricePerEgg
              : item.unitPrice,
          item.lineTotal,
          farmId,
          item.inventoryId,
          item.livestockId,
        ],
      );
      await EggFifoService(_db).deductForInventorySale(
        farmId: farmId,
        inventoryId: item.inventoryId,
        quantity: item.resolvedQuantityEggs,
        batchId: item.eggAllocationMode == 'batch' ? item.eggBatchId : null,
      );
    }

    await _db.customStatement(
      '''
      INSERT INTO financial_transactions (
        id, farm_id, user_id, type, category, amount, payment_status,
        payment_method, reference_num, transaction_date, description,
        customer_id, deposit_amount, outstanding_credit, expense_outlay,
        is_deleted, settled_at, created_at, updated_at, synced
      ) VALUES (?, ?, ?, 'REVENUE', 'SALES', ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, ?, ?, ?, 0)
      ''',
      [
        '${saleId}_transaction',
        farmId,
        userId,
        computedTotal,
        paymentStatus,
        paymentMethod,
        paymentReference?.trim().isNotEmpty == true ? paymentReference!.trim() : saleId,
        now.toIso8601String(),
        paymentAccountName != null && paymentAccountName.trim().isNotEmpty
            ? '${items.map((item) => '${item.quantity} x ${item.description}').join(', ')} to $resolvedCustomerName (${paymentAccountName.trim()})'
            : '${items.map((item) => '${item.quantity} x ${item.description}').join(', ')} to $resolvedCustomerName',
        customerId,
        cashReceived,
        outstanding,
        isPaid ? now.toIso8601String() : null,
        now.toIso8601String(),
        now.toIso8601String(),
      ],
    );

    if (customerId != null && customerId.isNotEmpty && outstanding > 0) {
      final customer = await (_db.select(_db.customers)
            ..where((t) => t.id.equals(customerId)))
          .getSingleOrNull();
      if (customer != null) {
        await (_db.update(_db.customers)..where((t) => t.id.equals(customerId)))
            .write(
          CustomersCompanion(
            balanceOwed: Value(roundMoney(customer.balanceOwed + outstanding)),
            synced: const Value(false),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    }

    return saleId;
  }
}
