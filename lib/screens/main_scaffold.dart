import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'overview.dart';
import 'livestock_manager.dart';
import 'inventory_manager.dart';
import 'houses_screen.dart';
import 'operation_log_screen.dart';
import 'sales_screen.dart';
import 'customer_directory_screen.dart';
import 'financial_control_screen.dart';
import 'team_management_screen.dart';
import 'license_screen.dart';
import 'settings_screen.dart';
import 'audit_log_screen.dart';
import '../widgets/app_sidebar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  bool _isCollapsed = false;

  final List<Widget> _pages = [
    const OverviewPage(), // 0
    const LivestockManager(), // 1
    const HousesScreen(), // 2
    const OperationLogScreen(type: OperationType.eggs), // 3
    const OperationLogScreen(type: OperationType.feeding), // 4
    const OperationLogScreen(type: OperationType.mortality), // 5
    const SalesScreen(), // 6
    const CustomerDirectoryScreen(), // 7
    const FinancialControlScreen(), // 8
    const InventoryManager(), // 9
    const TeamManagementScreen(), // 10
    const LicenseScreen(), // 11
    const SettingsScreen(), // 12
    const AuditLogScreen(), // 13
  ];

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Sign out of Supabase (Online)
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint("Supabase signout warning: $e");
    }

    // 2. Clear user session (Local) — keep device binding (is_bound, bound_farm_id)
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncEngine = Provider.of<SyncEngine>(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoints for Desktop Responsiveness
          final bool isNarrow = constraints.maxWidth < 1000;
          
          // Auto-collapse sidebar on narrow screens
          final bool effectiveCollapsed = _isCollapsed || isNarrow;

          return Row(
            children: [
              // Navigation Sidebar
              AppSidebar(
                selectedIndex: _selectedIndex,
                isCollapsed: effectiveCollapsed,
                onToggleCollapse: () => setState(() => _isCollapsed = !_isCollapsed),
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                onLogout: () => _logout(context),
                syncStatus: StreamBuilder<bool>(
                  stream: syncEngine.syncStatus,
                  initialData: syncEngine.isSyncing,
                  builder: (context, snapshot) {
                    final isSyncing = snapshot.data ?? false;
                    return Tooltip(
                      message: isSyncing ? 'Synchronizing data...' : 'Click to sync now',
                      child: InkWell(
                        onTap: isSyncing ? null : () => syncEngine.syncNow(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSyncing)
                                const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                  ),
                                )
                              else
                                const Icon(Icons.cloud_done_rounded, color: Color(0xFF22C55E), size: 16),
                              if (!effectiveCollapsed) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    isSyncing ? 'SYNCING...' : 'CLOUD SYNCED',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: isSyncing ? Colors.white70 : const Color(0xFF22C55E),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1, color: Colors.black12),
              // Main Content
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _pages[_selectedIndex],
                ),
              ),
            ],
          );
        },
      ),
  );
}
}
