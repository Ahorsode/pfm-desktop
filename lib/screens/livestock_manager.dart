import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Batch, Column;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import '../widgets/register_unit_dialog.dart';

class LivestockManager extends StatelessWidget {
  const LivestockManager({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Livestock Inventory',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
              childAspectRatio: 1.1,
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
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RegisterUnitDialog(),
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
        color: Theme.of(context).cardColor,
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
                _buildStatusBadge(context, batch.status),
                const SizedBox(height: 16),
                Text(batch.batchName, 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(batch.type.replaceAll('_', ' '),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(context, 'Birds', batch.currentCount.toString(), Icons.pets_rounded),
                    _buildInfoItem(context, 'Age', '$ageDays Days', Icons.calendar_today_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text('Arrived: ${DateFormat('MMM dd, yyyy').format(batch.arrivalDate)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.edit_note_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
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
