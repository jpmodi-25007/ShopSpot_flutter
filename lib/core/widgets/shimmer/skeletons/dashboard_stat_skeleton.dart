import 'package:flutter/material.dart';
import '../shimmer.dart';

class DashboardStatSkeleton extends StatelessWidget {
  const DashboardStatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 60, height: 24, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 16),
            const ShimmerText(width: 100, height: 32),
            const SizedBox(height: 4),
            const ShimmerText(width: 80, height: 12),
          ],
        ),
      ),
    );
  }
}
