import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Batch, Column;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class LivestockManager extends StatelessWidget {
  const LivestockManager({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Livestock Inventory', 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddBatchDialog(context, db),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Register New Batch', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Batch>>(
        stream: db.select(db.batches).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final batches = snapshot.data!;

          if (batches.isEmpty) {
            return _buildEmptyState(context, db);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(32),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.4,
            ),
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final batch = batches[index];
              return _BatchDetailCard(batch: batch);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppDatabase db) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 100, color: Colors.blueGrey[100]),
          const SizedBox(height: 24),
          const Text('No Livestock Registered', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Register your first batch of birds to start tracking.', 
            style: TextStyle(color: Colors.blueGrey[400])),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _showAddBatchDialog(context, db),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
            child: const Text('Add Your First Batch'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBatchDialog(BuildContext context, AppDatabase db) async {
    final nameController = TextEditingController();
    final countController = TextEditingController();
    String selectedType = 'POULTRY_BROILER';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Livestock Batch', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Batch Name/ID',
                  hintText: 'e.g. Batch A-2024',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'POULTRY_BROILER', child: Text('Broilers')),
                  DropdownMenuItem(value: 'POULTRY_LAYER', child: Text('Layers')),
                  DropdownMenuItem(value: 'POULTRY_TURKEY', child: Text('Turkeys')),
                ],
                onChanged: (v) => selectedType = v!,
                decoration: InputDecoration(
                  labelText: 'Livestock Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Initial Bird Count',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancel', style: TextStyle(color: Colors.blueGrey[400]))
          ),
          ElevatedButton(
            onPressed: () async {
              final count = int.tryParse(countController.text) ?? 0;
              if (nameController.text.isEmpty || count <= 0) return;
              
              final farmId = await FarmUtils.getBoundFarmId();
              if (farmId == null) return;
              
              await db.into(db.batches).insert(
                BatchesCompanion.insert(
                  farmId: farmId,
                  batchName: Value(nameController.text),
                  type: Value(selectedType),
                  arrivalDate: DateTime.now(),
                  currentCount: count,
                  initialCount: count,
                  synced: const Value(false),
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text('Register Batch'),
          ),
        ],
      ),
    );
  }
}

class _BatchDetailCard extends StatelessWidget {
  final Batch batch;
  const _BatchDetailCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final ageDays = DateTime.now().difference(batch.arrivalDate).inDays;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBadge(batch.status),
                const SizedBox(height: 16),
                Text(batch.batchName, 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(batch.type.replaceAll('_', ' '), 
                  style: TextStyle(color: Colors.blueGrey[400], fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Birds', batch.currentCount.toString(), Icons.pets_rounded),
                    _buildInfoItem('Age', '$ageDays Days', Icons.calendar_today_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text('Arrived: ${DateFormat('MMM dd, yyyy').format(batch.arrivalDate)}',
                  style: TextStyle(color: Colors.blueGrey[300], fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.edit_note_rounded, color: Colors.blueGrey[200]),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.blueGrey[200]),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.blueGrey[200], fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.blueGrey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status.toUpperCase(), 
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.blueGrey, 
          fontSize: 10, 
          fontWeight: FontWeight.w900,
          letterSpacing: 1
        )),
    );
  }
}
