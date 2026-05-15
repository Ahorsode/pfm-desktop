import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../widgets/register_unit_dialog.dart';
import '../widgets/batch_actions_dialogs.dart';
import 'batch_details_screen.dart';

class LivestockManager extends StatefulWidget {
  const LivestockManager({super.key});

  @override
  State<LivestockManager> createState() => _LivestockManagerState();
}

class _LivestockManagerState extends State<LivestockManager> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(context, db, cs, isCompact),

          // ── Body ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 16.0 : 28.0),
              child: Column(
                children: [
                  // Filter chips
                  _buildFilterRow(cs),
                  const SizedBox(height: 20),

                  // Table
                  Expanded(
                    child: _buildTableCard(db, cs, isCompact),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  //  HEADER
  // ────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AppDatabase db, ColorScheme cs, bool isCompact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isCompact ? 16 : 32,
        isCompact ? 20 : 32,
        isCompact ? 16 : 32,
        isCompact ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 16,
        children: [
          // Title block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: 'Livestock ',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isCompact ? 22 : 30,
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Management',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isCompact ? 22 : 30,
                    color: const Color(0xFF10B981),
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.5,
                  ),
                ),
              ])),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Text(
                    'LIFECYCLE & PERFORMANCE TRACKING',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: () => _showAddBatchDialog(context, db),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  isCompact ? 'ADD' : 'ADD UNIT',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  //  FILTER ROW
  // ────────────────────────────────────────────
  Widget _buildFilterRow(ColorScheme cs) {
    const filters = ['All', 'Broiler', 'Layer', 'Turkey', 'Duck', 'Other'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: selected,
              label: Text(f, style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? Colors.white : cs.onSurfaceVariant,
              )),
              avatar: selected ? null : Icon(_filterIcon(f), size: 16, color: cs.onSurfaceVariant),
              selectedColor: const Color(0xFF10B981),
              backgroundColor: cs.surfaceContainerLowest,
              side: BorderSide(color: selected ? Colors.transparent : cs.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _filterIcon(String label) {
    return switch (label) {
      'All' => Icons.select_all_rounded,
      'Broiler' => Icons.flutter_dash_rounded,
      'Layer' => Icons.egg_outlined,
      'Turkey' => Icons.set_meal_rounded,
      'Duck' => Icons.water_rounded,
      _ => Icons.category_outlined,
    };
  }

  // ────────────────────────────────────────────
  //  TABLE CARD
  // ────────────────────────────────────────────
  Widget _buildTableCard(AppDatabase db, ColorScheme cs, bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: StreamBuilder<List<Batch>>(
        stream: db.select(db.batches).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
          }
          final allBatches = snapshot.data!;
          if (allBatches.isEmpty) return _buildEmptyState(context, db, cs);

          // Apply filter
          final batches = _applyFilter(allBatches);

          if (batches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_alt_outlined, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No batches match "$_selectedFilter"',
                    style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _selectedFilter = 'All'),
                    child: const Text('Show All'),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, tableConstraints) {
              return Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(cs.primary.withValues(alpha: 0.5)),
                    thickness: WidgetStateProperty.all(8),
                    radius: const Radius.circular(4),
                  ),
                ),
                child: Scrollbar(
                  controller: ScrollController(), // Optional: for persistent scrollbar
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: tableConstraints.maxWidth > 1000 ? tableConstraints.maxWidth : 1000,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
                          headingRowHeight: 52,
                          dataRowMinHeight: 72,
                          dataRowMaxHeight: 72,
                          horizontalMargin: 20,
                          columnSpacing: 24,
                          columns: [
                            _col('#'),
                            _col('UNIT NAME / IDENTITY'),
                            _col('TYPE & SPECIES'),
                            _col('WORKER STAMPS'),
                            _col('STOCK (START / NOW)'),
                            _col('ARRIVAL DATE'),
                            _col('STATUS'),
                            _col('ACTIONS'),
                          ],
                          rows: batches.asMap().entries.map((entry) {
                            final index = entry.key;
                            final batch = entry.value;
                            return _row(batch, index, db, cs);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Batch> _applyFilter(List<Batch> batches) {
    if (_selectedFilter == 'All') return batches;
    return batches.where((b) {
      final type = b.type.toUpperCase();
      return switch (_selectedFilter) {
        'Broiler' => type.contains('BROILER'),
        'Layer' => type.contains('LAYER'),
        'Turkey' => type.contains('TURKEY'),
        'Duck' => type.contains('DUCK'),
        _ => !type.contains('BROILER') && !type.contains('LAYER') && !type.contains('TURKEY') && !type.contains('DUCK'),
      };
    }).toList();
  }

  DataColumn _col(String label) {
    return DataColumn(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  String _getBatchTypeLabel(String type) {
    return switch (type.toUpperCase()) {
      'POULTRY_BROILER' => 'Poultry Broiler',
      'POULTRY_LAYER' => 'Poultry Layer',
      'POULTRY_TURKEY' => 'Turkey',
      'POULTRY_DUCK' => 'Duck',
      'OTHER' => 'Other Species',
      _ => type,
    };
  }

  DataRow _row(Batch batch, int index, AppDatabase db, ColorScheme cs) {
    final arrivalDate = DateFormat('dd MMM yyyy').format(batch.arrivalDate);
    final typeLabel = _getBatchTypeLabel(batch.type);
    final isLayer = batch.type.toUpperCase().contains('LAYER');
    final breed = batch.breedType ?? 'Other';

    return DataRow(
      cells: [
        // Index
        DataCell(
          Text('${index + 1}', style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        // Unit name / Identity
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(batch.batchName,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF10B981)),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Type & Species
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(typeLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF1E293B))),
              Text(breed, style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        // Worker Stamps
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _workerStamp('SYS', Colors.blue),
              const SizedBox(width: 4),
              _workerStamp('VET', Colors.orange),
              if (batch.currentCount < 100) ...[
                const SizedBox(width: 4),
                _workerStamp('MGR', Colors.red),
              ],
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${NumberFormat('#,###').format(batch.initialCount)} START',
                    style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(batch.currentCount)} NOW',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                isLayer ? 'layers' : 'broilers',
                style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        // Arrival Date
        DataCell(
          Text(
            arrivalDate,
            style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        // Status
        DataCell(_statusChip(batch.status)),
        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _manageBtn(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BatchDetailsScreen(batch: batch)),
                );
              }),
              const SizedBox(width: 8),
              _iconAction(Icons.coronavirus_outlined, const Color(0xFFEF4444), 'Mortality', onTap: () {
                showDialog(context: context, builder: (c) => MortalityDialog(batch: batch));
              }),
              const SizedBox(width: 8),
              _iconAction(Icons.shopping_cart_outlined, const Color(0xFF10B981), 'Sales', onTap: () {
                showDialog(context: context, builder: (c) => QuickSaleDialog(batch: batch));
              }),
              const SizedBox(width: 8),
              _iconAction(Icons.edit_outlined, const Color(0xFF3B82F6), 'Edit', onTap: () {
                showDialog(context: context, builder: (c) => EditBatchDialog(batch: batch));
              }),
              const SizedBox(width: 8),
              _iconAction(Icons.delete_outline_rounded, const Color(0xFF94A3B8), 'Delete', onTap: () => _confirmDelete(batch, db)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workerStamp(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9),
      ),
    );
  }

  Widget _manageBtn(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility_outlined, size: 14, color: Color(0xFF10B981)),
            const SizedBox(width: 6),
            const Text(
              'MANAGE',
              style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconAction(IconData icon, Color color, String tooltip, {VoidCallback? onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // ────────────────────────────────────────────
  //  STATUS CHIP
  // ────────────────────────────────────────────
  Widget _statusChip(String status) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? const Color(0xFF10B981) : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  // ────────────────────────────────────────────
  //  DELETE CONFIRMATION
  // ────────────────────────────────────────────
  Future<void> _confirmDelete(Batch batch, AppDatabase db) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
          SizedBox(width: 12),
          Text('Delete Batch', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
        content: Text.rich(TextSpan(children: [
          const TextSpan(text: 'Are you sure you want to permanently delete '),
          TextSpan(text: batch.batchName, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
          const TextSpan(text: '?\n\nThis will also remove all associated feeding, mortality, and production records.'),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (batch.synced) {
        await db.into(db.pendingDeletions).insert(
          PendingDeletionsCompanion.insert(
            targetTableName: 'batches',
            recordId: batch.id.toString(),
            farmId: batch.farmId,
          ),
        );
      }
      
      await (db.delete(db.batches)..where((t) => t.id.equals(batch.id))).go();
      
      // Trigger sync in background
      if (mounted) {
        context.read<SyncEngine>().performSync();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${batch.batchName} deleted'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }

  // ────────────────────────────────────────────
  //  EMPTY STATE
  // ────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, AppDatabase db, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 56, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 24),
          Text('No Livestock Units Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text('Register your first batch to start tracking.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showAddBatchDialog(context, db),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Register First Unit', style: TextStyle(fontWeight: FontWeight.w800)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  //  DIALOG LAUNCHER
  // ────────────────────────────────────────────
  Future<void> _showAddBatchDialog(BuildContext context, AppDatabase db) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RegisterUnitDialog(),
    );
  }
}
