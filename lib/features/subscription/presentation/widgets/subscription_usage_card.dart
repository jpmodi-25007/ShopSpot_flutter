import 'package:flutter/material.dart';

class SubscriptionUsageCard extends StatelessWidget {
  final Map<String, dynamic> usage;
  const SubscriptionUsageCard({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    final productsCount = int.tryParse(usage['productsCount']?.toString() ?? '') ?? 0;
    final productLimit = int.tryParse(usage['productLimit']?.toString() ?? '') ?? 50;
    final eventsUsed = int.tryParse(usage['eventsUsedThisMonth']?.toString() ?? '') ?? 0;
    final eventLimit = int.tryParse(usage['eventLimit']?.toString() ?? '') ?? 0;

    final productPct = productLimit > 0 ? (productsCount / productLimit).clamp(0.0, 1.0) : 0.0;
    final eventPct = eventLimit > 0 ? (eventsUsed / eventLimit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.speed_rounded, color: Color(0xFFF59E0B), size: 18),
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
          const SizedBox(height: 18),
          _usageBar(
            icon: Icons.inventory_2_outlined,
            label: 'Product Catalogue Limit',
            used: productsCount,
            limit: productLimit,
            pct: productPct,
            barColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 16),
          _usageBar(
            icon: Icons.campaign_outlined,
            label: 'Home Screen Promoted Events',
            used: eventsUsed,
            limit: eventLimit,
            pct: eventPct,
            barColor: const Color(0xFFF59E0B),
            isEvent: true,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icon, size: 15, color: Colors.white60),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isAtLimit
                    ? Colors.red.withOpacity(0.2)
                    : isNearLimit
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                limit == 0 ? '0 / 0' : '$used / $limit',
                style: TextStyle(
                  color: isAtLimit
                      ? Colors.redAccent
                      : isNearLimit
                          ? Colors.orangeAccent
                          : Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: limit == 0 ? 0.0 : pct,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
              isAtLimit
                  ? Colors.redAccent
                  : isNearLimit
                      ? Colors.orangeAccent
                      : barColor,
            ),
            minHeight: 8,
          ),
        ),
        if (limit == 0 && isEvent)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '💡 Upgrade to Pro or Premium to promote events on home screen',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w500),
            ),
          )
        else if (isNearLimit && used < limit)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '⚠️ Reaching limit — upgrade plan to add more without interruption',
              style: TextStyle(color: Colors.orange.shade300, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          )
        else if (isAtLimit)
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              '🚫 Limit reached — upgrade to unlock more quota',
              style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
