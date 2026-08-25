import 'package:flutter/material.dart';
import '../shimmer.dart';

class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Order Number and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerText(width: 120, height: 16),
                ShimmerBox(width: 80, height: 26, borderRadius: 20),
              ],
            ),
            
            const Divider(height: 24, color: Colors.transparent),
            
            // Middle row: Item image and details
            Row(
              children: [
                const ShimmerImage(width: 60, height: 60, borderRadius: 8),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerText(width: double.infinity, height: 16),
                      SizedBox(height: 6),
                      ShimmerText(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Bottom row: Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerText(width: 80, height: 14),
                ShimmerText(width: 60, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
