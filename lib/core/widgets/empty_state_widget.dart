import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final double height;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
