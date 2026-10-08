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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          children: [
            ShimmerImage(width: 72, height: 72, borderRadius: 12),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerText(width: 150, height: 16),
                  SizedBox(height: 4),
                  ShimmerText(width: 100, height: 12),
                  SizedBox(height: 8),
                  ShimmerBox(width: 80, height: 24, borderRadius: 12),
                ],
              ),
            ),
            ShimmerCircle(radius: 12),
          ],
        ),
      ),
    );
  }
}
