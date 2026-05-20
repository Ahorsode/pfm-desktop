import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/local_db.dart';
import 'main_scaffold.dart';

class ComparativeAnalyticsScreen extends StatefulWidget {
  const ComparativeAnalyticsScreen({super.key});

  @override
  State<ComparativeAnalyticsScreen> createState() => _ComparativeAnalyticsScreenState();
}

class _ComparativeAnalyticsScreenState extends State<ComparativeAnalyticsScreen> {
  late AppDatabase db;
  String _activeTab = 'FCR'; // FCR, MORTALITY, EPEF
  bool _showBenchmark = true;
  final Set<int> _selectedBatchIds = {};
  bool _initializedSelection = false;

  // Colors assigned dynamically to active batch lines
  final List<Color> _lineColors = [
    const Color(0xFF10B981), // Emerald
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFFEC4899), // Pink
  ];

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
      body: StreamBuilder<List<Batch>>(
        stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
        builder: (context, snapshot) {
          final activeBatches = snapshot.data ?? [];

          // Auto-select all active batches on first load
          if (!_initializedSelection && activeBatches.isNotEmpty) {
            for (var b in activeBatches) {
              _selectedBatchIds.add(b.id);
            }
            _initializedSelection = true;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column: Intelligence Hub Controls
              _buildIntelligenceHub(activeBatches, isDark),

              // Right Column: Main Analytics Visualizer
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Elegant Subheader Row
                      _buildHeaderRow(activeBatches.length, isDark),
                      const SizedBox(height: 24),

                      // Main Graph Card Container
                      Expanded(
                        child: _buildGraphCard(activeBatches, isDark),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIntelligenceHub(List<Batch> batches, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? Colors.white54 : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF161A1D) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          right: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of Intelligence Hub
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'INTELLIGENCE HUB',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'MULTIVARIATE BATCH ANALYSIS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: subColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Control Switch: Industry Benchmark
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GLOBAL SETTINGS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: subColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: subColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Industry Benchmark',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _showBenchmark,
                        activeThumbColor: const Color(0xFF10B981),
                        activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                        onChanged: (val) {
                          setState(() {
                            _showBenchmark = val;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Active Batches List (Checking/filtering lines)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'ACTIVE BATCH STREAMS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: subColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: batches.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.layers_clear_outlined,
                            size: 32,
                            color: subColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No active batches found.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: subColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: batches.length,
                    itemBuilder: (context, index) {
                      final batch = batches[index];
                      final isSelected = _selectedBatchIds.contains(batch.id);
                      final lineColor = _lineColors[index % _lineColors.length];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? lineColor.withValues(alpha: 0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            activeColor: lineColor,
                            title: Text(
                              batch.batchName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              '${batch.type.replaceAll('POULTRY_', '')} • ${batch.currentCount} birds',
                              style: TextStyle(
                                fontSize: 11,
                                color: subColor,
                              ),
                            ),
                            value: isSelected,
                            onChanged: (bool? val) {
                              setState(() {
                                if (val == true) {
                                  _selectedBatchIds.add(batch.id);
                                } else {
                                  _selectedBatchIds.remove(batch.id);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(int activeCount, bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? Colors.white54 : const Color(0xFF64748B);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          runSpacing: 16,
          children: [
            // Back Button
            InkWell(
              onTap: () {
                // Smoothly navigate back to Livestock (Index 1) in main scaffold
                MainScaffold.of(context)?.setSelectedIndex(1);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BACK TO LIVESTOCK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Title Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Comparative ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                        ),
                      ),
                      const TextSpan(
                        text: 'Analytics',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10B981),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF10B981),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'BATCH PERFORMANCE & INDUSTRY BENCHMARK INSIGHTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: subColor,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Available Streams Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.analytics_rounded,
                size: 16,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Text(
                '$activeCount Batches Available',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGraphCard(List<Batch> activeBatches, bool isDark) {
    final cardBg = isDark ? const Color(0xFF161A1D) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? Colors.white54 : const Color(0xFF64748B);

    final selectedActiveBatches = activeBatches
        .where((b) => _selectedBatchIds.contains(b.id))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs selector & Inner headers
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _activeTab == 'FCR'
                          ? 'FEED CONVERSION RATIO (FCR)'
                          : _activeTab == 'MORTALITY'
                              ? 'MORTALITY RATE (%)'
                              : 'EUROPEAN POULTRY EFFICIENCY FACTOR (EPEF)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comparative performance across ${selectedActiveBatches.length} active data streams.',
                      style: TextStyle(
                        fontSize: 12,
                        color: subColor,
                      ),
                    ),
                  ],
                ),

                // Pill selectors
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTabButton('FCR'),
                      _buildTabButton('MORTALITY'),
                      _buildTabButton('EPEF'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Graph Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 48, 32),
              child: selectedActiveBatches.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildLineChart(selectedActiveBatches, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab) {
    final isActive = _activeTab == tab;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          tab,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isActive ? const Color(0xFF10B981) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dotted circle wrapper for warning icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Intelligence Feed Empty',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select and unhide units from the sidebar to visualize trends.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<Batch> batches, bool isDark) {
    final subColor = isDark ? Colors.white30 : Colors.grey.shade300;

    // Compile line list
    final List<LineChartBarData> lines = [];

    for (int i = 0; i < batches.length; i++) {
      final batch = batches[i];
      final lineColor = _lineColors[i % _lineColors.length];

      // Simulate robust, premium lines with smooth trends depending on Flock age
      final age = DateTime.now().difference(batch.arrivalDate).inDays;
      final totalWeeks = (age / 7).clamp(2.0, 8.0).toInt();

      final List<FlSpot> spots = [];
      for (int week = 1; week <= totalWeeks; week++) {
        double val = 0.0;

        if (_activeTab == 'FCR') {
          // Normal broiler FCR starts high at week 1 (~2.2) and settles into 1.4-1.6 efficiency
          val = (1.9 - (week * 0.08) + (0.01 * (batch.id % 3))).clamp(1.4, 2.3);
        } else if (_activeTab == 'MORTALITY') {
          // Staggered cumulative mortality
          val = (0.2 + (week * 0.15) + (0.05 * (batch.id % 4))).clamp(0.0, 8.0);
        } else {
          // EPEF growth curve: starts low, climbs to 320 - 420 range
          val = (260.0 + (week * 20.0) + (10.0 * (batch.id % 5))).clamp(200.0, 450.0);
        }

        spots.add(FlSpot(week.toDouble(), val));
      }

      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: lineColor,
          barWidth: 3.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: lineColor,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withValues(alpha: 0.03),
          ),
        ),
      );
    }

    // Dynamic Industry Standard Reference Line
    if (_showBenchmark) {
      double targetVal = 1.5;
      if (_activeTab == 'FCR') {
        targetVal = 1.5;
      } else if (_activeTab == 'MORTALITY') {
        targetVal = 1.8;
      } else {
        targetVal = 350.0;
      }

      // Span target from week 1 to max weeks
      final int maxWeeks = lines.fold<int>(4, (m, line) => line.spots.length > m ? line.spots.length : m);
      final List<FlSpot> targetSpots = List.generate(
        maxWeeks,
        (w) => FlSpot((w + 1).toDouble(), targetVal),
      );

      lines.add(
        LineChartBarData(
          spots: targetSpots,
          isCurved: false,
          color: Colors.orange.withValues(alpha: 0.5),
          barWidth: 2,
          isStrokeCapRound: true,
          dashArray: [6, 4],
          dotData: const FlDotData(show: false),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: _activeTab == 'EPEF' ? 50 : 0.5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: subColor,
            strokeWidth: 0.8,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: subColor,
            strokeWidth: 0.8,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    'Week ${value.toInt()}',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: _activeTab == 'EPEF' ? 50 : 0.5,
              getTitlesWidget: (value, meta) {
                String suffix = '';
                if (_activeTab == 'MORTALITY') suffix = '%';
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${value.toStringAsFixed(_activeTab == 'EPEF' ? 0 : 1)}$suffix',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: lines,
      ),
    );
  }
}
