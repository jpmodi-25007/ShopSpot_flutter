import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';
  
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
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => _ProductFilterBottomSheet(
                  currentFilter: _selectedFilter,
                  currentSort: _selectedSort,
                ),
              );
            },
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
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
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
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
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

                BlocListener<RetailerInventoryBloc, RetailerInventoryState>(
                  listener: (context, state) {
                    if (state is RetailerInventoryError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(LucideIcons.alertCircle, color: AppColors.white, size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(state.failure.message)),
                            ],
                          ),
                          backgroundColor: AppColors.error500,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<RetailerInventoryBloc, RetailerInventoryState>(
                    builder: (context, state) {
                    int totalItems = 0;
                    double totalValue = 0.0;
                    if (state is RetailerInventoryLoaded) {
                      totalItems = state.products.length;
                      for (var product in state.products) {
                        totalValue +=
                            product.sellingPrice * product.stockQuantity;
                      }
                    }

                    final currencyFormat = NumberFormat.currency(
                        locale: 'en_IN', symbol: '₹', decimalDigits: 2);

                    return Column(
                      children: [
                        // Total Stock Value
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.roleRetailer.withValues(alpha: 0.9),
                                AppColors.roleRetailer.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.roleRetailer.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: AppColors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle),
                                    child: const Icon(LucideIcons.wallet,
                                        color: AppColors.white, size: 24),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(LucideIcons.trendingUp, color: AppColors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('+4.2%', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text('Total Stock Value',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 6),
                              Text(currencyFormat.format(totalValue),
                                  style: AppTextStyles.h1.copyWith(color: AppColors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Total Items in Stock
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.neutral900.withValues(alpha: 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8)),
                            ],
                            border: Border.all(
                                color: AppColors.neutral200.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: AppColors.warning50,
                                    borderRadius: BorderRadius.circular(20)),
                                child: const Icon(LucideIcons.packageOpen,
                                    color: AppColors.warning600, size: 28),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Items in Stock',
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: AppColors.neutral500)),
                                  const SizedBox(height: 4),
                                  Text(NumberFormat.compact().format(totalItems),
                                      style: AppTextStyles.h2.copyWith(color: AppColors.neutral900)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
                      BlocBuilder<RetailerInventoryBloc, RetailerInventoryState>(
                        builder: (context, state) {
                          if (state is! RetailerInventoryLoaded || state.products.isEmpty) {
                            return const Center(child: Text("No data available"));
                          }
                          
                          final Map<String, int> categoryCounts = {};
                          for (var p in state.products) {
                            final cat = p.categoryId ?? 'Uncategorized';
                            categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
                          }
                          
                          final sortedCats = categoryCounts.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));
                            
                          final totalProducts = state.products.length;
                          final topColors = [AppColors.roleRetailer, AppColors.warning500, AppColors.info500, AppColors.neutral400];
                          
                          return Column(
                            children: [
                              for (int i = 0; i < sortedCats.length && i < 4; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildCategoryProgress(
                                    sortedCats[i].key, 
                                    sortedCats[i].value / totalProducts, 
                                    topColors[i % topColors.length]
                                  ),
                                ),
                            ],
                          );
                        }
                      ),
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
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Low Stock';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Filtered by Low Stock! Scroll down to view.'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: Text('View All',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.roleRetailer,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                BlocBuilder<RetailerInventoryBloc, RetailerInventoryState>(
                  builder: (context, state) {
                    if (state is! RetailerInventoryLoaded) return const SizedBox.shrink();
                    final lowStockProducts = state.products.where((p) => p.stockQuantity < 10).take(3).toList();
                    if (lowStockProducts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("All stocks look good!"),
                      );
                    }
                    return Column(
                      children: lowStockProducts.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildLowStockItem(
                          p.name, 
                          p.categoryId ?? 'Uncategorized', 
                          '${p.stockQuantity} Left',
                          p.stockQuantity <= 3 ? AppColors.error500 : AppColors.warning600
                        ),
                      )).toList(),
                    );
                  }
                ),

                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Products', style: AppTextStyles.h3),
                    InkWell(
                      onTap: () async {
                        final result = await showModalBottomSheet<Map<String, String>>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => _ProductFilterBottomSheet(
                            currentFilter: _selectedFilter,
                            currentSort: _selectedSort,
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedFilter = result['filter'] ?? 'All';
                            _selectedSort = result['sort'] ?? 'Newest';
                          });
                        }
                      },
                      child: Row(
                        children: [
                          if (_selectedFilter != 'All')
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.roleRetailer.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(_selectedFilter, style: AppTextStyles.caption.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.bold)),
                            ),
                          Text('Filter',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.roleRetailer,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                BlocBuilder<RetailerInventoryBloc, RetailerInventoryState>(
                  builder: (context, state) {
                    if (state is RetailerInventoryLoading) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            const ProductListItemSkeleton(),
                      );
                    } else if (state is RetailerInventoryError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.error50.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.wifiOff, color: AppColors.error500, size: 32),
                              ),
                              const SizedBox(height: 16),
                              Text('Failed to load products', style: AppTextStyles.h4),
                              const SizedBox(height: 8),
                              Text('Please check your connection and try again.', 
                                style: AppTextStyles.body.copyWith(color: AppColors.neutral500),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.read<RetailerInventoryBloc>().add(const GetMyProductsRequested());
                                },
                                icon: const Icon(LucideIcons.refreshCw, size: 16, color: AppColors.roleRetailer),
                                label: const Text('Try Again', style: TextStyle(color: AppColors.roleRetailer)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.roleRetailer),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else if (state is RetailerInventoryLoaded) {
                      List<dynamic> filteredProducts = state.products;
                      
                      if (_searchQuery.isNotEmpty) {
                        filteredProducts = filteredProducts.where((p) => 
                          p.name.toLowerCase().contains(_searchQuery) || 
                          (p.sku?.toLowerCase().contains(_searchQuery) ?? false)
                        ).toList();
                      }
                      
                      if (_selectedFilter == 'Low Stock') {
                        filteredProducts = filteredProducts.where((p) => p.stockQuantity > 0 && p.stockQuantity < 10).toList();
                      } else if (_selectedFilter == 'Out of Stock') {
                        filteredProducts = filteredProducts.where((p) => p.stockQuantity <= 0).toList();
                      }
                      
                      if (_selectedSort == 'Newest') {
                         filteredProducts.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0);
                      } else if (_selectedSort == 'Price: High to Low') {
                         filteredProducts.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
                      } else if (_selectedSort == 'Price: Low to High') {
                         filteredProducts.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
                      }
                        
                      if (filteredProducts.isEmpty) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Text('No products found matching your filters.'),
                        ));
                      }
                      return Column(
                        children: filteredProducts.map((product) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildPremiumProductListItem(
                              context,
                              product,
                              product.id,
                              product.name,
                              product.categoryId ?? 'Uncategorized',
                              '₹${product.sellingPrice}',
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
                          onPressed: () {
                            context.push('/retailer/inventory-report');
                          },
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
          border:
              Border.all(color: AppColors.neutral200.withValues(alpha: 0.8)),
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
                    color: AppColors.neutral700, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral700, fontWeight: FontWeight.w600)),
            Text('${(percentage * 100).toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral900, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
              ),
            ),
          ],
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
      dynamic productObj,
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
          border:
              Border.all(color: AppColors.neutral200.withValues(alpha: 0.6)),
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
                  context.push('/retailer/add-product', extra: productObj);
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

class _ProductFilterBottomSheet extends StatefulWidget {
  final String currentFilter;
  final String currentSort;
  const _ProductFilterBottomSheet({required this.currentFilter, required this.currentSort});

  @override
  State<_ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<_ProductFilterBottomSheet> {
  late String _selectedSort;
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
    _selectedFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter & Sort', style: AppTextStyles.h3),
                  IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => context.pop()),
                ],
              ),
              const SizedBox(height: 24),
              Text('Status',
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'All',
                  'Low Stock',
                  'Out of Stock',
                ]
                    .map((s) => ChoiceChip(
                          label: Text(s),
                          selected: _selectedFilter == s,
                          onSelected: (val) {
                            if (val) setState(() => _selectedFilter = s);
                          },
                          selectedColor: AppColors.roleRetailerLight
                              .withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: _selectedFilter == s
                                ? AppColors.roleRetailer
                                : AppColors.neutral700,
                            fontWeight: _selectedFilter == s
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text('Sort By',
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Newest',
                  'Oldest',
                  'Price: High to Low',
                  'Price: Low to High'
                ]
                    .map((s) => ChoiceChip(
                          label: Text(s),
                          selected: _selectedSort == s,
                          onSelected: (val) {
                            if (val) setState(() => _selectedSort = s);
                          },
                          selectedColor: AppColors.roleRetailerLight
                              .withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: _selectedSort == s
                                ? AppColors.roleRetailer
                                : AppColors.neutral700,
                            fontWeight: _selectedSort == s
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roleRetailer,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  context.pop({'filter': _selectedFilter, 'sort': _selectedSort});
                },
                child: const Text('Apply Filters',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
