import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import '../data/local_db.dart';

class FinancialInitDialog extends StatefulWidget {
  final Batch batch;
  const FinancialInitDialog({super.key, required this.batch});

  @override
  State<FinancialInitDialog> createState() => _FinancialInitDialogState();
}

class _FinancialInitDialogState extends State<FinancialInitDialog> {
  final _costPerUnitController = TextEditingController();
  final _carriageController = TextEditingController();
  final _otherExpensesController = TextEditingController();
  
  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _costPerUnitController.addListener(_calculateTotal);
    _carriageController.addListener(_calculateTotal);
    _otherExpensesController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final qty = widget.batch.initialCount;
    final cpu = double.tryParse(_costPerUnitController.text) ?? 0.0;
    final carriage = double.tryParse(_carriageController.text) ?? 0.0;
    final other = double.tryParse(_otherExpensesController.text) ?? 0.0;
    
    setState(() {
      _totalCost = (qty * cpu) + carriage + other;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 550,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),
  
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Batch Summary Card
                      _buildBatchSummary(),
                      const SizedBox(height: 32),
  
                      // Form Fields
                      _buildInputField('Cost Per Unit (Bird)', _costPerUnitController, Icons.payments_outlined),
                      const SizedBox(height: 24),
                      _buildInputField('Carriage / Transport', _carriageController, Icons.local_shipping_outlined),
                      const SizedBox(height: 24),
                      _buildInputField('Other Direct Expenses', _otherExpensesController, Icons.more_horiz_rounded),
                      
                      const SizedBox(height: 32),
                      Divider(color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 24),
  
                      // Total Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL ACTUAL COST', 
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF94A3B8), letterSpacing: 1)),
                              SizedBox(height: 4),
                              Text('COMBINED BATCH VALUATION', 
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 9, color: Color(0xFF64748B), letterSpacing: 0.5)),
                            ],
                          ),
                          Text(NumberFormat.currency(symbol: 'GH₵ ').format(_totalCost), 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF10B981), letterSpacing: -1)),
                        ],
                      ),
  
                      const SizedBox(height: 40),
  
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                              child: const Text('SKIP FOR NOW', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: () => _saveCosts(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('SAVE INITIAL COSTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.amber, size: 28),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FINANCIAL INITIALIZATION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'SET UP INITIAL BATCH COSTS',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BATCH NAME', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(widget.batch.batchName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
            ],
          ),
          const Spacer(),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('INITIAL QUANTITY', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('${widget.batch.initialCount} birds', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF10B981))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF10B981), letterSpacing: 1)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            prefixText: 'GH₵ ',
            prefixStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(18),
          ),
        ),
      ],
    );
  }

  Future<void> _saveCosts(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    
    try {
      await (db.update(db.batches)..where((t) => t.id.equals(widget.batch.id)))
        .write(BatchesCompanion(
          initialActualCost: Value(_totalCost),
          updatedAt: Value(DateTime.now()),
        ));
      
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      
      messenger.showSnackBar(const SnackBar(
        content: Text('Financial data initialized successfully'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
