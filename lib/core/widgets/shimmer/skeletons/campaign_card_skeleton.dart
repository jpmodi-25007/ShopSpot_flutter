import 'package:flutter/material.dart';
import '../shimmer.dart';

class CampaignCardSkeleton extends StatelessWidget {
  const CampaignCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerText(width: 150, height: 18),
                ShimmerBox(width: 60, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatSkeleton(),
                const ShimmerBox(width: 1, height: 30),
                _buildStatSkeleton(),
                const ShimmerBox(width: 1, height: 30),
                _buildStatSkeleton(),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1, color: Colors.transparent),
            ),
            const Center(
              child: ShimmerText(width: 100, height: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Column(
      children: const [
        ShimmerText(width: 50, height: 20),
        SizedBox(height: 4),
        ShimmerText(width: 40, height: 12),
      ],
    );
  }
}
