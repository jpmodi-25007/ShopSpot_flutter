import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SubscriptionUsageCard extends StatelessWidget {
  final Map<String, dynamic> usage;
  const SubscriptionUsageCard({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    final productsCount = usage['productsCount'] as int? ?? 0;
    final productLimit = usage['productLimit'] as int? ?? 50;
    final eventsUsed = usage['eventsUsedThisMonth'] as int? ?? 0;
    final eventLimit = usage['eventLimit'] as int? ?? 0;

    final productPct = productLimit > 0 ? (productsCount / productLimit).clamp(0.0, 1.0) : 0.0;
    final eventPct = eventLimit > 0 ? (eventsUsed / eventLimit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This Month\'s Usage',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _usageBar('Products', productsCount, productLimit, productPct, AppColors.primary600),
          const SizedBox(height: 12),
          if (eventLimit > 0)
            _usageBar('Events on Home Screen', eventsUsed, eventLimit, eventPct, AppColors.secondary500),
        ],
      ),
    );
  }

  Widget _usageBar(String label, int used, int limit, double pct, Color color) {
    final isNearLimit = pct >= 0.8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text('$used / $limit',
              style: TextStyle(
                color: isNearLimit ? Colors.orange : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              isNearLimit ? Colors.orange : color,
            ),
            minHeight: 8,
          ),
        ),
        if (isNearLimit && used < limit)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('⚠️ Nearing limit — consider upgrading',
              style: TextStyle(color: Colors.orange.shade300, fontSize: 11)),
          ),
      ],
    );
  }
}

