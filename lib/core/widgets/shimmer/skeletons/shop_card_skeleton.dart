import 'package:flutter/material.dart';
import '../shimmer.dart';

class ShopCardSkeleton extends StatelessWidget {
  const ShopCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image
            const ShimmerImage(
              width: double.infinity,
              height: 140,
              borderRadius: 20, // Approximates the top radius
            ),
            
            // Bottom Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerText(width: 140, height: 16),
                        SizedBox(height: 8),
                        ShimmerText(width: 100, height: 12),
                      ],
                    ),
                  ),
                  const ShimmerBox(width: 50, height: 26, borderRadius: 8),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
