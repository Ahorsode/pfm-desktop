import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/local_db.dart';

class FinancialControlScreen extends StatefulWidget {
  const FinancialControlScreen({super.key});

  @override
  State<FinancialControlScreen> createState() => _FinancialControlScreenState();
}

class _FinancialControlScreenState extends State<FinancialControlScreen> {
  late AppDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'GHS ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<EggProduction>>(
        stream: db.select(db.eggProductions).watch(),
        builder: (context, eggSnap) {
          return StreamBuilder<List<InventoryItem>>(
            stream: db.select(db.inventory).watch(),
            builder: (context, invSnap) {
              return StreamBuilder<List<Mortality>>(
                stream: db.select(db.mortalities).watch(),
                builder: (context, mortSnap) {
                  return StreamBuilder<List<Customer>>(
                    stream: db.select(db.customers).watch(),
                    builder: (context, custSnap) {
                      final eggs = eggSnap.data ?? [];
                      final inventory = invSnap.data ?? [];
                      final customers = custSnap.data ?? [];

                      // Revenue: proxy = total eggs collected × avg price (we'll use a flat GHS 0.40/egg)
                      const pricePerEgg = 0.40;
                      final totalEggs = eggs.fold(0, (s, e) => s + e.eggsCollected);
                      final totalRevenue = totalEggs * pricePerEgg;

                      // Stock value
                      final stockValue = inventory.fold(0.0, (s, i) => s + (i.stockLevel * (i.costPerUnit ?? 0.0)));

                      // Outstanding receivables
                      final outstanding = customers.fold(0.0, (s, c) => s + (c.balanceOwed ?? 0.0));

                      // Monthly egg data for chart (last 6 months)
                      final now = DateTime.now();
                      final monthlyData = List.generate(6, (i) {
                        final month = DateTime(now.year, now.month - (5 - i), 1);
                        final monthEggs = eggs
                            .where((e) => e.logDate.year == month.year && e.logDate.month == month.month)
                            .fold(0, (s, e) => s + e.eggsCollected);
                        return FlSpot(i.toDouble(), (monthEggs * pricePerEgg));
                      });

                      final monthLabels = List.generate(6, (i) {
                        final month = DateTime(now.year, now.month - (5 - i), 1);
                        return DateFormat('MMM').format(month);
                      });

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            const Text('Financial Control',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                            Text('Farm revenue, stock value, and receivables overview',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
                            const SizedBox(height: 28),

                            // KPI Cards
                            Row(children: [
                              Expanded(child: _kpiCard(
                                'Est. Revenue',
                                currency.format(totalRevenue),
                                Icons.trending_up_rounded,
                                const Color(0xFF16A34A),
                                '+${totalEggs.toStringAsFixed(0)} eggs collected',
                              )),
                              const SizedBox(width: 16),
                              Expanded(child: _kpiCard(
                                'Stock Value',
                                currency.format(stockValue),
                                Icons.inventory_2_rounded,
                                const Color(0xFF3B82F6),
                                '${inventory.length} inventory items',
                              )),
                              const SizedBox(width: 16),
                              Expanded(child: _kpiCard(
                                'Outstanding Receivables',
                                currency.format(outstanding),
                                Icons.payments_rounded,
                                const Color(0xFFF59E0B),
                                '${customers.where((c) => (c.balanceOwed ?? 0) > 0).length} customers with balance',
                              )),
                            ]),
                            const SizedBox(height: 28),

                            // Revenue Chart
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Text('Revenue Trend (Last 6 Months)',
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF16A34A).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Egg Revenue', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w700, fontSize: 12)),
                                    ),
                                  ]),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 220,
                                    child: LineChart(LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (_) => FlLine(color: Theme.of(context).colorScheme.outline, strokeWidth: 1),
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 60,
                                          getTitlesWidget: (v, _) => Text('GHS ${v.toInt()}', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                        )),
                                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (v, _) {
                                            final idx = v.toInt();
                                            if (idx < 0 || idx >= monthLabels.length) return const SizedBox();
                                            return Text(monthLabels[idx], style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)));
                                          },
                                        )),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: monthlyData,
                                          isCurved: true,
                                          color: const Color(0xFF16A34A),
                                          barWidth: 3,
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: const Color(0xFF16A34A).withOpacity(0.08),
                                          ),
                                          dotData: FlDotData(
                                            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                                              radius: 4,
                                              color: const Color(0xFF16A34A),
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Inventory breakdown
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Inventory Stock Levels',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                                  const SizedBox(height: 16),
                                  if (inventory.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24),
                                      child: Center(child: Text('No inventory data. Sync from cloud or add items.',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                                    )
                                  else
                                    ...inventory.take(8).map((item) {
                                      final pct = item.reorderLevel != null && item.reorderLevel! > 0
                                          ? (item.stockLevel / (item.reorderLevel! * 2)).clamp(0.0, 1.0)
                                          : 0.5;
                                      final isLow = item.reorderLevel != null && item.stockLevel <= item.reorderLevel!;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Row(children: [
                                                Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                                if (isLow) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red[50],
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text('Low Stock', style: TextStyle(color: Colors.red[600], fontSize: 10, fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              ]),
                                              Text('${item.stockLevel.toStringAsFixed(1)} ${item.unit}',
                                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                            ]),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: pct,
                                                minHeight: 6,
                                                backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                                valueColor: AlwaysStoppedAnimation(isLow ? Colors.red[400]! : const Color(0xFF16A34A)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
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
            },
          );
        },
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color, String subtitle) {
    return Builder(builder: (context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 16),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: cs.onSurface)),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
      ]),
    );
    });
  }
}
