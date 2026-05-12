import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'overview.dart';
import 'livestock_manager.dart';
import 'daily_operations.dart';
import 'inventory_manager.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const OverviewPage(),
    const LivestockManager(),
    const DailyOperations(),
    const InventoryManager(),
    const Center(child: Text('Sales & Finance (Coming Soon)')),
    const Center(child: Text('Settings')),
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
      body: Row(
        children: [
          // Navigation Sidebar
          NavigationRail(
            extended: true,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            leading: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.agriculture, size: 40, color: Colors.green),
                const SizedBox(height: 10),
                const Text('Agri-ERP', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Unified Sync Status Area
                      StreamBuilder<bool>(
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSyncing)
                                      const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                        ),
                                      )
                                    else
                                      const Icon(Icons.cloud_done, color: Colors.green, size: 20),
                                    const SizedBox(height: 6),
                                    Text(
                                      isSyncing ? 'Syncing...' : 'Synced',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSyncing ? Colors.blue[700] : Colors.green[700],
                                      ),
                                    ),
                                    if (!isSyncing)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          'Refresh Now',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const Divider(indent: 16, endIndent: 16),

                      // Logout button
                      TextButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                        label: const Text(
                          'Logout Account',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.redAccent,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pets_outlined),
                selectedIcon: Icon(Icons.pets),
                label: Text('Livestock'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.edit_note_outlined),
                selectedIcon: Icon(Icons.edit_note),
                label: Text('Daily Logs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Inventory'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.monetization_on_outlined),
                selectedIcon: Icon(Icons.monetization_on),
                label: Text('Finance'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
