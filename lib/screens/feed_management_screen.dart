import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Table, Batch;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class FeedManagementScreen extends StatefulWidget {
  const FeedManagementScreen({super.key});

  @override
  State<FeedManagementScreen> createState() => _FeedManagementScreenState();
}

class _FeedManagementScreenState extends State<FeedManagementScreen> {
  final ScrollController _tableHorizontalController = ScrollController();

  @override
  void dispose() {
    _tableHorizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium dynamic gradient background matching light/dark modes
    final bgGradient = LinearGradient(
      colors: isDark
          ? [const Color(0xFF020617), const Color(0xFF052E16)]
          : [const Color(0xFFF8FAFC), const Color(0xFFE2F0D9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(db, isDark),
                const SizedBox(height: 40),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final col1Width = (totalWidth - 32) * 2 / 3;
                    final col2Width = (totalWidth - 32) * 1 / 3;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: col1Width,
                          child: Column(
                            children: [
                              _buildFcrCard(db, isDark),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 24,
                                runSpacing: 24,
                                children: [
                                  SizedBox(
                                    width: (col1Width - 24) / 2,
                                    child: _buildQuickActionCard(
                                      title: 'Active Formulations',
                                      icon: Icons.layers_rounded,
                                      iconColor: Colors.amber,
                                      onTap: () => _showActiveFormulationsDialog(db),
                                      isDark: isDark,
                                    ),
                                  ),
                                  SizedBox(
                                    width: (col1Width - 24) / 2,
                                    child: _buildQuickActionCard(
                                      title: 'Inventory Check',
                                      icon: Icons.widgets_outlined,
                                      iconColor: const Color(0xFF0D9488),
                                      onTap: () => _showInventoryCheckDialog(db),
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        SizedBox(
                          width: col2Width,
                          child: _buildIngredientUsageCard(db, isDark),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),
                _buildHistoryCard(db, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeader(AppDatabase db, bool isDark) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feed Management',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'FORMULATION BUILDER & CONSUMPTION EFFICIENCY ANALYTICS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.green.shade400 : const Color(0xFF15803D),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // LOG FEEDING button
            OutlinedButton.icon(
              onPressed: () => _showLogFeedingDialog(db),
              icon: const Icon(Icons.dining_outlined, color: Color(0xFF10B981), size: 18),
              label: const Text(
                'LOG FEEDING',
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(width: 16),
            // CREATE FORMULATION button
            ElevatedButton.icon(
              onPressed: () => _showCreateFormulationDialog(db),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'CREATE FORMULATION',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- CONSUMPTION EFFICIENCY (FCR) CARD ---
  Widget _buildFcrCard(AppDatabase db, bool isDark) {
    final cardBg = isDark ? const Color(0xFF0F172A).withValues(alpha: 0.7) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
    final titleColor = isDark ? Colors.white70 : const Color(0xFF334155);
    final textStyleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white38 : Colors.grey.shade500;
    final warningTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final warningCardBg = isDark ? Colors.green.withValues(alpha: 0.02) : const Color(0xFFF0FDF4);
    final shadowColor = isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.02);

    return StreamBuilder<List<FeedingLog>>(
      stream: db.select(db.feedingLogs).watch(),
      builder: (context, feedSnapshot) {
        return StreamBuilder<List<WeightRecord>>(
          stream: db.select(db.weightRecords).watch(),
          builder: (context, weightSnapshot) {
            final feedings = feedSnapshot.data ?? [];
            final weights = weightSnapshot.data ?? [];

            // Calculate active FCR
            double? averageFcr;
            if (feedings.isNotEmpty && weights.isNotEmpty) {
              final totalFeed = feedings.fold<double>(0.0, (sum, f) => sum + f.amountConsumed);
              // Get average weight in kg
              final totalWeight = weights.fold<double>(0.0, (sum, w) => sum + w.averageWeight);
              final avgWeightKg = (totalWeight / weights.length);
              if (avgWeightKg > 0) {
                averageFcr = totalFeed / (avgWeightKg * 100); // scaled estimation
              }
            }

            return Container(
              height: 240,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  // Vector Line Chart background using custom painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: FcrTrendPainter(isDark: isDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, color: isDark ? Colors.green.shade400 : const Color(0xFF16A34A), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'CONSUMPTION EFFICIENCY (FCR)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (averageFcr == null) ...[
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(16),
                                color: warningCardBg,
                              ),
                              child: Text(
                                'No efficiency data available. Log weights and feedings.',
                                style: TextStyle(color: warningTextColor, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                averageFcr.toStringAsFixed(2),
                                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: textStyleColor, height: 1),
                              ),
                              const SizedBox(width: 12),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'OPTIMAL',
                                    style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Estimated feed conversion efficiency based on current flock weight records and active feeding logs.',
                            style: TextStyle(color: subtitleColor, fontSize: 12),
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- ACTIVE FORMULATIONS & INVENTORY QUICK ACTIONS ---
  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final cardBg = isDark ? const Color(0xFF0F172A).withValues(alpha: 0.7) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final arrowColor = isDark ? Colors.white30 : Colors.grey.shade400;
    final shadowColor = isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.02);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: arrowColor, size: 16),
          ],
        ),
      ),
    );
  }

  // --- INGREDIENT USAGE CARD ---
  Widget _buildIngredientUsageCard(AppDatabase db, bool isDark) {
    final cardBg = isDark ? const Color(0xFF0F172A).withValues(alpha: 0.7) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final labelColor = isDark ? Colors.white70 : const Color(0xFF334155);
    final valueColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final emptyTextColor = isDark ? Colors.white38 : Colors.grey.shade500;
    final progressBg = isDark ? Colors.white10 : Colors.grey.shade200;
    final shadowColor = isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.02);

    return StreamBuilder<List<FeedingLog>>(
      stream: db.select(db.feedingLogs).watch(),
      builder: (context, snapshot) {
        return StreamBuilder<List<FeedFormulation>>(
          stream: db.select(db.feedFormulations).watch(),
          builder: (context, formSnapshot) {
            final logs = snapshot.data ?? [];
            final formulations = formSnapshot.data ?? [];

            // Aggregate ingredient usage
            final Map<String, double> ingredientTotals = {};

            for (var log in logs) {
              if (log.formulationId != null) {
                final form = formulations.firstWhere((f) => f.id == log.formulationId, orElse: () => const FeedFormulation(id: 0, farmId: 0, name: '', isActive: false, synced: false));
                if (form.id != 0 && form.ingredientsJson != null) {
                  try {
                    final Map<String, dynamic> ratios = jsonDecode(form.ingredientsJson!);
                    ratios.forEach((ingredient, percentage) {
                      final parsedPercentage = double.tryParse(percentage.toString()) ?? 0.0;
                      final ingredientUsed = log.amountConsumed * (parsedPercentage / 100.0);
                      ingredientTotals[ingredient] = (ingredientTotals[ingredient] ?? 0.0) + ingredientUsed;
                    });
                  } catch (_) {}
                }
              }
            }

            return Container(
              height: 388,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INGREDIENT USAGE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: titleColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (ingredientTotals.isEmpty) ...[
                    Expanded(
                      child: Center(
                        child: Text(
                          'No ingredients used yet.\nLog feedings with active formulas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: emptyTextColor, fontSize: 13, height: 1.5),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ListView(
                        children: ingredientTotals.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: TextStyle(color: labelColor, fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    Text(
                                      '${entry.value.toStringAsFixed(1)} kg',
                                      style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (entry.value / 1000).clamp(0.0, 1.0), // dynamic scaling
                                    backgroundColor: progressBg,
                                    valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.green.shade400 : const Color(0xFF16A34A)),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- DIALOG: LOG FEEDING ---
  void _showLogFeedingDialog(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int? selectedBatch;
    int? selectedFeedType;
    int? selectedFormulation;
    final amountCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LOG BATCH FEEDING',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Batch Dropdown
                    Text('Select Batch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Batch>>(
                      stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
                      builder: (context, snapshot) {
                        final list = snapshot.data ?? [];
                        return DropdownButtonFormField<int>(
                          dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          items: list.map((b) => DropdownMenuItem(value: b.id, child: Text(b.batchName))).toList(),
                          onChanged: (val) => setDialogState(() => selectedBatch = val),
                          decoration: _dialogInputDecoration('Select Layer/Broiler flock', isDark),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Feed Type Dropdown
                    Text('Feed Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                    const SizedBox(height: 8),
                    StreamBuilder<List<FeedType>>(
                      stream: db.select(db.feedTypes).watch(),
                      builder: (context, snapshot) {
                        final list = snapshot.data ?? [];
                        return DropdownButtonFormField<int>(
                          dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          items: list.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                          onChanged: (val) => setDialogState(() => selectedFeedType = val),
                          decoration: _dialogInputDecoration('Select raw feed ingredient', isDark),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Active Formulation Dropdown
                    Text('Active Formulation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                    const SizedBox(height: 8),
                    StreamBuilder<List<FeedFormulation>>(
                      stream: db.select(db.feedFormulations).watch(),
                      builder: (context, snapshot) {
                        final list = snapshot.data ?? [];
                        return DropdownButtonFormField<int>(
                          dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          items: list.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                          onChanged: (val) => setDialogState(() => selectedFormulation = val),
                          decoration: _dialogInputDecoration('Select feed formula split', isDark),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Log Date picker field
                    Text('Log Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: isDark
                                  ? ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFF10B981),
                                        onPrimary: Colors.white,
                                        surface: Color(0xFF0F172A),
                                        onSurface: Colors.white,
                                      ),
                                    )
                                  : ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF10B981),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.black87,
                                      ),
                                    ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMMM yyyy').format(selectedDate),
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                            ),
                            const Icon(Icons.calendar_today_rounded, color: Color(0xFF10B981), size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Feed Weight Input
                    Text('Amount Consumed (KG)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _dialogInputDecoration('Weight in kilograms', isDark),
                    ),
                    const SizedBox(height: 24),

                    // Submit Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                          if (selectedBatch == null || selectedFeedType == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Please select batch, feed type, and enter amount'),
                              backgroundColor: Colors.orange,
                            ));
                            return;
                          }

                          final farmId = await FarmUtils.getBoundFarmId();
                          if (farmId == null) return;

                          try {
                            await db.transaction(() async {
                              // 1. Insert Feeding log record
                              await db.into(db.feedingLogs).insert(FeedingLogsCompanion.insert(
                                farmId: farmId,
                                batchId: Value(selectedBatch),
                                feedTypeId: Value(selectedFeedType),
                                formulationId: Value(selectedFormulation),
                                amountConsumed: amount,
                                logDate: selectedDate,
                                synced: const Value(false),
                              ));

                              // 2. Decrement corresponding stock levels from FeedTypes
                              final currentFeedList = await (db.select(db.feedTypes)..where((t) => t.id.equals(selectedFeedType!))).get();
                              if (currentFeedList.isNotEmpty) {
                                final feed = currentFeedList.first;
                                await (db.update(db.feedTypes)..where((t) => t.id.equals(selectedFeedType!))).write(
                                  FeedTypesCompanion(
                                    currentStock: Value((feed.currentStock - amount).clamp(0.0, 999999.0)),
                                    synced: const Value(false),
                                  ),
                                );
                              }
                            });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Feeding logged and inventory updated successfully'),
                                backgroundColor: Colors.green,
                              ));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('SUBMIT FEED RECORD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- DIALOG: CREATE FORMULATION ---
  void _showCreateFormulationDialog(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController();
    final List<Map<String, dynamic>> ingredients = [
      {'name': TextEditingController(), 'percentage': TextEditingController()},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double totalPercentage = 0.0;
            try {
              totalPercentage = ingredients.fold<double>(0.0, (sum, item) {
                final p = double.tryParse((item['percentage'] as TextEditingController).text) ?? 0.0;
                return sum + p;
              });
            } catch (_) {}

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CREATE CUSTOM FORMULATION',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Formulation Name Input
                    Text('Formulation Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _dialogInputDecoration('e.g., Layer Starter Formula', isDark),
                    ),
                    const SizedBox(height: 16),

                    // Ingredients Splitter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ingredients Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                        TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              ingredients.add({'name': TextEditingController(), 'percentage': TextEditingController()});
                            });
                          },
                          icon: const Icon(Icons.add, size: 16, color: Color(0xFF10B981)),
                          label: const Text('Add Item', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: ingredients.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: ingredients[index]['name'] as TextEditingController,
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                    decoration: _dialogInputDecoration('Maize, Fishmeal, etc.', isDark),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: ingredients[index]['percentage'] as TextEditingController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                    decoration: _dialogInputDecoration('% ratio', isDark),
                                    onChanged: (_) => setDialogState(() {}),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    setDialogState(() {
                                      ingredients.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total Percentage Tracker Widget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Ratio Allocation:', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(
                          '${totalPercentage.toStringAsFixed(1)}% / 100.0%',
                          style: TextStyle(
                            color: totalPercentage == 100.0 ? (isDark ? Colors.green : const Color(0xFF16A34A)) : (isDark ? Colors.amberAccent : Colors.orange.shade800),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Please name this custom formulation'),
                              backgroundColor: Colors.orange,
                            ));
                            return;
                          }
                          if (totalPercentage != 100.0) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Ingredient ratios must sum to exactly 100%'),
                              backgroundColor: Colors.orange,
                            ));
                            return;
                          }

                          final farmId = await FarmUtils.getBoundFarmId();
                          if (farmId == null) return;

                          // Construct ingredient map JSON
                          final Map<String, double> ratios = {};
                          for (var item in ingredients) {
                            final ingName = (item['name'] as TextEditingController).text.trim();
                            final ingPct = double.tryParse((item['percentage'] as TextEditingController).text) ?? 0.0;
                            if (ingName.isNotEmpty && ingPct > 0) {
                              ratios[ingName] = ingPct;
                            }
                          }

                          try {
                            await db.into(db.feedFormulations).insert(FeedFormulationsCompanion.insert(
                              farmId: farmId,
                              name: name,
                              ingredientsJson: Value(jsonEncode(ratios)),
                              isActive: const Value(true),
                              synced: const Value(false),
                            ));

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Formulation created successfully'),
                                backgroundColor: Colors.green,
                              ));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('SAVE FORMULATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- DIALOG/MODAL: ACTIVE FORMULATIONS VIEW ---
  void _showActiveFormulationsDialog(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE FORMULATIONS',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                StreamBuilder<List<FeedFormulation>>(
                  stream: db.select(db.feedFormulations).watch(),
                  builder: (context, snapshot) {
                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('No formulas created yet. Get started by clicking Create Formulation.', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500)),
                        ),
                      );
                    }

                    return Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final formula = list[index];
                          Map<String, dynamic> ingredientsMap = {};
                          try {
                            ingredientsMap = jsonDecode(formula.ingredientsJson ?? '{}');
                          } catch (_) {}

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formula.name,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () async {
                                        await (db.delete(db.feedFormulations)..where((t) => t.id.equals(formula.id))).go();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Formulation removed')));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: ingredientsMap.entries.map((e) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.green.withValues(alpha: 0.1) : const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${e.key}: ${e.value}%',
                                        style: TextStyle(color: isDark ? Colors.green.shade300 : const Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- DIALOG/MODAL: INVENTORY CHECK VIEW ---
  void _showInventoryCheckDialog(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'INVENTORY CHECK',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Raw Feed Ingredients Add block
                    Text('Quick Add Feed Ingredient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: nameCtrl,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: _dialogInputDecoration('Ingredient Name (e.g., Maize)', isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: _dialogInputDecoration('Initial Stock (KG)', isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            final stock = double.tryParse(stockCtrl.text) ?? 0.0;
                            if (name.isEmpty || stock <= 0) return;

                            final farmId = await FarmUtils.getBoundFarmId();
                            if (farmId == null) return;

                            try {
                              await db.into(db.feedTypes).insert(FeedTypesCompanion.insert(
                                farmId: farmId,
                                name: name,
                                currentStock: Value(stock),
                                synced: const Value(false),
                              ));
                              nameCtrl.clear();
                              stockCtrl.clear();
                              setDialogState(() {});
                            } catch (_) {}
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                          child: const Text('Add', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // List of current items
                    Text('Current Ingredient Stock Levels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                    const SizedBox(height: 12),
                    StreamBuilder<List<FeedType>>(
                      stream: db.select(db.feedTypes).watch(),
                      builder: (context, snapshot) {
                        final list = snapshot.data ?? [];
                        if (list.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: Text('No ingredients in stock.', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500))),
                          );
                        }

                        return Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final item = list[index];
                              final isLow = item.currentStock < 100.0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                                          if (isLow)
                                            Text('LOW STOCK WARNING', style: TextStyle(color: isDark ? Colors.amberAccent : Colors.orange.shade800, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${item.currentStock.toStringAsFixed(1)} kg',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isLow ? (isDark ? Colors.amberAccent : Colors.orange.shade800) : (isDark ? Colors.green.shade400 : const Color(0xFF16A34A)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Restock Quick Action
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981), size: 20),
                                            onPressed: () async {
                                              final restockController = TextEditingController(text: '100.0');
                                              final restockAmount = await showDialog<double>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                                    title: Text('Restock Feed', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('Enter amount to restock ${item.name} in kilograms (KG):', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF475569))),
                                                        const SizedBox(height: 12),
                                                        TextField(
                                                          controller: restockController,
                                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                                          decoration: InputDecoration(
                                                            hintText: 'Weight in KG',
                                                            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                                                            filled: true,
                                                            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade300)),
                                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade300)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          final val = double.tryParse(restockController.text) ?? 0.0;
                                                          Navigator.pop(context, val);
                                                        },
                                                        child: const Text('RESTOCK', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              if (restockAmount != null && restockAmount > 0) {
                                                await (db.update(db.feedTypes)..where((t) => t.id.equals(item.id))).write(
                                                  FeedTypesCompanion(
                                                    currentStock: Value(item.currentStock + restockAmount),
                                                    synced: const Value(false),
                                                  ),
                                                );
                                                setDialogState(() {});
                                              }
                                            },
                                            tooltip: 'Restock Feed',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                            onPressed: () async {
                                              await (db.delete(db.feedTypes)..where((t) => t.id.equals(item.id))).go();
                                              setDialogState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- REUSABLE DROPDOWN DECORATION ---
  InputDecoration _dialogInputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade300),
      ),
    );
  }

  Widget _buildHistoryCard(AppDatabase db, bool isDark) {
    final cardBg = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.7)
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.08);
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'FEEDING HISTORY',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: headingColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),

          StreamBuilder<List<FeedingLog>>(
            stream: (db.select(db.feedingLogs)..orderBy([(t) => OrderingTerm.desc(t.logDate)])).watch(),
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];

              if (logs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_rounded, size: 36, color: subColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                          'No feeding logs registered yet.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Dynamic Batch & FeedType & Formulation lookups mapping id to name
              return FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  db.select(db.batches).get(),
                  db.select(db.feedTypes).get(),
                  db.select(db.feedFormulations).get(),
                ]),
                builder: (context, dynamicSnapshot) {
                  final data = dynamicSnapshot.data;
                  final List<Batch> batches = data != null ? data[0] as List<Batch> : [];
                  final List<FeedType> feedTypes = data != null ? data[1] as List<FeedType> : [];
                  final List<FeedFormulation> formulations = data != null ? data[2] as List<FeedFormulation> : [];

                  final batchMap = {for (var b in batches) b.id: b.batchName};
                  final feedTypeMap = {for (var f in feedTypes) f.id: f.name};
                  final formulationMap = {for (var f in formulations) f.id: f.name};

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Scrollbar(
                        controller: _tableHorizontalController,
                        thumbVisibility: true,
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: SingleChildScrollView(
                            controller: _tableHorizontalController,
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: DataTable(
                              columnSpacing: 36,
                        headingRowColor: WidgetStateProperty.all(
                          isDark
                              ? Colors.white.withValues(alpha: 0.02)
                              : Colors.black.withValues(alpha: 0.02),
                        ),
                        headingRowHeight: 46,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 52,
                        horizontalMargin: 12,
                        columns: [
                          _buildTableColumn('DATE', isDark),
                          _buildTableColumn('FLOCK/BATCH', isDark),
                          _buildTableColumn('FEED TYPE', isDark),
                          _buildTableColumn('FORMULATION', isDark),
                          _buildTableColumn('AMOUNT CONSUMED', isDark),
                          _buildTableColumn('STATUS', isDark),
                          _buildTableColumn('ACTION', isDark),
                        ],
                        rows: logs.map((log) {
                          final batchName = log.batchId != null ? (batchMap[log.batchId] ?? 'Flock #${log.batchId}') : 'Global';
                          final feedTypeName = log.feedTypeId != null ? (feedTypeMap[log.feedTypeId] ?? 'Feed Type #${log.feedTypeId}') : 'N/A';
                          final formulationName = log.formulationId != null ? (formulationMap[log.formulationId] ?? 'Custom Formulation') : 'None';
                          
                          // Synced status
                          final isSynced = log.synced;
                          final statusChipColor = isSynced ? const Color(0xFF10B981) : Colors.orange;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  DateFormat('dd MMM yyyy').format(log.logDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  batchName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  feedTypeName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  formulationName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${log.amountConsumed.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.greenAccent : const Color(0xFF047857),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusChipColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusChipColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Text(
                                    isSynced ? 'SYNCED' : 'OFFLINE',
                                    style: TextStyle(color: statusChipColor, fontSize: 9, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                  onPressed: () => _confirmDeleteFeedingLog(db, log.id),
                                  tooltip: 'Delete log',
                                ),
                              ),
                            ],
                          );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                  },
                );
              },
            );
          },
        ),
      ],
    ),
  );
  }

  DataColumn _buildTableColumn(String label, bool isDark) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white54 : Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _confirmDeleteFeedingLog(AppDatabase db, int logId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          title: Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          content: Text('Are you sure you want to permanently delete this feeding log?', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF475569))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  await (db.delete(db.feedingLogs)..where((t) => t.id.equals(logId))).go();
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Log deleted successfully.'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(20),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}

// --- CUSTOM TREND LINE PAINTER ---
class FcrTrendPainter extends CustomPainter {
  final bool isDark;
  FcrTrendPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: isDark ? 0.08 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.45,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.1,
      size.width,
      size.height * 0.35,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
