import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/shop_entity.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import '../../../product/domain/entities/product_entity.dart';

class ShopDetailScreen extends StatefulWidget {
  final String shopId;
  const ShopDetailScreen({super.key, required this.shopId});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<ShopBloc>().add(GetPublicShopRequested(widget.shopId));
    context.read<ShopBloc>().add(GetShopProductsRequested(id: widget.shopId));
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
            return const Center(child: CircularProgressIndicator());
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
                        onPressed: () {},
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
                    child: Transform.translate(
                      offset: const Offset(0, -20),
                      child: Column(
                        children: [
                          // Logo and Title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.neutral300, width: 2),
                                    image: DecorationImage(
                                      image: NetworkImage(shop?.logoUrl ?? 'https://images.unsplash.com/photo-1555529733-0e670560f7e1?q=80&w=100&auto=format&fit=crop'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(shop?.name ?? 'Shop Name', style: AppTextStyles.h2),
                                          const SizedBox(width: 4),
                                          if (shop?.isKycVerified == true)
                                            const Icon(LucideIcons.shieldCheck, size: 20, color: AppColors.primary500),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.star, size: 14, color: AppColors.secondary500),
                                          const SizedBox(width: 4),
                                          Text('${shop?.rating ?? 0.0} (${shop?.reviewCount ?? 0} Reviews) • ${shop?.city ?? ""}', style: AppTextStyles.caption.copyWith(color: AppColors.neutral700)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                      
                      // Action Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionItem(context, LucideIcons.phone, 'Call'),
                          _buildActionItem(context, LucideIcons.messageCircle, 'Message'),
                          _buildActionItem(context, LucideIcons.cornerUpRight, 'Directions'),
                          _buildActionItem(context, LucideIcons.share, 'Share'),
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
                                    child: Text('102, Shivalik High Street, C.G. Road\nAhmedabad, Gujarat 380009', style: AppTextStyles.bodySmall),
                                  )
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Divider(),
                              ),
                              Row(
                                children: [
                                  const Icon(LucideIcons.clock, size: 20, color: AppColors.success500),
                                  const SizedBox(width: 12),
                                  Text('Open Now', style: AppTextStyles.bodySmall.copyWith(color: AppColors.success500, fontWeight: FontWeight.w600)),
                                  Text(' • Closes 9:00 PM', style: AppTextStyles.bodySmall),
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
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary500,
                    unselectedLabelColor: AppColors.neutral500,
                    indicatorColor: AppColors.primary500,
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
              _buildReviewsTab(),
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
  Widget _buildActionItem(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label action tapped')));
      },
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary500),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary500),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.primary500)),
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
                        color: isSelected ? AppColors.primary500 : AppColors.primary100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categories[index],
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected ? AppColors.white : AppColors.primary500,
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
                        '\$${p.sellingPrice}', 
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
      onTap: () => context.push('/product-detail/$productId'),
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: [
        Container(
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
              Text('FESTIVAL SALE', style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Flat 20% Off on Audio', style: AppTextStyles.h2.copyWith(color: AppColors.white)),
              const SizedBox(height: 4),
              Text('Valid till Oct 31. T&C Apply.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withValues(alpha: 0.9))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BUNDLE OFFER', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Buy 1 Get 1 on Accessories', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text('Selected items only.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('4.8', style: AppTextStyles.h1.copyWith(fontSize: 48)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) => Icon(LucideIcons.star, color: index < 4 ? AppColors.secondary500 : AppColors.neutral300, size: 20)),
                ),
                const SizedBox(height: 4),
                Text('Based on 124 reviews', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        _buildReviewItem('Sarah J.', '2 weeks ago', 5, 'Great experience! I bought a TV and they delivered it within 2 hours. Very professional staff.'),
        const Divider(),
        _buildReviewItem('Mike T.', '1 month ago', 4, 'Good collection of gadgets, but parking is a bit tight near the store.'),
        const Divider(),
        _buildReviewItem('Priya S.', '2 months ago', 5, 'Authentic products and amazing discounts. Highly recommend for electronics!'),
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
        Text('About ElectroHub', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Text(
          'ElectroHub is your premium destination for the latest electronics, home appliances, and gadgets. We pride ourselves on offering authentic products with official warranties.',
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
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=400&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
              ]),
              child: const Icon(LucideIcons.mapPin, color: AppColors.primary500),
            ),
          ),
        )
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
