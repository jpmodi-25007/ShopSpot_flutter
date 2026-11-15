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
    final displayPrice = isYearly && yearlyPrice != null ? yearlyPrice / 12 : price;
    final savings = (isYearly && yearlyPrice != null && price > 0)
        ? (price * 12 - yearlyPrice).clamp(0, double.infinity)
        : 0.0;

    final productLimit = int.tryParse(plan['productLimit']?.toString() ?? '') ??
        (isFree ? 50 : isHighlighted ? 200 : 500);
    final eventLimit = int.tryParse(plan['eventLimit']?.toString() ?? '') ??
        (isFree ? 0 : isHighlighted ? 1 : 3);

    final List<String> features = [];
    if (plan['features'] is List) {
      for (final f in plan['features'] as List) {
        if (f != null && f.toString().isNotEmpty) features.add(f.toString());
      }
    }

    // ── Color theming per tier ───────────────────────────────────────────────
    late final List<Color> cardGradient;
    late final Color accentColor;
    late final Color glowColor;
    late final IconData tierIcon;
    late final String badgeText;

    if (isPremium) {
      cardGradient = const [Color(0xFF26190C), Color(0xFF181008), Color(0xFF33200E)];
      accentColor = const Color(0xFFF59E0B);
      glowColor = const Color(0x25F59E0B);
      tierIcon = Icons.workspace_premium_rounded;
      badgeText = '👑 BEST VALUE';
    } else if (isHighlighted) {
      cardGradient = const [Color(0xFF131D36), Color(0xFF0C1322), Color(0xFF1E2D4E)];
      accentColor = const Color(0xFF3B82F6);
      glowColor = const Color(0x253B82F6);
      tierIcon = Icons.rocket_launch_rounded;
      badgeText = '★ MOST POPULAR';
    } else {
      cardGradient = const [Color(0xFF1D222C), Color(0xFF141720), Color(0xFF191D26)];
      accentColor = const Color(0xFF94A3B8);
      glowColor = Colors.transparent;
      tierIcon = Icons.storefront_rounded;
      badgeText = 'STARTER';
    }

    // Slightly larger card for the highlighted plan
    final double cardElevation = isHighlighted ? 2 : 0;

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
                  ? accentColor.withAlpha(230)
                  : Colors.white.withAlpha(30),
          width: (isHighlighted || isPremium || isCurrentPlan) ? 1.8 : 1,
        ),
        boxShadow: [
          if (glowColor != Colors.transparent)
            BoxShadow(color: glowColor, blurRadius: 32, offset: const Offset(0, 12), spreadRadius: 2),
          BoxShadow(
            color: Colors.black.withAlpha(isHighlighted ? 100 : 70),
            blurRadius: 16,
            offset: Offset(0, cardElevation + 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Most Popular / Best Value raised ribbon for highlighted plans ──
          if (!isCurrentPlan && (isHighlighted || isPremium))
            Positioned(
              top: -1,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPremium
                        ? const [Color(0xFFF59E0B), Color(0xFFD97706)]
                        : const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Header Row ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tier Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(46),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accentColor.withAlpha(90)),
                      ),
                      child: Icon(tierIcon, color: accentColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    // Plan name + tagline — leaves room on the right for the badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Extra top padding when a badge will appear
                          if (!isCurrentPlan && (isHighlighted || isPremium))
                            const SizedBox(height: 2),
                          Text(
                            (plan['name'] ?? tier).toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (plan['tagline'] ?? '').toString(),
                            style: TextStyle(
                              color: Colors.white.withAlpha(178),
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right-side badge (ACTIVE or tier badge)
                    const SizedBox(width: 8),
                    if (isCurrentPlan)
                      _activeBadge()
                    else if (isHighlighted || isPremium)
                      _tierBadge(badgeText, isPremium, accentColor),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Metric Chips Row ────────────────────────────────────────
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
                          ? 'No Events'
                          : '$eventLimit Home Banner${eventLimit > 1 ? "s" : ""}/mo',
                      accent: accentColor,
                    ),
                    if (isHighlighted)
                      _metricChip(
                        icon: Icons.verified_rounded,
                        label: '🔵 Pro Badge',
                        accent: const Color(0xFF60A5FA),
                      ),
                    if (isPremium)
                      _metricChip(
                        icon: Icons.auto_awesome,
                        label: '👑 Top 3 Boost',
                        accent: const Color(0xFFFBBF24),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Price Row ───────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price == 0
                          ? '₹0'
                          : '₹${displayPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        price == 0 ? 'forever free' : '/ month',
                        style: TextStyle(
                          color: Colors.white.withAlpha(165),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                // Yearly savings note
                if (isYearly && yearlyPrice != null && price > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(46),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withAlpha(76)),
                    ),
                    child: Text(
                      'Billed ₹${yearlyPrice.toStringAsFixed(0)}/yr · You save ₹${savings.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],

                // Free tier first-month note
                if (isFree) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.celebration_rounded, size: 14, color: Color(0xFF34D399)),
                      const SizedBox(width: 6),
                      Text(
                        '1st month free for all new shopkeepers',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 18),
                Divider(color: Colors.white.withAlpha(26), height: 1),
                const SizedBox(height: 16),

                // ── Features List ───────────────────────────────────────────
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: accentColor.withAlpha(51),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: isFree ? const Color(0xFF10B981) : accentColor,
                                size: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 20),

                // ── CTA Button ──────────────────────────────────────────────
                if (isCurrentPlan)
                  _currentPlanBanner()
                else
                  _ctaButton(isFree, isHighlighted, isPremium, accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _activeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF065F46),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Color(0xFF34D399), size: 7),
          SizedBox(width: 5),
          Text(
            'ACTIVE',
            style: TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierBadge(String text, bool isPremium, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)])
            : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(102),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isPremium ? const Color(0xFF1A1108) : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _currentPlanBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF065F46).withAlpha(90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
          SizedBox(width: 8),
          Text(
            'Your Current Active Plan',
            style: TextStyle(
              color: Color(0xFFD1FAE5),
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctaButton(bool isFree, bool isHighlighted, bool isPremium, Color accentColor) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isPremium
              ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)])
              : isHighlighted
                  ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)])
                  : null,
          color: isFree ? const Color(0xFF2D3748) : null,
          boxShadow: (isHighlighted || isPremium)
              ? [
                  BoxShadow(
                    color: accentColor.withAlpha(102),
                    blurRadius: 18,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          onPressed: isProcessing ? null : onSubscribe,
          child: isProcessing
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: isPremium ? const Color(0xFF1A1108) : Colors.white,
                  ),
                )
              : Text(
                  isFree
                      ? 'Start for Free →'
                      : isHighlighted
                          ? 'Upgrade to Pro Growth →'
                          : 'Get Premium VIP 👑',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isPremium ? const Color(0xFF1A1108) : Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _metricChip({
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(26)),
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
