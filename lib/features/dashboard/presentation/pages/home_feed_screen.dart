import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/utils/location_helper.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../shop/presentation/bloc/shop_event.dart';
import '../../../shop/presentation/bloc/shop_state.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../product/presentation/bloc/product_state.dart';
import '../../../../core/utils/guest_helper.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String _currentAddress = 'Fetching location...';

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
      final address = await LocationHelper.getAddressFromCoordinates(
          pos.latitude, pos.longitude);
      if (mounted && address != null) {
        setState(() {
          _currentAddress = address;
        });
      } else if (mounted) {
        setState(() {
          _currentAddress = 'Unknown Location';
        });
      }
    } else {
      if (mounted) {
        context.read<ShopBloc>().add(
            const GetNearbyShopsRequested(lat: 23.0225, lng: 72.5714));
      }
      if (mounted) {
        setState(() {
          _currentAddress = 'Ahmedabad (Default)';
        });
      }
    }
  }

  Future<void> _refresh() async {
    _fetchLocationAndShops();
    context.read<ProductBloc>().add(const GetTrendingProductsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.roleCustomer,
          backgroundColor: AppColors.white,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
            // Sticky Premium Header
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.neutral50.withValues(alpha: 0.95),
              surfaceTintColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.roleCustomerLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.mapPin,
                        size: 16, color: AppColors.roleCustomer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Delivering to',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.neutral500)),
                        Row(
                          children: [
                            Text(_currentAddress,
                                style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.neutral900)),
                            const Icon(LucideIcons.chevronDown,
                                size: 16, color: AppColors.neutral900),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (GuestHelper.checkGuestAndPrompt(context)) return;
                      context.push('/notifications');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neutral900
                                .withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Badge(
                          child: Icon(LucideIcons.bell,
                              size: 20, color: AppColors.neutral900)),
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.neutral900.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search boutiques, products, styles...',
                        hintStyle: AppTextStyles.body
                            .copyWith(color: AppColors.neutral400),
                        prefixIcon: const Icon(LucideIcons.search,
                            color: AppColors.neutral900),
                        suffixIcon: const Icon(LucideIcons.slidersHorizontal,
                            color: AppColors.neutral900, size: 18),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Categories
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _buildCategoryItem(LucideIcons.monitor, 'Electronics',
                            AppColors.warning100, AppColors.warning600),
                        _buildCategoryItem(LucideIcons.gem, 'Jewellery',
                            AppColors.roleCustomerLight, AppColors.roleCustomer),
                        _buildCategoryItem(LucideIcons.shirt, 'Fashion',
                            AppColors.info100, AppColors.info500),
                        _buildCategoryItem(LucideIcons.sofa, 'Furniture',
                            AppColors.neutral200, AppColors.neutral700),
                        _buildCategoryItem(LucideIcons.shoppingBag, 'Grocery',
                            AppColors.error100, AppColors.error500),
                      ],
                    ),
                  ),

                  // Premium Deals Banner
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.roleCustomer,
                            AppColors.roleCustomerLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.roleCustomer
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.white
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('LIMITED TIME',
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5)),
                                ),
                                const SizedBox(height: 12),
                                Text('Exclusive App\nDiscounts',
                                    style: AppTextStyles.h2
                                        .copyWith(color: AppColors.white)),
                                const SizedBox(height: 8),
                                Text('Up to 40% off on nearby shops',
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.white
                                            .withValues(alpha: 0.8))),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text('Explore Deals',
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.roleCustomer,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.white.withValues(alpha: 0.2),
                                  width: 1),
                            ),
                            child: const Center(
                              child: Text('40%',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Nearby Shops Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Curated Boutiques', style: AppTextStyles.h3),
                        Text('See all',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.roleCustomer,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  BlocBuilder<ShopBloc, ShopState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (state.failure != null) {
                        return Center(child: Text('Failed to load shops'));
                      } else if (state.nearbyShops != null) {
                        final shops = state.nearbyShops!;
                        if (shops.isEmpty) {
                          return const Center(
                              child: Text("No nearby shops found."));
                        }
                        return SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: shops.length,
                            itemBuilder: (context, index) {
                              final shop = shops[index];
                              return _buildPremiumShopCard(
                                  context,
                                  shop.id,
                                  shop.name,
                                  shop.city ?? 'Local',
                                  '1.2 km',
                                  shop.rating.toString(),
                                  shop.logoUrl ?? '');
                            },
                          ),
                        );
                      }
                      return const SizedBox(
                          height: 240,
                          child: Center(child: Text("Loading boutiques...")));
                    },
                  ),

                  // Trending Products Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Trending Near You', style: AppTextStyles.h3),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        if (constraints.maxWidth >= 900) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 3;
                        }

                        return BlocBuilder<ProductBloc, ProductState>(
                          builder: (context, state) {
                            if (state is ProductLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (state is ProductError) {
                              return Center(
                                  child: Text(state.failure.message));
                            } else if (state is ProductsLoaded) {
                              if (state.products.isEmpty) {
                                return const Center(
                                    child: Text("No trending products."));
                              }
                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.58, // Taller for premium feel
                                children: state.products
                                    .take(crossAxisCount * 3) // Show a few rows
                                    .map((p) => _buildPremiumProductCard(
                                        context,
                                        p.id,
                                        p.shopId,
                                        p.name,
                                        'Shop Spot',
                                        '₹${p.sellingPrice}',
                                        p.images.isNotEmpty
                                            ? p.images.first
                                            : '',
                                        p.stockQuantity > 0
                                            ? AppBadgeType.inStock
                                            : AppBadgeType.lowStock,
                                        p.stockQuantity > 0
                                            ? 'In Stock'
                                            : 'Low Stock'))
                                    .toList(),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding for nav
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      IconData icon, String label, Color bgColor, Color iconColor) {
    return GestureDetector(
      onTap: () {
        context.go('/search?q=$label');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral900.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutral700, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumShopCard(BuildContext context, String shopId,
      String title, String category, String distance, String rating, String imageUrl) {
    return InkWell(
      onTap: () async {
        await context.push('/shop-detail/$shopId');
        if (mounted) _refresh();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl.isNotEmpty ? imageUrl : 'invalid',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/web_hero_boutique.jpg',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(100)),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.star,
                              size: 14, color: AppColors.secondary500),
                          const SizedBox(width: 4),
                          Text(rating,
                              style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neutral900)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(category,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.neutral500)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.mapPin,
                            size: 12, color: AppColors.neutral600),
                        const SizedBox(width: 4),
                        Text(distance,
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.neutral600,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumProductCard(
      BuildContext context,
      String productId,
      String shopId,
      String title,
      String shop,
      String price,
      String imageUrl,
      AppBadgeType? badgeType,
      String badgeText) {
    return GestureDetector(
      onTap: () async {
        await context.push('/product-detail/$productId');
        if (mounted) _refresh();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      imageUrl.isNotEmpty ? imageUrl : 'invalid',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/web_lifestyle_shopping.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  if (badgeType != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: AppBadge(type: badgeType, text: badgeText),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle),
                      child: const Icon(LucideIcons.heart,
                          size: 16, color: AppColors.neutral600),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(shop,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.neutral500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price,
                          style: AppTextStyles.h4
                              .copyWith(color: AppColors.roleCustomer)),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: AppColors.roleCustomerLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(LucideIcons.plus,
                            size: 16, color: AppColors.roleCustomer),
                      ),
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
