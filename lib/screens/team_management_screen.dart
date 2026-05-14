import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  late AppDatabase db;

  final _roles = ['OWNER', 'MANAGER', 'WORKER', 'VETERINARIAN', 'ACCOUNTANT'];

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
  }

  Future<int> _getFarmId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bound_farm_id') ?? 0;
  }

  Future<void> _showAddMemberDialog() async {
    final farmId = await _getFarmId();
    if (!mounted) return;
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRole = 'WORKER';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(ctx).cardColor,
          title: Text('Add Team Member',
              style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(ctx).colorScheme.onSurface)),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _buildField(nameCtrl, 'Full Name', Icons.person_rounded, ctx),
                const SizedBox(height: 12),
                _buildField(emailCtrl, 'Email Address', Icons.email_rounded, ctx, required: true),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.badge_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setDlg(() => selectedRole = v!),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final userId = 'local_${DateTime.now().millisecondsSinceEpoch}';
                await db.into(db.farmMembers).insert(FarmMembersCompanion.insert(
                  farmId: farmId,
                  userId: userId,
                  role: Value(selectedRole),
                ));
                await db.into(db.users).insert(UsersCompanion.insert(
                  id: userId,
                  name: Value(nameCtrl.text),
                  email: Value(emailCtrl.text),
                  role: Value(selectedRole),
                ), mode: InsertMode.insertOrIgnore);
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() {});
                if (mounted) {
                  Provider.of<SyncEngine>(context, listen: false).syncNow();
                }
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
              child: const Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildField(TextEditingController ctrl, String label, IconData icon, BuildContext ctx, {bool required = false}) {
    return TextFormField(
      controller: ctrl,
      validator: required ? (v) => (v == null || v.isEmpty) ? '$label is required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'OWNER': return const Color(0xFF7C3AED);
      case 'MANAGER': return const Color(0xFF2563EB);
      case 'VETERINARIAN': return const Color(0xFF0891B2);
      case 'ACCOUNTANT': return const Color(0xFFF59E0B);
      default: return const Color(0xFF16A34A);
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'OWNER': return Icons.stars_rounded;
      case 'MANAGER': return Icons.admin_panel_settings_rounded;
      case 'VETERINARIAN': return Icons.medical_services_rounded;
      case 'ACCOUNTANT': return Icons.calculate_rounded;
      default: return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Team Management',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: cs.onSurface)),
                const SizedBox(height: 4),
                Text('Manage your farm team and access roles',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
              ]),
              FilledButton.icon(
                onPressed: _showAddMemberDialog,
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Add Member'),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ]),
            const SizedBox(height: 28),

            // Role legend
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _roles.map((role) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _roleColor(role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _roleColor(role).withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Icon(_roleIcon(role), size: 14, color: _roleColor(role)),
                      const SizedBox(width: 6),
                      Text(role, style: TextStyle(color: _roleColor(role), fontWeight: FontWeight.w700, fontSize: 12)),
                    ]),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: StreamBuilder<List<FarmMember>>(
                stream: db.select(db.farmMembers).watch(),
                builder: (ctx, snap) {
                  final members = snap.data ?? [];
                  if (members.isEmpty) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.group_rounded, size: 72, color: cs.outline),
                      const SizedBox(height: 16),
                      Text('No team members yet.', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _showAddMemberDialog,
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text('Add Your First Member'),
                        style: FilledButton.styleFrom(backgroundColor: cs.primary),
                      ),
                    ]));
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: members.length,
                    itemBuilder: (ctx, i) {
                      final m = members[i];
                      final role = m.role;
                      final color = _roleColor(role);
                      return FutureBuilder<User?>(
                        future: (db.select(db.users)..where((u) => u.id.equals(m.userId))).getSingleOrNull(),
                        builder: (ctx, uSnap) {
                          final user = uSnap.data;
                          final name = user?.name ?? user?.email ?? m.userId;
                          final email = user?.email ?? '';
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.15)),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 12)],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: color.withValues(alpha: 0.15),
                                      child: Text(
                                        name[0].toUpperCase(),
                                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(children: [
                                        Icon(_roleIcon(role), size: 12, color: color),
                                        const SizedBox(width: 4),
                                        Text(role, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ]),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () async {
                                        final ok = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Remove Member'),
                                            content: Text('Remove "$name" from the team?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                              FilledButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                                child: const Text('Remove'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (ok == true) {
                                          await (db.delete(db.farmMembers)..where((t) => t.id.equals(m.id))).go();
                                          setState(() {});
                                        }
                                      },
                                      child: Icon(Icons.close_rounded, size: 16, color: cs.onSurfaceVariant),
                                    ),
                                  ]),
                                  const Spacer(),
                                  Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cs.onSurface), overflow: TextOverflow.ellipsis),
                                  if (email.isNotEmpty) Text(email, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12), overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('Joined ${DateFormat('MMM dd, yyyy').format(m.joinedAt)}',
                                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
