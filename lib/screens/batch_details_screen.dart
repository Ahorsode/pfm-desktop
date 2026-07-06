import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:provider/provider.dart';
import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import '../utils/growth_utils.dart';
import '../utils/livestock_breed_options.dart';
import '../utils/mortality_log_utils.dart';
import '../widgets/batch_actions_dialogs.dart';
import 'package:fl_chart/fl_chart.dart';

class BatchDetailsScreen extends StatefulWidget {
  final Batch batch;
  const BatchDetailsScreen({super.key, required this.batch});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  late AppDatabase db;
  List<WeightRecord> _weightRecords = [];
  int _totalMortality = 0;
  double _totalFeed = 0.0;
  double _totalSales = 0.0;
  double _fcr = 0.0;
  double _mortalityRate = 0.0;
  GrowthPerformance? _growthPerformance;
  bool _showFinancials = false;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    final mortality = await (db.select(
      db.mortalities,
    )..where((t) => t.batchId.equals(widget.batch.id))).get();
    final feeding = await (db.select(
      db.feedingLogs,
    )..where((t) => t.batchId.equals(widget.batch.id))).get();
    final weights =
        await (db.select(db.weightRecords)
              ..where((t) => t.batchId.equals(widget.batch.id))
              ..orderBy([(t) => OrderingTerm.desc(t.logDate)]))
            .get();
    final sales = await (db.select(
      db.sales,
    )..where((t) => t.batchId.equals(widget.batch.id))).get();
    final canView = await FarmUtils.canViewFinancials();

    final deadCount = mortality
        .where(
          (m) => isDeadMortalityRecord(
            healthType: m.healthType,
            category: m.category,
          ),
        )
        .fold(0, (sum, m) => sum + m.count);
    final totalFeed = feeding.fold(0.0, (sum, f) => sum + f.amountConsumed);
    final latestWeight =
        weights.isNotEmpty ? weights.first.averageWeight : 0.0;
    final fcr = latestWeight > 0 && widget.batch.currentCount > 0
        ? totalFeed / (widget.batch.currentCount * latestWeight)
        : 0.0;
    final mortalityRate = widget.batch.initialCount > 0
        ? (deadCount / widget.batch.initialCount) * 100
        : 0.0;
    final growth = latestWeight > 0
        ? calculateGrowthPerformance(
            hatchDate: widget.batch.arrivalDate,
            currentWeight: latestWeight,
          )
        : null;

    if (mounted) {
      setState(() {
        _totalMortality = deadCount;
        _totalFeed = totalFeed;
        _weightRecords = weights.reversed.toList();
        _totalSales = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
        _fcr = fcr;
        _mortalityRate = mortalityRate;
        _growthPerformance = growth;
        _showFinancials = canView;
      });
    }
  }


  Widget _buildMetricsRow(bool isNarrow) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cards = [
      _metricCard(
        'Feed Conversion (FCR)',
        _fcr > 0 ? _fcr.toStringAsFixed(2) : '---',
        '${_totalFeed.toStringAsFixed(0)} bags fed',
        Icons.show_chart,
        const Color(0xFFF59E0B),
        isDark,
      ),
      _metricCard(
        'Mortality Rate',
        '${_mortalityRate.toStringAsFixed(1)}%',
        '$_totalMortality total deaths',
        Icons.coronavirus_outlined,
        const Color(0xFFEF4444),
        isDark,
      ),
      if (_growthPerformance != null)
        _metricCard(
          'Growth Progress',
          '${_growthPerformance!.weightPerformance.toStringAsFixed(0)}%',
          'Target ${_growthPerformance!.targetWeight.toStringAsFixed(2)} kg',
          Icons.trending_up,
          _growthPerformance!.status == GrowthStatus.critical
              ? const Color(0xFFEF4444)
              : _growthPerformance!.status == GrowthStatus.deviated
              ? const Color(0xFFF59E0B)
              : const Color(0xFF10B981),
          isDark,
        ),
    ];

    if (isNarrow) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }

  Widget _metricCard(
    String title,
    String value,
    String subtext,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D21) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  subtext,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(widget.batch.arrivalDate).inDays;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1113)
          : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        title: Text(
          widget.batch.batchName,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        actions: [
          _buildStatusChip(widget.batch.status),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 850;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isNarrow ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(age, isNarrow),
                const SizedBox(height: 16),
                _buildMetricsRow(isNarrow),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 24),
                if (isNarrow) ...[
                  _buildMainStats(isNarrow),
                  const SizedBox(height: 24),
                  _buildSideInfo(isNarrow),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildMainStats(isNarrow)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildSideInfo(isNarrow)),
                    ],
                  ),
                const SizedBox(height: 24),
                _buildActivitySection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = status == 'active' ? const Color(0xFF10B981) : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildHeroHeader(int age, bool isNarrow) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isNarrow) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D21) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 150,
              child: _heroStat(
                'Stock',
                '${widget.batch.currentCount}',
                Icons.inventory_2_outlined,
              ),
            ),
            SizedBox(
              width: 150,
              child: _heroStat(
                'Age',
                '$age Days',
                Icons.calendar_today_outlined,
              ),
            ),
            SizedBox(
              width: 150,
              child: _heroStat(
                'Initial',
                '${widget.batch.initialCount}',
                Icons.add_circle_outline,
              ),
            ),
            SizedBox(
              width: 150,
              child: _heroStat(
                'Breed',
                LivestockBreedCatalog.labelForKey(widget.batch.breedType),
                Icons.pets_outlined,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D21) : Colors.white,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.1),
            isDark ? Colors.transparent : Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _heroStat(
              'Current Stock',
              '${widget.batch.currentCount}',
              Icons.inventory_2_outlined,
            ),
          ),
          _divider(),
          Expanded(
            child: _heroStat('Age', '$age Days', Icons.calendar_today_outlined),
          ),
          _divider(),
          Expanded(
            child: _heroStat(
              'Initial Count',
              '${widget.batch.initialCount}',
              Icons.add_circle_outline,
            ),
          ),
          _divider(),
          Expanded(
            child: _heroStat(
              'Breed',
              LivestockBreedCatalog.labelForKey(widget.batch.breedType),
              Icons.pets_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(
          icon,
          color: isDark ? Colors.grey : Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey : Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: Colors.white12);

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _actionBtn(
            'Record Mortality',
            Icons.coronavirus_outlined,
            Colors.red,
            () {
              showDialog(
                context: context,
                builder: (_) => MortalityDialog(batch: widget.batch),
              ).then((_) => _loadData());
            },
          ),
          const SizedBox(width: 12),
          _actionBtn(
            'Quick Sale',
            Icons.point_of_sale_outlined,
            Colors.green,
            () {
              showDialog(
                context: context,
                builder: (_) => QuickSaleDialog(batch: widget.batch),
              ).then((_) => _loadData());
            },
          ),
          const SizedBox(width: 12),
          _actionBtn('Edit Batch', Icons.edit_outlined, Colors.orange, () {
            showDialog(
              context: context,
              builder: (_) => EditBatchDialog(batch: widget.batch),
            ).then((_) => _loadData());
          }),
        ],
      ),
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : color.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStats(bool isNarrow) {
    return Column(
      children: [
        _buildChartCard('Growth vs Benchmark', Icons.show_chart, isNarrow),
        const SizedBox(height: 24),
        _buildLogTable(),
      ],
    );
  }

  Widget _buildChartCard(String title, IconData icon, bool isNarrow) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 300,
      padding: EdgeInsets.all(isNarrow ? 16 : 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D21) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _weightRecords.isEmpty
                ? const Center(
                    child: Text(
                      'No weight records yet.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value % 7 == 0) {
                                return Text(
                                  'Day ${value.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _weightRecords.asMap().entries.map((e) {
                            final days = e.value.logDate
                                .difference(widget.batch.arrivalDate)
                                .inDays;
                            return FlSpot(
                              days.toDouble(),
                              e.value.averageWeight,
                            );
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFF10B981),
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideInfo(bool isNarrow) {
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);
    return Column(
      children: [
        if (_showFinancials)
          _infoTile(
            'Financial Initialization',
            currency.format(widget.batch.initialActualCost ?? 0.0),
            Icons.payments_outlined,
            Colors.blue,
          ),
        if (_showFinancials) const SizedBox(height: 16),
        _infoTile(
          'Total Mortality',
          '$_totalMortality birds',
          Icons.coronavirus_outlined,
          Colors.red,
        ),
        const SizedBox(height: 16),
        _infoTile(
          'Feed Consumed',
          '${_totalFeed.toStringAsFixed(1)} kg',
          Icons.restaurant_outlined,
          Colors.orange,
        ),
        if (_showFinancials) const SizedBox(height: 16),
        if (_showFinancials)
          _infoTile(
            'Total Sales',
            currency.format(_totalSales),
            Icons.shopping_cart_outlined,
            Colors.green,
          ),
      ],
    );
  }

  Widget _infoTile(String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D21) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogTable() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D21) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Operations',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No recent logs found.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batch History',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1D21) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: const Center(
            child: Text(
              'Timeline coming soon...',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
