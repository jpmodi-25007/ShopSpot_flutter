import 'package:flutter/material.dart';
import '../shimmer.dart';

class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerBox(width: double.infinity, height: 250, borderRadius: 16),
            SizedBox(height: 24),
            ShimmerBox(width: 200, height: 24, borderRadius: 4),
            SizedBox(height: 12),
            ShimmerBox(width: 100, height: 16, borderRadius: 4),
            SizedBox(height: 24),
            ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
            SizedBox(height: 8),
            ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
            SizedBox(height: 8),
            ShimmerBox(width: 250, height: 14, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}
