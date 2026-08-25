import 'package:flutter/material.dart';
import '../shimmer.dart';

class StockHistoryItemSkeleton extends StatelessWidget {
  const StockHistoryItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              ShimmerCircle(radius: 7),
              SizedBox(width: 6),
              ShimmerText(width: 120, height: 12),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const ShimmerBox(width: 40, height: 40, borderRadius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerText(width: 150, height: 14),
                          SizedBox(height: 4),
                          ShimmerText(width: 100, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerText(width: 40, height: 12),
                    ShimmerText(width: 60, height: 14),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerText(width: 50, height: 12),
                    ShimmerBox(width: 80, height: 20, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerText(width: 40, height: 12),
                    ShimmerCircle(radius: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
