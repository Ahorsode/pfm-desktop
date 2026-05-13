import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';

class CustomerDirectoryScreen extends StatefulWidget {
  const CustomerDirectoryScreen({super.key});

  @override
  State<CustomerDirectoryScreen> createState() => _CustomerDirectoryScreenState();
}

class _CustomerDirectoryScreenState extends State<CustomerDirectoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late AppDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<int> _getFarmId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bound_farm_id') ?? 0;
  }

  Future<void> _showCustomerDialog({Customer? customer}) async {
    final farmId = await _getFarmId();
    final nameCtrl = TextEditingController(text: customer?.name ?? '');
    final phoneCtrl = TextEditingController(text: customer?.phone ?? '');
    final emailCtrl = TextEditingController(text: customer?.email ?? '');
    final addressCtrl = TextEditingController(text: customer?.address ?? '');
    final balanceCtrl = TextEditingController(text: customer?.balanceOwed.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          customer == null ? 'Add Customer' : 'Edit Customer',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(nameCtrl, 'Full Name', Icons.person_rounded, required: true),
                const SizedBox(height: 12),
                _buildField(phoneCtrl, 'Phone Number', Icons.phone_rounded),
                const SizedBox(height: 12),
                _buildField(emailCtrl, 'Email Address', Icons.email_rounded),
                const SizedBox(height: 12),
                _buildField(addressCtrl, 'Address', Icons.location_on_rounded),
                const SizedBox(height: 12),
                _buildField(balanceCtrl, 'Balance Owed', Icons.payments_rounded, isNumber: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final companion = CustomersCompanion(
                farmId: Value(farmId),
                name: Value(nameCtrl.text),
                phone: Value(phoneCtrl.text.isEmpty ? null : phoneCtrl.text),
                email: Value(emailCtrl.text.isEmpty ? null : emailCtrl.text),
                address: Value(addressCtrl.text.isEmpty ? null : addressCtrl.text),
                balanceOwed: Value(double.tryParse(balanceCtrl.text) ?? 0.0),
                synced: const Value(false),
              );
              if (customer == null) {
                await db.into(db.customers).insert(companion);
              } else {
                await (db.update(db.customers)..where((t) => t.id.equals(customer.id))).write(companion);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
              if (mounted) {
                Provider.of<SyncEngine>(context, listen: false).syncNow();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: Text(customer == null ? 'Add Customer' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool required = false, bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: required ? (v) => (v == null || v.isEmpty) ? '$label is required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete "${customer.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await (db.delete(db.customers)..where((t) => t.id.equals(customer.id))).go();
      setState(() {});
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer Directory',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    Text('Manage your customer relationships',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => _showCustomerDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Customer'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or email...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Table
            Expanded(
              child: StreamBuilder<List<Customer>>(
                stream: db.select(db.customers).watch(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snapshot.data ?? [];
                  final filtered = all.where((c) {
                    final q = _searchQuery.toLowerCase();
                    return q.isEmpty ||
                        c.name.toLowerCase().contains(q) ||
                        (c.phone?.toLowerCase().contains(q) ?? false) ||
                        (c.email?.toLowerCase().contains(q) ?? false);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.people_alt_rounded, size: 64, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(_searchQuery.isEmpty ? 'No customers yet.' : 'No results for "$_searchQuery".',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16)),
                        if (_searchQuery.isEmpty)
                          TextButton(onPressed: () => _showCustomerDialog(), child: const Text('Add your first customer →')),
                      ]),
                    );
                  }

                  final totalBalance = all.fold(0.0, (sum, c) => sum + (c.balanceOwed ?? 0.0));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF15803D)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _summaryChip(Icons.people_rounded, 'Total Customers', '${all.length}'),
                            const SizedBox(width: 32),
                            _summaryChip(Icons.payments_rounded, 'Total Outstanding', currency.format(totalBalance)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Data table
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)),
                                columns: const [
                                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
                                  DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.w700))),
                                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.w700))),
                                  DataColumn(label: Text('Balance Owed', style: TextStyle(fontWeight: FontWeight.w700))),
                                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
                                ],
                                rows: filtered.map((c) => DataRow(cells: [
                                  DataCell(Row(children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(0xFF16A34A).withOpacity(0.1),
                                      child: Text(c.name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ])),
                                  DataCell(Text(c.phone ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                  DataCell(Text(c.email ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                  DataCell(Text(
                                    currency.format(c.balanceOwed ?? 0),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: (c.balanceOwed ?? 0) > 0 ? Colors.orange[700] : Colors.green[700],
                                    ),
                                  )),
                                  DataCell(Row(children: [
                                    IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: Colors.blue, onPressed: () => _showCustomerDialog(customer: c), tooltip: 'Edit'),
                                    IconButton(icon: const Icon(Icons.delete_rounded, size: 18), color: Colors.red, onPressed: () => _deleteCustomer(c), tooltip: 'Delete'),
                                  ])),
                                ])).toList(),
                              ),
                            ),
                          ),
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

  Widget _summaryChip(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: Colors.white70, size: 20),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
      ]),
    ]);
  }
}
