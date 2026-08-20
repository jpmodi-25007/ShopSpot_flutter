import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../sections/web_hero_section.dart';
import '../sections/feature_section.dart';
import '../sections/how_it_works_section.dart';
import '../sections/faq_section.dart';
import '../sections/cta_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

class WebHomePage extends StatelessWidget {
  const WebHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Hero with announcement bar + photo collage + role cards
        WebHeroSection(),

        // ── For Customers ───────────────────────────────────────────────────
        FeatureSection(
          sectionLabel: '🛍️  For Shoppers',
          title: 'Your neighbourhood, in your pocket.',
          description:
              'Discover unique products from independent boutiques near you. '
              'Browse curated collections, save your favourites, and chat directly '
              'with store owners—all from one beautiful app.',
          imagePath: 'assets/images/intro1.jpg',
          badgeValue: '10,000+',
          badgeLabel: 'Active shoppers',
          badgeIcon: LucideIcons.shoppingBag,
          badgeColor: AppColors.roleCustomer,
          benefits: [
            'Personalised feed of local products & drops',
            'Real-time negotiation chat with store owners',
            'Secure checkout with order tracking',
            'Save favourite shops & get restock alerts',
          ],
        ),

        // ── How it works ────────────────────────────────────────────────────
        HowItWorksSection(),

        // ── For Retailers ───────────────────────────────────────────────────
        FeatureSection(
          sectionLabel: '🏪  For Retailers',
          title: 'Your digital storefront, effortlessly managed.',
          description:
              'Stop juggling spreadsheets. ShopSpot gives independent retailers '
              'a powerful dashboard to manage products, track inventory, '
              'engage customers, and run influencer campaigns—all in one place.',
          imagePath: 'assets/images/intro2.jpg',
          reversed: true,
          badgeValue: '500+',
          badgeLabel: 'Retail stores live',
          badgeIcon: LucideIcons.store,
          badgeColor: AppColors.roleRetailer,
          benefits: [
            'Smart inventory management with low-stock alerts',
            'Create & manage local influencer campaigns',
            'Real-time negotiation & customer communication',
            'Sales analytics & conversion reporting',
          ],
        ),

        // ── For Influencers ─────────────────────────────────────────────────
        FeatureSection(
          sectionLabel: '📈  For Influencers',
          title: 'Monetise your local following authentically.',
          description:
              'Connect with boutiques and brands you already love. '
              'Browse campaigns, submit bids, collaborate on content, '
              'and get paid—all within ShopSpot. No agents. No middlemen.',
          imagePath: 'assets/images/intro3.jpg',
          badgeValue: '\$45K+',
          badgeLabel: 'Paid to influencers',
          badgeIcon: LucideIcons.trendingUp,
          badgeColor: AppColors.roleInfluencer,
          benefits: [
            'Discover local brand campaigns near you',
            'Submit bids and negotiate terms directly',
            'Transparent earnings dashboard & fast payouts',
            'Build a professional content portfolio',
          ],
        ),

        // ── Metrics banner ──────────────────────────────────────────────────
        _StatsBanner(),

        // ── Inline FAQ ──────────────────────────────────────────────────────
        FAQSection(
          faqs: [
            {
              'question': 'What is ShopSpot?',
              'answer':
                  'ShopSpot is a hyper-local e-commerce platform connecting customers with local boutiques, giving retailers powerful management tools, and allowing influencers to discover and bid on brand campaigns.'
            },
            {
              'question': 'How much does it cost?',
              'answer':
                  'Completely free for customers. Retailers and influencers get a generous free tier; premium analytics and advanced features are available on paid plans.'
            },
            {
              'question': 'How do I start selling as a retailer?',
              'answer':
                  'Click "Get Started", choose the Retailer role, submit your business details for quick verification (under 24 h), and you can immediately start listing products.'
            },
            {
              'question': 'Can I negotiate prices?',
              'answer':
                  'Yes! Many retailers enable live offer/counter-offer negotiation directly through our in-app chat.'
            },
          ],
        ),

        // ── Final CTA ───────────────────────────────────────────────────────
        CTASection(),
      ],
    );
  }
}

// ─── Stats Banner ──────────────────────────────────────────────────────────────

class _StatsBanner extends StatelessWidget {
  const _StatsBanner();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    final stats = [
      _StatItem(
        icon: LucideIcons.users,
        value: '10,000+',
        label: 'Active Users',
        color: AppColors.roleCustomer,
        bg: AppColors.roleCustomerLight,
      ),
      _StatItem(
        icon: LucideIcons.store,
        value: '500+',
        label: 'Local Retailers',
        color: AppColors.roleRetailer,
        bg: AppColors.roleRetailerLight,
      ),
      _StatItem(
        icon: LucideIcons.trendingUp,
        value: '1,200+',
        label: 'Influencer Campaigns',
        color: AppColors.roleInfluencer,
        bg: AppColors.roleInfluencerLight,
      ),
      _StatItem(
        icon: LucideIcons.mapPin,
        value: '25+',
        label: 'Cities Live',
        color: AppColors.neutral500,
        bg: AppColors.neutral100,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.neutral900, AppColors.neutral800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 48 : 72, horizontal: 24),
      child: ResponsiveContainer(
        child: isMobile
            ? Wrap(
                alignment: WrapAlignment.center,
                spacing: 32,
                runSpacing: 32,
                children: stats,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: stats,
              ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white, size: 24),
        ),
        const SizedBox(height: 14),
        Text(
          value,
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.white,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
