import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late AppDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
  }

  Future<int> _getFarmId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bound_farm_id') ?? 0;
  }

  Future<void> _showSaleDialog(List<Customer> customers, List<Batch> batches) async {
    final farmId = await _getFarmId();
    Customer? selectedCustomer;
    Batch? selectedBatch;
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Record Sale', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Customer>(
                  decoration: InputDecoration(
                    labelText: 'Customer',
                    prefixIcon: const Icon(Icons.person_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: customers.map((c) => DropdownMenuItem<Customer>(value: c, child: Text(c.name))).toList(),
                  onChanged: (v) => setDlgState(() => selectedCustomer = v),
                  validator: (v) => v == null ? 'Please select a customer' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Batch>(
                  decoration: InputDecoration(
                    labelText: 'Batch',
                    prefixIcon: const Icon(Icons.inventory_2_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: batches.map((b) => DropdownMenuItem<Batch>(value: b, child: Text(b.batchName ?? 'Unnamed'))).toList(),
                  onChanged: (v) => setDlgState(() => selectedBatch = v),
                  validator: (v) => v == null ? 'Please select a batch' : null,
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextFormField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: const Icon(Icons.numbers_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    decoration: InputDecoration(
                      labelText: 'Unit Price (GHS)',
                      prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )),
                ]),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final qty = int.tryParse(qtyCtrl.text) ?? 0;
              final price = double.tryParse(priceCtrl.text) ?? 0.0;
              final total = qty * price;

              // Update customer's balance
              if (selectedCustomer != null) {
                await (db.update(db.customers)..where((t) => t.id.equals(selectedCustomer!.id))).write(
                  CustomersCompanion(balanceOwed: Value((selectedCustomer!.balanceOwed ?? 0.0) + total), synced: const Value(false)),
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
              if (mounted) Provider.of<SyncEngine>(context, listen: false).syncNow();
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Record Sale'),
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'GHS ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            StreamBuilder<List<Customer>>(
              stream: db.select(db.customers).watch(),
              builder: (context, custSnap) {
                return StreamBuilder<List<Batch>>(
                  stream: db.select(db.batches).watch(),
                  builder: (context, batchSnap) {
                    final customers = custSnap.data ?? [];
                    final batches = batchSnap.data ?? [];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sales Management',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                            Text('Track transactions and outstanding balances',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: customers.isEmpty ? null : () => _showSaleDialog(customers, batches),
                          icon: const Icon(Icons.add),
                          label: const Text('Record Sale'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 28),

            // Customer balance cards
            Expanded(
              child: StreamBuilder<List<Customer>>(
                stream: db.select(db.customers).watch(),
                builder: (context, snapshot) {
                  final customers = snapshot.data ?? [];
                  final totalBalance = customers.fold(0.0, (s, c) => s + (c.balanceOwed ?? 0.0));
                  final overdue = customers.where((c) => (c.balanceOwed ?? 0.0) > 0).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary strip
                      Row(children: [
                        Expanded(child: _statCard('Total Customers', '${customers.length}', Icons.people_rounded, const Color(0xFF3B82F6))),
                        const SizedBox(width: 16),
                        Expanded(child: _statCard('Customers with Balance', '${overdue.length}', Icons.warning_amber_rounded, const Color(0xFFF59E0B))),
                        const SizedBox(width: 16),
                        Expanded(child: _statCard('Total Outstanding', currency.format(totalBalance), Icons.payments_rounded, const Color(0xFF16A34A))),
                      ]),
                      const SizedBox(height: 24),

                      Text('Outstanding Balances',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 12),

                      // List
                      Expanded(
                        child: customers.isEmpty
                            ? Center(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.receipt_long_rounded, size: 64, color: Theme.of(context).colorScheme.outline),
                                  const SizedBox(height: 16),
                                  Text('No customers found. Add customers in the Customer Directory.',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15)),
                                ]),
                              )
                            : ListView.separated(
                                itemCount: customers.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final c = customers[i];
                                  final balance = c.balanceOwed ?? 0.0;
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: balance > 0 ? Colors.orange.withOpacity(0.3) : Theme.of(context).colorScheme.outline,
                                      ),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: const Color(0xFF16A34A).withOpacity(0.1),
                                          child: Text(c.name[0].toUpperCase(),
                                              style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 18)),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                            Text(c.phone ?? c.email ?? 'No contact info',
                                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                                          ]),
                                        ),
                                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                          Text(currency.format(balance),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: balance > 0 ? Colors.orange[700] : Colors.green[700],
                                              )),
                                          Text(balance > 0 ? 'Outstanding' : 'Settled',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: balance > 0 ? Colors.orange[400] : Colors.green[500],
                                              )),
                                        ]),
                                        const SizedBox(width: 16),
                                        if (balance > 0)
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
                                            tooltip: 'Mark as Settled',
                                            onPressed: () async {
                                              await (db.update(db.customers)..where((t) => t.id.equals(c.id))).write(
                                                const CustomersCompanion(balanceOwed: Value(0.0), synced: Value(false)),
                                              );
                                              setState(() {});
                                            },
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
        ]),
      ]),
    );
  }
}
