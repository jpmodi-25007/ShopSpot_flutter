import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/network/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../domain/entities/shop_entity.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import '../../../product/domain/entities/product_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShopDetailScreen extends StatefulWidget {
  final String shopId;
  final bool isInfluencer;
  const ShopDetailScreen({super.key, required this.shopId, this.isInfluencer = false});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;
  List<dynamic> _reviews = [];
  List<dynamic> _offers = [];
  bool _isLoadingReviews = true;
  bool _isLoadingOffers = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<ShopBloc>().add(GetPublicShopRequested(widget.shopId));
    context.read<ShopBloc>().add(GetShopProductsRequested(id: widget.shopId));
    _fetchReviews();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.get('/shops/${widget.shopId}/offers');
      if (mounted) {
        setState(() {
          _offers = response.data is List ? response.data : (response.data['data'] ?? []);
          _isLoadingOffers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingOffers = false);
      }
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.get('/shops/${widget.shopId}/reviews');
      if (mounted) {
        setState(() {
          _reviews = response.data is List ? response.data : (response.data['data'] ?? []);
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  String _formatAddress(ShopEntity? shop) {
    if (shop == null) return '';
    final addressLine = shop.address.isNotEmpty ? shop.address : null;
    final otherParts = [shop.city, shop.state, shop.pincode].where((p) => p != null && p.isNotEmpty).toList();
    if (addressLine == null && otherParts.isEmpty) return 'Address not provided';
    if (addressLine != null && otherParts.isNotEmpty) return '$addressLine\n${otherParts.join(', ')}';
    if (addressLine != null) return addressLine;
    return otherParts.join(', ');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: BlocBuilder<ShopBloc, ShopState>(
        builder: (context, state) {
          if (state is ShopInitial || (state is ShopStateLoaded && state.shop == null && state.isLoading)) {
            return const ShopDetailSkeleton();
          }
          if (state is ShopStateLoaded && state.failure != null && state.shop == null) {
            return Center(child: Text(state.failure!.message));
          }
          
          final shop = state is ShopStateLoaded ? state.shop : null;
          final products = state is ShopStateLoaded ? (state.products ?? <ProductEntity>[]) : <ProductEntity>[];

          return DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.share2, color: AppColors.neutral900),
                        ),
                        onPressed: () async {
                          if (shop != null) {
                            try {
                              final name = shop.name.isNotEmpty ? shop.name : 'Shop Name';
                              await Share.share('Check out $name on Findivo!\n${ApiConstants.webBaseUrl}/shop-detail/${shop.id}');
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share functionality unavailable. Try restarting the app.')));
                              }
                            }
                          }
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            shop?.coverImageUrl ?? 'https://images.unsplash.com/photo-1555529733-0e670560f7e1?q=80&w=800&auto=format&fit=crop',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, AppColors.neutral900.withValues(alpha: 0.5)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Logo and Title
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                                  ],
                                  image: DecorationImage(
                                    image: NetworkImage(shop?.logoUrl ?? 'https://images.unsplash.com/photo-1555529733-0e670560f7e1?q=80&w=100&auto=format&fit=crop'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text(shop?.name != null && shop!.name.isNotEmpty ? shop!.name : 'Shop Name', style: AppTextStyles.h2.copyWith(fontSize: 20), maxLines: 3, overflow: TextOverflow.ellipsis)),
                                          const SizedBox(width: 4),
                                          if (shop?.isKycVerified == true)
                                            const Icon(LucideIcons.shieldCheck, size: 20, color: AppColors.primary500),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.star, size: 14, color: AppColors.secondary500),
                                          const SizedBox(width: 4),
                                          Text('${shop?.rating ?? 0.0} (${shop?.reviewCount ?? 0} Reviews)${(shop?.city != null && shop!.city!.isNotEmpty) ? ' • ${shop.city}' : ''}', style: AppTextStyles.caption.copyWith(color: AppColors.neutral700)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      
                      // Action Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionItem(context, LucideIcons.phone, 'Call', onTap: () async {
                            if (shop?.phone != null) {
                              final uri = Uri.parse('tel:${shop!.phone}');
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number not available')));
                            }
                          }),
                          _buildActionItem(context, LucideIcons.messageCircle, 'Message', onTap: () async {
                            if (shop?.whatsapp != null || shop?.phone != null) {
                              final number = shop?.whatsapp ?? shop!.phone;
                              final uri = Uri.parse('sms:$number');
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact number not available')));
                            }
                          }),
                          _buildActionItem(context, LucideIcons.cornerUpRight, 'Directions', onTap: () async {
                            if (shop != null) {
                              final addressQuery = Uri.encodeComponent('${shop.name}, ${shop.address}, ${shop.city}, ${shop.state}');
                              final uri = (shop.latitude != 0 && shop.longitude != 0) 
                                ? Uri.parse('https://www.google.com/maps/search/?api=1&query=${shop.latitude},${shop.longitude}') 
                                : Uri.parse('https://www.google.com/maps/search/?api=1&query=$addressQuery');
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            }
                          }),
                          _buildActionItem(context, LucideIcons.share, 'Share', onTap: () async {
                            if (shop != null) {
                              try {
                                final name = shop.name.isNotEmpty ? shop.name : 'Shop Name';
                                await Share.share('Check out $name on Findivo!\n${ApiConstants.webBaseUrl}/shop-detail/${shop.id}');
                              } catch (e) {
                                // Fallback if Share plugin is missing on this platform (e.g., dev environment)
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share functionality unavailable. Try restarting the app.')));
                                }
                              }
                            }
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Info Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.mapPin, size: 20, color: AppColors.neutral500),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(_formatAddress(shop), style: AppTextStyles.bodySmall),
                                  )
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(),
                              ),
                              Row(
                                children: [
                                  Icon(LucideIcons.clock, size: 20, color: shop?.isOpen == true ? AppColors.success500 : AppColors.error500),
                                  const SizedBox(width: 12),
                                  Text(shop?.isOpen == true ? 'Open Now' : 'Closed', style: AppTextStyles.bodySmall.copyWith(color: shop?.isOpen == true ? AppColors.success500 : AppColors.error500, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: widget.isInfluencer ? AppColors.roleInfluencer : AppColors.primary500,
                    unselectedLabelColor: AppColors.neutral500,
                    indicatorColor: widget.isInfluencer ? AppColors.roleInfluencer : AppColors.primary500,
                    indicatorWeight: 3,
                    labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                    tabs: const [
                      Tab(text: 'Products'),
                      Tab(text: 'Offers'),
                      Tab(text: 'Reviews'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildProductsTab(products),
              _buildOffersTab(),
              _buildReviewsTab(shop),
              _buildAboutTab(shop),
            ],
          ),
        ),
      );
        },
      ),
          ),
        ),
      );
  }
  Widget _buildActionItem(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    final color = widget.isInfluencer ? AppColors.roleInfluencer : AppColors.primary500;
    return InkWell(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label action tapped')));
      },
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: color),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildProductsTab(List<ProductEntity> products) {
    final List<String> categories = ['All', ...products.map((p) => p.categoryId ?? 'Other').toSet()];
    final String selectedCategory = categories.length > _selectedCategoryIndex ? categories[_selectedCategoryIndex] : 'All';
    final List<ProductEntity> filteredProducts = selectedCategory == 'All' 
        ? products 
        : products.where((p) => (p.categoryId ?? 'Other') == selectedCategory).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (widget.isInfluencer ? AppColors.roleInfluencer : AppColors.primary500)
                            : (widget.isInfluencer ? AppColors.roleInfluencerLight : AppColors.primary100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categories[index],
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : (widget.isInfluencer ? AppColors.roleInfluencer : AppColors.primary500),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: filteredProducts.isEmpty 
              ? const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("No products found."),
                  )),
                )
              : SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = filteredProducts[index];
                      return _buildProductCard(
                        p.id,
                        p.name, 
                        '₹${p.sellingPrice}', 
                        p.images.isNotEmpty ? p.images.first : 'https://placehold.co/400x400.png', 
                        p.stockQuantity > 0 ? AppBadgeType.inStock : AppBadgeType.lowStock, 
                        p.stockQuantity > 0 ? 'In Stock' : 'Out of Stock'
                      );
                    },
                    childCount: filteredProducts.length,
                  ),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildProductCard(String productId, String title, String price, String imageUrl, AppBadgeType? badgeType, String badgeText) {
    return InkWell(
      onTap: () => context.push(
        '/product-detail/$productId${widget.isInfluencer ? '?from=influencer' : ''}',
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover),
                  ),
                  if (badgeType != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: AppBadge(type: badgeType, text: badgeText),
                    ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.heart, size: 14, color: AppColors.neutral500),
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
                  Text(title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Immersive audio and vibrant colors.', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price, style: AppTextStyles.h4.copyWith(color: AppColors.primary500)),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.primary100, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.plus, size: 16, color: AppColors.primary500),
                      )
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

  Widget _buildOffersTab() {
    if (_isLoadingOffers) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      ));
    }
    
    if (_offers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(LucideIcons.tag, size: 48, color: AppColors.neutral300),
              const SizedBox(height: 16),
              Text('No active offers', style: AppTextStyles.h4.copyWith(color: AppColors.neutral500)),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: _offers.map((offer) {
        final title = offer['title'] ?? 'Special Offer';
        final description = offer['description'] ?? 'Limited time only';
        final discountType = offer['discountType'] ?? 'PERCENTAGE';
        final discountValue = offer['discountValue']?.toString() ?? '0';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary500, Color(0xFFF97316)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                discountType == 'PERCENTAGE' ? 'FLAT $discountValue% OFF' : '₹$discountValue OFF', 
                style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              Text(title, style: AppTextStyles.h2.copyWith(color: AppColors.white)),
              const SizedBox(height: 4),
              Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withValues(alpha: 0.9))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewsTab(ShopEntity? shop) {
    if (_isLoadingReviews) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      ));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${shop?.rating ?? 0.0}', style: AppTextStyles.h1.copyWith(fontSize: 48)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final rating = shop?.rating ?? 0;
                    return Icon(LucideIcons.star, color: index < rating ? AppColors.secondary500 : AppColors.neutral300, size: 20);
                  }),
                ),
                const SizedBox(height: 4),
                Text('Based on ${shop?.reviewCount ?? 0} reviews', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        if (_reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(LucideIcons.messageSquare, size: 48, color: AppColors.neutral300),
                  const SizedBox(height: 16),
                  Text('No reviews yet', style: AppTextStyles.h4.copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
          )
        else
          ..._reviews.map((r) {
            final customer = r['customer'];
            final name = customer != null ? (customer['displayName'] ?? customer['name'] ?? 'User') : 'Anonymous';
            final date = r['createdAt'] != null ? DateTime.parse(r['createdAt']).toLocal().toString().split(' ')[0] : 'Recently';
            final rating = (r['rating'] as num?)?.toInt() ?? 5;
            final comment = r['comment'] ?? r['title'] ?? 'No comment provided';
            return Column(
              children: [
                _buildReviewItem(name, date, rating, comment),
                const Divider(),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildReviewItem(String name, String date, int rating, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text(date, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) => Icon(LucideIcons.star, color: index < rating ? AppColors.secondary500 : AppColors.neutral300, size: 14)),
          ),
          const SizedBox(height: 8),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAboutTab(ShopEntity? shop) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: [
        Text('About ${shop?.name ?? 'Shop'}', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Text(
          shop?.description ?? 'No description available.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral700, height: 1.5),
        ),
        const SizedBox(height: 24),
        Text('Store Policies', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        _buildPolicyRow(LucideIcons.rotateCcw, '7-Day Return Policy on defective items.'),
        _buildPolicyRow(LucideIcons.truck, 'Free Delivery within 5km radius.'),
        _buildPolicyRow(LucideIcons.creditCard, 'Accepts all major cards and UPI.'),
        const SizedBox(height: 24),
        Text('Location', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        if (shop != null && shop.latitude != 0 && shop.longitude != 0)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(shop.latitude, shop.longitude),
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(shop.id),
                    position: LatLng(shop.latitude, shop.longitude),
                    infoWindow: InfoWindow(title: shop.name),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                  )
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                scrollGesturesEnabled: false,
              ),
            ),
          )
        else
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Location coordinates unavailable',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPolicyRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.neutral500),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
