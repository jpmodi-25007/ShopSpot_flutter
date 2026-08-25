import 'package:flutter/material.dart';
import '../shimmer.dart';

class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: 300,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ShimmerImage(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 16,
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ShimmerText(width: 200, height: 20),
                  SizedBox(height: 8),
                  ShimmerText(width: 150, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
