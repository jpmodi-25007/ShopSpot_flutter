import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../sections/feature_section.dart';
import '../sections/cta_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

class WebFeaturesPage extends StatefulWidget {
  const WebFeaturesPage({super.key});

  @override
  State<WebFeaturesPage> createState() => _WebFeaturesPageState();
}

class _WebFeaturesPageState extends State<WebFeaturesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, -0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeroHeader(context),
        _buildRoleComparisonStrip(context),
        const FeatureSection(
          sectionLabel: '🛍️  For Shoppers',
          title: 'Shop local, discover the extraordinary.',
          description:
              'Browse curated collections from independent boutiques in your city. '
              'Interact directly with shop owners, negotiate on price, and '
              'check out securely—all from one app.',
          imagePath: 'assets/images/intro1.jpg',
          badgeValue: '10k+',
          badgeLabel: 'Active shoppers',
          badgeIcon: LucideIcons.shoppingBag,
          badgeColor: AppColors.neutral900,
          benefits: [
            'Personalised local feed based on your location',
            'Real-time negotiation chat with store owners',
            'Secure checkout, order tracking & receipts',
            'Save favourite shops and get restock alerts',
            'Map-view to discover boutiques nearby',
          ],
        ),
        const FeatureSection(
          sectionLabel: '🏪  For Retailers',
          title: 'A complete toolkit for independent stores.',
          description:
              'From listing your first product to running city-wide influencer campaigns, '
              'Findivo gives local retailers everything needed to grow without the complexity.',
          imagePath: 'assets/images/intro2.jpg',
          reversed: true,
          badgeValue: '500+',
          badgeLabel: 'Retail stores live',
          badgeIcon: LucideIcons.store,
          badgeColor: AppColors.success600,
          benefits: [
            'Easy product listing and bulk import tools',
            'Smart inventory with low-stock notifications',
            'Create targeted influencer campaigns',
            'Customer negotiation & live chat dashboard',
            'Detailed analytics: sales, visits, conversions',
          ],
        ),
        const FeatureSection(
          sectionLabel: '📈  For Influencers',
          title: 'Authentic partnerships, real earnings.',
          description:
              'Discover campaigns from local brands you already love, submit bids, '
              'collaborate on content, and track your earnings—all in one seamless flow.',
          imagePath: 'assets/images/intro3.jpg',
          badgeValue: '₹45K+',
          badgeLabel: 'Paid to creators',
          badgeIcon: LucideIcons.trendingUp,
          badgeColor: AppColors.secondary500,
          benefits: [
            'Browse active campaigns in your city',
            'Submit bids and negotiate deal terms directly',
            'In-app content brief and deliverables tracker',
            'Transparent earnings dashboard & fast payouts',
            'Build a professional creator portfolio',
          ],
        ),
        const CTASection(),
      ],
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.neutral900, AppColors.neutral800],
        ),
      ),
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 72 : 104, horizontal: 24),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ResponsiveContainer(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Platform Features',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'One platform.\nThree powerful experiences.',
                  style: (isMobile
                          ? AppTextStyles.h1
                          : AppTextStyles.display.copyWith(fontSize: 52))
                      .copyWith(color: AppColors.white, height: 1.15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Built for the entire local commerce ecosystem—shoppers, '
                  'store owners, and community creators.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleComparisonStrip(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final roles = [
      _RoleChip(
        icon: LucideIcons.shoppingBag,
        label: 'Shoppers',
        color: AppColors.roleCustomer,
        bg: AppColors.roleCustomerLight,
      ),
      _RoleChip(
        icon: LucideIcons.store,
        label: 'Retailers',
        color: AppColors.success600,
        bg: AppColors.success100,
      ),
      _RoleChip(
        icon: LucideIcons.trendingUp,
        label: 'Influencers',
        color: AppColors.secondary500,
        bg: AppColors.secondary100,
      ),
    ];

    return Container(
      color: AppColors.neutral50,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 28 : 36, horizontal: 24),
      child: ResponsiveContainer(
        child: Column(
          children: [
            Text(
              'Scroll to explore each role ↓',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral500, letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: roles,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _RoleChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: AppTextStyles.body
                  .copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
