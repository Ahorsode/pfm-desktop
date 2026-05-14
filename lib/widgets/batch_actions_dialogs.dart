import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:provider/provider.dart';
import '../data/local_db.dart';
import '../utils/farm_utils.dart';

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
    return AlertDialog(
      backgroundColor: const Color(0xFF121417),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.coronavirus_outlined, color: Color(0xFFEF4444), size: 24),
          SizedBox(width: 12),
          Text('Record Mortality', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Recording mortality for ${widget.batch.batchName}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _countController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Number of Birds Lost', Icons.remove_circle_outline),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final count = int.tryParse(v) ?? 0;
                if (count <= 0) return 'Must be > 0';
                if (count > widget.batch.currentCount) return 'Cannot exceed current count';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Reason (Optional)', Icons.notes),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
          child: const Text('RECORD LOSS'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      fillColor: const Color(0xFF23262B),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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
  late TextEditingController _countController;
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
    _countController = TextEditingController(text: widget.batch.currentCount.toString());
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
                        controller: _countController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Current Count', Icons.numbers),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDatePicker(context),
                    ),
                  ],
                ),
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
              items: [
                const DropdownMenuItem(value: null, child: Text('No House Assigned')),
                ...houses.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))),
              ],
              onChanged: (v) => setState(() => _selectedHouseId = v),
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
          currentCount: Value(int.parse(_countController.text)),
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
}
