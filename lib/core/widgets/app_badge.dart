import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum AppBadgeType { inStock, lowStock, outOfStock, verified, premium, deal, newBadge }

class AppBadge extends StatelessWidget {
  final AppBadgeType type;
  final String text;
  final Color? color;
  final Color? backgroundColor;

  const AppBadge({super.key, required this.type, required this.text, this.color, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (backgroundColor != null) return backgroundColor!;
      switch (type) {
        case AppBadgeType.inStock: return AppColors.success100;
        case AppBadgeType.lowStock: return AppColors.warning100;
        case AppBadgeType.outOfStock: return AppColors.error100;
        case AppBadgeType.verified: return AppColors.info100;
        case AppBadgeType.premium: return AppColors.secondary100;
        case AppBadgeType.deal: return AppColors.secondary500;
        case AppBadgeType.newBadge: return AppColors.info100;
      }
    }

    Color getTextColor() {
      if (color != null) return color!;
      switch (type) {
        case AppBadgeType.inStock: return AppColors.success500;
        case AppBadgeType.lowStock: return AppColors.warning500;
        case AppBadgeType.outOfStock: return AppColors.error500;
        case AppBadgeType.verified: return AppColors.info500;
        case AppBadgeType.premium: return AppColors.secondary500;
        case AppBadgeType.deal: return AppColors.white;
        case AppBadgeType.newBadge: return AppColors.info500;
      }
    }

    IconData? getIcon() {
      switch (type) {
        case AppBadgeType.inStock: return LucideIcons.checkCircle;
        case AppBadgeType.lowStock: return LucideIcons.alertTriangle;
        case AppBadgeType.outOfStock: return LucideIcons.xCircle;
        case AppBadgeType.verified: return LucideIcons.shieldCheck;
        case AppBadgeType.premium: return LucideIcons.crown;
        case AppBadgeType.deal: return LucideIcons.flame;
        case AppBadgeType.newBadge: return LucideIcons.sparkles;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getIcon(), size: 10, color: getTextColor()),
          const SizedBox(width: 4),
          Text(text, style: AppTextStyles.caption.copyWith(color: getTextColor())),
        ],
      ),
    );
  }
}
