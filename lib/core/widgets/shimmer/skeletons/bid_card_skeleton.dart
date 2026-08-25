import 'package:flutter/material.dart';
import '../shimmer.dart';

class BidCardSkeleton extends StatelessWidget {
  const BidCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerImage(width: 48, height: 48, borderRadius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerText(width: 100, height: 16),
                      SizedBox(height: 4),
                      ShimmerText(width: 80, height: 12),
                    ],
                  ),
                ),
                const ShimmerBox(width: 80, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 16),
            const ShimmerText(width: double.infinity, height: 14),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatSkeleton(),
                const ShimmerBox(width: 1, height: 30),
                _buildStatSkeleton(),
                const ShimmerBox(width: 1, height: 30),
                _buildStatSkeleton(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: ShimmerButton(height: 48, borderRadius: 8)),
                SizedBox(width: 12),
                Expanded(child: ShimmerButton(height: 48, borderRadius: 8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Column(
      children: const [
        ShimmerText(width: 60, height: 16),
        SizedBox(height: 4),
        ShimmerText(width: 40, height: 12),
      ],
    );
  }
}
