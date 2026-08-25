import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

class HowItWorksSection extends StatefulWidget {
  const HowItWorksSection({super.key});

  @override
  State<HowItWorksSection> createState() => _HowItWorksSectionState();
}

class _HowItWorksSectionState extends State<HowItWorksSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _steps = [
    _StepData(
      number: '01',
      icon: LucideIcons.userPlus,
      title: 'Create your account',
      description:
          'Sign up as a Shopper, Retailer, or Influencer in under 60 seconds. '
          'No credit card required—start exploring immediately.',
      color: AppColors.roleCustomer,
      bg: AppColors.roleCustomerLight,
    ),
    _StepData(
      number: '02',
      icon: LucideIcons.search,
      title: 'Explore & connect',
      description:
          'Discover unique local products, run campaigns as a retailer, '
          'or browse influencer opportunities—all in one beautifully simple interface.',
      color: AppColors.roleRetailer,
      bg: AppColors.roleRetailerLight,
    ),
    _StepData(
      number: '03',
      icon: LucideIcons.trendingUp,
      title: 'Shop, sell & grow',
      description:
          'Complete secure purchases, negotiate in real time, track orders, '
          'monitor your earnings, and watch your community thrive.',
      color: AppColors.roleInfluencer,
      bg: AppColors.roleInfluencerLight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        border: Border.symmetric(
          horizontal:
              BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 64 : 100),
      child: ResponsiveContainer(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.neutral900,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Simple & Fast',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Up and running in minutes.',
                  style: isMobile
                      ? AppTextStyles.h2
                      : AppTextStyles.displaySmall.copyWith(fontSize: 40),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Three simple steps to join the local commerce revolution.',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.neutral600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 72),

                // Steps
                isMobile
                    ? Column(
                        children: _steps.asMap().entries.map((e) {
                          return _HowItWorksStep(
                            step: e.value,
                            index: e.key,
                            isMobile: true,
                            isLast: e.key == _steps.length - 1,
                          );
                        }).toList(),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _steps.asMap().entries.expand((e) {
                          final widgets = <Widget>[
                            Expanded(
                              child: _HowItWorksStep(
                                step: e.value,
                                index: e.key,
                                isMobile: false,
                                isLast: e.key == _steps.length - 1,
                              ),
                            ),
                          ];
                          if (e.key < _steps.length - 1) {
                            widgets.add(_buildConnector());
                          }
                          return widgets;
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnector() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Row(
        children: List.generate(
          6,
          (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: i % 2 == 0
                    ? AppColors.primary300
                    : AppColors.neutral200,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepData {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color bg;

  const _StepData({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.bg,
  });
}

class _HowItWorksStep extends StatefulWidget {
  final _StepData step;
  final int index;
  final bool isMobile;
  final bool isLast;

  const _HowItWorksStep({
    required this.step,
    required this.index,
    required this.isMobile,
    required this.isLast,
  });

  @override
  State<_HowItWorksStep> createState() => _HowItWorksStepState();
}

class _HowItWorksStepState extends State<_HowItWorksStep> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + widget.index * 120),
      curve: Curves.easeOutCubic,
      builder: (ctx, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - v)),
          child: child,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(
            bottom: widget.isMobile && !widget.isLast ? 32 : 0,
          ),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.step.color.withValues(alpha: 0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
            border: Border.all(
              color: _hovered
                  ? widget.step.color.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              // Icon circle with step number badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _hovered
                          ? widget.step.color
                          : widget.step.bg,
                      shape: BoxShape.circle,
                      boxShadow: _hovered
                          ? [
                              BoxShadow(
                                color: widget.step.color
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      widget.step.icon,
                      size: 32,
                      color: _hovered
                          ? AppColors.white
                          : widget.step.color,
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.step.color,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        widget.step.number,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                widget.step.title,
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.step.description,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.neutral600, height: 1.65),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
