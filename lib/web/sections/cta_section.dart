import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

class CTASection extends StatefulWidget {
  const CTASection({super.key});

  @override
  State<CTASection> createState() => _CTASectionState();
}

class _CTASectionState extends State<CTASection>
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

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: AppColors.neutral900,
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 64 : 100, horizontal: 24),
      child: ResponsiveContainer(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              children: [
                // Top label
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'Join the community',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Headline
                Text(
                  isMobile
                      ? 'Ready to shop local?'
                      : 'Ready to transform your\nlocal shopping experience?',
                  style: (isMobile
                          ? AppTextStyles.h2
                          : AppTextStyles.display.copyWith(fontSize: 48))
                      .copyWith(color: AppColors.white, height: 1.15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Text(
                  'Join thousands of customers, retailers, and influencers\nalready using Findivo to grow their local communities.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.neutral400,
                    height: 1.65,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // CTAs
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _CTAButton(
                      label: 'Get Started Free',
                      icon: LucideIcons.arrowRight,
                      onTap: () => context.go('/signup'),
                      isPrimary: true,
                    ),
                    _CTAButton(
                      label: 'Contact Sales',
                      icon: LucideIcons.mail,
                      onTap: () => context.go('/contact'),
                      isPrimary: false,
                    ),
                  ],
                ),
                const SizedBox(height: 56),

                // Social proof row
                _buildSocialProof(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialProof(bool isMobile) {
    final items = [
      {'icon': LucideIcons.shieldCheck, 'text': 'No credit card required'},
      {'icon': LucideIcons.zap, 'text': 'Setup in under 5 minutes'},
      {'icon': LucideIcons.lock, 'text': 'Bank-grade security'},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isMobile ? 20 : 40,
      runSpacing: 12,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item['icon'] as IconData,
                size: 16, color: AppColors.white),
            const SizedBox(width: 8),
            Text(
              item['text'] as String,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.neutral400),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _CTAButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _CTAButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> {
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
              const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (_hovered ? AppColors.neutral200 : AppColors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isPrimary
                  ? (_hovered ? AppColors.neutral200 : AppColors.white)
                  : (_hovered
                      ? AppColors.neutral400
                      : AppColors.neutral700),
              width: 1.5,
            ),
            boxShadow: widget.isPrimary && _hovered
                ? [
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.button.copyWith(
                  fontSize: 15,
                  color: widget.isPrimary
                      ? AppColors.neutral900
                      : (_hovered
                          ? AppColors.white
                          : AppColors.neutral300),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSlide(
                offset: _hovered ? const Offset(0.15, 0) : Offset.zero,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isPrimary
                      ? AppColors.neutral900
                      : (_hovered
                          ? AppColors.white
                          : AppColors.neutral400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
