import 'package:flutter/material.dart';

class SubscriptionUsageCard extends StatelessWidget {
  final Map<String, dynamic> usage;
  const SubscriptionUsageCard({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    final productsCount =
        int.tryParse(usage['productsCount']?.toString() ?? '') ?? 0;
    final productLimit =
        int.tryParse(usage['productLimit']?.toString() ?? '') ?? 50;
    final eventsUsed =
        int.tryParse(usage['eventsUsedThisMonth']?.toString() ?? '') ?? 0;
    final eventLimit =
        int.tryParse(usage['eventLimit']?.toString() ?? '') ?? 0;

    final productPct =
        productLimit > 0 ? (productsCount / productLimit).clamp(0.0, 1.0) : 0.0;
    final eventPct =
        eventLimit > 0 ? (eventsUsed / eventLimit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.speed_rounded,
                    color: Color(0xFFF59E0B), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Current Monthly Usage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Product Catalogue Bar ─────────────────────────────────────────
          _usageBar(
            icon: Icons.inventory_2_outlined,
            label: 'Product Catalogue',
            used: productsCount,
            limit: productLimit,
            pct: productPct,
            barColor: const Color(0xFF3B82F6),
          ),

          const SizedBox(height: 18),

          // ── Promoted Events Bar ───────────────────────────────────────────
          if (eventLimit > 0)
            _usageBar(
              icon: Icons.campaign_outlined,
              label: 'Promoted Events',
              used: eventsUsed,
              limit: eventLimit,
              pct: eventPct,
              barColor: const Color(0xFFF59E0B),
              isEvent: true,
            )
          else
            _lockedRow(
              icon: Icons.campaign_outlined,
              label: 'Home Screen Events',
              hint: 'Upgrade to Pro to run promoted events',
            ),
        ],
      ),
    );
  }

  Widget _usageBar({
    required IconData icon,
    required String label,
    required int used,
    required int limit,
    required double pct,
    required Color barColor,
    bool isEvent = false,
  }) {
    final isNearLimit = pct >= 0.8 && limit > 0;
    final isAtLimit = used >= limit && limit > 0;

    final Color statusColor = isAtLimit
        ? Colors.redAccent
        : isNearLimit
            ? Colors.orangeAccent
            : barColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: Colors.white60),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: isAtLimit
                    ? Colors.red.withAlpha(51)
                    : isNearLimit
                        ? Colors.orange.withAlpha(51)
                        : Colors.white.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$used / $limit',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white.withAlpha(20),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 7,
          ),
        ),
        if (isAtLimit)
          _hint('🚫 Limit reached — upgrade to unlock more quota',
              Colors.redAccent)
        else if (isNearLimit && used < limit)
          _hint('⚠️ Nearing limit — consider upgrading soon',
              Colors.orange.shade300),
      ],
    );
  }

  Widget _lockedRow({
    required IconData icon,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: Colors.white38),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'LOCKED',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: 0,
            backgroundColor: Colors.white.withAlpha(12),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.transparent),
            minHeight: 7,
          ),
        ),
        _hint('💡 $hint', const Color(0xFF60A5FA)),
      ],
    );
  }

  Widget _hint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }
}
