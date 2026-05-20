import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppDatabase db;
  late ThemeProvider themeProvider;

  // Farm settings
  String _currency = 'GH₵';
  int _eggsPerCrate = 30;
  String _eggReminderTime = '08:00';
  String _feedReminderTime = '07:00';
  bool _autoSync = true;
  int _syncInterval = 30;
  String _farmName = '';
  String _farmLocation = '';
  bool _loaded = false;

  final _currencies = ['GH₵', 'USD', 'EUR', 'GBP', 'NGN', 'KES', 'ZAR'];

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final farmId = prefs.getInt('bound_farm_id') ?? 0;
    final farmRow = farmId > 0
        ? await (db.select(db.farms)..where((f) => f.id.equals(farmId))).getSingleOrNull()
        : null;
    final settingsRow = farmId > 0
        ? await (db.select(db.farmSettings)..where((s) => s.farmId.equals(farmId))).getSingleOrNull()
        : null;

    setState(() {
      _farmName = farmRow?.name ?? '';
      _farmLocation = farmRow?.location ?? '';
      _currency = settingsRow?.currency ?? 'GH₵';
      _eggsPerCrate = settingsRow?.eggsPerCrate ?? 30;
      _eggReminderTime = settingsRow?.eggRecordReminderTime ?? '08:00';
      _feedReminderTime = settingsRow?.feedRecordReminderTime ?? '07:00';
      _autoSync = prefs.getBool('auto_sync') ?? true;
      _syncInterval = prefs.getInt('sync_interval_minutes') ?? 30;
      _loaded = true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final farmId = prefs.getInt('bound_farm_id') ?? 0;
    await prefs.setBool('auto_sync', _autoSync);
    await prefs.setInt('sync_interval_minutes', _syncInterval);

    if (farmId > 0) {
      // Update farm
      await (db.update(db.farms)..where((f) => f.id.equals(farmId))).write(
        FarmsCompanion(name: Value(_farmName), location: Value(_farmLocation)),
      );
      // Upsert farm settings
      final existing = await (db.select(db.farmSettings)..where((s) => s.farmId.equals(farmId))).getSingleOrNull();
      final companion = FarmSettingsCompanion(
        farmId: Value(farmId),
        currency: Value(_currency),
        eggsPerCrate: Value(_eggsPerCrate),
        eggRecordReminderTime: Value(_eggReminderTime.isEmpty ? null : _eggReminderTime),
        feedRecordReminderTime: Value(_feedReminderTime.isEmpty ? null : _feedReminderTime),
      );
      if (existing == null) {
        await db.into(db.farmSettings).insert(companion);
      } else {
        await (db.update(db.farmSettings)..where((s) => s.farmId.equals(farmId))).write(companion);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Settings saved successfully'),
          ]),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Provider.of<ThemeProvider>(context);

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 850;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isNarrow ? 16 : 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNarrow)
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: cs.onSurface)),
                    const SizedBox(height: 4),
                    Text('Configure your farm preferences',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save Changes'),
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ])
                else
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: cs.onSurface)),
                      const SizedBox(height: 4),
                      Text('Configure your farm and application preferences',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                    ]),
                    FilledButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Changes'),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ]),
                const SizedBox(height: 36),


            // Appearance
            _sectionCard(
              context: context,
              icon: Icons.palette_rounded,
              title: 'Appearance',
              color: const Color(0xFF7C3AED),
              child: Column(children: [
                _settingRow(
                  context: context,
                  label: 'Dark Mode',
                  subtitle: 'Switch to a darker color scheme',
                  icon: Icons.dark_mode_rounded,
                  trailing: Switch(
                    value: theme.isDark,
                    onChanged: (_) => theme.toggle(),
                    activeThumbColor: cs.primary,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Farm Details
            _sectionCard(
              context: context,
              icon: Icons.agriculture_rounded,
              title: 'Farm Details',
              color: const Color(0xFF16A34A),
              child: Column(children: [
                _inputRow(
                  context: context,
                  label: 'Farm Name',
                  icon: Icons.store_rounded,
                  value: _farmName,
                  onChanged: (v) => setState(() => _farmName = v),
                ),
                const SizedBox(height: 14),
                _inputRow(
                  context: context,
                  label: 'Farm Location',
                  icon: Icons.location_on_rounded,
                  value: _farmLocation,
                  onChanged: (v) => setState(() => _farmLocation = v),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Financial
            _sectionCard(
              context: context,
              icon: Icons.payments_rounded,
              title: 'Financial Settings',
              color: const Color(0xFFF59E0B),
              child: Column(children: [
                _settingRow(
                  context: context,
                  label: 'Currency',
                  subtitle: 'Default currency for reports and pricing',
                  icon: Icons.attach_money_rounded,
                  trailing: DropdownButton<String>(
                    value: _currency,
                    underline: const SizedBox(),
                    items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.w700)))).toList(),
                    onChanged: (v) => setState(() => _currency = v!),
                    style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w700),
                    dropdownColor: Theme.of(context).cardColor,
                  ),
                ),
                Divider(color: cs.outline.withValues(alpha: 0.5)),
                _settingRow(
                  context: context,
                  label: 'Eggs per Crate',
                  subtitle: 'Standard crate size for production calculations',
                  icon: Icons.egg_rounded,
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: _eggsPerCrate.toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      onChanged: (v) => setState(() => _eggsPerCrate = int.tryParse(v) ?? 30),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Reminders
            _sectionCard(
              context: context,
              icon: Icons.notifications_rounded,
              title: 'Reminders',
              color: const Color(0xFF3B82F6),
              child: Column(children: [
                _settingRow(
                  context: context,
                  label: 'Egg Collection Reminder',
                  subtitle: 'Daily reminder to log egg production',
                  icon: Icons.egg_alt_rounded,
                  trailing: SizedBox(
                    width: 110,
                    child: TextFormField(
                      initialValue: _eggReminderTime,
                      textAlign: TextAlign.center,
                      onChanged: (v) => setState(() => _eggReminderTime = v),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        hintText: 'HH:MM',
                      ),
                      style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Divider(color: cs.outline.withValues(alpha: 0.5)),
                _settingRow(
                  context: context,
                  label: 'Feeding Log Reminder',
                  subtitle: 'Daily reminder to log feeding data',
                  icon: Icons.restaurant_rounded,
                  trailing: SizedBox(
                    width: 110,
                    child: TextFormField(
                      initialValue: _feedReminderTime,
                      textAlign: TextAlign.center,
                      onChanged: (v) => setState(() => _feedReminderTime = v),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        hintText: 'HH:MM',
                      ),
                      style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Sync settings
            _sectionCard(
              context: context,
              icon: Icons.sync_rounded,
              title: 'Sync Settings',
              color: const Color(0xFF0891B2),
              child: Column(children: [
                _settingRow(
                  context: context,
                  label: 'Auto Sync',
                  subtitle: 'Automatically sync data in the background',
                  icon: Icons.cloud_sync_rounded,
                  trailing: Switch(
                    value: _autoSync,
                    onChanged: (v) => setState(() => _autoSync = v),
                    activeThumbColor: cs.primary,
                  ),
                ),
                if (_autoSync) ...[
                  Divider(color: cs.outline.withValues(alpha: 0.5)),
                  _settingRow(
                    context: context,
                    label: 'Sync Interval',
                    subtitle: 'How often to sync data with the cloud',
                    icon: Icons.timer_rounded,
                    trailing: DropdownButton<int>(
                      value: _syncInterval,
                      underline: const SizedBox(),
                      items: [5, 10, 15, 30, 60].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
                      onChanged: (v) => setState(() => _syncInterval = v!),
                      style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w700),
                      dropdownColor: Theme.of(context).cardColor,
                    ),
                  ),
                ],
                Divider(color: cs.outline.withValues(alpha: 0.5)),
                _settingRow(
                  context: context,
                  label: 'Sync Now',
                  subtitle: 'Force an immediate sync with the cloud',
                  icon: Icons.cloud_upload_rounded,
                  trailing: FilledButton.icon(
                    onPressed: () => Provider.of<SyncEngine>(context, listen: false).syncNow(),
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text('Sync'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Danger zone
            _sectionCard(
              context: context,
              icon: Icons.warning_rounded,
              title: 'Danger Zone',
              color: Colors.red,
              child: _settingRow(
                context: context,
                label: 'Clear Local Data',
                subtitle: 'Delete all local data. Cloud data will not be affected.',
                icon: Icons.delete_sweep_rounded,
                trailing: OutlinedButton(
                  onPressed: () => _confirmClearData(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Clear Data'),
                ),
              ),
            ),
              ],
            ),
          );
        },
      ),
    );
  }



  Widget _sectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface)),
            ]),
          ),
          Divider(height: 1, color: cs.outline.withValues(alpha: 0.5)),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _settingRow({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
  }) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 400;
      if (isNarrow) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 20, color: cs.onSurfaceVariant),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface))),
              ]),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: trailing),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
            Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ])),
          const SizedBox(width: 16),
          trailing,
        ]),
      );
    });
  }

  Widget _inputRow({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String value,
    required Function(String) onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 400;
      if (isNarrow) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 20, color: cs.onSurfaceVariant),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface))),
              ]),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: value,
                onChanged: onChanged,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: 'Enter $label',
                ),
                style: TextStyle(color: cs.onSurface),
              ),
            ],
          ),
        );
      }
      return Row(children: [
        Icon(icon, size: 20, color: cs.onSurfaceVariant),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface))),
        const SizedBox(width: 16),
        SizedBox(
          width: 250,
          child: TextFormField(
            initialValue: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: 'Enter $label',
            ),
            style: TextStyle(color: cs.onSurface),
          ),
        ),
      ]);
    });
  }


  Future<void> _confirmClearData() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_rounded, color: Colors.red),
          SizedBox(width: 12),
          Text('Clear All Local Data', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        content: const Text(
          'This will delete ALL locally stored data including batches, houses, mortality records, and egg production logs.\n\nCloud data will NOT be affected. You can re-sync after clearing.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Clear Data'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local data cleared. Sync to restore from cloud.')),
      );
    }
  }
}
