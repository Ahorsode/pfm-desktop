import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class MortalityQuarantineScreen extends StatefulWidget {
  const MortalityQuarantineScreen({super.key});

  @override
  State<MortalityQuarantineScreen> createState() => _MortalityQuarantineScreenState();
}

class _MortalityQuarantineScreenState extends State<MortalityQuarantineScreen> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(int id) {
    return _controllers.putIfAbsent(id, () => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 32),

            // Top Row: Stats and Tips
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTotalDeathsCard(db)),
                const SizedBox(width: 24),
                Expanded(child: _buildHealthTipCard()),
              ],
            ),
            const SizedBox(height: 40),

            // Quick Mortality Logging
            _buildSectionHeader(
              icon: Icons.dangerous_outlined,
              title: 'QUICK MORTALITY LOGGING',
              iconColor: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            _buildQuickLoggingList(db),
            const SizedBox(height: 48),

            // Isolation Rooms
            _buildSectionHeader(
              icon: Icons.home_work_outlined,
              title: 'Isolation Rooms',
              subtitle: 'Configure dedicated housing for sick or quarantined birds.',
              iconColor: Colors.amber,
              isLarge: true,
            ),
            const SizedBox(height: 24),
            _buildIsolationRoomsSection(db),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dangerous_outlined, color: Colors.redAccent, size: 28),
            ),
            const SizedBox(width: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1),
                children: [
                  TextSpan(text: 'MORTALITY & ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  TextSpan(text: 'QUARANTINE', style: TextStyle(color: Colors.red.shade400, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Centralized history of livestock mortality records and active isolation management.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildTotalDeathsCard(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<List<Mortality>>(
      stream: db.select(db.mortalities).watch(),
      builder: (context, snapshot) {
        final total = snapshot.data?.fold<int>(0, (sum, m) => sum + m.count) ?? 0;
        return Container(
          height: 160,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [Colors.red.shade900.withValues(alpha: 0.8), Colors.red.shade800.withValues(alpha: 0.4)]
                : [const Color(0xFFEF4444), const Color(0xFFF87171)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.red.shade700.withValues(alpha: 0.3) : Colors.red.shade200.withValues(alpha: 0.5)),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(Icons.cancel_outlined, size: 100, color: Colors.white.withValues(alpha: 0.1)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL DEATHS (HISTORY)',
                    style: TextStyle(
                      color: isDark ? Colors.redAccent : Colors.white.withValues(alpha: 0.9), 
                      fontWeight: FontWeight.w900, 
                      fontSize: 12, 
                      letterSpacing: 1
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat('#,###').format(total),
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('livestock', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Across all active & archived batches',
                    style: TextStyle(color: isDark ? Colors.red.shade300 : Colors.white.withValues(alpha: 0.7), fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthTipCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 160,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber.shade400, size: 18),
              const SizedBox(width: 8),
              Text(
                'HEALTH TIP',
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Consistent mortality logging helps identify early signs of disease. If mortality exceeds 1% in 24 hours, contact a veterinarian immediately.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    bool isLarge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: isLarge ? 24 : 18),
            const SizedBox(width: 12),
            Text(
              isLarge ? title : title.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: isLarge ? 20 : 13,
                letterSpacing: isLarge ? 0 : 1,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
        ],
      ],
    );
  }

  Widget _buildQuickLoggingList(AppDatabase db) {
    return StreamBuilder<List<Batch>>(
      stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
      builder: (context, snapshot) {
        final batches = snapshot.data ?? [];
        if (batches.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1), style: BorderStyle.solid),
            ),
            child: Center(
              child: Text(
                'No active units to log mortality for.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
              ),
            ),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: batches.length,
            separatorBuilder: (_, _) => Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05), height: 1),
            itemBuilder: (context, index) {
              final batch = batches[index];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(batch.batchName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            '${batch.currentCount} ${batch.type.toLowerCase().replaceAll('poultry_', '')} remaining',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _getController(batch.id),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'Lost',
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _submitMortality(db, batch),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('LOG LOSS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildIsolationRoomsSection(AppDatabase db) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCreateRoomCard(db),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: _buildIsolationRoomsGrid(db),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateRoomCard(AppDatabase db) {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Create New Room'.toUpperCase(),
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('ROOM NAME', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: _roomInputDecoration('e.g. Isolation A'),
          ),
          const SizedBox(height: 20),
          Text('CAPACITY', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            controller: capacityController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: _roomInputDecoration('Max birds'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _createIsolationRoom(db, nameController, capacityController),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('CONFIRM CREATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _roomInputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1))),
    );
  }

  Widget _buildIsolationRoomsGrid(AppDatabase db) {
    return StreamBuilder<List<House>>(
      stream: (db.select(db.houses)..where((t) => t.isIsolation.equals(true))).watch(),
      builder: (context, snapshot) {
        final rooms = snapshot.data ?? [];
        if (rooms.isEmpty) {
          return Container(
            height: 350,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1), style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No isolation rooms configured yet.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.house_rounded, color: Colors.amber),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(room.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Capacity: ${room.capacity} birds', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _deleteRoom(db, room),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitMortality(AppDatabase db, Batch batch) async {
    final controller = _getController(batch.id);
    final count = int.tryParse(controller.text) ?? 0;

    if (count <= 0) return;

    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;

    try {
      await db.transaction(() async {
        // 1. Insert mortality record
        await db.into(db.mortalities).insert(MortalitiesCompanion.insert(
          farmId: farmId,
          batchId: batch.id,
          count: count,
          logDate: DateTime.now(),
          synced: const Value(false),
        ));

        // 2. Update batch currentCount
        await (db.update(db.batches)..where((t) => t.id.equals(batch.id))).write(
          BatchesCompanion(
            currentCount: Value(batch.currentCount - count),
            updatedAt: Value(DateTime.now()),
            synced: const Value(false),
          ),
        );
      });

      controller.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Mortality logged successfully'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _createIsolationRoom(AppDatabase db, TextEditingController nameCtrl, TextEditingController capCtrl) async {
    final name = nameCtrl.text.trim();
    final capacity = int.tryParse(capCtrl.text) ?? 0;

    if (name.isEmpty || capacity <= 0) return;

    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;

    try {
      await db.into(db.houses).insert(HousesCompanion.insert(
        farmId: farmId,
        name: name,
        capacity: capacity,
        isIsolation: const Value(true),
        synced: const Value(false),
      ));

      nameCtrl.clear();
      capCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Isolation room created'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteRoom(AppDatabase db, House room) async {
    try {
      await (db.delete(db.houses)..where((t) => t.id.equals(room.id))).go();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
