import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import '../theme/constants.dart';

class RegisterUnitDialog extends StatefulWidget {
  const RegisterUnitDialog({super.key});

  @override
  State<RegisterUnitDialog> createState() => _RegisterUnitDialogState();
}

class _RegisterUnitDialogState extends State<RegisterUnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _vaccineNameController = TextEditingController();
  
  String? _selectedCategory = 'Poultry (Meat)';
  String? _selectedBreed;
  int? _selectedHouseId;
  DateTime _arrivalDate = DateTime.now();
  DateTime? _vaccinationDate;
  
  final List<String> _categories = [
    'Poultry (Meat)',
    'Poultry (Egg)',
    'Poultry (Dual Purpose)',
    'Turkey',
    'Duck',
    'Other'
  ];

  final List<String> _breeds = [
    'Cobb 500',
    'Ross 308',
    'Lohmann Brown',
    'Isa Brown',
    'Local Breed',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _vaccineNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    
    return Dialog(
      backgroundColor: const Color(0xFF121417),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'REGISTER NEW UNIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'UNIT NAME / IDENTITY',
                        hint: 'e.g., Q1-Broiler-Alpha',
                        controller: _nameController,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField<String>(
                        label: 'LIVESTOCK CATEGORY',
                        value: _selectedCategory,
                        items: _categories,
                        onChanged: (v) => setState(() => _selectedCategory = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField<String>(
                        label: 'PRIMARY BREED / SPECIE',
                        value: _selectedBreed,
                        items: _breeds,
                        onChanged: (v) => setState(() => _selectedBreed = v),
                        hint: 'Select Breed',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'INITIAL QUANTITY',
                        hint: '1000',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (int.tryParse(v) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildHouseDropdown(db),
                const SizedBox(height: 24),
                
                _buildDateField(
                  label: 'ARRIVAL / HATCH DATE',
                  value: _arrivalDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _arrivalDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _arrivalDate = picked);
                  },
                ),
                
                const SizedBox(height: 32),
                const Text(
                  'OPTIONAL INITIAL SCHEDULE',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: '1ST VACCINATION DATE',
                        value: _vaccinationDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _vaccinationDate = picked);
                        },
                        isOptional: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'VACCINE NAME',
                        hint: 'e.g., Gumboro',
                        controller: _vaccineNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _handleSubmit(db),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'REGISTER UNIT & CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF00C853),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            fillColor: const Color(0xFF23262B),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF00C853),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF121417),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            fillColor: const Color(0xFF23262B),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          items: items.map((e) => DropdownMenuItem<T>(
            value: e,
            child: Text(e.toString()),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildHouseDropdown(AppDatabase db) {
    return FutureBuilder<int?>(
      future: FarmUtils.getBoundFarmId(),
      builder: (context, farmSnapshot) {
        if (!farmSnapshot.hasData) return const SizedBox();
        final farmId = farmSnapshot.data!;
        
        return StreamBuilder<List<House>>(
          stream: (db.select(db.houses)..where((t) => t.farmId.equals(farmId))).watch(),
          builder: (context, snapshot) {
            final houses = snapshot.data ?? [];
            return _buildDropdownField<int>(
              label: 'FARM HOUSE',
              value: _selectedHouseId,
              items: houses.map((h) => h.id).toList(),
              onChanged: (v) => setState(() => _selectedHouseId = v),
              hint: houses.isEmpty ? 'No Houses Available' : 'Select House Location',
            );
          },
        );
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF00C853),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF23262B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? DateFormat('MM/dd/yyyy').format(value) : 'mm/dd/yyyy',
                  style: TextStyle(
                    color: value != null ? Colors.white : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(AppDatabase db) async {
    if (!_formKey.currentState!.validate()) return;
    
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No farm bound to this device.')),
      );
      return;
    }

    final quantity = int.parse(_quantityController.text);
    
    try {
      await db.transaction(() async {
        // 1. Create Batch
        final batchId = await db.into(db.batches).insert(
          BatchesCompanion.insert(
            farmId: farmId,
            batchName: Value(_nameController.text),
            type: Value(_mapCategoryToType(_selectedCategory!)),
            breedType: Value(_selectedBreed),
            houseId: Value(_selectedHouseId),
            arrivalDate: _arrivalDate,
            currentCount: quantity,
            initialCount: quantity,
            synced: const Value(false),
          ),
        );

        // 2. Optional Vaccination
        if (_vaccinationDate != null && _vaccineNameController.text.isNotEmpty) {
          await db.into(db.vaccinationSchedules).insert(
            VaccinationSchedulesCompanion.insert(
              batchId: batchId,
              vaccineName: _vaccineNameController.text,
              scheduledDate: _vaccinationDate!,
              farmId: farmId,
              synced: const Value(false),
            ),
          );
        }
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _mapCategoryToType(String category) {
    switch (category) {
      case 'Poultry (Meat)': return 'POULTRY_BROILER';
      case 'Poultry (Egg)': return 'POULTRY_LAYER';
      case 'Turkey': return 'POULTRY_TURKEY';
      case 'Duck': return 'POULTRY_DUCK';
      default: return 'OTHER';
    }
  }
}
