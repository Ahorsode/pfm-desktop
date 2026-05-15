import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift hide Column;
import '../utils/farm_utils.dart';
import '../data/sync_engine.dart';
import '../data/local_db.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _auditLogs = [];
  List<Map<String, dynamic>> _deleteLogs = [];
  List<Map<String, dynamic>> _financialLogs = [];
  List<Map<String, dynamic>> _stockLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      if (mounted) {
        await context.read<SyncEngine>().performSync();
      }

      final farmId = await FarmUtils.getBoundFarmId();
      if (farmId == null) return;

      // 1. Fetch Edit Logs
      final auditData = await _supabase
          .from('audit_logs')
          .select('*, users(firstname, surname, email)')
          .eq('farm_id', farmId)
          .order('created_at', ascending: false)
          .limit(100);

      // 2. Fetch Delete Logs
      final deleteData = await _supabase
          .from('delete_logs')
          .select('*, users(firstname, surname, email)')
          .eq('farm_id', farmId)
          .order('deleted_at', ascending: false)
          .limit(100);

      // Map audit logs
      final List<Map<String, dynamic>> combined = [];
      
      for (var row in auditData) {
        combined.add({
          ...row,
          'type': 'UPDATE',
          'display_date': row['created_at'],
          'display_table': row['table_name'],
        });
      }

      setState(() {
        _auditLogs = combined;
        _deleteLogs = List<Map<String, dynamic>>.from(deleteData);
      });

      await _fetchFinancialLogs();
      await _fetchStockLogs();
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFinancialLogs() async {
    final db = context.read<AppDatabase>();
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;

    final sales = await (db.select(db.sales)..where((t) => t.farmId.equals(farmId))).get();
    final expenses = await (db.select(db.expenses)..where((t) => t.farmId.equals(farmId))).get();
    final settlements = await (db.select(db.settlements)..where((t) => t.farmId.equals(farmId))).get();
    final customers = await (db.select(db.customers)..where((t) => t.farmId.equals(farmId))).get();

    final customerMap = {for (var c in customers) c.id: c.name};
    final List<Map<String, dynamic>> combined = [];

    for (var s in sales) {
      combined.add({
        'title': 'Sale Recorded',
        'subtitle': 'Quantity: ${s.quantity}',
        'amount': s.totalAmount,
        'date': s.saleDate,
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF16A34A),
        'details': 'Sale ID: ${s.id} • Unit Price: GH₵ ${s.unitPrice}',
        'is_income': true,
      });
    }

    for (var e in expenses) {
      combined.add({
        'title': 'Expense: ${e.category}',
        'subtitle': e.description ?? 'No description',
        'amount': e.amount,
        'date': e.date,
        'icon': Icons.trending_down_rounded,
        'color': const Color(0xFFDC2626),
        'details': 'Expense ID: ${e.id}',
        'is_income': false,
      });
    }

    for (var st in settlements) {
      final entityName = customerMap[st.customerId] ?? 'Unknown';
      String title = 'Settlement';
      String subtitle = 'Entity: $entityName';
      IconData icon = Icons.receipt_long_rounded;
      Color color = Colors.grey;
      bool isIncome = false;

      if (st.settlementType == 'COLLECTION') {
        title = 'Balance Collection';
        subtitle = 'From: $entityName';
        icon = Icons.account_balance_wallet_rounded;
        color = Colors.orange;
        isIncome = true;
      } else if (st.settlementType == 'PAYMENT') {
        title = 'Debt Payment';
        subtitle = 'To: $entityName';
        icon = Icons.payments_rounded;
        color = Colors.purpleAccent;
        isIncome = false;
      } else if (st.settlementType == 'DEBT_INCURRED') {
        title = 'Credit Purchase';
        subtitle = 'Debt to: $entityName';
        icon = Icons.credit_score_rounded;
        color = Colors.blueGrey;
        isIncome = false; // It's an obligation, not an immediate cash outflow, but recorded as an expense
      }

      combined.add({
        'title': title,
        'subtitle': subtitle,
        'amount': st.amount,
        'date': st.settlementDate,
        'icon': icon,
        'color': color,
        'details': 'Settlement ID: ${st.id} • Type: ${st.settlementType}',
        'is_income': isIncome,
      });
    }

    combined.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    setState(() {
      _financialLogs = combined;
    });
  }

  Future<void> _fetchStockLogs() async {
    final db = context.read<AppDatabase>();
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;

    final logs = await (db.select(db.stockLogs)
          ..where((t) => t.farmId.equals(farmId))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.logDate, mode: drift.OrderingMode.desc)]))
        .get();

    final inventory = await (db.select(db.inventory)..where((t) => t.farmId.equals(farmId))).get();
    final inventoryMap = {for (var i in inventory) i.id: i.itemName};

    final List<Map<String, dynamic>> mappedLogs = [];
    for (var l in logs) {
      final itemName = inventoryMap[l.itemId] ?? 'Unknown Item';

      String title = 'Inventory Update';
      IconData icon = Icons.inventory_2_rounded;
      Color color = Colors.grey;

      if (l.logType == 'PROCURED') {
        title = 'Restock: $itemName';
        icon = Icons.add_shopping_cart_rounded;
        color = const Color(0xFF16A34A);
      } else if (l.logType == 'CONSUMED') {
        title = 'Usage: $itemName';
        icon = Icons.remove_shopping_cart_rounded;
        color = const Color(0xFFF59E0B);
      } else if (l.logType == 'ADJUSTED') {
        title = 'Adjustment: $itemName';
        icon = Icons.tune_rounded;
        color = const Color(0xFF3B82F6);
      }

      mappedLogs.add({
        'title': title,
        'subtitle': '${l.logType} • Qty: ${l.quantity.abs()}',
        'date': l.logDate,
        'icon': icon,
        'color': color,
        'details': 'Log ID: ${l.id}${l.note != null ? ' • Note: ${l.note}' : ''}',
      });
    }

    setState(() {
      _stockLogs = mappedLogs;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Audit Logs', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _fetchLogs,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Logs',
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1))),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Edits'),
                    Tab(text: 'Deletions'),
                    Tab(text: 'Financials'),
                    Tab(text: 'Inventory'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAuditList(),
                _buildDeleteList(),
                _buildFinancialList(),
                _buildStockList(),
              ],
            ),
    );
  }

  Widget _buildAuditList() {
    if (_auditLogs.isEmpty) {
      return _buildEmptyState('No audit logs found', Icons.history_rounded);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _auditLogs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = _auditLogs[index];
        final date = DateTime.parse(log['display_date']).toLocal();
        
        String user = 'System';
        if (log['users'] != null) {
          final userData = log['users'];
          final fname = userData['firstname'] ?? '';
          final sname = userData['surname'] ?? '';
          user = '$fname $sname'.trim();
          if (user.isEmpty) user = userData['email'] ?? 'Unknown User';
        }


        return _buildLogCard(
          title: 'Edit: ${log['display_table']}',
          subtitle: 'Modified by $user',
          date: DateFormat('MMM dd, yyyy • HH:mm').format(date),
          icon: Icons.edit_rounded,
          color: const Color(0xFFF59E0B),
          details: 'ID: ${log['record_id']} • ${log['attribute_name']} (${log['old_value'] ?? 'NULL'} -> ${log['new_value'] ?? 'NULL'})',
        );
      },
    );
  }

  Widget _buildDeleteList() {
    if (_deleteLogs.isEmpty) {
      return _buildEmptyState('No deletions found in vault', Icons.delete_outline_rounded);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _deleteLogs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = _deleteLogs[index];
        final date = DateTime.parse(log['deleted_at']).toLocal();

        String user = 'System';
        if (log['users'] != null) {
          final userData = log['users'];
          final fname = userData['firstname'] ?? '';
          final sname = userData['surname'] ?? '';
          user = '$fname $sname'.trim();
          if (user.isEmpty) user = userData['email'] ?? 'Unknown User';
        }

        return _buildLogCard(
          title: 'Deleted from ${log['table_name']}',
          subtitle: 'Deleted by $user',
          date: DateFormat('MMM dd, yyyy • HH:mm').format(date),
          icon: Icons.delete_forever_rounded,
          color: Colors.red,
          details: 'Log ID: ${log['id']}',
          trailing: FilledButton.icon(
            onPressed: () => _confirmRestore(log),
            icon: const Icon(Icons.restore_rounded, size: 16),
            label: const Text('Restore'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinancialList() {
    if (_financialLogs.isEmpty) {
      return _buildEmptyState('No financial logs found', Icons.account_balance_rounded);
    }

    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _financialLogs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = _financialLogs[index];
        final date = log['date'] as DateTime;
        final isIncome = log['is_income'] as bool;

        return _buildLogCard(
          title: log['title'],
          subtitle: log['subtitle'],
          date: DateFormat('MMM dd, yyyy • HH:mm').format(date),
          icon: log['icon'],
          color: log['color'],
          details: log['details'],
          trailing: Text(
            '${isIncome ? "+" : "-"}${currency.format(log['amount'])}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockList() {
    if (_stockLogs.isEmpty) {
      return _buildEmptyState('No inventory logs found', Icons.inventory_2_outlined);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _stockLogs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = _stockLogs[index];
        final date = log['date'] as DateTime;

        return _buildLogCard(
          title: log['title'],
          subtitle: log['subtitle'],
          date: DateFormat('MMM dd, yyyy • HH:mm').format(date),
          icon: log['icon'],
          color: log['color'],
          details: log['details'],
        );
      },
    );
  }

  Widget _buildLogCard({
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
    required Color color,
    required String details,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title, 
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5))),
                      const SizedBox(width: 8),
                      Text(date, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(details, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }


  Future<void> _confirmRestore(Map<String, dynamic> log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Record?'),
        content: Text('This will restore the deleted record from ${log['table_name']} with its original ID.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Confirm Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _performRestore(log);
    }
  }

  Future<void> _performRestore(Map<String, dynamic> log) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // In a production app, we would call a Supabase RPC that handles 
      // the JSON parsing, insertion, and sequence reset.
      // For now, we will notify the user that restoration is initiated.
      
      // Attempting to call the 'restore_deleted_record' RPC if it exists
      await _supabase.rpc('restore_deleted_record', params: {
        'p_delete_log_id': log['id'],
      });

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Record restored successfully'),
          backgroundColor: Color(0xFF16A34A),
        ));
        _fetchLogs();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Restoration failed: $e. Make sure you have an internet connection.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }
}
