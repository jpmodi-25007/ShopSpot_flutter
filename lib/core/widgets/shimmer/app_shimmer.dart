import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';

class AppShimmer extends StatelessWidget {
  final Widget child;
  
  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // In a real app with dark mode, we would check Theme.of(context).brightness
    // For now, based on AppColors, we use a subtle, premium light shimmer.
    // If the app gets dark mode, this central place will adapt automatically.
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final baseColor = isDark ? Colors.grey.shade800 : AppColors.neutral200;
    final highlightColor = isDark ? Colors.grey.shade700 : AppColors.neutral100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500), // Smooth, subtle 1.5s animation
      child: child,
    );
  }
}
