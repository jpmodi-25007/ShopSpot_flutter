import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

class WebHeroSection extends StatefulWidget {
  const WebHeroSection({super.key});

  @override
  State<WebHeroSection> createState() => _WebHeroSectionState();
}

class _WebHeroSectionState extends State<WebHeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bool isMobile = w < 800;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neutral50,
            AppColors.white,
            AppColors.neutral50,
          ],
          stops: [0, 0.5, 1],
        ),
      ),
      child: Column(
        children: [
          // Top announcement bar
          Container(
            width: double.infinity,
            color: AppColors.neutral900,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '🎉  Findivo is now live in 25+ cities!  Join your local community today.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Main hero content
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 56 : 96,
              horizontal: 24,
            ),
            child: ResponsiveContainer(
              child: isMobile
                  ? _buildMobileHero(context)
                  : _buildDesktopHero(context),
            ),
          ),

          // Role cards strip
          _buildRoleCards(context, isMobile),
        ],
      ),
    );
  }

  // ─── Desktop layout ────────────────────────────────────────────────────────
  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: copy
        Expanded(
          flex: 55,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _textSlide,
              child: _buildCopyColumn(context, isMobile: false),
            ),
          ),
        ),
        const SizedBox(width: 64),
        // Right: photo collage
        Expanded(
          flex: 45,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: _buildPhotoCollage(isMobile: false),
          ),
        ),
      ],
    );
  }

  // ─── Mobile layout ─────────────────────────────────────────────────────────
  Widget _buildMobileHero(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          _buildCopyColumn(context, isMobile: true),
          const SizedBox(height: 48),
          _buildPhotoCollage(isMobile: true),
        ],
      ),
    );
  }

  // ─── Copy column ───────────────────────────────────────────────────────────
  Widget _buildCopyColumn(BuildContext context, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        _AnimatedBadge(
          icon: Icons.bolt,
          text: 'Shop Local · Sell More · Earn Together',
        ),
        const SizedBox(height: 28),

        // Headline
        RichText(
          text: TextSpan(
            style: (isMobile
                    ? AppTextStyles.h1.copyWith(fontSize: 36)
                    : AppTextStyles.display.copyWith(fontSize: 56))
                .copyWith(
              color: AppColors.neutral900,
              height: 1.1,
            ),
            children: const [
              TextSpan(text: 'The smarter way\nto '),
              TextSpan(
                text: 'shop local.',
                style: TextStyle(color: AppColors.neutral900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Subtitle
        Text(
          'Findivo brings together curious shoppers, passionate local retailers, and community influencers—all in one beautifully simple platform.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.neutral600,
            fontSize: 17,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 40),

        // CTA buttons
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _PrimaryButton(
              label: 'Get Started Free',
              icon: LucideIcons.arrowRight,
              onTap: () => context.go('/signup'),
            ),
            _SecondaryButton(
              label: 'See How It Works',
              onTap: () => context.go('/how-it-works'),
            ),
          ],
        ),
        const SizedBox(height: 48),

        // Social proof
        _buildSocialProof(),
      ],
    );
  }

  // ─── Photo collage ─────────────────────────────────────────────────────────
  Widget _buildPhotoCollage({required bool isMobile}) {
    final h = isMobile ? 320.0 : 500.0;
    return SizedBox(
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background card – retailer
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: isMobile ? 160 : 260,
            child: _PhotoCard(
              imagePath: 'assets/images/intro2.jpg',
              borderRadius: 20,
              shadowIntensity: 0.08,
            ),
          ),
          // Foreground card – customer (centre)
          Positioned(
            left: isMobile ? 20 : 30,
            right: isMobile ? 60 : 90,
            top: isMobile ? 40 : 50,
            bottom: isMobile ? 40 : 50,
            child: _PhotoCard(
              imagePath: 'assets/images/intro1.jpg',
              borderRadius: 24,
              shadowIntensity: 0.18,
              borderColor: AppColors.white,
              borderWidth: 6,
            ),
          ),
          // Floating stat badge – top left
          Positioned(
            left: 0,
            top: isMobile ? 16 : 24,
            child: _FloatingBadge(
              icon: LucideIcons.shoppingBag,
              label: '10k+ Shoppers',
              color: AppColors.roleCustomer,
            ),
          ),
          // Floating stat badge – bottom right
          Positioned(
            right: 0,
            bottom: isMobile ? 16 : 28,
            child: _FloatingBadge(
              icon: LucideIcons.store,
              label: '500+ Retailers',
              color: AppColors.roleRetailer,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Role cards ────────────────────────────────────────────────────────────
  Widget _buildRoleCards(BuildContext context, bool isMobile) {
    final roles = [
      _RoleCardData(
        icon: LucideIcons.shoppingBag,
        title: 'Shoppers',
        subtitle: 'Discover & buy unique products from local boutiques near you.',
        color: AppColors.roleCustomer,
        lightColor: AppColors.roleCustomerLight,
        ctaLabel: 'Start Shopping',
        route: '/signup?role=CUSTOMER',
      ),
      _RoleCardData(
        icon: LucideIcons.store,
        title: 'Retailers',
        subtitle: 'List products, manage inventory, and run influencer campaigns.',
        color: AppColors.roleRetailer,
        lightColor: AppColors.roleRetailerLight,
        ctaLabel: 'Open Your Store',
        route: '/signup?role=SHOPKEEPER',
      ),
      _RoleCardData(
        icon: LucideIcons.trendingUp,
        title: 'Influencers',
        subtitle: 'Partner with local brands and monetize your authentic reach.',
        color: AppColors.roleInfluencer,
        lightColor: AppColors.roleInfluencerLight,
        ctaLabel: 'Join as Influencer',
        route: '/signup?role=INFLUENCER',
      ),
    ];

    return Container(
      color: AppColors.neutral900,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 40 : 56, horizontal: 24),
      child: ResponsiveContainer(
        child: isMobile
            ? Column(
                children: roles
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: EdgeInsets.only(
                              bottom: e.key < roles.length - 1 ? 20 : 0),
                          child: _RoleCard(
                              data: e.value,
                              isMobile: true,
                              onTap: () => context.go(e.value.route)),
                        ))
                    .toList(),
              )
            : Row(
                children: roles.asMap().entries.map((e) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: e.key < roles.length - 1 ? 20 : 0),
                      child: _RoleCard(
                          data: e.value,
                          isMobile: false,
                          onTap: () => context.go(e.value.route)),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  // ─── Social proof ──────────────────────────────────────────────────────────
  Widget _buildSocialProof() {
    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 40,
          child: Stack(
            children: List.generate(4, (i) {
              final colors = [
                AppColors.roleCustomerLight,
                AppColors.roleRetailerLight,
                AppColors.roleInfluencerLight,
                AppColors.neutral200,
              ];
              return Positioned(
                left: i * 22.0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.5),
                  ),
                  child: const Icon(LucideIcons.user,
                      size: 18, color: AppColors.neutral500),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                  5,
                  (_) => const Icon(LucideIcons.star,
                      size: 14, color: AppColors.secondary500)),
            ),
            const SizedBox(height: 3),
            Text(
              'Loved by 10,000+ local users',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.neutral600),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _AnimatedBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AnimatedBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neutral900),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.neutral800 : AppColors.neutral900,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.neutral900.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label,
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.white, fontSize: 15)),
              const SizedBox(width: 10),
              AnimatedSlide(
                offset: _hovered ? const Offset(0.2, 0) : Offset.zero,
                duration: const Duration(milliseconds: 180),
                child:
                    Icon(widget.icon, size: 18, color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryButton({required this.label, required this.onTap});

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.neutral100 : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _hovered
                    ? AppColors.neutral400
                    : AppColors.neutral300,
                width: 1.5),
          ),
          child: Text(widget.label,
              style: AppTextStyles.button
                  .copyWith(color: AppColors.neutral800, fontSize: 15)),
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String imagePath;
  final double borderRadius;
  final double shadowIntensity;
  final Color? borderColor;
  final double borderWidth;

  const _PhotoCard({
    required this.imagePath,
    required this.borderRadius,
    this.shadowIntensity = 0.1,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900
                .withValues(alpha: shadowIntensity),
            blurRadius: 32,
            offset: const Offset(0, 16),
          )
        ],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FloatingBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─── Role card data ────────────────────────────────────────────────────────────

class _RoleCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color lightColor;
  final String ctaLabel;
  final String route;

  const _RoleCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.lightColor,
    required this.ctaLabel,
    required this.route,
  });
}

class _RoleCard extends StatefulWidget {
  final _RoleCardData data;
  final bool isMobile;
  final VoidCallback onTap;

  const _RoleCard(
      {required this.data, required this.isMobile, required this.onTap});

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.neutral800
                : AppColors.neutral900,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? widget.data.color.withValues(alpha: 0.5)
                  : AppColors.neutral800,
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.data.color.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: widget.isMobile
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.data.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.data.icon,
                        size: 22, color: widget.data.color),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      LucideIcons.arrowUpRight,
                      size: 20,
                      color: _hovered
                          ? widget.data.color
                          : AppColors.neutral600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.data.title,
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 10),
              Text(
                widget.data.subtitle,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.neutral400, height: 1.6),
              ),
              const SizedBox(height: 24),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _hovered
                      ? widget.data.color
                      : widget.data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.data.ctaLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _hovered
                        ? AppColors.white
                        : widget.data.color,
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
