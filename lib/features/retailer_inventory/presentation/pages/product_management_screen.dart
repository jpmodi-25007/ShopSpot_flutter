import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/retailer_inventory_bloc.dart';
import '../bloc/retailer_inventory_event.dart';
import '../bloc/retailer_inventory_state.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RetailerInventoryBloc>().add(const GetMyProductsRequested());
  }

  Future<void> _refresh() async {
    context.read<RetailerInventoryBloc>().add(const GetMyProductsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(LucideIcons.packageSearch,
                color: AppColors.roleRetailer),
            onPressed: () {},
          ),
        ),
        title: Text('Inventory Hub',
            style: AppTextStyles.h3.copyWith(color: AppColors.roleRetailer)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.neutral900),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.roleRetailer,
            backgroundColor: AppColors.white,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              children: [
              Text('Inventory Overview',
                  style: AppTextStyles.h1.copyWith(height: 1.2)),
              const SizedBox(height: 4),
              Text('Manage your stock, alerts, and detailed reports.',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 32),

              // Premium Floating Search Bar
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.neutral900.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4)),
                  ],
                  border: Border.all(
                      color: AppColors.neutral200.withValues(alpha: 0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search,
                        size: 20, color: AppColors.neutral400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products, SKUs...',
                          hintStyle: AppTextStyles.body
                              .copyWith(color: AppColors.neutral400),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const Icon(LucideIcons.slidersHorizontal,
                        size: 20, color: AppColors.roleRetailer),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Links Horizontal Scroll
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildPremiumQuickLink(context, 'Stock History',
                        LucideIcons.history, '/retailer/stock-history'),
                    const SizedBox(width: 12),
                    _buildPremiumQuickLink(context, 'Bulk Update',
                        LucideIcons.layers, '/retailer/bulk-update'),
                    const SizedBox(width: 12),
                    _buildPremiumQuickLink(context, 'Suppliers',
                        LucideIcons.truck, '/retailer/suppliers'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Total Stock Value
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.neutral900.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 8)),
                  ],
                  border: Border.all(
                      color: AppColors.neutral200.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.roleRetailerLight
                                  .withValues(alpha: 0.5),
                              shape: BoxShape.circle),
                          child: const Icon(LucideIcons.wallet,
                              color: AppColors.roleRetailer, size: 24),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.success50,
                              borderRadius: BorderRadius.circular(100)),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.trendingUp,
                                  size: 14, color: AppColors.success600),
                              const SizedBox(width: 4),
                              Text('+5.2%',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.success600,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Total Stock Value',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.neutral500)),
                    const SizedBox(height: 6),
                    Text('\$124,500.00', style: AppTextStyles.h1),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total Items in Stock
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.neutral900.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 8)),
                  ],
                  border: Border.all(
                      color: AppColors.neutral200.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.warning50,
                          shape: BoxShape.circle),
                      child: const Icon(LucideIcons.package,
                          color: AppColors.warning600, size: 24),
                    ),
                    const SizedBox(height: 20),
                    Text('Total Items in Stock',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.neutral500)),
                    const SizedBox(height: 6),
                    Text('3,452', style: AppTextStyles.h1),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Category Distribution
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.neutral900.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 8)),
                  ],
                  border: Border.all(
                      color: AppColors.neutral200.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category Distribution', style: AppTextStyles.h3),
                    const SizedBox(height: 24),
                    _buildCategoryProgress(
                        'Electronics', 0.45, AppColors.roleRetailer),
                    const SizedBox(height: 16),
                    _buildCategoryProgress(
                        'Accessories', 0.30, AppColors.warning500),
                    const SizedBox(height: 16),
                    _buildCategoryProgress(
                        'Apparel', 0.15, AppColors.info500),
                    const SizedBox(height: 16),
                    _buildCategoryProgress(
                        'Other', 0.10, AppColors.neutral400),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Low Stock Alerts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.alertTriangle,
                          size: 24, color: AppColors.error500),
                      const SizedBox(width: 8),
                      Text('Low Stock Alerts', style: AppTextStyles.h3),
                    ],
                  ),
                  Text('View All',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.roleRetailer,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),

              _buildLowStockItem('Pro Wireless Headphones', 'Audio', '3 Left',
                  AppColors.error500),
              const SizedBox(height: 12),
              _buildLowStockItem('Smart Home Hub', 'Electronics', '5 Left',
                  AppColors.warning600),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All Products', style: AppTextStyles.h3),
                  Text('Filter',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.roleRetailer,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),

              BlocBuilder<RetailerInventoryBloc, RetailerInventoryState>(
                builder: (context, state) {
                  if (state is RetailerInventoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RetailerInventoryError) {
                    return Center(
                        child: Text(state.failure.message,
                            style: const TextStyle(color: Colors.red)));
                  } else if (state is RetailerInventoryLoaded) {
                    if (state.products.isEmpty) {
                      return const Center(child: Text('No products found.'));
                    }
                    return Column(
                      children: state.products.map((product) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildPremiumProductListItem(
                            context,
                            product.id,
                            product.name,
                            product.categoryId ?? 'Uncategorized',
                            'Rs.${product.sellingPrice}',
                            product.stockQuantity,
                            product.images.isNotEmpty
                                ? product.images.first
                                : '',
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
          ),

          // Sticky Bottom Buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.8),
                    border: Border(
                        top: BorderSide(
                            color:
                                AppColors.neutral200.withValues(alpha: 0.5))),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.neutral900.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                                color: AppColors.roleRetailer, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Report',
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.roleRetailer,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.push('/retailer/add-product'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.roleRetailer,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.plus,
                                  size: 20, color: AppColors.white),
                              const SizedBox(width: 8),
                              Text('Add Stock',
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumQuickLink(
      BuildContext context, String label, IconData icon, String route) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: AppColors.neutral200.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.neutral700),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral700,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(String label, double percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 44,
          child: Text('${(percentage * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral900, fontWeight: FontWeight.w800),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildLowStockItem(
      String title, String category, String stockLabel, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.alertCircle, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(category,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.neutral500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(stockLabel,
                style: AppTextStyles.bodySmall
                    .copyWith(color: color, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumProductListItem(
      BuildContext context,
      String id,
      String title,
      String category,
      String price,
      int stockQuantity,
      String image) {
    AppBadgeType badgeType =
        stockQuantity > 0 ? AppBadgeType.inStock : AppBadgeType.outOfStock;
    String stockLabel =
        stockQuantity > 0 ? '$stockQuantity left' : 'Out of Stock';

    return InkWell(
      onTap: () async {
        await context.push('/product-detail/$id');
        if (mounted) _refresh();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
          border: Border.all(
              color: AppColors.neutral200.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image.isNotEmpty ? image : 'invalid',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/web_retailer_inventory.jpg',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('$category • $price',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.neutral500)),
                  const SizedBox(height: 8),
                  AppBadge(type: badgeType, text: stockLabel),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical,
                  color: AppColors.neutral400, size: 20),
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('/retailer/add-product');
                } else if (value == 'delete') {
                  // Handle delete
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(LucideIcons.edit2,
                          size: 16, color: AppColors.neutral700),
                      const SizedBox(width: 12),
                      Text('Edit', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(LucideIcons.trash2,
                          size: 16, color: AppColors.error500),
                      const SizedBox(width: 12),
                      Text('Delete',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.error500)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
