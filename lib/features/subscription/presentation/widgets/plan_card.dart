import 'package:flutter/material.dart';

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
    final tier = (plan['tier'] ?? 'FREE').toString().toUpperCase();
    final isHighlighted = plan['isHighlighted'] == true || tier == 'PRO';
    final isPremium = tier == 'PREMIUM';
    final isFree = tier == 'FREE';

    final price = double.tryParse(plan['price']?.toString() ?? '0') ?? 0;
    final yearlyPrice = plan['yearlyPrice'] != null
        ? double.tryParse(plan['yearlyPrice'].toString())
        : null;
    final displayPrice = isYearly && yearlyPrice != null
        ? yearlyPrice / 12
        : price;
    final savings = (isYearly && yearlyPrice != null && price > 0)
        ? (price * 12 - yearlyPrice).clamp(0, double.infinity)
        : 0.0;

    final productLimit = int.tryParse(plan['productLimit']?.toString() ?? '') ?? (isFree ? 50 : isHighlighted ? 200 : 500);
    final eventLimit = int.tryParse(plan['eventLimit']?.toString() ?? '') ?? (isFree ? 0 : isHighlighted ? 1 : 3);

    final List<String> features = [];
    if (plan['features'] is List) {
      for (final f in plan['features'] as List) {
        if (f != null && f.toString().isNotEmpty) features.add(f.toString());
      }
    }

    // Color theming per tier
    late final List<Color> cardGradient;
    late final Color accentColor;
    late final Color glowColor;
    late final IconData tierIcon;
    late final String badgeText;

    if (isPremium) {
      cardGradient = const [
        Color(0xFF26190C),
        Color(0xFF181008),
        Color(0xFF33200E),
      ];
      accentColor = const Color(0xFFF59E0B); // Amber gold
      glowColor = const Color(0x35F59E0B);
      tierIcon = Icons.workspace_premium_rounded;
      badgeText = '👑 BEST VALUE';
    } else if (isHighlighted) {
      cardGradient = const [
        Color(0xFF131D36),
        Color(0xFF0C1322),
        Color(0xFF1E2D4E),
      ];
      accentColor = const Color(0xFF3B82F6); // Royal sapphire blue
      glowColor = const Color(0x353B82F6);
      tierIcon = Icons.rocket_launch_rounded;
      badgeText = '★ MOST POPULAR';
    } else {
      cardGradient = const [
        Color(0xFF1D222C),
        Color(0xFF141720),
        Color(0xFF191D26),
      ];
      accentColor = const Color(0xFF94A3B8); // Slate silver
      glowColor = Colors.transparent;
      tierIcon = Icons.storefront_rounded;
      badgeText = 'STARTER';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrentPlan
              ? const Color(0xFF10B981)
              : (isHighlighted || isPremium)
                  ? accentColor.withOpacity(0.9)
                  : Colors.white.withOpacity(0.12),
          width: (isHighlighted || isPremium || isCurrentPlan) ? 1.8 : 1,
        ),
        boxShadow: [
          if (glowColor != Colors.transparent)
            BoxShadow(
              color: glowColor,
              blurRadius: 28,
              offset: const Offset(0, 10),
              spreadRadius: 1,
            ),
          const BoxShadow(
            color: Color(0x60000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tier Icon Container
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accentColor.withOpacity(0.35)),
                      ),
                      child: Icon(tierIcon, color: accentColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (plan['name'] ?? tier).toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            (plan['tagline'] ?? '').toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Key Metric Chips Row (Quotas)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _metricChip(
                      icon: Icons.inventory_2_outlined,
                      label: '$productLimit Products',
                      accent: accentColor,
                    ),
                    _metricChip(
                      icon: Icons.campaign_outlined,
                      label: eventLimit == 0
                          ? '0 Events'
                          : '$eventLimit Home Banner${eventLimit > 1 ? "s" : ""}/mo',
                      accent: accentColor,
                    ),
                    if (isHighlighted)
                      _metricChip(
                        icon: Icons.verified_rounded,
                        label: 'Pro Badge',
                        accent: const Color(0xFF60A5FA),
                      ),
                    if (isPremium)
                      _metricChip(
                        icon: Icons.auto_awesome,
                        label: 'Top 3 Boost',
                        accent: const Color(0xFFFBBF24),
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                // Price Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price == 0 ? '₹0' : '₹${displayPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      price == 0 ? 'forever free' : '/ month',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Yearly savings note
                if (isYearly && yearlyPrice != null && price > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Billed ₹${yearlyPrice.toStringAsFixed(0)}/yr · Save ₹${savings.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (isFree) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '🎉 1st month free for all new shopkeepers',
                    style: TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                const SizedBox(height: 14),

                // Features List
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: isFree ? const Color(0xFF10B981) : accentColor,
                              size: 13,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 18),

                // CTA Action Button
                if (isCurrentPlan)
                  // Active Plan badge banner (Never dark-on-dark!)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF065F46).withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Current Active Plan',
                          style: TextStyle(
                            color: Color(0xFFD1FAE5),
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Upgrade / Activate Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: isPremium
                            ? const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              )
                            : isHighlighted
                                ? const LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                  )
                                : null,
                        color: isFree ? const Color(0xFF334155) : null,
                        boxShadow: (isHighlighted || isPremium)
                            ? [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: isPremium ? const Color(0xFF1A1108) : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isProcessing ? null : onSubscribe,
                        child: isProcessing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isFree
                                        ? 'Activate Free Starter'
                                        : isHighlighted
                                            ? 'Upgrade to Pro Growth →'
                                            : 'Get Premium VIP 👑',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: isPremium ? const Color(0xFF1A1108) : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Floating Top-Right Badges
          if (isCurrentPlan)
            Positioned(
              top: 18,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFF34D399), size: 8),
                    SizedBox(width: 5),
                    Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Color(0xFFD1FAE5),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (isHighlighted || isPremium)
            Positioned(
              top: 18,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  gradient: isPremium
                      ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)])
                      : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: isPremium ? const Color(0xFF1A1108) : Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricChip({
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
