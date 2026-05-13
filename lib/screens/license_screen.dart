import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  String _currentTier = 'FREE';

  @override
  void initState() {
    super.initState();
    _loadTier();
  }

  Future<void> _loadTier() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _currentTier = prefs.getString('subscription_tier') ?? 'FREE');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('License & Subscription',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: cs.onSurface)),
            const SizedBox(height: 4),
            Text('Manage your plan and unlock premium features',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
            const SizedBox(height: 32),

            // Current plan banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF16A34A), Color(0xFF065F46)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Current Plan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(_currentTier == 'FREE' ? 'Free Plan' : _currentTier == 'PRO' ? 'Pro Plan' : 'Enterprise Plan',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(_currentTier == 'FREE'
                      ? 'Limited to 1 farm, 3 houses, and basic reporting'
                      : _currentTier == 'PRO'
                          ? 'Unlimited farms, advanced analytics, and priority support'
                          : 'Full platform access, white-label, and dedicated support',
                      style: const TextStyle(color: Colors.white60, fontSize: 13)),
                ])),
                if (_currentTier == 'FREE')
                  FilledButton(
                    onPressed: () => _showUpgradeDialog('PRO'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
              ]),
            ),
            const SizedBox(height: 40),

            Text('Choose a Plan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: cs.onSurface)),
            const SizedBox(height: 20),

            // Plan cards
            Row(children: [
              Expanded(child: _planCard(
                ctx: context,
                name: 'Free',
                price: 'GHS 0',
                period: '/month',
                tier: 'FREE',
                description: 'Perfect for small farms getting started',
                color: cs.onSurfaceVariant,
                features: [
                  _feat('1 Farm', true),
                  _feat('3 Poultry Houses', true),
                  _feat('Basic Batch Tracking', true),
                  _feat('Cloud Sync (Desktop)', true),
                  _feat('Advanced Analytics', false),
                  _feat('Multi-Farm Management', false),
                  _feat('Team Collaboration (3 users)', false),
                  _feat('Priority Support', false),
                ],
                isDark: isDark,
              )),
              const SizedBox(width: 20),
              Expanded(child: _planCard(
                ctx: context,
                name: 'Pro',
                price: 'GHS 149',
                period: '/month',
                tier: 'PRO',
                description: 'For growing commercial operations',
                color: const Color(0xFF16A34A),
                features: [
                  _feat('Up to 5 Farms', true),
                  _feat('Unlimited Houses', true),
                  _feat('Advanced Batch Tracking', true),
                  _feat('Real-Time Cloud Sync', true),
                  _feat('Advanced Analytics & Reports', true),
                  _feat('Multi-Farm Management', true),
                  _feat('Team Collaboration (10 users)', true),
                  _feat('Priority Support', false),
                ],
                isDark: isDark,
                isPopular: true,
              )),
              const SizedBox(width: 20),
              Expanded(child: _planCard(
                ctx: context,
                name: 'Enterprise',
                price: 'Custom',
                period: 'pricing',
                tier: 'ENTERPRISE',
                description: 'For large-scale commercial farms',
                color: const Color(0xFF7C3AED),
                features: [
                  _feat('Unlimited Farms', true),
                  _feat('Unlimited Houses', true),
                  _feat('Full Platform Access', true),
                  _feat('Real-Time Cloud Sync', true),
                  _feat('Advanced Analytics & Reports', true),
                  _feat('Multi-Farm Management', true),
                  _feat('Unlimited Team Members', true),
                  _feat('Dedicated Support & SLA', true),
                ],
                isDark: isDark,
              )),
            ]),
            const SizedBox(height: 40),

            // Feature comparison table
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                  },
                  children: [
                    _tableHeader(context),
                    _tableRow(context, 'Cloud Sync', true, true, true),
                    _tableRow(context, 'Offline Mode', true, true, true),
                    _tableRow(context, 'Egg Production Tracking', true, true, true),
                    _tableRow(context, 'Mortality Tracking', true, true, true),
                    _tableRow(context, 'Feeding Logs', true, true, true),
                    _tableRow(context, 'Inventory Management', false, true, true),
                    _tableRow(context, 'Financial Reports', false, true, true),
                    _tableRow(context, 'Sales Management', false, true, true),
                    _tableRow(context, 'API Access', false, false, true),
                    _tableRow(context, 'White-Label Branding', false, false, true, isLast: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, bool> _feat(String label, bool included) => {'label': label as dynamic, 'included': included as dynamic}.cast();

  Widget _planCard({
    required BuildContext ctx,
    required String name,
    required String price,
    required String period,
    required String tier,
    required String description,
    required Color color,
    required List<Map<String, bool>> features,
    required bool isDark,
    bool isPopular = false,
  }) {
    final cs = Theme.of(ctx).colorScheme;
    final isCurrent = _currentTier == tier;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(ctx).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? color : isPopular ? color.withOpacity(0.3) : cs.outline,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color)),
                const Spacer(),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                    child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
                    child: Text('ACTIVE', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ]),
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(price, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: cs.onSurface)),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(period, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                ),
              ]),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Icon(
                    f['included']! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 18,
                    color: f['included']! ? color : cs.outline,
                  ),
                  const SizedBox(width: 10),
                  Text(f['label']! as String,
                      style: TextStyle(
                        color: f['included']! ? cs.onSurface : cs.onSurfaceVariant,
                        fontSize: 13,
                        decoration: f['included']! ? null : TextDecoration.lineThrough,
                      )),
                ]),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: isCurrent
                    ? OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Current Plan', style: TextStyle(color: color)),
                      )
                    : FilledButton(
                        onPressed: () => _showUpgradeDialog(tier),
                        style: FilledButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(tier == 'FREE' ? 'Downgrade' : 'Upgrade to $name'),
                      ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(String tier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFF16A34A)),
          const SizedBox(width: 12),
          Text('Upgrade to $tier', style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
        content: const Text(
          'To upgrade your subscription, please visit the Poultry PMS web portal at\napp.poultrypms.com or contact our support team.\n\nYour desktop app will automatically sync the new features once your plan is updated.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Visit Web Portal'),
          ),
        ],
      ),
    );
  }

  TableRow _tableHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TableRow(
      decoration: BoxDecoration(color: cs.surfaceContainerHighest),
      children: [
        _cell(context, 'Feature', isHeader: true),
        _cell(context, 'Free', isHeader: true, color: cs.onSurfaceVariant),
        _cell(context, 'Pro', isHeader: true, color: const Color(0xFF16A34A)),
        _cell(context, 'Enterprise', isHeader: true, color: const Color(0xFF7C3AED)),
      ],
    );
  }

  TableRow _tableRow(BuildContext context, String feature, bool free, bool pro, bool enterprise, {bool isLast = false}) {
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).cardColor;
    return TableRow(
      decoration: BoxDecoration(color: bg, border: isLast ? null : Border(bottom: BorderSide(color: cs.outline.withOpacity(0.5)))),
      children: [
        _cell(context, feature),
        _checkCell(context, free),
        _checkCell(context, pro, color: const Color(0xFF16A34A)),
        _checkCell(context, enterprise, color: const Color(0xFF7C3AED)),
      ],
    );
  }

  Widget _cell(BuildContext context, String text, {bool isHeader = false, Color? color}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Text(text, style: TextStyle(
        fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
        fontSize: isHeader ? 13 : 13,
        color: color ?? cs.onSurface,
      )),
    );
  }

  Widget _checkCell(BuildContext context, bool val, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(child: Icon(
        val ? Icons.check_circle_rounded : Icons.remove_rounded,
        size: 18,
        color: val ? (color ?? const Color(0xFF16A34A)) : Theme.of(context).colorScheme.outline,
      )),
    );
  }
}
