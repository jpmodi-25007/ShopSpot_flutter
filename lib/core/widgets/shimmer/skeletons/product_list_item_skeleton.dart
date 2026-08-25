import 'package:flutter/material.dart';
import '../shimmer.dart';

class ProductListItemSkeleton extends StatelessWidget {
  const ProductListItemSkeleton({super.key});

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
        child: Row(
          children: [
            const ShimmerImage(width: 72, height: 72, borderRadius: 12),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerText(width: 150, height: 16),
                  SizedBox(height: 4),
                  ShimmerText(width: 100, height: 12),
                  SizedBox(height: 8),
                  ShimmerBox(width: 80, height: 24, borderRadius: 12),
                ],
              ),
            ),
            const ShimmerCircle(radius: 12),
          ],
        ),
      ),
    );
  }
}
