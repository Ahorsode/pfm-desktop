import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Batch, Column;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class DailyOperations extends StatefulWidget {
  const DailyOperations({super.key});

  @override
  State<DailyOperations> createState() => _DailyOperationsState();
}

class _DailyOperationsState extends State<DailyOperations> {
  final _amountController = TextEditingController();
  final _countController = TextEditingController();
  int? _selectedBatchId;
  String _logType = 'FEEDING'; // FEEDING, MORTALITY, EGGS

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildSidebarItem(Icons.restaurant_rounded, 'Feeding', 'FEEDING'),
                _buildSidebarItem(Icons.warning_rounded, 'Mortality', 'MORTALITY'),
                _buildSidebarItem(Icons.egg_rounded, 'Eggs', 'EGGS'),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Record Daily Activity', 
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.blueGrey[900])),
                    const SizedBox(height: 8),
                    Text('Log ${_logType.toLowerCase()} data for your active batches', 
                      style: TextStyle(color: Colors.blueGrey[400], fontSize: 16)),
                    const SizedBox(height: 48),
                    
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Select Batch'),
                          StreamBuilder<List<Batch>>(
                            stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
                            builder: (context, snapshot) {
                              final batches = snapshot.data ?? [];
                              return DropdownButtonFormField<int>(
                                value: _selectedBatchId,
                                hint: const Text('Choose an active batch'),
                                items: batches.map((b) => DropdownMenuItem(
                                  value: b.id,
                                  child: Text(b.batchName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                )).toList(),
                                onChanged: (v) => setState(() => _selectedBatchId = v),
                                decoration: _inputDecoration(Icons.layers_rounded),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          
                          _buildLabel(_getAmountLabel()),
                          TextField(
                            controller: _logType == 'FEEDING' ? _amountController : _countController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: _inputDecoration(_getAmountIcon()),
                          ),
                          
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () => _submitLog(db),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getPrimaryColor(),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded),
                                  const SizedBox(width: 12),
                                  Text('Confirm ${_logType.toLowerCase()} Log', 
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, String type) {
    final isSelected = _logType == type;
    final color = isSelected ? _getPrimaryColor() : Colors.blueGrey[200];
    
    return InkWell(
      onTap: () => setState(() => _logType = type),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, 
              style: TextStyle(
                color: color, 
                fontSize: 12, 
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey[700])),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blueGrey[200]),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(20),
    );
  }

  String _getAmountLabel() {
    switch (_logType) {
      case 'FEEDING': return 'Amount Consumed (kg)';
      case 'MORTALITY': return 'Bird Loss Count';
      case 'EGGS': return 'Total Eggs Collected';
      default: return 'Value';
    }
  }

  IconData _getAmountIcon() {
    switch (_logType) {
      case 'FEEDING': return Icons.scale_rounded;
      case 'MORTALITY': return Icons.remove_circle_outline_rounded;
      case 'EGGS': return Icons.egg_outlined;
      default: return Icons.edit_note_rounded;
    }
  }

  Color _getPrimaryColor() {
    switch (_logType) {
      case 'FEEDING': return Colors.blue[600]!;
      case 'MORTALITY': return Colors.red[500]!;
      case 'EGGS': return Colors.amber[600]!;
      default: return Colors.blueGrey;
    }
  }

  Future<void> _submitLog(AppDatabase db) async {
    if (_selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a batch')));
      return;
    }

    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;
    final now = DateTime.now();

    try {
      if (_logType == 'FEEDING') {
        final amount = double.tryParse(_amountController.text) ?? 0;
        await db.into(db.feedingLogs).insert(FeedingLogsCompanion.insert(
          farmId: farmId,
          batchId: Value(_selectedBatchId),
          amountConsumed: amount,
          logDate: now,
          synced: const Value(false),
        ));
      } else if (_logType == 'MORTALITY') {
        final count = int.tryParse(_countController.text) ?? 0;
        await db.into(db.mortalities).insert(MortalitiesCompanion.insert(
          farmId: farmId,
          batchId: _selectedBatchId!,
          count: count,
          logDate: now,
          synced: const Value(false),
        ));
      } else if (_logType == 'EGGS') {
        final count = int.tryParse(_countController.text) ?? 0;
        await db.into(db.eggProductions).insert(EggProductionsCompanion.insert(
          farmId: farmId,
          batchId: _selectedBatchId!,
          eggsCollected: count,
          logDate: now,
          synced: const Value(false),
        ));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[800],
            content: const Text('Log Entry Saved Successfully', style: TextStyle(fontWeight: FontWeight.bold))
          )
        );
        _amountController.clear();
        _countController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
