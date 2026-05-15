import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/farm_utils.dart';
import '../data/sync_engine.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Edits', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        backgroundColor: Colors.white,
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
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  labelColor: cs.primary,
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Edits'),
                    Tab(text: 'Deletions'),
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
        final type = log['type'] as String;
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
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
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: Colors.black.withValues(alpha: 0.2))),
                      const SizedBox(width: 8),
                      Text(date, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(details, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
            ),
            if (trailing != null) trailing,
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
          Icon(icon, size: 64, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w600)),
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
