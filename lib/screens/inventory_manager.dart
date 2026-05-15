import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:intl/intl.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../utils/farm_utils.dart';

class InventoryManager extends StatelessWidget {
  const InventoryManager({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Inventory & Stock',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddItemDialog(context, db),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text('New Item', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 850;
        return StreamBuilder<List<InventoryItem>>(
          stream: db.select(db.inventory).watch(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final items = snapshot.data!;

            if (items.isEmpty) return _buildEmptyState(context, db);

            final totalValue = items.fold(0.0, (s, item) => s + (item.stockLevel * (item.costPerUnit ?? 0)));
            final lowStockItems = items.where((item) => item.stockLevel < (item.reorderLevel ?? 10)).length;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(isNarrow ? 16 : 32),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _kpiCard(context, 'Total Inventory Value', currency.format(totalValue), Icons.account_balance_wallet_rounded, Colors.teal, isNarrow),
                        _kpiCard(context, 'Total Stock Items', '${items.length}', Icons.inventory_2_rounded, Colors.blue, isNarrow),
                        _kpiCard(context, 'Low Stock Alerts', '$lowStockItems', Icons.warning_amber_rounded, Colors.orange, isNarrow),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isNarrow ? 16 : 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _InventoryItemTile(item: item, isNarrow: isNarrow),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _kpiCard(BuildContext context, String title, String value, IconData icon, Color color, bool isNarrow) {
    return Container(
      width: isNarrow ? (MediaQuery.of(context).size.width - 48) : 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppDatabase db) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warehouse_outlined, size: 100, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 24),
          const Text('Inventory is Empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Add feed, medication, or supplies to track your stock.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _showAddItemDialog(context, db),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
            child: const Text('Add Your First Item'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context, AppDatabase db) async {
    final nameController = TextEditingController();
    final levelController = TextEditingController();
    final unitController = TextEditingController();
    final costController = TextEditingController();
    final reorderController = TextEditingController(text: '10');
    String selectedCategory = 'FEED';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add New Stock Item', style: TextStyle(fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g. Broiler Starter Mash',
                    prefixIcon: const Icon(Icons.inventory_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'FEED', child: Text('Poultry Feed')),
                    DropdownMenuItem(value: 'MEDICATION', child: Text('Medication / Vaccine')),
                    DropdownMenuItem(value: 'EQUIPMENT', child: Text('Equipment')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other Supplies')),
                  ],
                  onChanged: (v) => selectedCategory = v!,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: levelController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Initial Stock',
                          prefixIcon: const Icon(Icons.numbers_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          hintText: 'e.g., kg, pcs, bottles',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cost Per Unit (GH₵)',
                          prefixIcon: const Icon(Icons.attach_money_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: reorderController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Reorder Level',
                          prefixIcon: const Icon(Icons.notification_important_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final stock = double.tryParse(levelController.text) ?? 0;
              final cost = double.tryParse(costController.text) ?? 0;
              final reorder = double.tryParse(reorderController.text) ?? 10;
              if (nameController.text.isEmpty) return;

              final farmId = await FarmUtils.getBoundFarmId();
              if (farmId == null) return;

              await db.into(db.inventory).insert(
                    InventoryCompanion.insert(
                      farmId: farmId,
                      itemName: nameController.text,
                      category: Value(selectedCategory),
                      stockLevel: stock,
                      unit: unitController.text,
                      costPerUnit: Value(cost),
                      reorderLevel: Value(reorder),
                      synced: const Value(false),
                    ),
                  );

              if (context.mounted) {
                context.read<SyncEngine>().syncNow();
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.teal[600]),
            child: const Text('Create Item'),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  final InventoryItem item;
  final bool isNarrow;
  const _InventoryItemTile({required this.item, required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final isLow = item.stockLevel <= (item.reorderLevel ?? 10);
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return Container(
      padding: EdgeInsets.all(isNarrow ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLow ? Colors.red.withValues(alpha: 0.3) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(item.category ?? 'OTHER').withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCategoryIcon(item.category ?? 'OTHER'), color: _getCategoryColor(item.category ?? 'OTHER'), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18), overflow: TextOverflow.ellipsis),
                    Text(item.category ?? 'Uncategorized',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item.stockLevel} ${item.unit}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: isLow ? Colors.red[700] : Theme.of(context).colorScheme.onSurface,
                      )),
                  if (isLow) Text('LOW STOCK', style: TextStyle(color: Colors.red[700], fontSize: 10, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _infoChip(context, 'Cost/Unit: ${currency.format(item.costPerUnit ?? 0)}', Icons.sell_rounded, Colors.grey),
                  const SizedBox(width: 12),
                  _infoChip(context, 'Total Value: ${currency.format(item.stockLevel * (item.costPerUnit ?? 0))}', Icons.payments_rounded, Colors.green),
                ],
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => _showRestockDialog(context, db, item),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    tooltip: 'Restock Item',
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _showUsageDialog(context, db, item),
                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                    style: IconButton.styleFrom(backgroundColor: Colors.orange.withValues(alpha: 0.1), foregroundColor: Colors.orange),
                    tooltip: 'Record Usage',
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _showHistoryDialog(context, db, item),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    style: IconButton.styleFrom(backgroundColor: Colors.blue.withValues(alpha: 0.1), foregroundColor: Colors.blue),
                    tooltip: 'View History',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _showRestockDialog(BuildContext context, AppDatabase db, InventoryItem item) async {
    final qtyController = TextEditingController();
    final costController = TextEditingController(text: item.costPerUnit?.toString() ?? '');
    Customer? selectedSupplier;
    bool isCredit = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text('Restock: ${item.itemName}', style: const TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<List<Customer>>(
                stream: (db.select(db.customers)..where((t) => t.customerType.equals('SUPPLIER'))).watch(),
                builder: (context, snapshot) {
                  final suppliers = snapshot.data ?? [];
                  return DropdownButtonFormField<Customer>(
                    initialValue: selectedSupplier,
                    items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                    onChanged: (v) => setDlgState(() => selectedSupplier = v),
                    decoration: InputDecoration(
                      labelText: 'Supplier',
                      prefixIcon: const Icon(Icons.business_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Added Quantity',
                        suffixText: item.unit,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'New Cost/Unit',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Buy on Credit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: isCredit,
                onChanged: (v) => setDlgState(() => isCredit = v),
                secondary: const Icon(Icons.credit_card_rounded),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final qty = double.tryParse(qtyController.text) ?? 0;
                final cost = double.tryParse(costController.text) ?? item.costPerUnit ?? 0;
                if (qty <= 0) return;

                final farmId = await FarmUtils.getBoundFarmId();
                if (farmId == null) return;

                // 1. Update Inventory
                await (db.update(db.inventory)..where((t) => t.id.equals(item.id))).write(
                  InventoryCompanion(
                    stockLevel: Value(item.stockLevel + qty),
                    costPerUnit: Value(cost),
                    synced: const Value(false),
                  ),
                );

                // 2. Log Stock movement
                await db.into(db.stockLogs).insert(StockLogsCompanion.insert(
                      farmId: farmId,
                      itemId: item.id,
                      quantity: qty,
                      logType: 'PROCURED',
                      supplierId: Value(selectedSupplier?.id),
                      logDate: Value(DateTime.now()),
                      synced: const Value(false),
                    ));

                // 3. Create Expense
                final total = qty * cost;
                final descSuffix = selectedSupplier != null ? ' (Supplier: ${selectedSupplier!.name})' : '';
                await db.into(db.expenses).insert(ExpensesCompanion.insert(
                      farmId: farmId,
                      amount: total,
                      category: item.category ?? 'INVENTORY',
                      description: Value('Restocked ${item.itemName} x $qty ${item.unit}$descSuffix${isCredit ? ' [CREDIT]' : ''}'),
                      date: Value(DateTime.now()),
                      synced: const Value(false),
                    ));

                // 4. Update Supplier Balance if credit
                if (isCredit && selectedSupplier != null) {
                  await (db.update(db.customers)..where((t) => t.id.equals(selectedSupplier!.id))).write(
                    CustomersCompanion(balanceOwed: Value(selectedSupplier!.balanceOwed + total), synced: const Value(false)),
                  );
                }

                if (context.mounted) {
                  context.read<SyncEngine>().syncNow();
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirm Restock'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUsageDialog(BuildContext context, AppDatabase db, InventoryItem item) async {
    final qtyController = TextEditingController();
    Batch? selectedBatch;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text('Record Usage: ${item.itemName}', style: const TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<List<Batch>>(
                stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
                builder: (context, snapshot) {
                  final batches = snapshot.data ?? [];
                  return DropdownButtonFormField<Batch>(
                    initialValue: selectedBatch,
                    items: batches.map((b) => DropdownMenuItem(value: b, child: Text(b.batchName))).toList(),
                    onChanged: (v) => setDlgState(() => selectedBatch = v),
                    decoration: InputDecoration(
                      labelText: 'Assigned to Batch (Optional)',
                      prefixIcon: const Icon(Icons.egg_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity Used',
                  suffixText: item.unit,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final qty = double.tryParse(qtyController.text) ?? 0;
                if (qty <= 0 || qty > item.stockLevel) return;

                final farmId = await FarmUtils.getBoundFarmId();
                if (farmId == null) return;

                // 1. Update Inventory
                await (db.update(db.inventory)..where((t) => t.id.equals(item.id))).write(
                  InventoryCompanion(
                    stockLevel: Value(item.stockLevel - qty),
                    synced: const Value(false),
                  ),
                );

                // 2. Log Stock movement
                await db.into(db.stockLogs).insert(StockLogsCompanion.insert(
                      farmId: farmId,
                      itemId: item.id,
                      quantity: -qty,
                      logType: 'CONSUMED',
                      batchId: Value(selectedBatch?.id),
                      logDate: Value(DateTime.now()),
                      synced: const Value(false),
                    ));

                if (context.mounted) {
                  context.read<SyncEngine>().syncNow();
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.orange[700]),
              child: const Text('Record Usage'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHistoryDialog(BuildContext context, AppDatabase db, InventoryItem item) async {

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stock History: ${item.itemName}', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 500,
          height: 400,
          child: StreamBuilder<List<StockLog>>(
            stream: (db.select(db.stockLogs)..where((t) => t.itemId.equals(item.id))..orderBy([(t) => OrderingTerm(expression: t.logDate, mode: OrderingMode.desc)])).watch(),
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];
              if (logs.isEmpty) return const Center(child: Text('No history found for this item.'));

              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, i) {
                  final log = logs[i];
                  final isAdd = log.quantity > 0;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAdd ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                      child: Icon(isAdd ? Icons.add_rounded : Icons.remove_rounded, color: isAdd ? Colors.green : Colors.orange),
                    ),
                    title: Text('${isAdd ? '+' : ''}${log.quantity} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${log.logType} • ${DateFormat('MMM dd, yyyy HH:mm').format(log.logDate)}'),
                  );
                },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'FEED': return Icons.grass_rounded;
      case 'MEDICATION': return Icons.vaccines_rounded;
      case 'EQUIPMENT': return Icons.build_circle_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'FEED': return Colors.teal;
      case 'MEDICATION': return Colors.purple;
      case 'EQUIPMENT': return Colors.orange;
      default: return Colors.blueGrey;
    }
  }
}
