import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

class FeatureSection extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool reversed;
  final List<String> benefits;
  /// Optional: little floating stat badge shown on the image
  final String? badgeValue;
  final String? badgeLabel;
  final IconData? badgeIcon;
  final Color? badgeColor;
  /// Optional section label shown above title
  final String? sectionLabel;

  const FeatureSection({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.reversed = false,
    required this.benefits,
    this.badgeValue,
    this.badgeLabel,
    this.badgeIcon,
    this.badgeColor,
    this.sectionLabel,
  });

  @override
  State<FeatureSection> createState() => _FeatureSectionState();
}

class _FeatureSectionState extends State<FeatureSection>
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

    Widget textCol = FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _buildTextColumn(isMobile),
      ),
    );

    Widget imageCol = FadeTransition(
      opacity: _fade,
      child: _buildImageColumn(isMobile),
    );

    List<Widget> children = [
      Expanded(flex: isMobile ? 0 : 1, child: textCol),
      if (isMobile) const SizedBox(height: 40),
      Expanded(flex: isMobile ? 0 : 1, child: imageCol),
    ];

    if (widget.reversed && !isMobile) {
      children = children.reversed.toList();
    }

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 56 : 96),
      child: ResponsiveContainer(
        child: Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextColumn(bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(
        right: !widget.reversed && !isMobile ? 48 : 0,
        left: widget.reversed && !isMobile ? 48 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          if (widget.sectionLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: (widget.badgeColor ?? AppColors.neutral900).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                widget.sectionLabel!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: widget.badgeColor ?? AppColors.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Title
          Text(
            widget.title,
            style: (isMobile ? AppTextStyles.h2 : AppTextStyles.displaySmall)
                .copyWith(color: AppColors.neutral900, height: 1.2),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            widget.description,
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.neutral600, height: 1.65),
          ),
          const SizedBox(height: 36),

          // Benefits
          ...widget.benefits.asMap().entries.map((entry) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 350 + entry.key * 80),
              curve: Curves.easeOutCubic,
              builder: (ctx, v, child) => Opacity(
                opacity: v,
                child: Transform.translate(
                    offset: Offset(12 * (1 - v), 0), child: child),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: (widget.badgeColor ?? AppColors.neutral900).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.check,
                          size: 15, color: widget.badgeColor ?? AppColors.neutral900),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.neutral800),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImageColumn(bool isMobile) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main photo
        Container(
          height: isMobile ? 280 : 480,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.12),
                blurRadius: 40,
                offset: const Offset(0, 20),
              )
            ],
            image: DecorationImage(
              image: AssetImage(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Optional floating badge
        if (widget.badgeValue != null)
          Positioned(
            bottom: 24,
            left: 24,
            child: _FloatingMetricBadge(
              value: widget.badgeValue!,
              label: widget.badgeLabel ?? '',
              icon: widget.badgeIcon ?? LucideIcons.trendingUp,
              color: widget.badgeColor ?? AppColors.neutral900,
            ),
          ),
      ],
    );
  }
}

class _FloatingMetricBadge extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _FloatingMetricBadge({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: Offset.zero,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.neutral500)),
            ],
          ),
        ],
      ),
    );
  }
}
