import 'package:flutter/material.dart';
import '../shimmer.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            SizedBox(
              height: 140,
              child: ShimmerImage(
                width: double.infinity,
                borderRadius: 16,
              ),
            ),
            
            // Content area
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  ShimmerText(width: double.infinity, height: 14),
                  SizedBox(height: 6),
                  
                  // Shop and Location
                  ShimmerText(width: 80, height: 10),
                  SizedBox(height: 10),
                  
                  // Price and rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
