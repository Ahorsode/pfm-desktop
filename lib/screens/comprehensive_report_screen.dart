import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import 'report_log_screen.dart';

class ComprehensiveReportScreen extends StatefulWidget {
  const ComprehensiveReportScreen({super.key});

  @override
  State<ComprehensiveReportScreen> createState() =>
      _ComprehensiveReportScreenState();
}

class _ComprehensiveReportScreenState extends State<ComprehensiveReportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  _FarmReport? _report;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports & Logs',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generate farm reports and review operation logs.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_report != null && _tabController.index == 0)
                  FilledButton.icon(
                    onPressed: _exportReportAsCsv,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Export CSV'),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Farm Report'),
                Tab(text: 'Operation Logs'),
              ],
              onTap: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildReportTab(context), const ReportLogScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _DatePickerButton(
              label: 'Start Date',
              date: _startDate,
              onPick: (date) => setState(() => _startDate = date),
            ),
            _DatePickerButton(
              label: 'End Date',
              date: _endDate,
              onPick: (date) => setState(() => _endDate = date),
            ),
            FilledButton.icon(
              onPressed: _loading ? null : _generateReport,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.analytics_rounded, size: 18),
              label: const Text('Generate Report'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: _report == null
              ? Center(
                  child: Text(
                    'Choose a date range and generate a farm report.',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : SingleChildScrollView(child: _ReportView(report: _report!)),
        ),
      ],
    );
  }

  Future<void> _generateReport() async {
    setState(() => _loading = true);
    try {
      final db = context.read<AppDatabase>();
      final farmId = await FarmUtils.getBoundFarmId();
      if (farmId == null) throw Exception('No bound farm found.');

      final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
      final end = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        23,
        59,
        59,
      );

      final sales = await (db.select(
        db.sales,
      )..where((s) => s.farmId.equals(farmId))).get();
      final expenses = await (db.select(
        db.expenses,
      )..where((e) => e.farmId.equals(farmId))).get();
      final eggs = await (db.select(
        db.eggProductions,
      )..where((e) => e.farmId.equals(farmId))).get();
      final feeding = await (db.select(
        db.feedingLogs,
      )..where((f) => f.farmId.equals(farmId))).get();
      final mortalities = await (db.select(
        db.mortalities,
      )..where((m) => m.farmId.equals(farmId))).get();
      final batches = await (db.select(
        db.batches,
      )..where((b) => b.farmId.equals(farmId))).get();

      final periodSales = sales
          .where((s) => !s.saleDate.isBefore(start) && !s.saleDate.isAfter(end))
          .toList();
      final periodExpenses = expenses
          .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
          .toList();
      final periodEggs = eggs
          .where((e) => !e.logDate.isBefore(start) && !e.logDate.isAfter(end))
          .toList();
      final periodFeeding = feeding
          .where((f) => !f.logDate.isBefore(start) && !f.logDate.isAfter(end))
          .toList();
      final periodMortalities = mortalities
          .where((m) => !m.logDate.isBefore(start) && !m.logDate.isAfter(end))
          .toList();

      final totalRevenue = periodSales.fold(
        0.0,
        (sum, s) => sum + s.totalAmount,
      );
      final totalExpenses = periodExpenses.fold(
        0.0,
        (sum, e) => sum + e.amount,
      );
      final totalEggs = periodEggs.fold(0, (sum, e) => sum + e.eggsCollected);
      final totalFeed = periodFeeding.fold(
        0.0,
        (sum, f) => sum + f.amountConsumed,
      );
      final totalMortality = periodMortalities.fold(
        0,
        (sum, m) => sum + m.count,
      );
      final startingBirds = batches.fold(0, (sum, b) => sum + b.initialCount);

      final expenseCategories = <String, double>{};
      for (final expense in periodExpenses) {
        expenseCategories[expense.category] =
            (expenseCategories[expense.category] ?? 0) + expense.amount;
      }

      final batchRows = <_BatchReportRow>[];
      for (final batch in batches) {
        final batchEggs = periodEggs
            .where((e) => e.batchId == batch.id)
            .fold(0, (sum, e) => sum + e.eggsCollected);
        final batchFeed = periodFeeding
            .where((f) => f.batchId == batch.id)
            .fold(0.0, (sum, f) => sum + f.amountConsumed);
        final batchMortality = periodMortalities
            .where((m) => m.batchId == batch.id)
            .fold(0, (sum, m) => sum + m.count);
        batchRows.add(
          _BatchReportRow(
            batchName: batch.batchName,
            birds: batch.currentCount,
            eggs: batchEggs,
            feedKg: batchFeed,
            mortality: batchMortality,
            mortalityRate: batch.initialCount == 0
                ? 0
                : batchMortality / batch.initialCount * 100,
          ),
        );
      }

      final dailyEggs = <DateTime, double>{};
      for (final entry in periodEggs) {
        final day = DateTime(
          entry.logDate.year,
          entry.logDate.month,
          entry.logDate.day,
        );
        dailyEggs[day] = (dailyEggs[day] ?? 0) + entry.eggsCollected;
      }

      setState(() {
        _report = _FarmReport(
          startDate: start,
          endDate: end,
          totalRevenue: totalRevenue,
          totalExpenses: totalExpenses,
          totalEggs: totalEggs,
          totalFeed: totalFeed,
          totalMortality: totalMortality,
          mortalityRate: startingBirds == 0
              ? 0
              : totalMortality / startingBirds * 100,
          revenueCategories: {'Sales': totalRevenue},
          expenseCategories: expenseCategories,
          batches: batchRows,
          dailyEggs: dailyEggs,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to generate: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _exportReportAsCsv() async {
    final report = _report;
    if (report == null) return;
    final buffer = StringBuffer()
      ..writeln('Metric,Value')
      ..writeln('Total Revenue,${report.totalRevenue.toStringAsFixed(2)}')
      ..writeln('Total Expenses,${report.totalExpenses.toStringAsFixed(2)}')
      ..writeln('Net Income,${report.netIncome.toStringAsFixed(2)}')
      ..writeln('Total Eggs,${report.totalEggs}')
      ..writeln('Feed Consumed Kg,${report.totalFeed.toStringAsFixed(2)}')
      ..writeln('Mortality,${report.totalMortality}')
      ..writeln()
      ..writeln('Batch,Birds,Eggs,Feed Kg,Mortality,Mortality Rate');
    for (final row in report.batches) {
      buffer.writeln(
        '"${row.batchName}",${row.birds},${row.eggs},${row.feedKg.toStringAsFixed(2)},${row.mortality},${row.mortalityRate.toStringAsFixed(2)}%',
      );
    }

    final downloads =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final fileName =
        'pfm_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    final file = File(p.join(downloads.path, fileName));
    await file.writeAsString(buffer.toString());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report exported to ${file.path}')),
      );
    }
  }
}

class _ReportView extends StatelessWidget {
  final _FarmReport report;

  const _ReportView({required this.report});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'GHc ', decimalDigits: 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _SummaryCard('Total Revenue', money.format(report.totalRevenue)),
            _SummaryCard('Total Expenses', money.format(report.totalExpenses)),
            _SummaryCard(
              'Net Income',
              money.format(report.netIncome),
              accent: report.netIncome >= 0
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
            ),
            _SummaryCard('Total Eggs', '${report.totalEggs}'),
            _SummaryCard(
              'Feed Consumed',
              '${report.totalFeed.toStringAsFixed(1)} kg',
            ),
            _SummaryCard(
              'Mortality',
              '${report.totalMortality} (${report.mortalityRate.toStringAsFixed(1)}%)',
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 900;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                SizedBox(
                  width: narrow
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 18) / 2,
                  child: _BreakdownCard(
                    title: 'Revenue by Category',
                    values: report.revenueCategories,
                    currency: money,
                  ),
                ),
                SizedBox(
                  width: narrow
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 18) / 2,
                  child: _BreakdownCard(
                    title: 'Expenses by Category',
                    values: report.expenseCategories,
                    currency: money,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _BatchTable(rows: report.batches),
        const SizedBox(height: 18),
        _TrendCard(values: report.dailyEggs),
      ],
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) onPick(picked);
      },
      icon: const Icon(Icons.calendar_month_rounded, size: 18),
      label: Text('$label: ${DateFormat('MMM d, yyyy').format(date)}'),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? accent;

  const _SummaryCard(this.label, this.value, {this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = accent ?? cs.primary;
    return Container(
      width: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outline.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final String title;
  final Map<String, double> values;
  final NumberFormat currency;

  const _BreakdownCard({
    required this.title,
    required this.values,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = values.values.fold(0.0, (sum, v) => sum + v);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          if (values.isEmpty || total == 0)
            Text('No data', style: TextStyle(color: cs.onSurfaceVariant))
          else
            for (final entry in values.entries) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    currency.format(entry.value),
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: total == 0 ? 0 : entry.value / total,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _BatchTable extends StatelessWidget {
  final List<_BatchReportRow> rows;

  const _BatchTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Batch Name')),
            DataColumn(label: Text('Birds')),
            DataColumn(label: Text('Eggs')),
            DataColumn(label: Text('Feed (kg)')),
            DataColumn(label: Text('Mortality')),
            DataColumn(label: Text('Mortality Rate')),
          ],
          rows: rows
              .map(
                (row) => DataRow(
                  cells: [
                    DataCell(Text(row.batchName)),
                    DataCell(Text('${row.birds}')),
                    DataCell(Text('${row.eggs}')),
                    DataCell(Text(row.feedKg.toStringAsFixed(1))),
                    DataCell(Text('${row.mortality}')),
                    DataCell(Text('${row.mortalityRate.toStringAsFixed(1)}%')),
                  ],
                ),
              )
              .toList(),
          headingTextStyle: TextStyle(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
          dataTextStyle: TextStyle(color: cs.onSurface),
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final Map<DateTime, double> values;

  const _TrendCard({required this.values});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final entries = values.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date-range Egg Trend',
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'No egg production in this period',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : CustomPaint(
                    painter: _BarChartPainter(
                      values: entries.map((e) => e.value).toList(),
                      labels: entries
                          .map((e) => DateFormat('MMM d').format(e.key))
                          .toList(),
                      color: cs.primary,
                      labelColor: cs.onSurfaceVariant,
                    ),
                    size: Size.infinite,
                  ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: cs.outline.withValues(alpha: 0.14)),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12),
    ],
  );
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final Color labelColor;

  const _BarChartPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final paint = Paint()..color = color;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final chartHeight = size.height - 30;
    final gap = 5.0;
    final barWidth = (size.width - gap * (values.length - 1)) / values.length;

    for (var i = 0; i < values.length; i++) {
      final ratio = maxValue == 0 ? 0.0 : values[i] / maxValue;
      final height = chartHeight * ratio;
      final x = i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartHeight - height, barWidth.clamp(3, 34), height),
        const Radius.circular(5),
      );
      canvas.drawRRect(rect, paint);

      if (values.length <= 14 || i % (values.length / 7).ceil() == 0) {
        textPainter.text = TextSpan(
          text: labels[i],
          style: TextStyle(color: labelColor, fontSize: 10),
        );
        textPainter.layout(maxWidth: barWidth * 2);
        textPainter.paint(canvas, Offset(x, chartHeight + 8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _FarmReport {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalExpenses;
  final int totalEggs;
  final double totalFeed;
  final int totalMortality;
  final double mortalityRate;
  final Map<String, double> revenueCategories;
  final Map<String, double> expenseCategories;
  final List<_BatchReportRow> batches;
  final Map<DateTime, double> dailyEggs;

  const _FarmReport({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalEggs,
    required this.totalFeed,
    required this.totalMortality,
    required this.mortalityRate,
    required this.revenueCategories,
    required this.expenseCategories,
    required this.batches,
    required this.dailyEggs,
  });

  double get netIncome => totalRevenue - totalExpenses;
}

class _BatchReportRow {
  final String batchName;
  final int birds;
  final int eggs;
  final double feedKg;
  final int mortality;
  final double mortalityRate;

  const _BatchReportRow({
    required this.batchName,
    required this.birds,
    required this.eggs,
    required this.feedKg,
    required this.mortality,
    required this.mortalityRate,
  });
}
