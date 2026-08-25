import 'package:flutter/material.dart';
import '../shimmer.dart';

class ShopDetailSkeleton extends StatelessWidget {
  const ShopDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Banner Shimmer
            AppShimmer(child: const ShimmerBox(width: double.infinity, height: 200, borderRadius: 0)),
            
            // Logo and Title Shimmer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: AppShimmer(child: const ShimmerBox(width: 80, height: 80, borderRadius: 12)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(child: const ShimmerText(width: 200, height: 24)),
                          const SizedBox(height: 8),
                          AppShimmer(child: const ShimmerText(width: 150, height: 16)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => Column(
                  children: [
                    AppShimmer(child: const ShimmerCircle(radius: 24)),
                    const SizedBox(height: 8),
                    AppShimmer(child: const ShimmerText(width: 40, height: 12)),
                  ],
                )),
              ),
            ),
            const SizedBox(height: 24),

            // Info Card Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer(child: const ShimmerText(width: double.infinity, height: 16)),
                    const SizedBox(height: 8),
                    AppShimmer(child: const ShimmerText(width: 200, height: 16)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(),
                    ),
                    AppShimmer(child: const ShimmerText(width: 150, height: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tabs Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AppShimmer(child: const ShimmerText(width: 60, height: 16)),
                  AppShimmer(child: const ShimmerText(width: 60, height: 16)),
                  AppShimmer(child: const ShimmerText(width: 60, height: 16)),
                  AppShimmer(child: const ShimmerText(width: 60, height: 16)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // Product Grid Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
                children: List.generate(4, (index) => const ProductCardSkeleton()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
