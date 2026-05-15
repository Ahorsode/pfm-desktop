import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/local_db.dart';
import '../widgets/financial_init_dialog.dart';
import '../utils/farm_utils.dart';
import 'package:drift/drift.dart' hide Column;

class FinancialControlScreen extends StatefulWidget {
  const FinancialControlScreen({super.key});

  @override
  State<FinancialControlScreen> createState() => _FinancialControlScreenState();
}

class _FinancialControlScreenState extends State<FinancialControlScreen> {
  late AppDatabase db;
  bool _hasCheckedInit = false;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUninitializedBatches());
  }

  Future<void> _checkUninitializedBatches() async {
    if (_hasCheckedInit) return;
    _hasCheckedInit = true;
    final batches = await db.select(db.batches).get();
    final uninitialized = batches.where((b) => b.initialActualCost == null).toList();
    if (uninitialized.isNotEmpty && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 28),
            SizedBox(width: 12),
            Text('Financial Setup Required', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('The following batches need initial cost data before financial reports can be accurate:',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              ...uninitialized.map((b) => ListTile(
                dense: true,
                leading: const Icon(Icons.circle, size: 8, color: Color(0xFFF59E0B)),
                title: Text(b.batchName, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(context: context, barrierDismissible: false, builder: (_) => FinancialInitDialog(batch: b));
                  },
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                  child: const Text('Initialize', style: TextStyle(fontSize: 12)),
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('REMIND ME LATER', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 850;
        return StreamBuilder<List<EggProduction>>(
          stream: db.select(db.eggProductions).watch(),
          builder: (context, eggSnap) {
            return StreamBuilder<List<InventoryItem>>(
              stream: db.select(db.inventory).watch(),
              builder: (context, invSnap) {
                return StreamBuilder<List<Customer>>(
                  stream: db.select(db.customers).watch(),
                  builder: (context, custSnap) {
                    return StreamBuilder<List<Expense>>(
                      stream: db.select(db.expenses).watch(),
                      builder: (context, expSnap) {
                        return StreamBuilder<List<Settlement>>(
                          stream: db.select(db.settlements).watch(),
                          builder: (context, setSnap) {
                            final eggs = eggSnap.data ?? [];
                            final inventory = invSnap.data ?? [];
                            final customers = custSnap.data ?? [];
                            final expenses = expSnap.data ?? [];
                            final settlements = setSnap.data ?? [];

                            const pricePerEgg = 0.40;
                            final totalEggs = eggs.fold(0, (s, e) => s + e.eggsCollected);
                            final totalRevenue = totalEggs * pricePerEgg;
                            final totalExpenses = expenses.fold(0.0, (s, e) => s + e.amount);
                            final totalCollections = settlements.where((s) => s.settlementType == 'COLLECTION').fold(0.0, (s, st) => s + st.amount);
                            final totalPayments = settlements.where((s) => s.settlementType == 'PAYMENT').fold(0.0, (s, st) => s + st.amount);
                            final netCashflow = totalRevenue + totalCollections - totalExpenses - totalPayments;
                            final stockValue = inventory.fold(0.0, (s, i) => s + (i.stockLevel * (i.costPerUnit ?? 0.0)));
                            final totalReceivables = customers.where((c) => c.customerType == 'CUSTOMER').fold(0.0, (s, c) => s + c.balanceOwed);
                            final totalPayables = customers.where((c) => c.customerType == 'SUPPLIER').fold(0.0, (s, c) => s + c.balanceOwed);

                            final now = DateTime.now();
                            final monthlyData = List.generate(6, (i) {
                              final month = DateTime(now.year, now.month - (5 - i), 1);
                              final monthEggs = eggs
                                  .where((e) => e.logDate.year == month.year && e.logDate.month == month.month)
                                  .fold(0, (s, e) => s + e.eggsCollected);
                              return FlSpot(i.toDouble(), (monthEggs * pricePerEgg));
                            });

                            final monthLabels = List.generate(6, (i) {
                              final month = DateTime(now.year, now.month - (5 - i), 1);
                              return DateFormat('MMM').format(month);
                            });

                            return Scaffold(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              body: SingleChildScrollView(
                                padding: EdgeInsets.all(isNarrow ? 16 : 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Financial Control', style: TextStyle(fontSize: isNarrow ? 24 : 28, fontWeight: FontWeight.w900)),
                                    Text('Operational insight & performance metrics', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                                    const SizedBox(height: 32),
                                    
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        SizedBox(
                                          width: isNarrow ? (constraints.maxWidth - 32) : (constraints.maxWidth - 64 - 32) / 3,
                                          child: _kpiCard('Net Cashflow', currency.format(netCashflow), Icons.account_balance_rounded, netCashflow >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626), 'Actual liquid cash position'),
                                        ),
                                        SizedBox(
                                          width: isNarrow ? (constraints.maxWidth - 32) : (constraints.maxWidth - 64 - 32) / 3,
                                          child: _kpiCard('Total Outflow', currency.format(totalExpenses + totalPayments), Icons.trending_down_rounded, const Color(0xFFDC2626), 'Expenses + Supplier payments'),
                                        ),
                                        SizedBox(
                                          width: isNarrow ? (constraints.maxWidth - 32) : (constraints.maxWidth - 64 - 32) / 3,
                                          child: _kpiCard('Estimated Revenue', currency.format(totalRevenue), Icons.analytics_rounded, const Color(0xFF2563EB), 'Based on egg production value'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        SizedBox(
                                          width: isNarrow ? (constraints.maxWidth - 32) : (constraints.maxWidth - 64 - 16) / 3,
                                          child: _kpiCard('Total Receivables', currency.format(totalReceivables), Icons.call_received_rounded, Colors.orange, 'Owed by customers'),
                                        ),
                                        SizedBox(
                                          width: isNarrow ? (constraints.maxWidth - 32) : (constraints.maxWidth - 64 - 16) / 3,
                                          child: _kpiCard('Total Payables', currency.format(totalPayables), Icons.call_made_rounded, Colors.purpleAccent, 'Owed to suppliers'),
                                        ),
                                        SizedBox(
                                          width: isNarrow ? (constraints.maxWidth - 32) : (constraints.maxWidth - 64 - 16) / 3,
                                          child: _kpiCard('Inventory Value', currency.format(stockValue), Icons.inventory_2_rounded, const Color(0xFF3B82F6), 'Value of current stock'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),

                                    if (!isNarrow)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(flex: 2, child: _buildProductionChart(monthlyData, monthLabels)),
                                          const SizedBox(width: 24),
                                          Expanded(flex: 1, child: _buildStockSummary(inventory)),
                                        ],
                                      )
                                    else ...[
                                      _buildProductionChart(monthlyData, monthLabels),
                                      const SizedBox(height: 24),
                                      _buildStockSummary(inventory),
                                    ],
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                              floatingActionButton: FloatingActionButton.extended(
                                onPressed: () => _showExpenseDialog(customers),
                                backgroundColor: const Color(0xFF16A34A),
                                icon: const Icon(Icons.add_rounded, color: Colors.white),
                                label: const Text('Add Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color, String subtitle) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: cs.onSurface)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
        ]),
      );
    });
  }

  Widget _buildProductionChart(List<FlSpot> data, List<String> labels) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Revenue Trend (Last 6 Months)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 24),
        SizedBox(
          height: 250,
          child: LineChart(LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  if (v.toInt() < 0 || v.toInt() >= labels.length) return const SizedBox();
                  return Text(labels[v.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                },
              )),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: true,
                color: const Color(0xFF16A34A),
                barWidth: 4,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: true, color: const Color(0xFF16A34A).withValues(alpha: 0.1)),
              ),
            ],
          )),
        ),
      ]),
    );
  }

  Widget _buildStockSummary(List<InventoryItem> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Stock Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No inventory records found', style: TextStyle(color: Colors.grey))))
        else
          ...items.take(5).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${item.stockLevel} ${item.unit}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )),
      ]),
    );
  }

  void _showExpenseDialog(List<Customer> allContacts) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Feed';
    final categories = ['Feed', 'Medication', 'Labor', 'Fuel', 'Utility', 'Other'];
    
    final suppliers = allContacts.where((c) => c.customerType == 'SUPPLIER').toList();
    Customer? selectedSupplier;
    bool isCredit = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Record New Expense', style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TRANSACTION DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueAccent, letterSpacing: 1)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                  decoration: const InputDecoration(labelText: 'Expense Category', prefixIcon: Icon(Icons.category_outlined)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount (GH₵)', prefixText: 'GH₵ ', prefixIcon: Icon(Icons.payments_outlined)),
                ),
                const SizedBox(height: 24),
                const Text('SUPPLIER LINKAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueAccent, letterSpacing: 1)),
                const SizedBox(height: 12),
                DropdownButtonFormField<Customer?>(
                  initialValue: selectedSupplier,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('No Supplier (General Expense)')),
                    ...suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))),
                  ],
                  onChanged: (v) => setState(() => selectedSupplier = v),
                  decoration: const InputDecoration(labelText: 'Select Supplier', prefixIcon: Icon(Icons.person_outline)),
                ),
                if (selectedSupplier != null) ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Buy on Credit?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Increases your debt to this supplier', style: TextStyle(fontSize: 11)),
                    value: isCredit,
                    onChanged: (val) => setState(() => isCredit = val),
                    secondary: const Icon(Icons.credit_card_rounded),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Notes / Specifics', prefixIcon: Icon(Icons.edit_note_rounded)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            FilledButton(
              onPressed: () async {
                final ctx = context;
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount <= 0) return;

                final farmId = await FarmUtils.getBoundFarmId();
                if (farmId == null) return;

                final String finalDesc = isCredit 
                  ? "[CREDIT PURCHASE] ${descriptionController.text} - ${selectedSupplier?.name ?? ''}"
                  : descriptionController.text;

                await db.into(db.expenses).insert(ExpensesCompanion.insert(
                  farmId: farmId,
                  category: selectedCategory,
                  amount: amount,
                  date: Value(DateTime.now()),
                  description: Value(finalDesc.isEmpty ? null : finalDesc),
                  synced: const Value(false),
                ));

                if (isCredit && selectedSupplier != null) {
                  final newBalance = selectedSupplier!.balanceOwed + amount;
                  await db.update(db.customers).replace(
                    selectedSupplier!.copyWith(
                      balanceOwed: newBalance,
                      updatedAt: DateTime.now(),
                      synced: false,
                    ),
                  );
                  
                  await db.into(db.settlements).insert(SettlementsCompanion.insert(
                    farmId: farmId,
                    customerId: selectedSupplier!.id,
                    amount: amount,
                    settlementDate: Value(DateTime.now()),
                    settlementType: 'DEBT_INCURRED',
                    synced: const Value(false),
                  ));
                }

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(isCredit ? 'Credit purchase recorded' : 'Expense recorded successfully')),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: isCredit ? Colors.orangeAccent : const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(isCredit ? 'RECORD DEBT' : 'SAVE EXPENSE', style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}
