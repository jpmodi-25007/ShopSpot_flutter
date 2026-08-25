import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../sections/cta_section.dart';
import '../sections/faq_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────

const _categories = [
  _FAQCategoryData(
    label: 'General',
    icon: LucideIcons.helpCircle,
    color: AppColors.neutral900,
    lightColor: AppColors.neutral100,
    faqs: [
      {
        'question': 'What is Findivo?',
        'answer':
            'Findivo is a hyper-local e-commerce platform that connects customers directly with local boutiques, artisan shops, and independent retailers. We also empower local influencers to partner with these brands—creating a vibrant, community-driven commerce ecosystem.',
      },
      {
        'question': 'Is Findivo available in my city?',
        'answer':
            'We\'re growing fast! Findivo is currently live in over 25 cities across the US and is expanding every month. Enter your city in the app at signup—if we\'re not there yet, join the waitlist and we\'ll notify you when we launch near you.',
      },
      {
        'question': 'What devices does Findivo support?',
        'answer':
            'Findivo is available as a native iOS and Android app, and as a full-featured web application accessible from any modern browser. Your account syncs seamlessly across all your devices.',
      },
    ],
  ),
  _FAQCategoryData(
    label: 'Customers',
    icon: LucideIcons.shoppingBag,
    color: AppColors.info500,
    lightColor: AppColors.info50,
    faqs: [
      {
        'question': 'How much does it cost to join as a customer?',
        'answer':
            'Findivo is completely free for customers. There are no membership fees, subscription costs, or hidden charges. You only pay for the products you purchase from local shops.',
      },
      {
        'question': 'Can I negotiate prices with retailers?',
        'answer':
            'Yes! This is one of Findivo\'s most loved features. Many retailers allow customers to send offers and negotiate in real-time through our built-in chat system. Look for the "Make an Offer" button on eligible product listings.',
      },
      {
        'question': 'How do I track my orders?',
        'answer':
            'All your orders appear in the "My Orders" section of your profile. Retailers provide real-time status updates, and you\'ll receive push notifications at each stage—from confirmation, packing, dispatch, to delivery.',
      },
      {
        'question': 'Are payments secure on Findivo?',
        'answer':
            'Absolutely. All transactions are processed through bank-grade, PCI-DSS compliant payment infrastructure. We support major credit/debit cards, Apple Pay, Google Pay, and more. Your card details are never stored on our servers.',
      },
    ],
  ),
  _FAQCategoryData(
    label: 'Retailers',
    icon: LucideIcons.store,
    color: AppColors.success500,
    lightColor: AppColors.success50,
    faqs: [
      {
        'question': 'How do I list my business on Findivo?',
        'answer':
            'Click "Get Started" on our homepage and select "Retailer" during registration. Submit your business details for a quick verification (usually under 24 hours). Once approved, you\'ll have full access to the retailer dashboard to list products, manage inventory, and run campaigns.',
      },
      {
        'question': 'What tools does Findivo provide for retailers?',
        'answer':
            'Retailers get a powerful, dedicated dashboard that includes: product and inventory management, bulk upload tools, real-time negotiation chat with customers, influencer campaign creation, and analytics covering sales, visits, and conversion rates.',
      },
      {
        'question': 'Can I manage multiple store locations?',
        'answer':
            'Yes! Findivo supports multi-location retail operations. You can add and manage multiple store branches under a single account, each with its own inventory, staff access, and reporting.',
      },
      {
        'question': 'How do influencer campaigns work for retailers?',
        'answer':
            'In your Campaigns dashboard, you create a campaign with a budget, target demographic, and content brief. Local influencers in your city will then discover and bid on your campaign. You review bids, select the right partner, and collaborate directly through the platform.',
      },
    ],
  ),
  _FAQCategoryData(
    label: 'Influencers',
    icon: LucideIcons.trendingUp,
    color: AppColors.warning500,
    lightColor: AppColors.warning50,
    faqs: [
      {
        'question': 'How do I join Findivo as an influencer?',
        'answer':
            'Register with the "Influencer" role and connect your social media profiles. Our team reviews your account to verify your reach and engagement. Once approved, you\'ll be able to discover and bid on campaigns from local retailers in your city.',
      },
      {
        'question': 'Do I need a large following to qualify?',
        'answer':
            'Not at all! We actively celebrate micro-influencers. Many local retailers specifically look for creators with highly engaged, community-focused audiences of even 1,000+ followers. Authenticity and local reach matter far more than raw follower count.',
      },
      {
        'question': 'How and when do I get paid?',
        'answer':
            'Earnings are processed within 7 business days after a campaign is marked as complete. You can track all pending and completed payments in your Earnings dashboard. We support direct bank transfer, PayPal, and other major payout methods.',
      },
    ],
  ),
];

// ─── Data model ───────────────────────────────────────────────────────────────

class _FAQCategoryData {
  final String label;
  final IconData icon;
  final Color color;
  final Color lightColor;
  final List<Map<String, String>> faqs;

  const _FAQCategoryData({
    required this.label,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.faqs,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class WebFAQPage extends StatefulWidget {
  const WebFAQPage({super.key});

  @override
  State<WebFAQPage> createState() => _WebFAQPageState();
}

class _WebFAQPageState extends State<WebFAQPage> with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final selected = _categories[_selectedCategoryIndex];

    return Column(
      children: [
        _buildHeroHeader(context, isMobile),
        _buildStatsStrip(context, isMobile),
        _buildCategoryTabs(context, isMobile),
        _buildFAQBody(context, isMobile, selected),
        _buildContactTeaser(context, isMobile),
        const CTASection(),
      ],
    );
  }

  // ── Hero header ─────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(BuildContext context, bool isMobile) {
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
        vertical: isMobile ? 64 : 100,
        horizontal: 24,
      ),
      child: FadeTransition(
        opacity: _headerFade,
        child: SlideTransition(
          position: _headerSlide,
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.helpCircle, size: 16, color: AppColors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Help Center',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How can we help you?',
                style: (isMobile ? AppTextStyles.h1 : AppTextStyles.display).copyWith(
                  color: AppColors.white,
                  fontSize: isMobile ? 36 : 52,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Browse answers by topic, or reach out to our support team.',
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
    );
  }

  // ── Stats strip ─────────────────────────────────────────────────────────────
  Widget _buildStatsStrip(BuildContext context, bool isMobile) {
    final stats = [
      {'value': '14', 'label': 'FAQ topics', 'icon': LucideIcons.bookOpen},
      {'value': '< 24h', 'label': 'Response time', 'icon': LucideIcons.clock},
      {'value': '98%', 'label': 'Satisfaction rate', 'icon': LucideIcons.thumbsUp},
      {'value': '24/7', 'label': 'Support available', 'icon': LucideIcons.headphones},
    ];

    return Container(
      color: AppColors.neutral900,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 28 : 32),
      child: ResponsiveContainer(
        child: isMobile
            ? Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: stats
                    .map((s) => _buildStatItem(s['value'] as String,
                        s['label'] as String, s['icon'] as IconData))
                    .toList(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: stats
                    .map((s) => _buildStatItem(s['value'] as String,
                        s['label'] as String, s['icon'] as IconData))
                    .toList(),
              ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.neutral900.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: AppColors.neutral900, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: AppColors.white),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
      ],
    );
  }

  // ── Category tabs ───────────────────────────────────────────────────────────
  Widget _buildCategoryTabs(BuildContext context, bool isMobile) {
    return Container(
      color: AppColors.neutral50,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 28 : 36,
        horizontal: 24,
      ),
      child: ResponsiveContainer(
        child: Column(
          children: [
            Text(
              'Browse by Topic',
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_categories.length, (i) {
                final cat = _categories[i];
                final isSelected = i == _selectedCategoryIndex;
                return _CategoryTab(
                  label: cat.label,
                  icon: cat.icon,
                  count: cat.faqs.length,
                  isSelected: isSelected,
                  activeColor: cat.color,
                  activeLightColor: cat.lightColor,
                  onTap: () => setState(() => _selectedCategoryIndex = i),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAQ Body ─────────────────────────────────────────────────────────────────
  Widget _buildFAQBody(
      BuildContext context, bool isMobile, _FAQCategoryData selected) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_selectedCategoryIndex),
        color: AppColors.white,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
        child: ResponsiveContainer(
          maxWidth: 860,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected.lightColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(selected.icon, color: selected.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected.label,
                        style: AppTextStyles.h3.copyWith(color: selected.color),
                      ),
                      Text(
                        '${selected.faqs.length} questions',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),
              ...selected.faqs.asMap().entries.map((entry) {
                return AnimatedFAQItem(
                  key: ValueKey('${_selectedCategoryIndex}_${entry.key}'),
                  question: entry.value['question']!,
                  answer: entry.value['answer']!,
                  index: entry.key,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Contact teaser ──────────────────────────────────────────────────────────
  Widget _buildContactTeaser(BuildContext context, bool isMobile) {
    return Container(
      color: AppColors.neutral50,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 72),
      child: ResponsiveContainer(
        child: Container(
          padding: EdgeInsets.all(isMobile ? 32 : 56),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.06),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: isMobile
              ? _buildContactTeaserContent(context, isMobile)
              : Row(
                  children: [
                    Expanded(child: _buildContactTeaserContent(context, isMobile)),
                    const SizedBox(width: 48),
                    _buildContactChannels(isMobile),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildContactTeaserContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.mail,
              color: AppColors.neutral900, size: 28),
        ),
        const SizedBox(height: 20),
        Text(
          'Still have questions?',
          style: AppTextStyles.h2,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 12),
        Text(
          'Can\'t find the answer you\'re looking for? Our friendly support team is available around the clock to help.',
          style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutral600, height: 1.6),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go('/contact'),
              icon: const Icon(LucideIcons.mail, size: 18),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neutral900,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/contact'),
              icon: const Icon(LucideIcons.phone, size: 18),
              label: const Text('Schedule a Call'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neutral900,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                side: const BorderSide(color: AppColors.neutral300, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 40),
          _buildContactChannels(isMobile),
        ],
      ],
    );
  }

  Widget _buildContactChannels(bool isMobile) {
    final channels = [
      {
        'icon': LucideIcons.mail,
        'label': 'Email',
        'value': 'support@findivo.com',
        'color': AppColors.info500,
        'bg': AppColors.info50,
      },
      {
        'icon': LucideIcons.phone,
        'label': 'Phone',
        'value': '+1 (555) 123-4567',
        'color': AppColors.success500,
        'bg': AppColors.success50,
      },
      {
        'icon': LucideIcons.clock,
        'label': 'Availability',
        'value': 'Mon–Sun, 24/7',
        'color': AppColors.warning500,
        'bg': AppColors.warning50,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: channels.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c['bg'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(c['icon'] as IconData,
                    color: c['color'] as Color, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c['label'] as String,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.neutral500)),
                  Text(c['value'] as String,
                      style: AppTextStyles.h6
                          .copyWith(color: AppColors.neutral900)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Category Tab Widget ──────────────────────────────────────────────────────

class _CategoryTab extends StatefulWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final Color activeColor;
  final Color activeLightColor;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.activeColor,
    required this.activeLightColor,
    required this.onTap,
  });

  @override
  State<_CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<_CategoryTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.activeColor
                : (_isHovered ? widget.activeLightColor : AppColors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? widget.activeColor
                  : AppColors.neutral200,
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.activeColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? AppColors.white
                    : (_isHovered ? widget.activeColor : AppColors.neutral500),
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: AppTextStyles.h6.copyWith(
                  color: widget.isSelected
                      ? AppColors.white
                      : (_isHovered ? widget.activeColor : AppColors.neutral700),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.white.withValues(alpha: 0.25)
                      : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${widget.count}',
                  style: AppTextStyles.caption.copyWith(
                    color: widget.isSelected
                        ? AppColors.white
                        : AppColors.neutral500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
