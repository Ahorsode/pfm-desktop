import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';

enum OperationType { feeding, mortality, eggs }

class OperationLogScreen extends StatefulWidget {
  final OperationType type;
  const OperationLogScreen({super.key, required this.type});

  @override
  State<OperationLogScreen> createState() => _OperationLogScreenState();
}

class _OperationLogScreenState extends State<OperationLogScreen> {
  final _valueController = TextEditingController();
  int? _selectedBatchId;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final cs = Theme.of(context).colorScheme;
    final theme = _getTheme();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(theme.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: cs.onSurface)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outline),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(theme.subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cs.outline),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Select Active Batch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Batch>>(
                      stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
                      builder: (context, snapshot) {
                        final batches = snapshot.data ?? [];
                        return DropdownButtonFormField<int>(
                          value: _selectedBatchId,
                          hint: Text('Choose a batch', style: TextStyle(color: cs.onSurfaceVariant)),
                          dropdownColor: Theme.of(context).cardColor,
                          items: batches.map((b) => DropdownMenuItem<int>(value: b.id, child: Text(b.batchName, style: TextStyle(color: cs.onSurface)))).toList(),
                          onChanged: (v) => setState(() => _selectedBatchId = v),
                          decoration: _inputDecoration(Icons.layers_rounded, context),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(theme.valueLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _valueController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
                      decoration: _inputDecoration(theme.icon, context),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () => _submitLog(db),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Save ${theme.title} Log',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.outline)),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  _OperationTheme _getTheme() {
    switch (widget.type) {
      case OperationType.feeding:
        return _OperationTheme(title: 'Feeding Log', subtitle: 'Record daily feed consumption per batch',
            valueLabel: 'Amount Consumed (kg)', icon: Icons.restaurant_rounded, color: const Color(0xFF2563EB));
      case OperationType.mortality:
        return _OperationTheme(title: 'Mortality Record', subtitle: 'Track bird losses to monitor flock health',
            valueLabel: 'Number of Birds Lost', icon: Icons.cancel_rounded, color: const Color(0xFFDC2626));
      case OperationType.eggs:
        return _OperationTheme(title: 'Egg Production', subtitle: 'Log daily egg collection and quality',
            valueLabel: 'Total Eggs Collected', icon: Icons.egg_rounded, color: const Color(0xFFD97706));
    }
  }

  Future<void> _submitLog(AppDatabase db) async {
    if (_selectedBatchId == null) return;
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;
    final value = double.tryParse(_valueController.text) ?? 0;
    if (value <= 0) return;

    try {
      switch (widget.type) {
        case OperationType.feeding:
          await db.into(db.feedingLogs).insert(FeedingLogsCompanion.insert(
              farmId: farmId, batchId: Value(_selectedBatchId), amountConsumed: value, logDate: DateTime.now(), synced: const Value(false)));
          break;
        case OperationType.mortality:
          await db.into(db.mortalities).insert(MortalitiesCompanion.insert(
              farmId: farmId, batchId: _selectedBatchId!, count: value.toInt(), logDate: DateTime.now(), synced: const Value(false)));
          break;
        case OperationType.eggs:
          await db.into(db.eggProductions).insert(EggProductionsCompanion.insert(
              farmId: farmId, batchId: _selectedBatchId!, eggsCollected: value.toInt(), logDate: DateTime.now(), synced: const Value(false)));
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 12), Text('Log saved successfully')]),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
        ));
        _valueController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class _OperationTheme {
  final String title, subtitle, valueLabel;
  final IconData icon;
  final Color color;
  _OperationTheme({required this.title, required this.subtitle, required this.valueLabel, required this.icon, required this.color});
}
