import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:provider/provider.dart';
import '../data/local_db.dart';
import '../utils/farm_utils.dart';
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
  bool _showFinancials = false;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    final mortality = await (db.select(db.mortalities)..where((t) => t.batchId.equals(widget.batch.id))).get();
    final feeding = await (db.select(db.feedingLogs)..where((t) => t.batchId.equals(widget.batch.id))).get();
    final weights = await (db.select(db.weightRecords)..where((t) => t.batchId.equals(widget.batch.id))..orderBy([(t) => OrderingTerm.asc(t.logDate)])).get();
    final sales = await (db.select(db.sales)..where((t) => t.batchId.equals(widget.batch.id))).get();
    final canView = await FarmUtils.canViewFinancials();

    if (mounted) {
      setState(() {
        _totalMortality = mortality.fold(0, (sum, m) => sum + m.count);
        _totalFeed = feeding.fold(0.0, (sum, f) => sum + f.amountConsumed);
        _weightRecords = weights;
        _totalSales = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
        _showFinancials = canView;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(widget.batch.arrivalDate).inDays;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.batch.batchName, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          _buildStatusChip(widget.batch.status),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(age),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildMainStats()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildSideInfo()),
              ],
            ),
            const SizedBox(height: 24),
            _buildActivitySection(),
          ],
        ),
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
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildHeroHeader(int age) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF10B981).withValues(alpha: 0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _heroStat('Current Stock', '${widget.batch.currentCount}', Icons.inventory_2_outlined),
          _divider(),
          _heroStat('Age', '$age Days', Icons.calendar_today_outlined),
          _divider(),
          _heroStat('Initial Count', '${widget.batch.initialCount}', Icons.add_circle_outline),
          _divider(),
          _heroStat('Breed', widget.batch.breedType ?? 'N/A', Icons.pets_outlined),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: Colors.white12);

  Widget _buildMainStats() {
    return Column(
      children: [
        _buildChartCard('Growth vs Benchmark', Icons.show_chart),
        const SizedBox(height: 24),
        _buildLogTable(),
      ],
    );
  }

  Widget _buildChartCard(String title, IconData icon) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D21),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _weightRecords.isEmpty 
              ? const Center(child: Text('No weight records yet.', style: TextStyle(color: Colors.grey, fontSize: 12)))
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value % 7 == 0) {
                              return Text('Day ${value.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10));
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _weightRecords.asMap().entries.map((e) {
                          final days = e.value.logDate.difference(widget.batch.arrivalDate).inDays;
                          return FlSpot(days.toDouble(), e.value.averageWeight);
                        }).toList(),
                        isCurved: true,
                        color: const Color(0xFF10B981),
                        barWidth: 4,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
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

  Widget _buildSideInfo() {
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);
    return Column(
      children: [
        if (_showFinancials)
          _infoTile('Financial Initialization', currency.format(widget.batch.initialActualCost ?? 0.0), Icons.payments_outlined, Colors.blue),
        if (_showFinancials) const SizedBox(height: 16),
        _infoTile('Total Mortality', '$_totalMortality birds', Icons.coronavirus_outlined, Colors.red),
        const SizedBox(height: 16),
        _infoTile('Feed Consumed', '${_totalFeed.toStringAsFixed(1)} kg', Icons.restaurant_outlined, Colors.orange),
        if (_showFinancials) const SizedBox(height: 16),
        if (_showFinancials)
          _infoTile('Total Sales', currency.format(_totalSales), Icons.shopping_cart_outlined, Colors.green),
      ],
    );
  }

  Widget _infoTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D21),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Operations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Center(child: Text('No recent logs found.', style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Batch History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D21),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(child: Text('Timeline coming soon...', style: TextStyle(color: Colors.grey))),
        ),
      ],
    );
  }
}
