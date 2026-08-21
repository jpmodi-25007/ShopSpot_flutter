import 'package:flutter/material.dart';
import 'package:mobile_web/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class BaseShimmer extends StatelessWidget {
  final Widget child;
  const BaseShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral200,
      highlightColor: AppColors.neutral100,
      child: child,
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SearchResultShimmer extends StatelessWidget {
  const SearchResultShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const ShimmerContainer(
              width: 100,
              height: 100,
              borderRadius: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerContainer(width: 120, height: 18),
                    const SizedBox(height: 8),
                    const ShimmerContainer(width: 80, height: 14),
                    const SizedBox(height: 12),
                    const ShimmerContainer(width: 40, height: 14),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: ShimmerContainer(width: 24, height: 24, borderRadius: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultListShimmer extends StatelessWidget {
  final int itemCount;
  const SearchResultListShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SearchResultShimmer();
      },
    );
  }
}

class ShopCardShimmer extends StatelessWidget {
  const ShopCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerContainer(
              width: double.infinity,
              height: 140,
              borderRadius: 20, // Only top corners technically, but this is fine for shimmer
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerContainer(width: 120, height: 16),
                        SizedBox(height: 8),
                        ShimmerContainer(width: 80, height: 12),
                      ],
                    ),
                  ),
                  const ShimmerContainer(width: 60, height: 24, borderRadius: 8),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: ShimmerContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerContainer(width: double.infinity, height: 14),
                  const SizedBox(height: 4),
                  const ShimmerContainer(width: 60, height: 10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerContainer(width: 40, height: 16),
                      ShimmerContainer(width: 24, height: 24, borderRadius: 8),
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

class GenericListShimmer extends StatelessWidget {
  const GenericListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return BaseShimmer(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const ShimmerContainer(width: 60, height: 60, borderRadius: 12),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerContainer(width: double.infinity, height: 16),
                      SizedBox(height: 8),
                      ShimmerContainer(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DetailShimmer extends StatelessWidget {
  const DetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerContainer(width: double.infinity, height: 250, borderRadius: 16),
            const SizedBox(height: 24),
            const ShimmerContainer(width: 200, height: 24),
            const SizedBox(height: 12),
            const ShimmerContainer(width: 100, height: 16),
            const SizedBox(height: 24),
            const ShimmerContainer(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            const ShimmerContainer(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            const ShimmerContainer(width: 250, height: 14),
          ],
        ),
      ),
    );
  }
}

class ButtonShimmer extends StatelessWidget {
  const ButtonShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseShimmer(
      child: ShimmerContainer(width: double.infinity, height: 56, borderRadius: 16),
    );
  }
}

class ShopDetailShimmer extends StatelessWidget {
  const ShopDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Banner Shimmer
            const ShimmerContainer(width: double.infinity, height: 200, borderRadius: 0),
            
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
                    child: const ShimmerContainer(width: 80, height: 80, borderRadius: 12),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerContainer(width: 200, height: 24),
                          SizedBox(height: 8),
                          ShimmerContainer(width: 150, height: 16),
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
                  children: const [
                    ShimmerContainer(width: 48, height: 48, borderRadius: 24),
                    SizedBox(height: 8),
                    ShimmerContainer(width: 40, height: 12),
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
                  children: const [
                    ShimmerContainer(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    ShimmerContainer(width: 200, height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(),
                    ),
                    ShimmerContainer(width: 150, height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tabs Shimmer
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ShimmerContainer(width: 60, height: 16),
                  ShimmerContainer(width: 60, height: 16),
                  ShimmerContainer(width: 60, height: 16),
                  ShimmerContainer(width: 60, height: 16),
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
                children: List.generate(4, (index) => const ProductCardShimmer()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
