import 'package:flutter/material.dart';
import '../shimmer.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            const Expanded(
              child: ShimmerImage(
                width: double.infinity,
                borderRadius: 16,
              ),
            ),
            
            // Content area
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const ShimmerText(width: double.infinity, height: 14),
                  const SizedBox(height: 6),
                  
                  // Shop and Location
                  const ShimmerText(width: 80, height: 10),
                  const SizedBox(height: 10),
                  
                  // Price and rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerText(width: 60, height: 16),
                      ShimmerBox(width: 32, height: 20, borderRadius: 8),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
