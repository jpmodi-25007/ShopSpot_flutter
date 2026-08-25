import 'package:flutter/material.dart';
import '../shimmer.dart';

class PayoutCardSkeleton extends StatelessWidget {
  const PayoutCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 40, height: 40, borderRadius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerText(width: 120, height: 14),
                  SizedBox(height: 6),
                  ShimmerText(width: 80, height: 12),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                ShimmerText(width: 60, height: 16),
                SizedBox(height: 6),
                ShimmerBox(width: 50, height: 20, borderRadius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
