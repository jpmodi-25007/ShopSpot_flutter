import 'package:flutter/material.dart';
import '../shimmer.dart';

class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Placeholder
            const ShimmerCircle(radius: 22),
            const SizedBox(width: 16),
            
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerText(width: 150, height: 14),
                      ShimmerText(width: 40, height: 12),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const ShimmerText(width: double.infinity, height: 12),
                  const SizedBox(height: 4),
                  const ShimmerText(width: 200, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
