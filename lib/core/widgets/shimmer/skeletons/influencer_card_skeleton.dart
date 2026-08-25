import 'package:flutter/material.dart';
import '../shimmer.dart';

class InfluencerCardSkeleton extends StatelessWidget {
  const InfluencerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack Area
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  const ShimmerImage(width: double.infinity, height: 200),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: ShimmerBox(width: 90, height: 26, borderRadius: 100),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: ShimmerBox(width: 120, height: 32, borderRadius: 12),
                  ),
                ],
              ),
            ),
            
            // Details Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerText(width: 200, height: 24),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      ShimmerBox(width: 80, height: 26, borderRadius: 8),
                      SizedBox(width: 8),
                      ShimmerBox(width: 80, height: 26, borderRadius: 8),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerText(width: 80, height: 12),
                          SizedBox(height: 4),
                          ShimmerText(width: 120, height: 20),
                        ],
                      ),
                      const ShimmerButton(width: 130, height: 48, borderRadius: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
