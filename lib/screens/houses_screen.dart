import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class HousesScreen extends StatelessWidget {
  const HousesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Farm Houses', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: cs.onSurface)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outline),
        ),
      ),
      body: FutureBuilder<int?>(
        future: FarmUtils.getBoundFarmId(),
        builder: (context, farmSnapshot) {
          if (!farmSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final farmId = farmSnapshot.data!;
          return StreamBuilder<List<House>>(
            stream: (db.select(db.houses)..where((t) => t.farmId.equals(farmId))).watch(),
            builder: (context, snapshot) {
              final houses = snapshot.data ?? [];
              if (houses.isEmpty) return _buildEmptyState(context);
              return GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 1.5,
                ),
                itemCount: houses.length,
                itemBuilder: (context, index) => _buildHouseCard(context, houses[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHouseDialog(context, db),
        backgroundColor: const Color(0xFF16A34A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add New House', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.home_work_outlined, size: 80, color: cs.outline),
      const SizedBox(height: 16),
      Text('No houses registered yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
      const SizedBox(height: 8),
      Text('Register your farm houses to start tracking batches.', style: TextStyle(color: cs.onSurfaceVariant)),
    ]));
  }

  Widget _buildHouseCard(BuildContext context, House house) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 12)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(house.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
            if (house.isIsolation)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text('ISOLATION', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ]),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.groups_outlined, 'Capacity: ${house.capacity} birds', cs),
          _buildInfoRow(Icons.thermostat_outlined, 'Temp: ${house.currentTemperature ?? "--"}°C', cs),
          _buildInfoRow(Icons.water_drop_outlined, 'Humidity: ${house.currentHumidity ?? "--"}%', cs),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.0,
              backgroundColor: cs.outline.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
              minHeight: 6,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
      ]),
    );
  }

  Future<void> _showAddHouseDialog(BuildContext context, AppDatabase db) async {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    bool isIsolation = false;
    final cs = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Farm House', style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'House Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: capacityController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Capacity', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            SwitchListTile(
              title: Text('Is Isolation House?', style: TextStyle(color: cs.onSurface)),
              value: isIsolation,
              onChanged: (v) => setState(() => isIsolation = v),
              activeColor: cs.primary,
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final farmId = await FarmUtils.getBoundFarmId();
                if (farmId == null) return;
                await db.into(db.houses).insert(HousesCompanion.insert(
                  farmId: farmId,
                  name: nameController.text,
                  capacity: int.parse(capacityController.text),
                  isIsolation: Value(isIsolation),
                  synced: const Value(false),
                ));
                if (context.mounted) Navigator.pop(context);
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
              child: const Text('Add House'),
            ),
          ],
        ),
      ),
    );
  }
}
