import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../services/batch_analytics_processor.dart';
import 'main_scaffold.dart';

class ComparativeAnalyticsScreen extends StatefulWidget {
  const ComparativeAnalyticsScreen({super.key});

  @override
  State<ComparativeAnalyticsScreen> createState() =>
      _ComparativeAnalyticsScreenState();
}

class _ComparativeAnalyticsScreenState
    extends State<ComparativeAnalyticsScreen> {
  late AppDatabase db;
  Future<List<BatchPerformanceSnapshot>>? _analyticsFuture;
  String? _selectedBatchId;

  final _currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = Provider.of<AppDatabase>(context);
    _analyticsFuture ??= BatchAnalyticsProcessor.load(db);
  }

  void _refreshAnalytics() {
    setState(() {
      _analyticsFuture = BatchAnalyticsProcessor.load(db);
    });
  }

  BatchPerformanceSnapshot? _selectedSnapshot(
    List<BatchPerformanceSnapshot> snapshots,
  ) {
    if (snapshots.isEmpty) return null;
    final active = snapshots.where((s) => s.status == 'active').toList();
    final candidates = active.isEmpty ? snapshots : active;
    final selectedId = _selectedBatchId;
    final selected = selectedId == null
        ? null
        : candidates.where((s) => s.batchId == selectedId).firstOrNull;
    final resolved = selected ?? candidates.first;
    _selectedBatchId = resolved.batchId;
    return resolved;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF6F8FB);

    return Scaffold(
      backgroundColor: bg,
      body: FutureBuilder<List<BatchPerformanceSnapshot>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final snapshots = snapshot.data ?? const <BatchPerformanceSnapshot>[];
          final selected = _selectedSnapshot(snapshots);

          return Row(
            children: [
              _BatchAnalyticsRail(
                snapshots: snapshots,
                selectedBatchId: selected?.batchId,
                onSelect: (id) => setState(() => _selectedBatchId = id),
              ),
              Expanded(
                child: selected == null
                    ? _EmptyAnalyticsState(onRefresh: _refreshAnalytics)
                    : _AnalyticsWorkspace(
                        selected: selected,
                        snapshots: snapshots,
                        currency: _currency,
                        onRefresh: _refreshAnalytics,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BatchAnalyticsRail extends StatelessWidget {
  final List<BatchPerformanceSnapshot> snapshots;
  final String? selectedBatchId;
  final ValueChanged<String> onSelect;

  const _BatchAnalyticsRail({
    required this.snapshots,
    required this.selectedBatchId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final railBg = isDark ? const Color(0xFF101827) : Colors.white;
    final border = isDark ? const Color(0xFF253044) : const Color(0xFFE2E8F0);
    final active = snapshots.where((s) => s.status == 'active').toList();
    final display = active.isEmpty ? snapshots : active;

    return Container(
      width: 326,
      decoration: BoxDecoration(
        color: railBg,
        border: Border(right: BorderSide(color: border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to Livestock',
                  onPressed: () =>
                      MainScaffold.of(context)?.setSelectedIndex(1),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batch Reports',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${display.length} active data streams',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: border),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
            child: Text(
              'ACTIVE BATCHES',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
          Expanded(
            child: display.isEmpty
                ? Center(
                    child: Text(
                      'No batches found',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                    itemCount: display.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final batch = display[index];
                      final selected = batch.batchId == selectedBatchId;
                      final danger = batch.mortalityRate > 5.0;
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => onSelect(batch.batchId),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(
                                    0xFF16A34A,
                                  ).withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? const Color(
                                      0xFF16A34A,
                                    ).withValues(alpha: 0.35)
                                  : border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      batch.batchName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    danger
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle_rounded,
                                    size: 16,
                                    color: danger
                                        ? const Color(0xFFE8833A)
                                        : const Color(0xFF16A34A),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _RailMetric(
                                    label: 'FCR',
                                    value: batch.currentFcr > 0
                                        ? batch.currentFcr.toStringAsFixed(2)
                                        : 'N/A',
                                  ),
                                  _RailMetric(
                                    label: 'Loss',
                                    value:
                                        '${batch.mortalityRate.toStringAsFixed(1)}%',
                                  ),
                                  _RailMetric(
                                    label: 'Birds',
                                    value: '${batch.currentCount}',
                                  ),
                                ],
                              ),
                            ],
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
}

class _RailMetric extends StatelessWidget {
  final String label;
  final String value;

  const _RailMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsWorkspace extends StatelessWidget {
  final BatchPerformanceSnapshot selected;
  final List<BatchPerformanceSnapshot> snapshots;
  final NumberFormat currency;
  final VoidCallback onRefresh;

  const _AnalyticsWorkspace({
    required this.selected,
    required this.snapshots,
    required this.currency,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF253044) : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WorkspaceHeader(selected: selected, onRefresh: onRefresh),
          const SizedBox(height: 16),
          _KpiStrip(selected: selected, currency: currency),
          const SizedBox(height: 16),
          Expanded(
            flex: 7,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useColumns = constraints.maxWidth >= 980;
                if (!useColumns) {
                  return ListView(
                    children: [
                      SizedBox(
                        height: 300,
                        child: _FcrTrendPanel(snapshot: selected),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: _MortalityGaugePanel(snapshot: selected),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: _FinancialBarsPanel(
                          snapshot: selected,
                          currency: currency,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: _FcrTrendPanel(snapshot: selected)),
                    const SizedBox(width: 14),
                    Expanded(child: _MortalityGaugePanel(snapshot: selected)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _FinancialBarsPanel(
                        snapshot: selected,
                        currency: currency,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: _BatchComparisonTable(
              snapshots: snapshots,
              selectedBatchId: selected.batchId,
              currency: currency,
              border: border,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  final BatchPerformanceSnapshot selected;
  final VoidCallback onRefresh;

  const _WorkspaceHeader({required this.selected, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selected.batchName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${selected.type.replaceAll('POULTRY_', '')} • ${selected.currentCount} current birds • ${selected.totalFeedKg.toStringAsFixed(1)} kg feed logged',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('REFRESH'),
        ),
      ],
    );
  }
}

class _KpiStrip extends StatelessWidget {
  final BatchPerformanceSnapshot selected;
  final NumberFormat currency;

  const _KpiStrip({required this.selected, required this.currency});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Row(
        children: [
          Expanded(
            child: _KpiTile(
              label: 'Current FCR',
              value: selected.currentFcr > 0
                  ? selected.currentFcr.toStringAsFixed(2)
                  : 'N/A',
              icon: Icons.restaurant_rounded,
              color: const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KpiTile(
              label: 'Mortality',
              value: '${selected.mortalityRate.toStringAsFixed(2)}%',
              icon: Icons.monitor_heart_outlined,
              color: selected.mortalityRate <= 5
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFE8833A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KpiTile(
              label: 'Net Profit',
              value: currency.format(selected.netProfitability),
              icon: Icons.account_balance_wallet_rounded,
              color: selected.netProfitability >= 0
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KpiTile(
              label: 'Gross Revenue',
              value: currency.format(selected.grossRevenue),
              icon: Icons.point_of_sale_rounded,
              color: const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF253044) : const Color(0xFFE2E8F0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FcrTrendPanel extends StatelessWidget {
  final BatchPerformanceSnapshot snapshot;

  const _FcrTrendPanel({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final points = snapshot.weeklyFcr;
    final maxY = points.isEmpty
        ? 3.0
        : points.map((p) => p.fcr).reduce((a, b) => a > b ? a : b) * 1.2;

    return _AnalyticsPanel(
      title: 'FCR Trend Analysis',
      icon: Icons.show_chart_rounded,
      child: points.isEmpty
          ? const _PanelEmptyState('Log feed plus egg or weight records')
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY <= 0 ? 3.0 : maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.35),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final index = spot.x.toInt() - 1;
                        final safeIndex = index
                            .clamp(0, points.length - 1)
                            .toInt();
                        final point = points[safeIndex];
                        return LineTooltipItem(
                          'Week ${point.week}\nFCR ${point.fcr.toStringAsFixed(3)}\nFeed ${point.feedKg.toStringAsFixed(1)} kg',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            'W${value.toInt()}',
                            style: const TextStyle(
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
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: points
                        .map(
                          (point) => FlSpot(point.week.toDouble(), point.fcr),
                        )
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFF16A34A),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MortalityGaugePanel extends StatelessWidget {
  final BatchPerformanceSnapshot snapshot;

  const _MortalityGaugePanel({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final rate = snapshot.mortalityRate.clamp(0, 100).toDouble();
    final healthy = rate <= 5.0;
    final color = healthy ? const Color(0xFF16A34A) : const Color(0xFFE8833A);

    return _AnalyticsPanel(
      title: 'Mortality Monitoring',
      icon: Icons.monitor_heart_outlined,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    centerSpaceRadius: 58,
                    sectionsSpace: 2,
                    sections: [
                      PieChartSectionData(
                        value: rate <= 0 ? 0.01 : rate,
                        color: color,
                        showTitle: false,
                        radius: 28,
                      ),
                      PieChartSectionData(
                        value: (100 - rate).clamp(0.01, 100).toDouble(),
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.22),
                        showTitle: false,
                        radius: 28,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${snapshot.mortalityRate.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      healthy ? 'WITHIN LIMIT' : 'REVIEW NOW',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _MetricLine(
            label: 'Dead birds logged',
            value: '${snapshot.totalDeadBirds} of ${snapshot.initialCount}',
          ),
          _MetricLine(
            label: 'Threshold',
            value: healthy ? '<= 5% success band' : '> 5% warning band',
          ),
        ],
      ),
    );
  }
}

class _FinancialBarsPanel extends StatelessWidget {
  final BatchPerformanceSnapshot snapshot;
  final NumberFormat currency;

  const _FinancialBarsPanel({required this.snapshot, required this.currency});

  @override
  Widget build(BuildContext context) {
    final maxY =
        [
          snapshot.totalCosts,
          snapshot.grossRevenue,
        ].reduce((a, b) => a > b ? a : b) *
        1.25;

    return _AnalyticsPanel(
      title: 'Financial Comparison',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY <= 0 ? 100 : maxY,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.35),
                    strokeWidth: 1,
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = group.x == 0 ? 'Total Costs' : 'Revenue';
                      return BarTooltipItem(
                        '$label\n${currency.format(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toInt() == 0 ? 'Costs' : 'Revenue',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: snapshot.totalCosts,
                        color: const Color(0xFFDC2626),
                        width: 38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: snapshot.grossRevenue,
                        color: const Color(0xFF2563EB),
                        width: 38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _MetricLine(
            label: 'Direct expenses',
            value: currency.format(snapshot.directExpenses),
          ),
          _MetricLine(
            label: 'Allocated shared expenses',
            value: currency.format(snapshot.allocatedSharedExpenses),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _AnalyticsPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF253044) : const Color(0xFFE2E8F0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;

  const _MetricLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchComparisonTable extends StatelessWidget {
  final List<BatchPerformanceSnapshot> snapshots;
  final String selectedBatchId;
  final NumberFormat currency;
  final Color border;

  const _BatchComparisonTable({
    required this.snapshots,
    required this.selectedBatchId,
    required this.currency,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = snapshots.where((s) => s.status == 'active').toList();
    final rows = active.isEmpty ? snapshots : active;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _TableHeader('Batch')),
                Expanded(child: _TableHeader('FCR')),
                Expanded(child: _TableHeader('Mortality')),
                Expanded(flex: 2, child: _TableHeader('Revenue')),
                Expanded(flex: 2, child: _TableHeader('Costs')),
                Expanded(flex: 2, child: _TableHeader('Net')),
              ],
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? const _PanelEmptyState('No batch data available')
                : ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final selected = row.batchId == selectedBatchId;
                      final color = selected
                          ? const Color(0xFF16A34A).withValues(alpha: 0.08)
                          : Colors.transparent;
                      return Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        color: color,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                row.batchName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _TableCell(
                                row.currentFcr > 0
                                    ? row.currentFcr.toStringAsFixed(2)
                                    : 'N/A',
                              ),
                            ),
                            Expanded(
                              child: _TableCell(
                                '${row.mortalityRate.toStringAsFixed(1)}%',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _TableCell(
                                currency.format(row.grossRevenue),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _TableCell(
                                currency.format(row.totalCosts),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _TableCell(
                                currency.format(row.netProfitability),
                                color: row.netProfitability >= 0
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;

  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String value;
  final Color? color;

  const _TableCell(this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color ?? Theme.of(context).colorScheme.onSurface,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PanelEmptyState extends StatelessWidget {
  final String text;

  const _PanelEmptyState(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyAnalyticsState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyAnalyticsState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 42,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No local batch analytics available',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('REFRESH'),
          ),
        ],
      ),
    );
  }
}
