import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _CustomerDirectoryScreenState extends State<CustomerDirectoryScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late AppDatabase db;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
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
    final supplyItemsCtrl = TextEditingController(text: customer?.supplyItems ?? '');
    final contactPersonCtrl = TextEditingController(text: customer?.contactPerson ?? '');
    String selectedType = customer?.customerType ?? 'CUSTOMER';
    final formKey = GlobalKey<FormState>();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 600,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 20)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogHeader(
                      icon: customer == null ? Icons.person_add_rounded : Icons.edit_note_rounded,
                      title: customer == null ? 'ADD NEW CONTACT' : 'EDIT CONTACT INFO',
                      subtitle: 'RELATIONSHIP MANAGEMENT',
                      color: const Color(0xFF10B981),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CONTACT CATEGORY', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildTypeToggle('CUSTOMER', 'Customer', Icons.person_outline, selectedType, (val) => setDialogState(() => selectedType = val)),
                                  ),
                                  Expanded(
                                    child: _buildTypeToggle('SUPPLIER', 'Supplier', Icons.local_shipping_outlined, selectedType, (val) => setDialogState(() => selectedType = val)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildDialogInputField('Full Name', 'e.g. John Doe', nameCtrl, Icons.person_rounded, required: true),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildDialogInputField('Phone Number', '+233...', phoneCtrl, Icons.phone_rounded, required: true)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDialogInputField('Balance (GH₵)', '0.00', balanceCtrl, Icons.payments_rounded, isNumber: true)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildDialogInputField('Email Address', 'optional@example.com', emailCtrl, Icons.email_rounded),
                            const SizedBox(height: 16),
                            _buildDialogInputField('Address', 'Physical location...', addressCtrl, Icons.location_on_rounded),
                            if (selectedType == 'SUPPLIER') ...[
                              const SizedBox(height: 16),
                              const Divider(height: 32),
                              const Text('SUPPLIER DETAILS', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                              const SizedBox(height: 16),
                              _buildDialogInputField('Items Supplied', 'e.g. Feed, Chicks, Vaccines', supplyItemsCtrl, Icons.inventory_2_rounded),
                              const SizedBox(height: 16),
                              _buildDialogInputField('Primary Contact Person', 'Name of rep...', contactPersonCtrl, Icons.badge_rounded),
                            ],
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w800, letterSpacing: 1)),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: FilledButton(
                                    onPressed: () async {
                                      if (!formKey.currentState!.validate()) return;
                                      final companion = CustomersCompanion(
                                        farmId: Value(farmId),
                                        name: Value(nameCtrl.text),
                                        phone: Value(phoneCtrl.text.isEmpty ? null : phoneCtrl.text),
                                        email: Value(emailCtrl.text.isEmpty ? null : emailCtrl.text),
                                        address: Value(addressCtrl.text.isEmpty ? null : addressCtrl.text),
                                        customerType: Value(selectedType),
                                        balanceOwed: Value(double.tryParse(balanceCtrl.text) ?? 0.0),
                                        supplyItems: Value(supplyItemsCtrl.text.isEmpty ? null : supplyItemsCtrl.text),
                                        contactPerson: Value(contactPersonCtrl.text.isEmpty ? null : contactPersonCtrl.text),
                                        synced: const Value(false),
                                        updatedAt: Value(DateTime.now()),
                                      );
                                      final syncEngine = Provider.of<SyncEngine>(context, listen: false);
                                      if (customer == null) {
                                        await db.into(db.customers).insert(companion);
                                      } else {
                                        await (db.update(db.customers)..where((t) => t.id.equals(customer.id))).write(companion);
                                      }
                                      if (ctx.mounted) Navigator.pop(ctx);
                                      setState(() {});
                                      syncEngine.syncNow();
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(customer == null ? 'ADD CONTACT' : 'SAVE CHANGES', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle(String value, String label, IconData icon, String selected, Function(String) onSelect) {
    bool isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF94A3B8), fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInputField(String label, String hint, TextEditingController controller, IconData icon, {bool required = false, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : [],
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
            contentPadding: const EdgeInsets.all(18),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Contact', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to delete "${customer.name}"?', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('CANCEL', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
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
                if (isNarrow)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Directory', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _showCustomerDialog(),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('ADD CONTACT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Directory', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Text('Manage your customers and suppliers', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: () => _showCustomerDialog(),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('ADD CONTACT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),

                // Tabs and Search
                if (isNarrow)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5),
                          tabs: const [Tab(text: 'CUSTOMERS'), Tab(text: 'SUPPLIERS')],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _searchController,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search contacts...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Container(
                        width: 400,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5),
                          tabs: const [Tab(text: 'CUSTOMERS'), Tab(text: 'SUPPLIERS')],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Search contacts...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),

                // Table
                Expanded(
                  child: StreamBuilder<List<Customer>>(
                    stream: db.select(db.customers).watch(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
                      }
                      final all = snapshot.data ?? [];
                      
                      List<Customer> categoryFiltered = all;
                      if (_tabController.index == 0) {
                        categoryFiltered = all.where((c) => c.customerType == 'CUSTOMER').toList();
                      } else {
                        categoryFiltered = all.where((c) => c.customerType == 'SUPPLIER').toList();
                      }

                      final filtered = categoryFiltered.where((c) {
                        final q = _searchQuery.toLowerCase();
                        return q.isEmpty ||
                            c.name.toLowerCase().contains(q) ||
                            (c.phone?.toLowerCase().contains(q) ?? false) ||
                            (c.email?.toLowerCase().contains(q) ?? false);
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), shape: BoxShape.circle),
                              child: Icon(Icons.person_search_rounded, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 20),
                            Text(_searchQuery.isEmpty ? 'No contacts found.' : 'No results for "$_searchQuery".',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w600)),
                          ]),
                        );
                      }

                      final totalBalance = filtered.fold(0.0, (sum, c) => sum + c.balanceOwed);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Strip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05)),
                            ),
                            child: Wrap(
                              spacing: 32,
                              runSpacing: 16,
                              children: [
                                _summaryChip(Icons.people_rounded, 'TOTAL ${_tabController.index == 0 ? "CUSTOMERS" : "SUPPLIERS"}', '${filtered.length}', _tabController.index == 0 ? Colors.blue : Colors.indigo),
                                _summaryChip(
                                  _tabController.index == 0 ? Icons.account_balance_wallet_rounded : Icons.payments_rounded,
                                  _tabController.index == 0 ? 'TOTAL TO COLLECT' : 'TOTAL TO PAY',
                                  currency.format(totalBalance),
                                  _tabController.index == 0 ? Colors.orange : Colors.purpleAccent,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Data table
                          // Table Card - Full Width Focus
                          Expanded(
                            child: Card(
                              elevation: 4,
                              shadowColor: Colors.black.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                              ),
                              color: Theme.of(context).cardColor,
                              margin: EdgeInsets.zero,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: constraints.maxWidth - (isNarrow ? 32 : 64)),
                                      child: DataTable(
                                        headingRowHeight: 64,
                                        dataRowMinHeight: 72,
                                        dataRowMaxHeight: 72,
                                        horizontalMargin: 32,
                                        headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                                        columnSpacing: 40,
                                        columns: [
                                          DataColumn(label: Text('CONTACT NAME', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                          if (_tabController.index == 0) ...[
                                            DataColumn(label: Text('PHONE', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                            DataColumn(label: Text('EMAIL', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                            DataColumn(label: Text('ADDRESS', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                            DataColumn(label: Text('RECEIVABLE', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                          ] else ...[
                                            DataColumn(label: Text('SUPPLY ITEMS', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                            DataColumn(label: Text('CONTACT PERSON', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                            DataColumn(label: Text('PHONE', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                            DataColumn(label: Text('DEBT / PAYABLE', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                          ],
                                          DataColumn(label: Text('ACTIONS', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
                                        ],
                                        rows: filtered.map((c) => DataRow(cells: [
                                          DataCell(Row(children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: (c.customerType == 'SUPPLIER' ? Colors.blue : const Color(0xFF10B981)).withValues(alpha: 0.15),
                                              child: Text(c.name[0].toUpperCase(), style: TextStyle(color: c.customerType == 'SUPPLIER' ? Colors.blue : const Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 11)),
                                            ),
                                            const SizedBox(width: 14),
                                            Text(c.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)),
                                          ])),
                                          if (_tabController.index == 0) ...[
                                            DataCell(Text(c.phone ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500))),
                                            DataCell(Text(c.email ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13))),
                                            DataCell(Text(c.address ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13))),
                                            DataCell(Text(
                                              currency.format(c.balanceOwed),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: c.balanceOwed > 0 ? Colors.orangeAccent : const Color(0xFF10B981),
                                              ),
                                            )),
                                          ] else ...[
                                            DataCell(Text(c.supplyItems ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13))),
                                            DataCell(Text(c.contactPerson ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13))),
                                            DataCell(Text(c.phone ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500))),
                                            DataCell(Text(
                                              currency.format(c.balanceOwed),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: c.balanceOwed > 0 ? Colors.purpleAccent : const Color(0xFF10B981),
                                              ),
                                            )),
                                          ],
                                          DataCell(Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (c.balanceOwed > 0)
                                                IconButton(
                                                  icon: Icon(_tabController.index == 0 ? Icons.account_balance_wallet_rounded : Icons.payments_rounded, size: 18), 
                                                  color: _tabController.index == 0 ? Colors.orangeAccent : Colors.purpleAccent, 
                                                  onPressed: () => _showSettleDialog(c), 
                                                  tooltip: _tabController.index == 0 ? 'Collect Balance' : 'Pay Debt'
                                                ),
                                              IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: const Color(0xFF3B82F6), onPressed: () => _showCustomerDialog(customer: c), tooltip: 'Edit'),
                                              const SizedBox(width: 8),
                                              IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18), color: Colors.redAccent.withValues(alpha: 0.7), onPressed: () => _deleteCustomer(c), tooltip: 'Delete'),
                                            ],
                                          )),
                                        ])).toList(),
                                      ),
                                    ),
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
          );
        },
      ),
    );
  }

  Future<void> _showSettleDialog(Customer customer) async {
    final TextEditingController amountController = TextEditingController();
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.payments_rounded, color: Colors.orangeAccent),
            const SizedBox(width: 12),
            const Text('Settle Balance', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${customer.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Current Balance: ${currency.format(customer.balanceOwed)}', 
              style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                hintText: 'Enter amount paid',
                prefixText: 'GH₵ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => amountController.text = customer.balanceOwed.toString(),
                  child: const Text('Pay Full Amount'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final ctx = context;
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0) return;
              
              final newBalance = customer.balanceOwed - amount;
              
              await db.update(db.customers).replace(
                customer.copyWith(
                  balanceOwed: newBalance < 0 ? 0 : newBalance,
                  updatedAt: DateTime.now(),
                  synced: false,
                ),
              );

              // Log the settlement
              await db.into(db.settlements).insert(SettlementsCompanion.insert(
                farmId: customer.farmId,
                customerId: customer.id,
                amount: amount,
                settlementDate: Value(DateTime.now()),
                settlementType: customer.customerType == 'SUPPLIER' ? 'PAYMENT' : 'COLLECTION',
                synced: const Value(false),
              ));
              
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Payment of ${currency.format(amount)} recorded for ${customer.name}')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
      ],
    );
  }

}
