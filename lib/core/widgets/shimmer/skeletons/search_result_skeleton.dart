import 'package:flutter/material.dart';
import '../shimmer.dart';

class SearchResultSkeleton extends StatelessWidget {
  const SearchResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 100, height: 100, borderRadius: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerText(width: 120, height: 18),
                    SizedBox(height: 8),
                    ShimmerText(width: 80, height: 14),
                    SizedBox(height: 12),
                    ShimmerText(width: 40, height: 14),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: ShimmerBox(width: 24, height: 24, borderRadius: 12),
            ),
          ],
        ),
      ),
    );
  }
}
