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
    if (!context.mounted) return;
    Customer? selectedCustomer;
    Batch? selectedBatch;
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    if (!context.mounted) return;
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
                  items: customers.map((c) => DropdownMenuItem<Customer>(
                    value: c, 
                    child: Text(c.name),
                  )).toList(),
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
                  items: batches.map((b) => DropdownMenuItem<Batch>(value: b, child: Text(b.batchName))).toList(),
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

              final syncEngine = Provider.of<SyncEngine>(context, listen: false);
              final farmId = await _getFarmId();

              // 1. Insert sale record
              await db.into(db.sales).insert(SalesCompanion.insert(
                farmId: farmId,
                batchId: Value(selectedBatch!.id),
                customerId: Value(selectedCustomer!.id),
                quantity: qty,
                unitPrice: price,
                totalAmount: total,
                saleDate: Value(DateTime.now()),
                synced: const Value(false),
              ));

              // 2. Update customer's balance
              if (selectedCustomer != null) {
                await (db.update(db.customers)..where((t) => t.id.equals(selectedCustomer!.id))).write(
                  CustomersCompanion(balanceOwed: Value(selectedCustomer!.balanceOwed + total), synced: const Value(false)),
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
              syncEngine.syncNow();
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Record Sale'),
          ),
        ],
      )),
    );
  }

  Future<void> _showSettleDialog(Customer customer) async {
    final balance = customer.balanceOwed;
    final paymentCtrl = TextEditingController();
    double amountToPay = 0.0;
    final formKey = GlobalKey<FormState>();
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.orange, size: 22),
              ),
              const SizedBox(width: 16),
              const Text('Settle Balance', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Current Balance: ${currency.format(balance)}', 
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 24),
                  
                  Text('PAYMENT AMOUNT', style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: paymentCtrl,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                    decoration: InputDecoration(
                      prefixText: 'GH₵ ',
                      hintText: '0.00',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.auto_fix_high_rounded, color: Colors.orange),
                        tooltip: 'Pay Full Amount',
                        onPressed: () {
                          paymentCtrl.text = balance.toStringAsFixed(2);
                          setDlgState(() => amountToPay = balance);
                        },
                      ),
                    ),
                    onChanged: (v) {
                      setDlgState(() => amountToPay = double.tryParse(v) ?? 0.0);
                    },
                    validator: (v) {
                      final val = double.tryParse(v ?? '') ?? 0.0;
                      if (val <= 0) return 'Enter a valid amount';
                      if (val > balance + 0.01) return 'Cannot pay more than balance';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Live math preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        _dialogMathRow('Original Balance', currency.format(balance)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1),
                        ),
                        _dialogMathRow('Payment Amount', '- ${currency.format(amountToPay)}', isNegative: true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1, thickness: 2),
                        ),
                        _dialogMathRow('New Balance', currency.format(balance - amountToPay), isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                
                final newBalance = balance - amountToPay;
                final syncEngine = Provider.of<SyncEngine>(context, listen: false);

                await (db.update(db.customers)..where((t) => t.id.equals(customer.id))).write(
                  CustomersCompanion(
                    balanceOwed: Value(newBalance < 0.01 ? 0.0 : newBalance),
                    synced: const Value(false),
                    updatedAt: Value(DateTime.now()),
                  ),
                );
                
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() {});
                syncEngine.syncNow();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('CONFIRM PAYMENT', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogMathRow(String label, String value, {bool isNegative = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.normal)),
        Text(value, style: TextStyle(
          color: isNegative ? Colors.redAccent : (isBold ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant),
          fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          fontSize: isBold ? 15 : 13,
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isNarrow = constraints.maxWidth < 850;

          return Padding(
            padding: EdgeInsets.all(isNarrow ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                StreamBuilder<List<Customer>>(
                  stream: (db.select(db.customers)..where((t) => t.customerType.equals('CUSTOMER'))).watch(),
                  builder: (context, custSnap) {
                    return StreamBuilder<List<Batch>>(
                      stream: db.select(db.batches).watch(),
                      builder: (context, batchSnap) {
                        final customers = custSnap.data ?? [];
                        final batches = batchSnap.data ?? [];
                        
                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sales Management',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: customers.isEmpty ? null : () => _showSaleDialog(customers, batches),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Record Sale'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

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
                    stream: (db.select(db.customers)..where((t) => t.customerType.equals('CUSTOMER'))).watch(),
                    builder: (context, snapshot) {
                      final customers = snapshot.data ?? [];
                      final totalBalance = customers.fold(0.0, (s, c) => s + (c.balanceOwed));
                      final overdue = customers.where((c) => (c.balanceOwed) > 0).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary strip
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _statCard('Total Customers', '${customers.length}', Icons.people_rounded, const Color(0xFF3B82F6), isNarrow),
                              _statCard('Customers with Balance', '${overdue.length}', Icons.warning_amber_rounded, const Color(0xFFF59E0B), isNarrow),
                              _statCard('Total Outstanding', currency.format(totalBalance), Icons.payments_rounded, const Color(0xFF16A34A), isNarrow),
                            ],
                          ),
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
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15)),
                                    ]),
                                  )
                                : ListView.separated(
                                    itemCount: customers.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                                    itemBuilder: (context, i) {
                                      final c = customers[i];
                                      final balance = c.balanceOwed;
                                      return Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: balance > 0 ? Colors.orange.withValues(alpha: 0.3) : Theme.of(context).colorScheme.outline,
                                          ),
                                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.1),
                                              child: Text(c.name[0].toUpperCase(),
                                                  style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 16)),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis),
                                                Text(c.phone ?? c.email ?? 'No contact info',
                                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), overflow: TextOverflow.ellipsis),
                                              ]),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                              Text(currency.format(balance),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 14,
                                                    color: balance > 0 ? Colors.orange[700] : Colors.green[700],
                                                  )),
                                              Text(balance > 0 ? 'Outstanding' : 'Settled',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: balance > 0 ? Colors.orange[400] : Colors.green[500],
                                                  )),
                                            ]),
                                            const SizedBox(width: 8),
                                            if (balance > 0)
                                              IconButton(
                                                icon: const Icon(Icons.payment_rounded, color: Colors.orange, size: 20),
                                                tooltip: 'Settle Balance',
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () => _showSettleDialog(c),
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
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, bool isCompact) {
    return Container(
      width: isCompact ? double.infinity : 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: isCompact ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), overflow: TextOverflow.ellipsis),
              Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis),
            ]),
          ),
        ],
      ),
    );
  }

}
