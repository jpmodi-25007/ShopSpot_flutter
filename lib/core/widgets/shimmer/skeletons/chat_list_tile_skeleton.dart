import 'package:flutter/material.dart';
import '../shimmer.dart';

class ChatListTileSkeleton extends StatelessWidget {
  const ChatListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const ShimmerCircle(radius: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerText(width: 120, height: 16),
                      ShimmerText(width: 40, height: 12),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const ShimmerText(width: 180, height: 14),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 80, height: 20, borderRadius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
