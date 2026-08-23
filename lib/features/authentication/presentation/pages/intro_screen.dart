import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _textController;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  static const _pages = [
    _SlideData(
      title: 'Discover Local\nBoutique Products',
      subtitle:
          'Find unique, handpicked items from independent boutiques in your neighbourhood — all in one place.',
      image: 'assets/images/intro1_premium.jpg',
      roleBadge: '🛍️  For Shoppers',
      accentColor: AppColors.roleCustomer,
      lightColor: AppColors.roleCustomerLight,
      icon: LucideIcons.shoppingBag,
    ),
    _SlideData(
      title: 'Grow Your Store\nOnline & Locally',
      subtitle:
          'Manage inventory, connect with customers, and run influencer campaigns — all from a powerful retailer dashboard.',
      image: 'assets/images/intro2_premium.jpg',
      roleBadge: '🏪  For Retailers',
      accentColor: AppColors.roleRetailer,
      lightColor: AppColors.roleRetailerLight,
      icon: LucideIcons.store,
    ),
    _SlideData(
      title: 'Monetise Your\nLocal Following',
      subtitle:
          'Partner with brands you love, submit bids on campaigns, and earn — all within a single, seamless app.',
      image: 'assets/images/intro3_premium.jpg',
      roleBadge: '📈  For Influencers',
      accentColor: AppColors.roleInfluencer,
      lightColor: AppColors.roleInfluencerLight,
      icon: LucideIcons.trendingUp,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _textFade =
        CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));
    _textController.forward();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _textController.reset();
    _textController.forward();
  }

  void _nextOrFinish() {
    if (_currentPage == _pages.length - 1) {
      context.go('/login');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    if (kIsWeb) return const Scaffold(backgroundColor: AppColors.neutral900);

    return Scaffold(
      backgroundColor: AppColors.neutral900,
      body: Stack(
        children: [
          // ── Full-bleed page view ─────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (ctx, i) => _buildSlide(_pages[i], size),
          ),

          // ── Skip button ──────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom controls ──────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  28, 32, 28, MediaQuery.of(context).padding.bottom + 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.neutral900.withValues(alpha: 0.95),
                    AppColors.neutral900,
                  ],
                  stops: const [0, 0.3, 1],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated text content
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role badge chip
                          _RoleBadge(
                            label: current.roleBadge,
                            color: current.accentColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            current.title,
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.white,
                              fontSize: 30,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            current.subtitle,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color:
                                  AppColors.neutral400,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Pill indicators + Next button
                  Row(
                    children: [
                      // Animated pill indicators
                      Row(
                        children: List.generate(_pages.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 8),
                            width: isActive ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _pages[i].accentColor
                                  : AppColors.neutral700,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      // Next/Get Started button
                      _AnimatedIntroButton(
                        label: _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        icon: _currentPage == _pages.length - 1
                            ? LucideIcons.arrowRight
                            : LucideIcons.chevronRight,
                        color: current.accentColor,
                        onTap: _nextOrFinish,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(_SlideData data, Size size) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background photo
        Image.asset(data.image, fit: BoxFit.cover),

        // Dark gradient top-to-bottom
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.neutral900.withValues(alpha: 0.25),
                AppColors.neutral900.withValues(alpha: 0.5),
                AppColors.neutral900.withValues(alpha: 0.9),
                AppColors.neutral900,
              ],
              stops: const [0, 0.35, 0.65, 1],
            ),
          ),
        ),

        // Coloured accent top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [data.accentColor, data.lightColor],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Data model ────────────────────────────────────────────────────────────────
class _SlideData {
  final String title;
  final String subtitle;
  final String image;
  final String roleBadge;
  final Color accentColor;
  final Color lightColor;
  final IconData icon;

  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.roleBadge,
    required this.accentColor,
    required this.lightColor,
    required this.icon,
  });
}

// ─── Role badge ────────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _RoleBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Animated intro button ─────────────────────────────────────────────────────
class _AnimatedIntroButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedIntroButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedIntroButton> createState() => _AnimatedIntroButtonState();
}

class _AnimatedIntroButtonState extends State<_AnimatedIntroButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, color: AppColors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
