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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Inventory & Stock',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = MediaQuery.of(context).size.width < 850;
                return ElevatedButton.icon(
                  onPressed: () => _showAddItemDialog(context, db),
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                  label: isNarrow ? const Text('Add') : const Text('Add Stock Item', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                );
              }
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 850;
          return StreamBuilder<List<InventoryItem>>(
            stream: db.select(db.inventory).watch(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final items = snapshot.data!;

              if (items.isEmpty) {
                return _buildEmptyState(context, db);
              }

              return ListView.separated(
                padding: EdgeInsets.all(isNarrow ? 16 : 32),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _InventoryItemTile(item: item, isNarrow: isNarrow);
                },
              );
            },
          );
        }
      ),
    );

  }

  Widget _buildEmptyState(BuildContext context, AppDatabase db) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warehouse_outlined, size: 100, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 24),
          const Text('Inventory is Empty', 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Add feed, medication, or supplies to track your stock.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                initialValue: selectedCategory,
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
  final bool isNarrow;
  const _InventoryItemTile({required this.item, required this.isNarrow});

  @override
  Widget build(BuildContext context) {
    final isLow = item.stockLevel < (item.reorderLevel ?? 10);
    
    return Container(
      padding: EdgeInsets.all(isNarrow ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getCategoryColor(item.category ?? 'OTHER').withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getCategoryIcon(item.category ?? 'OTHER'), 
              color: _getCategoryColor(item.category ?? 'OTHER'),
              size: isNarrow ? 20 : 24),
          ),
          SizedBox(width: isNarrow ? 12 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName, 
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: isNarrow ? 16 : 18),
                  overflow: TextOverflow.ellipsis),
                Text(item.category ?? 'Uncategorized',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.stockLevel} ${item.unit}', 
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: isNarrow ? 16 : 20,
                  color: isLow ? Colors.red[700] : Theme.of(context).colorScheme.onSurface,
                )),
              if (isLow)
                Text('LOW STOCK', 
                  style: TextStyle(color: Colors.red[700], fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
          if (!isNarrow) ...[
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.add_box_rounded, color: Colors.blueAccent),
              onPressed: () {},
            ),
          ],
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
