import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isCurrentPlan;
  final bool isYearly;
  final bool isProcessing;
  final VoidCallback? onSubscribe;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.isYearly,
    required this.isProcessing,
    this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final tier = plan['tier'] as String? ?? 'FREE';
    final isHighlighted = plan['isHighlighted'] as bool? ?? false;
    final price = double.tryParse(plan['price'].toString()) ?? 0;
    final yearlyPrice = plan['yearlyPrice'] != null
      ? double.tryParse(plan['yearlyPrice'].toString())
      : null;
    final displayPrice = isYearly && yearlyPrice != null
      ? yearlyPrice / 12
      : price;
    final features = (plan['features'] as List?)?.cast<String>() ?? [];

    final Map<String, Map<String, dynamic>> tierConfig = {
      'FREE': {'icon': '🆓', 'gradient': [const Color(0xFF374151), const Color(0xFF1F2937)], 'accent': Colors.grey},
      'PRO': {'icon': '⭐', 'gradient': [const Color(0xFF1E3A5F), const Color(0xFF1E40AF)], 'accent': const Color(0xFF3B82F6)},
      'PREMIUM': {'icon': '👑', 'gradient': [const Color(0xFF78350F), const Color(0xFFB45309)], 'accent': const Color(0xFFF59E0B)},
    };

    final config = tierConfig[tier] ?? tierConfig['FREE']!;
    final gradientColors = (config['gradient'] as List).cast<Color>();
    final accent = config['accent'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? accent : Colors.white10,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted
          ? [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
          : [],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan header
                Row(
                  children: [
                    Text(config['icon'] as String, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan['name'] as String? ?? tier,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(plan['tagline'] as String? ?? '',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price == 0 ? 'Free' : '₹${displayPrice.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    if (price > 0) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('/month', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                      ),
                    ],
                  ],
                ),
                if (isYearly && yearlyPrice != null && price > 0)
                  Text('₹${yearlyPrice.toStringAsFixed(0)}/year · Save ₹${(price * 12 - yearlyPrice).toStringAsFixed(0)}',
                    style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600)),

                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 12),

                // Features
                ...features.take(5).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: accent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f, style: const TextStyle(color: Colors.white, fontSize: 13))),
                    ],
                  ),
                )),
                if (features.length > 5)
                  Text('+${features.length - 5} more features',
                    style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600)),

                const SizedBox(height: 20),

                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentPlan ? Colors.white10 : accent,
                        foregroundColor: isCurrentPlan ? Colors.white54 : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: isCurrentPlan ? null : onSubscribe,
                      child: isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            isCurrentPlan
                              ? '✓ Current Plan'
                              : price == 0 ? 'Get Started Free' : 'Upgrade to ${plan['name']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Most Popular badge
          if (isHighlighted)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Most Popular',
                  style: TextStyle(
                    color: accent == Colors.grey ? Colors.white : Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
              ),
            ),

          // Current plan indicator
          if (isCurrentPlan)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Active',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

