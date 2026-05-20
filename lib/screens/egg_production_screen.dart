import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class EggProductionScreen extends StatefulWidget {
  const EggProductionScreen({super.key});

  @override
  State<EggProductionScreen> createState() => _EggProductionScreenState();
}

class _EggProductionScreenState extends State<EggProductionScreen> {
  late AppDatabase db;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = Provider.of<AppDatabase>(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1113) : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Elegant Header Row
            _buildHeader(isDark),
            const SizedBox(height: 24),

            // Two Column Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 1100;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatsCard(isDark),
                      const SizedBox(height: 24),
                      _buildActiveLayersCard(isDark),
                      const SizedBox(height: 24),
                      _buildHistoryCard(isDark),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Active Layers & Production History)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildActiveLayersCard(isDark),
                          const SizedBox(height: 24),
                          _buildHistoryCard(isDark),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Right Column (Production Stats Card)
                    Expanded(
                      flex: 2,
                      child: _buildStatsCard(isDark),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? Colors.white54 : const Color(0xFF64748B);

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
              'Egg Production',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track daily egg yields across your layer flocks.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: subColor,
              ),
            ),
          ],
        ),

        // Action Buttons Row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // INDEPT MANAGEMENT Button
            OutlinedButton(
              onPressed: () => _showManagementInsights(isDark),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.05),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF0D9488), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'INDEPT MANAGEMENT',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // LOG NEW PRODUCTION Button
            ElevatedButton(
              onPressed: () => _openLogProductionDialog(isDark),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                elevation: 4,
                shadowColor: const Color(0xFF0D9488).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'LOG NEW PRODUCTION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveLayersCard(bool isDark) {
    final cardBg = isDark ? const Color(0xFF161A1D) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? Colors.white54 : const Color(0xFF64748B);

    return StreamBuilder<List<Batch>>(
      stream: (db.select(db.batches)
            ..where((t) => t.type.equals('POULTRY_LAYER'))
            ..where((t) => t.status.equals('active')))
          .watch(),
      builder: (context, snapshot) {
        final flocks = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVE LAYER FLOCKS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: subColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              if (flocks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.layers_clear_outlined, color: subColor.withValues(alpha: 0.4), size: 28),
                      const SizedBox(height: 12),
                      Text(
                        'No active layer batches found.',
                        style: TextStyle(fontSize: 12, color: subColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: flocks.map((f) {
                    final ageDays = DateTime.now().difference(f.arrivalDate).inDays;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      width: 220,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.layers_rounded, color: Color(0xFF0D9488), size: 14),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  f.batchName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _smallStatRow('Breed Type:', f.breedType ?? 'N/A', isDark),
                          const SizedBox(height: 4),
                          _smallStatRow('Flock Size:', '${f.currentCount} Birds', isDark),
                          const SizedBox(height: 4),
                          _smallStatRow('Flock Age:', '$ageDays Days', isDark),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _smallStatRow(String label, String val, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey.shade600, fontWeight: FontWeight.w600)),
        Text(val, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHistoryCard(bool isDark) {
    final cardBg = isDark ? const Color(0xFF161A1D) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? Colors.white54 : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PRODUCTION HISTORY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: subColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),

          StreamBuilder<List<EggProduction>>(
            stream: (db.select(db.eggProductions)..orderBy([(t) => OrderingTerm.desc(t.logDate)])).watch(),
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];

              if (logs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.insert_chart_outlined_rounded, size: 36, color: subColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                          'No egg logs registered yet.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subColor),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Dynamic Batch lookups mapping id to name
              return FutureBuilder<List<Batch>>(
                future: db.select(db.batches).get(),
                builder: (context, batchSnapshot) {
                  final batches = batchSnapshot.data ?? [];
                  final batchMap = {for (var b in batches) b.id: b.batchName};

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Scrollbar(
                        thumbVisibility: true,
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: DataTable(
                              columnSpacing: 28,
                        headingRowColor: WidgetStateProperty.all(isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC)),
                        headingRowHeight: 46,
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 52,
                        horizontalMargin: 12,
                        columns: [
                          _buildTableColumn('DATE', isDark),
                          _buildTableColumn('LIVESTOCK', isDark),
                          _buildTableColumn('STATUS', isDark),
                          _buildTableColumn('SMALL', isDark),
                          _buildTableColumn('MEDIUM', isDark),
                          _buildTableColumn('LARGE', isDark),
                          _buildTableColumn('TOTAL', isDark),
                          _buildTableColumn('UNUSABLE', isDark),
                          _buildTableColumn('ACTION', isDark),
                        ],
                        rows: logs.map((log) {
                          final batchName = batchMap[log.batchId] ?? 'Flock #${log.batchId}';
                          
                          // Parse grades
                          int s = 0, m = 0, l = 0;
                          final qGrade = log.qualityGrade;
                          if (qGrade != null && qGrade.contains('S:')) {
                            final parts = qGrade.split(',');
                            for (var part in parts) {
                              if (part.startsWith('S:')) s = int.tryParse(part.substring(2)) ?? 0;
                              if (part.startsWith('M:')) m = int.tryParse(part.substring(2)) ?? 0;
                              if (part.startsWith('L:')) l = int.tryParse(part.substring(2)) ?? 0;
                            }
                          }

                          // Synced indicator or status chip
                          final isSynced = log.synced;
                          final statusChipColor = isSynced ? const Color(0xFF10B981) : Colors.orange;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  DateFormat('dd MMM yyyy').format(log.logDate),
                                  style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                Text(
                                  batchName,
                                  style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w800),
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
                              DataCell(Text('$s', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600))),
                              DataCell(Text('$m', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600))),
                              DataCell(Text('$l', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600))),
                              DataCell(Text('${log.eggsCollected}', style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w900))),
                              DataCell(Text('${log.unusableCount}', style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w900))),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                  onPressed: () => _confirmDeleteLog(log.id),
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
          color: isDark ? Colors.white38 : const Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
    final cardBg = isDark ? const Color(0xFF161A1D) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return StreamBuilder<List<EggProduction>>(
      stream: db.select(db.eggProductions).watch(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];

        // Sum yields
        int todaySum = 0;
        int weekSum = 0;

        final today = DateTime.now();
        final startOfWeek = today.subtract(const Duration(days: 7));

        for (var log in logs) {
          final isSameDay = log.logDate.year == today.year &&
              log.logDate.month == today.month &&
              log.logDate.day == today.day;
          if (isSameDay) {
            todaySum += log.eggsCollected;
          }
          if (log.logDate.isAfter(startOfWeek)) {
            weekSum += log.eggsCollected;
          }
        }

        // Laying Efficiency
        return StreamBuilder<List<Batch>>(
          stream: (db.select(db.batches)
                ..where((t) => t.type.equals('POULTRY_LAYER'))
                ..where((t) => t.status.equals('active')))
              .watch(),
          builder: (context, flockSnapshot) {
            final activeFlocks = flockSnapshot.data ?? [];
            final totalLayers = activeFlocks.fold(0, (sum, f) => sum + f.currentCount);
            
            double efficiency = 0.0;
            if (totalLayers > 0 && todaySum > 0) {
              efficiency = (todaySum / totalLayers) * 100;
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Orange Header Accent Row
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'PRODUCTION STATS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFEA580C),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Today's Yield Stat
                  _statItem(
                    "Today's Yield",
                    '$todaySum eggs',
                    todaySum > 0 ? 'Normal levels' : 'No records today',
                    const Color(0xFF10B981),
                    isDark,
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),

                  // This Week Sum
                  _statItem(
                    "This Week",
                    '$weekSum eggs',
                    'Cumulative last 7 days',
                    const Color(0xFF3B82F6),
                    isDark,
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),

                  // Laying Efficiency
                  _statItem(
                    "Laying Efficiency",
                    totalLayers > 0 ? '${efficiency.toStringAsFixed(1)}%' : '-- %',
                    'Total Layers: $totalLayers birds',
                    const Color(0xFFF59E0B),
                    isDark,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statItem(String label, String value, String subtitle, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white38 : Colors.grey.shade500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showManagementInsights(bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161A1D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Egg Grading Standards',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _gradeRow('Small (S):', 'Under 53 grams. Typical in early lay batches.'),
              const SizedBox(height: 8),
              _gradeRow('Medium (M):', 'Between 53 to 63 grams. Balanced standard weight.'),
              const SizedBox(height: 8),
              _gradeRow('Large (L):', 'Over 63 grams. Premium classification eggs.'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Maintaining a daily laying standard above 75% is considered peak operational efficiency for layer flocks.',
                        style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  Widget _gradeRow(String grade, String desc) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$grade ', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0D9488))),
          TextSpan(text: desc, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  void _confirmDeleteLog(int logId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text('Are you sure you want to permanently delete this egg production log?'),
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
                  await (db.delete(db.eggProductions)..where((t) => t.id.equals(logId))).go();
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

  void _openLogProductionDialog(bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogEggProductionDialog(db: db, isDark: isDark),
    );
  }
}

class LogEggProductionDialog extends StatefulWidget {
  final AppDatabase db;
  final bool isDark;
  const LogEggProductionDialog({super.key, required this.db, required this.isDark});

  @override
  State<LogEggProductionDialog> createState() => _LogEggProductionDialogState();
}

class _LogEggProductionDialogState extends State<LogEggProductionDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedFlockId;
  
  bool _isCratesMode = false;
  bool _isSorted = false;

  final _totalController = TextEditingController(text: '0');
  final _cratesController = TextEditingController(text: '0');
  final _remainderController = TextEditingController(text: '0');

  final _smallController = TextEditingController(text: '0');
  final _mediumController = TextEditingController(text: '0');
  final _largeController = TextEditingController(text: '0');
  
  final _unusableController = TextEditingController(text: '0');
  
  String _selectedGeneralSize = 'Medium';
  DateTime _logDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _totalController.addListener(_updateState);
    _cratesController.addListener(_updateState);
    _remainderController.addListener(_updateState);
    _smallController.addListener(_updateState);
    _mediumController.addListener(_updateState);
    _largeController.addListener(_updateState);
  }

  @override
  void dispose() {
    _totalController.removeListener(_updateState);
    _cratesController.removeListener(_updateState);
    _remainderController.removeListener(_updateState);
    _smallController.removeListener(_updateState);
    _mediumController.removeListener(_updateState);
    _largeController.removeListener(_updateState);
    _totalController.dispose();
    _cratesController.dispose();
    _remainderController.dispose();
    _smallController.dispose();
    _mediumController.dispose();
    _largeController.dispose();
    _unusableController.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  int get _expectedTotal {
    if (_isCratesMode) {
      final crates = int.tryParse(_cratesController.text) ?? 0;
      final remainder = int.tryParse(_remainderController.text) ?? 0;
      return (crates * 30) + remainder;
    } else {
      return int.tryParse(_totalController.text) ?? 0;
    }
  }

  int get _allocatedTotal {
    final s = int.tryParse(_smallController.text) ?? 0;
    final m = int.tryParse(_mediumController.text) ?? 0;
    final l = int.tryParse(_largeController.text) ?? 0;
    return s + m + l;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF1E293B);
    final inputBg = widget.isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9);
    final primaryColor = const Color(0xFF0D9488);
    final orangeColor = const Color(0xFFF59E0B);

    return AlertDialog(
      backgroundColor: widget.isDark ? const Color(0xFF161A1D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LOG EGG PRODUCTION', style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 18, fontStyle: FontStyle.italic)),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, color: textColor, size: 20),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: Colors.white10),
                const SizedBox(height: 16),
                
                // Livestock selection
                _buildLabel('LIVESTOCK', primaryColor),
                const SizedBox(height: 8),
                StreamBuilder<List<Batch>>(
                  stream: (widget.db.select(widget.db.batches)
                        ..where((t) => t.type.equals('POULTRY_LAYER'))
                        ..where((t) => t.status.equals('active')))
                      .watch(),
                  builder: (context, snapshot) {
                    final flocks = snapshot.data ?? [];
                    return DropdownButtonFormField<int>(
                      dropdownColor: widget.isDark ? const Color(0xFF161A1D) : Colors.white,
                      hint: const Text('Select Livestock'),
                      initialValue: _selectedFlockId,
                      items: flocks.map((f) {
                        return DropdownMenuItem<int>(
                          value: f.id,
                          child: Text(' ( birds)', style: TextStyle(color: textColor, fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedFlockId = val),
                      validator: (v) => v == null ? 'Livestock is required' : null,
                      decoration: _dialogInputDec(inputBg),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Logging Mode
                _buildLabel('LOGGING MODE', Colors.grey),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildToggleButton(
                        label: 'INDIVIDUAL EGGS',
                        isActive: !_isCratesMode,
                        activeColor: orangeColor,
                        onTap: () => setState(() => _isCratesMode = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildToggleButton(
                        label: 'CRATES (30/EA)',
                        isActive: _isCratesMode,
                        activeColor: orangeColor,
                        onTap: () => setState(() => _isCratesMode = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sorting Status
                _buildLabel('SORTING STATUS', Colors.grey),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildToggleButton(
                        label: 'UNSORTED',
                        isActive: !_isSorted,
                        activeColor: primaryColor,
                        onTap: () => setState(() => _isSorted = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildToggleButton(
                        label: 'SORTED',
                        isActive: _isSorted,
                        activeColor: primaryColor,
                        onTap: () => setState(() => _isSorted = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Conditional Inputs
                if (!_isCratesMode) ...[
                  _buildLabel('TOTAL EGGS COLLECTED', primaryColor),
                  const SizedBox(height: 8),
                  _buildNumberInput(_totalController, inputBg),
                ] else ...[
                  _buildLabel('NUMBER OF CRATES', primaryColor),
                  const SizedBox(height: 8),
                  _buildNumberInput(_cratesController, inputBg),
                  const SizedBox(height: 20),
                  
                  _buildLabel('REMAINDER EGGS', primaryColor),
                  const SizedBox(height: 8),
                  _buildNumberInput(_remainderController, inputBg, isRemainder: true),
                ],
                const SizedBox(height: 20),

                if (!_isSorted) ...[
                  _buildLabel('GENERAL EGG SIZE', primaryColor),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    dropdownColor: widget.isDark ? const Color(0xFF161A1D) : Colors.white,
                    value: _selectedGeneralSize,
                    items: ['Small', 'Medium', 'Large'].map((s) {
                      return DropdownMenuItem<String>(value: s, child: Text(s, style: TextStyle(color: textColor, fontSize: 14)));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedGeneralSize = val!),
                    decoration: _dialogInputDec(inputBg),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('SIZE DISTRIBUTION', primaryColor),
                            Text(
                              'Allocated:  / ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _allocatedTotal == _expectedTotal ? primaryColor : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('SMALL', primaryColor),
                        const SizedBox(height: 4),
                        _buildNumberInput(_smallController, inputBg),
                        const SizedBox(height: 12),
                        _buildLabel('MEDIUM', primaryColor),
                        const SizedBox(height: 4),
                        _buildNumberInput(_mediumController, inputBg),
                        const SizedBox(height: 12),
                        _buildLabel('LARGE', primaryColor),
                        const SizedBox(height: 4),
                        _buildNumberInput(_largeController, inputBg),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Unusable count
                _buildLabel('UNUSABLE EGGS (DAMAGED/CRACKED)', primaryColor),
                const SizedBox(height: 8),
                _buildNumberInput(_unusableController, inputBg),
                const SizedBox(height: 20),

                // Log Date
                _buildLabel('LOG DATE', primaryColor),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: _logDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime.now(),
                    );
                    if (selected != null) {
                      setState(() => _logDate = selected);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: widget.isDark ? Colors.white12 : Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(_logDate), style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                        const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(24),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text('SAVE LOG', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: color,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildToggleButton({required String label, required bool isActive, required Color activeColor, required VoidCallback onTap}) {
    final bgColor = isActive ? activeColor : (widget.isDark ? const Color(0xFF2D333B) : const Color(0xFFE2E8F0));
    final textColor = isActive ? (activeColor == const Color(0xFFF59E0B) ? Colors.black87 : Colors.white) : (widget.isDark ? Colors.white54 : Colors.black54);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberInput(TextEditingController controller, Color bg, {bool isRemainder = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: widget.isDark ? Colors.white12 : Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: widget.isDark ? Colors.white12 : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0D9488))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: isRemainder ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.unfold_more, size: 16, color: Colors.grey)]) : null,
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Required';
        if (isRemainder) {
          final num = int.tryParse(val) ?? 0;
          if (num > 29) return 'Max 29';
        }
        return null;
      },
    );
  }

  InputDecoration _dialogInputDec(Color bg) {
    return InputDecoration(
      filled: true,
      fillColor: bg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: widget.isDark ? Colors.white12 : Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: widget.isDark ? Colors.white12 : Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0D9488))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSorted && _allocatedTotal != _expectedTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Allocated eggs (\) must equal total expected (\)')),
      );
      return;
    }

    int s = 0, m = 0, l = 0;
    
    if (_isSorted) {
      s = int.tryParse(_smallController.text) ?? 0;
      m = int.tryParse(_mediumController.text) ?? 0;
      l = int.tryParse(_largeController.text) ?? 0;
    } else {
      // If unsorted, assign all expected total to the selected general size
      final total = _expectedTotal;
      if (_selectedGeneralSize == 'Small') s = total;
      else if (_selectedGeneralSize == 'Medium') m = total;
      else l = total;
    }

    final totalCollected = _expectedTotal;
    final u = int.tryParse(_unusableController.text) ?? 0;
    
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null) return;

    final serializedGrades = 'S:,M:,L:';

    try {
      await widget.db.into(widget.db.eggProductions).insert(
            EggProductionsCompanion.insert(
              farmId: farmId,
              batchId: _selectedFlockId!,
              eggsCollected: totalCollected,
              unusableCount: Value(u),
              qualityGrade: Value(serializedGrades),
              logDate: _logDate,
              synced: const Value(false),
            ),
          );

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Egg production logged successfully!'),
          backgroundColor: const Color(0xFF0D9488),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: ')));
    }
  }
}
