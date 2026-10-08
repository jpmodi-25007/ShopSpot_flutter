import 'package:flutter/material.dart';
import '../shimmer.dart';

class SupplierCardSkeleton extends StatelessWidget {
  const SupplierCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 48, height: 48, borderRadius: 8),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(width: 120, height: 24),
                      SizedBox(height: 4),
                      ShimmerText(width: 80, height: 12),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShimmerBox(width: 40, height: 20, borderRadius: 4),
                    SizedBox(height: 4),
                    ShimmerText(width: 60, height: 12),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(width: 80, height: 12),
                      SizedBox(height: 4),
                      ShimmerText(width: 60, height: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(width: 80, height: 12),
                      SizedBox(height: 4),
                      ShimmerText(width: 60, height: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact Info
            const Row(
              children: [
                ShimmerBox(width: 100, height: 14, borderRadius: 4),
                SizedBox(width: 16),
                ShimmerBox(width: 100, height: 14, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 16),

            // Recent Orders
            const ShimmerText(width: 100, height: 14),
            const SizedBox(height: 12),
            
            // Order items
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerText(width: 80, height: 14),
                      SizedBox(height: 4),
                      ShimmerText(width: 120, height: 12),
                    ],
                  ),
                ),
                ShimmerBox(width: 60, height: 22, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
