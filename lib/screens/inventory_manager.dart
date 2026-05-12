import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class InventoryManager extends StatelessWidget {
  const InventoryManager({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Inventory & Stock', 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddItemDialog(context, db),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              label: const Text('Add Stock Item', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<InventoryItem>>(
        stream: db.select(db.inventory).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;

          if (items.isEmpty) {
            return _buildEmptyState(context, db);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(32),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return _InventoryItemTile(item: item);
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
          Icon(Icons.warehouse_outlined, size: 100, color: Colors.blueGrey[100]),
          const SizedBox(height: 24),
          const Text('Inventory is Empty', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Add feed, medication, or supplies to track your stock.', 
            style: TextStyle(color: Colors.blueGrey[400])),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _showAddItemDialog(context, db),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
            child: const Text('Add Your First Item'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context, AppDatabase db) async {
    final nameController = TextEditingController();
    final levelController = TextEditingController();
    final unitController = TextEditingController(text: 'kg');
    String selectedCategory = 'FEED';

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Inventory Item', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g. Starter Mash',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: const [
                  DropdownMenuItem(value: 'FEED', child: Text('Poultry Feed')),
                  DropdownMenuItem(value: 'MEDICATION', child: Text('Medication/Vaccine')),
                  DropdownMenuItem(value: 'EQUIPMENT', child: Text('Equipment')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Other Supplies')),
                ],
                onChanged: (v) => selectedCategory = v!,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: levelController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Initial Stock',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: unitController,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        hintText: 'kg, bags',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final stock = double.tryParse(levelController.text) ?? 0;
              if (nameController.text.isEmpty) return;
              
              final farmId = await FarmUtils.getBoundFarmId();
              if (farmId == null) return;
              
              await db.into(db.inventory).insert(
                InventoryCompanion.insert(
                  farmId: farmId,
                  itemName: nameController.text,
                  category: Value(selectedCategory),
                  stockLevel: stock,
                  unit: unitController.text,
                  synced: const Value(false),
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save Item'),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  final InventoryItem item;
  const _InventoryItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLow = item.stockLevel < (item.reorderLevel ?? 10);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getCategoryColor(item.category ?? 'OTHER').withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getCategoryIcon(item.category ?? 'OTHER'), 
              color: _getCategoryColor(item.category ?? 'OTHER')),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName, 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                Text(item.category ?? 'Uncategorized', 
                  style: TextStyle(color: Colors.blueGrey[300], fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.stockLevel} ${item.unit}', 
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: 20,
                  color: isLow ? Colors.red[700] : Colors.blueGrey[800],
                )),
              if (isLow)
                Text('LOW STOCK', 
                  style: TextStyle(color: Colors.red[700], fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(width: 24),
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: Colors.blueAccent),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'FEED': return Icons.grass_rounded;
      case 'MEDICATION': return Icons.vaccines_rounded;
      case 'EQUIPMENT': return Icons.build_circle_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'FEED': return Colors.teal;
      case 'MEDICATION': return Colors.purple;
      case 'EQUIPMENT': return Colors.orange;
      default: return Colors.blueGrey;
    }
  }
}
