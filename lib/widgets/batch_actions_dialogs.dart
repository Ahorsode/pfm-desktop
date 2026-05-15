import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:provider/provider.dart';
import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import '../data/sync_engine.dart';

class MortalityDialog extends StatefulWidget {
  final Batch batch;
  const MortalityDialog({super.key, required this.batch});

  @override
  State<MortalityDialog> createState() => _MortalityDialogState();
}

class _MortalityDialogState extends State<MortalityDialog> {
  final _countController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF121417) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      title: Row(
        children: [
          const Icon(Icons.coronavirus_outlined, color: Color(0xFFEF4444), size: 28),
          const SizedBox(width: 16),
          Text(
            'Record Mortality', 
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B), 
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            )
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recording mortality for ${widget.batch.batchName}',
                      style: const TextStyle(
                        color: Color(0xFFEF4444), 
                        fontSize: 12, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _countController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold),
              decoration: _inputDecoration(context, 'Number of Birds Lost', Icons.remove_circle_outline),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final count = int.tryParse(v) ?? 0;
                if (count <= 0) return 'Must be > 0';
                if (count > widget.batch.currentCount) return 'Cannot exceed current count';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _reasonController,
              maxLines: 2,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
              decoration: _inputDecoration(context, 'Reason (Optional)', Icons.notes),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            'CANCEL', 
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black45, 
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1,
            )
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            'RECORD LOSS', 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InputDecoration(
      labelText: label.toUpperCase(),
      labelStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
      prefixIcon: Icon(icon, color: isDark ? Colors.white24 : Colors.black26, size: 20),
      fillColor: isDark ? const Color(0xFF23262B) : const Color(0xFFF8FAFC),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final count = int.parse(_countController.text);
    final db = context.read<AppDatabase>();
    final farmId = await FarmUtils.getBoundFarmId();
    
    if (farmId == null) return;

    try {
      await db.transaction(() async {
        // 1. Insert mortality record
        await db.into(db.mortalities).insert(
          MortalitiesCompanion.insert(
            farmId: farmId,
            batchId: widget.batch.id,
            count: count,
            logDate: DateTime.now(),
            reason: Value(_reasonController.text),
            synced: const Value(false),
          ),
        );

        // 2. Update batch count
        await (db.update(db.batches)..where((t) => t.id.equals(widget.batch.id))).write(
          BatchesCompanion(
            currentCount: Value(widget.batch.currentCount - count),
            synced: const Value(false),
          ),
        );
      });
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class QuickSaleDialog extends StatefulWidget {
  final Batch batch;
  const QuickSaleDialog({super.key, required this.batch});

  @override
  State<QuickSaleDialog> createState() => _QuickSaleDialogState();
}

class _QuickSaleDialogState extends State<QuickSaleDialog> {
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  bool _isWalkIn = true;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    
    return AlertDialog(
      backgroundColor: const Color(0xFF121417),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.shopping_cart_outlined, color: Color(0xFF10B981), size: 24),
          SizedBox(width: 12),
          Text('Walk-in Sale', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selling from ${widget.batch.batchName}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildTypeToggle(),
              const SizedBox(height: 20),
              if (!_isWalkIn) ...[
                _buildCustomerDropdown(db),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Quantity', Icons.numbers),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final q = int.tryParse(v) ?? 0;
                        if (q <= 0) return 'Must be > 0';
                        if (q > widget.batch.currentCount) return 'Exceeds stock';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Price (GH₵)', Icons.payments),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTotalDisplay(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
          child: const Text('COMPLETE SALE'),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF23262B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleBtn('Walk-In', _isWalkIn, () => setState(() => _isWalkIn = true)),
          ),
          Expanded(
            child: _toggleBtn('Existing Customer', !_isWalkIn, () => setState(() => _isWalkIn = false)),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(AppDatabase db) {
    return StreamBuilder<List<Customer>>(
      stream: db.select(db.customers).watch(),
      builder: (context, snapshot) {
        final customers = snapshot.data ?? [];
        return DropdownButtonFormField<Customer>(
          dropdownColor: const Color(0xFF23262B),
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Select Customer', Icons.person),
          items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
          onChanged: (v) => setState(() => _selectedCustomer = v),
          validator: (v) => (!_isWalkIn && v == null) ? 'Required' : null,
        );
      },
    );
  }

  Widget _buildTotalDisplay() {
    return ValueListenableBuilder(
      valueListenable: _qtyController,
      builder: (context, _, _) {
        return ValueListenableBuilder(
          valueListenable: _priceController,
          builder: (context, _, _) {
            final qty = double.tryParse(_qtyController.text) ?? 0;
            final price = double.tryParse(_priceController.text) ?? 0;
            final total = qty * price;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL REVENUE', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 11)),
                  Text(
                    'GH₵ ${NumberFormat('#,###.00').format(total)}',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF10B981), fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      fillColor: const Color(0xFF23262B),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final qty = int.parse(_qtyController.text);
    final price = double.parse(_priceController.text);
    final total = qty * price;
    
    final db = context.read<AppDatabase>();
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;

    try {
      await db.transaction(() async {
        // 1. Record Sale
        await db.into(db.sales).insert(
          SalesCompanion.insert(
            farmId: farmId,
            batchId: Value(widget.batch.id),
            customerId: Value(_selectedCustomer?.id),
            quantity: qty,
            unitPrice: price,
            totalAmount: total,
            saleDate: Value(DateTime.now()),
            synced: const Value(false),
          ),
        );

        // 2. Update Batch Count
        await (db.update(db.batches)..where((t) => t.id.equals(widget.batch.id))).write(
          BatchesCompanion(
            currentCount: Value(widget.batch.currentCount - qty),
            synced: const Value(false),
          ),
        );

        // 3. Update Customer Balance if credit
        if (!_isWalkIn && _selectedCustomer != null) {
          await (db.update(db.customers)..where((t) => t.id.equals(_selectedCustomer!.id))).write(
            CustomersCompanion(
              balanceOwed: Value((_selectedCustomer!.balanceOwed) + total),
              synced: const Value(false),
            ),
          );
        }
      });
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class EditBatchDialog extends StatefulWidget {
  final Batch batch;
  const EditBatchDialog({super.key, required this.batch});

  @override
  State<EditBatchDialog> createState() => _EditBatchDialogState();
}

class _EditBatchDialogState extends State<EditBatchDialog> {
  late TextEditingController _nameController;
  late TextEditingController _initialCountController;
  late TextEditingController _currentCountController;
  late TextEditingController _breedController;
  late String _status;
  late String _type;
  late String _selectedBenchmark;
  late DateTime _arrivalDate;
  int? _selectedHouseId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.batch.batchName);
    _initialCountController = TextEditingController(text: widget.batch.initialCount.toString());
    _currentCountController = TextEditingController(text: widget.batch.currentCount.toString());
    _breedController = TextEditingController(text: widget.batch.breedType ?? '');
    _selectedBenchmark = widget.batch.growthTarget ?? 'Default (From Breed)';
    _status = widget.batch.status;
    _type = widget.batch.type;
    _arrivalDate = widget.batch.arrivalDate;
    _selectedHouseId = widget.batch.houseId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF121417),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Edit Unit Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Unit Name / Identity', Icons.edit),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _initialCountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Arrival Quantity', Icons.add_circle_outline),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        onChanged: (v) {
                          // Automatically update current count based on the difference
                          final newInitial = int.tryParse(v) ?? 0;
                          final diff = newInitial - widget.batch.initialCount;
                          _currentCountController.text = (widget.batch.currentCount + diff).toString();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _currentCountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Current Stock', Icons.inventory_2_outlined),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDatePicker(context),
                const SizedBox(height: 16),
                _buildHouseDropdown(context),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  dropdownColor: const Color(0xFF23262B),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Batch Type', Icons.category_outlined),
                  items: const [
                    DropdownMenuItem(value: 'POULTRY_BROILER', child: Text('BROILER')),
                    DropdownMenuItem(value: 'POULTRY_LAYER', child: Text('LAYER')),
                    DropdownMenuItem(value: 'POULTRY_TURKEY', child: Text('TURKEY')),
                    DropdownMenuItem(value: 'POULTRY_DUCK', child: Text('DUCK')),
                    DropdownMenuItem(value: 'POULTRY_OTHER', child: Text('OTHER')),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _breedController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Breed (e.g. Cobb 500)', Icons.pets),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBenchmark,
                  dropdownColor: const Color(0xFF23262B),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Benchmark Override', Icons.speed),
                  items: const [
                    DropdownMenuItem(value: 'Default (From Breed)', child: Text('Default (From Breed)')),
                    DropdownMenuItem(value: 'Ross 308 (Meat)', child: Text('Ross 308 (Meat)')),
                    DropdownMenuItem(value: 'Cobb 500 (Meat)', child: Text('Cobb 500 (Meat)')),
                    DropdownMenuItem(value: 'ISA Brown (Eggs)', child: Text('ISA Brown (Eggs)')),
                    DropdownMenuItem(value: 'Lohmann (Eggs)', child: Text('Lohmann (Eggs)')),
                    DropdownMenuItem(value: 'Ankole (Cattle)', child: Text('Ankole (Cattle)')),
                  ],
                  onChanged: (v) => setState(() => _selectedBenchmark = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  dropdownColor: const Color(0xFF23262B),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Status', Icons.info_outline),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('ACTIVE')),
                    DropdownMenuItem(value: 'completed', child: Text('COMPLETED')),
                    DropdownMenuItem(value: 'archived', child: Text('ARCHIVED')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
          child: const Text('UPDATE UNIT'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      fillColor: const Color(0xFF23262B),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: _arrivalDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (d != null) setState(() => _arrivalDate = d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF23262B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(
              DateFormat('MMM dd, yyyy').format(_arrivalDate),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseDropdown(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return FutureBuilder<int?>(
      future: FarmUtils.getBoundFarmId(),
      builder: (context, farm) {
        if (!farm.hasData) return const SizedBox.shrink();
        return StreamBuilder<List<House>>(
          stream: (db.select(db.houses)..where((t) => t.farmId.equals(farm.data!))).watch(),
          builder: (context, snapshot) {
            final houses = snapshot.data ?? [];
            return DropdownButtonFormField<int?>(
              initialValue: _selectedHouseId,
              dropdownColor: const Color(0xFF23262B),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Assign House', Icons.house_outlined),
              onChanged: (v) {
                if (v == -1) {
                  _showQuickAddHouseDialog(context, db, farm.data!);
                } else {
                  setState(() => _selectedHouseId = v);
                }
              },
              items: [
                const DropdownMenuItem(value: null, child: Text('No House Assigned')),
                ...houses.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))),
                const DropdownMenuItem<int>(
                  value: -1,
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF3B82F6)),
                      SizedBox(width: 8),
                      Text('Add New House', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final db = context.read<AppDatabase>();
    try {
      await (db.update(db.batches)..where((t) => t.id.equals(widget.batch.id))).write(
        BatchesCompanion(
          batchName: Value(_nameController.text),
          initialCount: Value(int.parse(_initialCountController.text)),
          currentCount: Value(int.parse(_currentCountController.text)),
          status: Value(_status),
          type: Value(_type),
          arrivalDate: Value(_arrivalDate),
          houseId: Value(_selectedHouseId),
          breedType: Value(_breedController.text),
          growthTarget: Value(_selectedBenchmark),
          synced: const Value(false),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showQuickAddHouseDialog(BuildContext context, AppDatabase db, int farmId) {
    final houseNameCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121417),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        title: const Text('Add House', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HOUSE NAME', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: houseNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Enter house name', Icons.home_work_outlined),
            ),
            const SizedBox(height: 24),
            const Text('CAPACITY (OPTIONAL)', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: capacityCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('Enter capacity', Icons.people_outline),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
          ),
          FilledButton(
            onPressed: () async {
              if (houseNameCtrl.text.trim().isEmpty) return;
              final cap = int.tryParse(capacityCtrl.text) ?? 1000;
              final userId = await FarmUtils.getUserId() ?? 'local_user';
              
              final houseId = await db.into(db.houses).insert(HousesCompanion.insert(
                farmId: farmId,
                name: houseNameCtrl.text.trim(),
                capacity: cap,
                userId: Value(userId),
                isIsolation: const Value(false),
                synced: const Value(false),
              ));
              
              if (ctx.mounted) {
                ctx.read<SyncEngine>().performSync();
                Navigator.pop(ctx);
                setState(() => _selectedHouseId = houseId);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
