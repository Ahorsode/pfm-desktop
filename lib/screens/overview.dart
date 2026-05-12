import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../data/local_db.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard', 
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.w800, 
                        color: Colors.blueGrey[900],
                        letterSpacing: -0.5,
                      )),
                    const SizedBox(height: 4),
                    Text('Overview of your poultry farm performance', 
                      style: TextStyle(color: Colors.blueGrey[400], fontSize: 16)),
                  ],
                ),
                _buildSyncStatusBadge(),
              ],
            ),
            const SizedBox(height: 40),
            const _PremiumStatsGrid(),
            const SizedBox(height: 48),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Active Batches', Icons.grid_view_rounded),
                      const SizedBox(height: 20),
                      StreamBuilder<List<Batch>>(
                        stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final batches = snapshot.data!;
                          if (batches.isEmpty) return _buildEmptyState();

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 1.6,
                            ),
                            itemCount: batches.length,
                            itemBuilder: (context, index) => _PremiumBatchCard(batch: batches[index]),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Recent Activity', Icons.history_rounded),
                      const SizedBox(height: 20),
                      const _RecentActivityPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Text(title, 
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
      ],
    );
  }

  Widget _buildSyncStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          const Text('Live Sync Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.add_business_outlined, size: 80, color: Colors.blueGrey[100]),
          const SizedBox(height: 24),
          const Text('No Active Batches', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 8),
          Text('Start your poultry journey by registering your first flock.', 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey[400])),
        ],
      ),
    );
  }
}

class _PremiumStatsGrid extends StatelessWidget {
  const _PremiumStatsGrid();

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    
    return StreamBuilder<List<Batch>>(
      stream: db.select(db.batches).watch(),
      builder: (context, snapshot) {
        final batches = snapshot.data ?? [];
        final totalBirds = batches.fold(0, (sum, b) => sum + b.currentCount);
        
        return Row(
          children: [
            _buildStatCard('Total Birds', totalBirds.toString(), Icons.pets_rounded, Colors.orange),
            const SizedBox(width: 24),
            StreamBuilder<List<EggProduction>>(
              stream: db.select(db.eggProductions).watch(),
              builder: (context, eggSnap) {
                final eggs = eggSnap.data ?? [];
                final totalEggs = eggs.fold(0, (sum, e) => sum + e.eggsCollected);
                return _buildStatCard('Total Eggs', totalEggs.toString(), Icons.egg_rounded, Colors.amber);
              },
            ),
            const SizedBox(width: 24),
            StreamBuilder<List<InventoryItem>>(
              stream: db.select(db.inventory).watch(),
              builder: (context, invSnap) {
                final items = invSnap.data ?? [];
                final feedItems = items.where((i) => i.category == 'FEED').length;
                return _buildStatCard('Feed Types', feedItems.toString(), Icons.inventory_2_rounded, Colors.teal);
              },
            ),
            const SizedBox(width: 24),
            StreamBuilder<List<Mortality>>(
              stream: db.select(db.mortalities).watch(),
              builder: (context, mortSnap) {
                final mortalities = mortSnap.data ?? [];
                final totalDeaths = mortalities.fold(0, (sum, m) => sum + m.count);
                return _buildStatCard('Total Mortality', totalDeaths.toString(), Icons.warning_rounded, Colors.red);
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 24),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.blueGrey[400], fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _PremiumBatchCard extends StatelessWidget {
  final Batch batch;
  const _PremiumBatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final isLayer = batch.type.contains('LAYER');
    final ageDays = DateTime.now().difference(batch.arrivalDate).inDays;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isLayer ? Colors.purple : Colors.blue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(batch.type.split('_').last, 
                  style: TextStyle(
                    color: isLayer ? Colors.purple : Colors.blue, 
                    fontWeight: FontWeight.w800, 
                    fontSize: 12
                  )),
              ),
              Icon(Icons.more_horiz, color: Colors.blueGrey[200]),
            ],
          ),
          const SizedBox(height: 20),
          Text(batch.batchName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Age: $ageDays Days', style: TextStyle(color: Colors.blueGrey[400], fontSize: 14)),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.group_rounded, size: 18, color: Colors.blueGrey[300]),
              const SizedBox(width: 8),
              Text('${batch.currentCount}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('In Stock', style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivityPanel extends StatelessWidget {
  const _RecentActivityPanel();

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: StreamBuilder<List<dynamic>>(
        stream: CombineLatestStream.list([
          db.select(db.feedingLogs).watch(),
          db.select(db.mortalities).watch(),
          db.select(db.eggProductions).watch(),
        ]).map((lists) {
          final combined = <dynamic>[];
          for (var list in lists) {
            combined.addAll(list as List<dynamic>);
          }
          combined.sort((a, b) {
             final dateA = (a is FeedingLog) ? a.logDate : (a is Mortality ? a.logDate : (a as EggProduction).logDate);
             final dateB = (b is FeedingLog) ? b.logDate : (b is Mortality ? b.logDate : (b as EggProduction).logDate);
             return dateB.compareTo(dateA);
          });
          return combined.take(10).toList();
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('No activity logs yet', style: TextStyle(color: Colors.grey))),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
            itemBuilder: (context, index) {
              final log = logs[index];
              String title = '';
              IconData icon = Icons.info;
              Color color = Colors.grey;
              DateTime date = DateTime.now();

              if (log is FeedingLog) {
                title = 'Feeding: ${log.amountConsumed}kg';
                icon = Icons.restaurant;
                color = Colors.blue;
                date = log.logDate;
              } else if (log is Mortality) {
                title = 'Mortality: ${log.count} birds';
                icon = Icons.warning_rounded;
                color = Colors.red;
                date = log.logDate;
              } else if (log is EggProduction) {
                title = 'Eggs: ${log.eggsCollected} collected';
                icon = Icons.egg_rounded;
                color = Colors.amber;
                date = log.logDate;
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(DateFormat('MMM dd, HH:mm').format(date), 
                  style: TextStyle(color: Colors.blueGrey[400])),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              );
            },
          );
        },
      ),
    );
  }
}
