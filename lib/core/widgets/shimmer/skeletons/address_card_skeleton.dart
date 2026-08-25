import 'package:flutter/material.dart';
import '../shimmer.dart';

class AddressCardSkeleton extends StatelessWidget {
  const AddressCardSkeleton({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    ShimmerCircle(radius: 10),
                    SizedBox(width: 8),
                    ShimmerText(width: 80, height: 16),
                    SizedBox(width: 8),
                    ShimmerBox(width: 60, height: 24, borderRadius: 4),
                  ],
                ),
                const ShimmerCircle(radius: 10),
              ],
            ),
            const SizedBox(height: 16),
            const ShimmerText(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            const ShimmerText(width: 200, height: 14),
            const SizedBox(height: 8),
            const ShimmerText(width: 150, height: 14),
          ],
        ),
      ),
    );
  }
}
