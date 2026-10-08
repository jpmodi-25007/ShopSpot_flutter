import 'package:flutter/material.dart';
import '../shimmer.dart';

class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Placeholder
            ShimmerCircle(radius: 22),
            SizedBox(width: 16),
            
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerText(width: 150, height: 14),
                      ShimmerText(width: 40, height: 12),
                    ],
                  ),
                  SizedBox(height: 8),
                  ShimmerText(width: double.infinity, height: 12),
                  SizedBox(height: 4),
                  ShimmerText(width: 200, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
