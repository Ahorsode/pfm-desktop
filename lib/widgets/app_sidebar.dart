import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final Function(int) onDestinationSelected;
  final VoidCallback onLogout;
  final Widget syncStatus;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onDestinationSelected,
    required this.onLogout,
    required this.syncStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Sidebar always has its own dark gradient regardless of app theme
    final sidebarBg = isDark
        ? const Color(0xFF0D1117)
        : const Color(0xFF013328);
    final sidebarAccent = const Color(0xFF16A34A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 270,
      decoration: BoxDecoration(
        color: sidebarBg,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(sidebarAccent),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCollapsed) _buildSectionHeader('OPERATIONS'),
                  _buildMenuItem(
                    context,
                    0,
                    Icons.grid_view_rounded,
                    'Dashboard',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    1,
                    Icons.pets_rounded,
                    'Livestock',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    2,
                    Icons.home_work_rounded,
                    'Houses',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    3,
                    Icons.egg_rounded,
                    'Eggs',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    4,
                    Icons.restaurant_rounded,
                    'Feeding',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    5,
                    Icons.cancel_outlined,
                    'Mortality',
                    sidebarAccent,
                  ),

                  const SizedBox(height: 20),
                  if (!isCollapsed) _buildSectionHeader('COMMERCIAL HUB'),
                  _buildMenuItem(
                    context,
                    6,
                    Icons.receipt_long_rounded,
                    'Sales',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    7,
                    Icons.people_alt_rounded,
                    'Customers',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    8,
                    Icons.account_balance_wallet_rounded,
                    'Finance',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    9,
                    Icons.inventory_2_rounded,
                    'Inventory',
                    sidebarAccent,
                  ),

                  const SizedBox(height: 20),
                  if (!isCollapsed) _buildSectionHeader('GOVERNANCE'),
                  _buildMenuItem(
                    context,
                    10,
                    Icons.group_rounded,
                    'Team',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    11,
                    Icons.workspace_premium_rounded,
                    'License',
                    sidebarAccent,
                  ),
                  _buildMenuItem(
                    context,
                    12,
                    Icons.settings_rounded,
                    'Settings',
                    sidebarAccent,
                  ),
                ],
              ),
            ),
          ),
          _buildFooter(context, sidebarAccent),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 20),
      child: Row(
        mainAxisAlignment: isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, const Color(0xFF15803D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'POULTRY PMS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'ENTERPRISE',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                      letterSpacing: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!isCollapsed)
            IconButton(
              icon: const Icon(
                Icons.menu_open_rounded,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: onToggleCollapse,
              tooltip: 'Collapse Menu',
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    Color accent,
  ) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? accent.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: accent.withValues(alpha: 0.35))
              : null,
        ),
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? const Color(0xFF4ADE80)
                      : Colors.white.withValues(alpha: 0.65),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.65),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color accent) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Column(
        children: [
          syncStatus,
          const SizedBox(height: 12),

          // Dark mode toggle
          InkWell(
            onTap: () => themeProvider.toggle(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 16,
                    color: Colors.white60,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isDark ? 'Light Mode' : 'Dark Mode',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isDark ? accent : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: isDark
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Logout
          InkWell(
            onTap: onLogout,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(Icons.logout_rounded, size: 16, color: Colors.red[400]),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isCollapsed)
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: onToggleCollapse,
              tooltip: 'Expand Menu',
            ),
        ],
      ),
    );
  }
}
