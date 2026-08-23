import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/location_helper.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../shop/presentation/bloc/shop_event.dart';
import '../../../shop/presentation/bloc/shop_state.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../product/presentation/bloc/product_state.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  @override
  void initState() {
    super.initState();
    _fetchLocationAndShops();
    context.read<ProductBloc>().add(const GetTrendingProductsRequested());
  }

  Future<void> _fetchLocationAndShops() async {
    final pos = await LocationHelper.getCurrentLocation();
    if (pos != null) {
      if (mounted) {
        context.read<ShopBloc>().add(GetNearbyShopsRequested(
            lat: pos.latitude, lng: pos.longitude));
      }
    } else {
      if (mounted) {
        context.read<ShopBloc>().add(
            const GetNearbyShopsRequested(lat: 23.0225, lng: 72.5714));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Premium Background Map Placeholder
          Container(
            color: AppColors.neutral100,
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GridPaper(
                    color: AppColors.neutral300.withValues(alpha: 0.5),
                    divisions: 1,
                    subdivisions: 1,
                    interval: 100,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.map,
                          size: 80, color: AppColors.neutral300),
                      const SizedBox(height: 16),
                      Text('Interactive Map Loading...',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.neutral400)),
                    ],
                  ),
                ),
                // Fake premium markers
                Positioned(
                  top: 300,
                  left: 150,
                  child: _buildPremiumMarker('The Style Studio'),
                ),
                Positioned(
                  top: 450,
                  right: 100,
                  child: _buildPremiumMarker('Luxe Living'),
                ),
              ],
            ),
          ),

          // Floating Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.neutral900
                                .withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.search,
                            color: AppColors.neutral900, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Search curated boutiques...',
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.neutral500)),
                        ),
                        Container(
                            width: 1,
                            height: 20,
                            color: AppColors.neutral200,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16)),
                        const Icon(LucideIcons.slidersHorizontal,
                            color: AppColors.roleCustomer, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Action Buttons (Right side)
          Positioned(
            right: 20,
            top: 140,
            child: Column(
              children: [
                _buildFloatingButton(LucideIcons.crosshair),
                const SizedBox(height: 16),
                _buildFloatingButton(LucideIcons.layers),
              ],
            ),
          ),

          // Premium Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.15,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.neutral900
                              .withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, -8)),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                              color: AppColors.neutral200,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Discover Nearby',
                          style: AppTextStyles.h2
                              .copyWith(color: AppColors.neutral900)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 14, color: AppColors.neutral500),
                          const SizedBox(width: 6),
                          Text('Exploring C.G. Road Area',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.neutral500)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Curated Offers',
                              style: AppTextStyles.h4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.roleCustomerLight,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.flame,
                                    size: 14,
                                    color: AppColors.roleCustomer),
                                const SizedBox(width: 4),
                                Text('Hot',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.roleCustomer,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state is ProductLoading) {
                            return const SizedBox(
                                height: 180,
                                child: Center(
                                    child: CircularProgressIndicator()));
                          } else if (state is ProductError) {
                            return SizedBox(
                                height: 180,
                                child: Center(
                                    child: Text(state.failure.message)));
                          } else if (state is ProductsLoaded) {
                            if (state.products.isEmpty) {
                              return const SizedBox(
                                  height: 180,
                                  child: Center(
                                      child: Text("No featured deals.")));
                            }
                            return SizedBox(
                              height: 180,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: state.products.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final p = state.products[index];
                                  return _buildPremiumHorizontalDealCard(
                                    p.name,
                                    'Rs.${p.sellingPrice}',
                                    p.mrp != null ? 'Rs.${p.mrp}' : '',
                                    p.mrp != null
                                        ? '${((1 - (p.sellingPrice / p.mrp!)) * 100).toStringAsFixed(0)}% OFF'
                                        : '',
                                    p.images.isNotEmpty
                                        ? p.images.first
                                        : '',
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 40),

                      // List of boutiques
                      Text('Local Boutiques', style: AppTextStyles.h4),
                      const SizedBox(height: 16),
                      BlocBuilder<ShopBloc, ShopState>(
                        builder: (context, state) {
                          if (state.isLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state.nearbyShops != null) {
                            final shops = state.nearbyShops!;
                            if (shops.isEmpty) {
                              return const Center(
                                  child: Text('No shops found nearby.'));
                            }
                            return Column(
                              children: shops
                                  .map((shop) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 16),
                                        child: _buildPremiumShopListItem(
                                          shop.name,
                                          shop.city ?? 'Local',
                                          shop.rating.toString(),
                                          '1.2 km away',
                                          'View Collection',
                                          AppBadgeType.inStock,
                                        ),
                                      ))
                                  .toList(),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPremiumMarker(String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neutral900,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text(title,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.white, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 4),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.roleCustomer,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.roleCustomer.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Icon(icon, color: AppColors.neutral700, size: 22),
    );
  }

  Widget _buildPremiumHorizontalDealCard(String title, String price,
      String originalPrice, String discount, String imageUrl) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.8)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15)),
                  child: Image.network(
                    imageUrl.isNotEmpty ? imageUrl : 'invalid',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset(
                            'assets/images/web_lifestyle_shopping.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity),
                  ),
                ),
                if (discount.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(discount,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.error500,
                              fontWeight: FontWeight.w800)),
                    ),
                  )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(price,
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.neutral900,
                            fontWeight: FontWeight.w800)),
                    if (originalPrice.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(originalPrice,
                          style: AppTextStyles.caption.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.neutral400)),
                    ]
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPremiumShopListItem(String name, String category, String rating,
      String distance, String topProduct, AppBadgeType badgeType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neutral200)),
                child: ClipOval(
                  child: Image.network(
                    'invalid',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/web_hero_boutique.jpg',
                            fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name,
                            style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(distance,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.neutral600,
                                  fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(LucideIcons.star,
                            size: 14, color: AppColors.secondary500),
                        const SizedBox(width: 4),
                        Text(rating,
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.neutral900,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Text('• $category',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.neutral500)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, color: AppColors.neutral100),
          ),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: AppColors.roleCustomerLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(LucideIcons.sparkles,
                    size: 16, color: AppColors.roleCustomer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest Collection',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.neutral500)),
                    Text(topProduct,
                        style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900)),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight,
                  color: AppColors.neutral400, size: 20),
            ],
          )
        ],
      ),
    );
  }
}
