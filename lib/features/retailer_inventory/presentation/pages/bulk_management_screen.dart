import 'package:flutter/material.dart';
import 'package:mobile_web/core/widgets/shimmer_effects.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/retailer_inventory_bloc.dart';
import '../bloc/retailer_inventory_event.dart';
import '../bloc/retailer_inventory_state.dart';

class BulkManagementScreen extends StatefulWidget {
  const BulkManagementScreen({super.key});

  @override
  State<BulkManagementScreen> createState() => _BulkManagementScreenState();
}

class _BulkManagementScreenState extends State<BulkManagementScreen> {
  final List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<RetailerInventoryBloc>().add(const GetMyProductsRequested());
  }

  bool get _allSelected {
    if (_products.isEmpty) return false;
    return _products.every((p) => p['selected'] as bool);
  }
  int get _selectedCount => _products.where((p) => p['selected'] as bool).length;

  void _toggleAll(bool? value) {
    if (value == null) return;
    setState(() {
      for (var p in _products) {
        p['selected'] = value;
      }
    });
  }

  void _toggleItem(int index, bool? value) {
    if (value == null) return;
    setState(() {
      _products[index]['selected'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.neutral50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: Text('ShopSpot', style: AppTextStyles.h3.copyWith(color: AppColors.roleRetailer)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.neutral900),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: BlocListener<RetailerInventoryBloc, RetailerInventoryState>(
        listener: (context, state) {
          if (state is RetailerInventoryLoaded) {
            setState(() {
              _products.clear();
              _products.addAll(state.products.map((p) => {
                'id': p.id,
                'name': p.name,
                'category': p.categoryId ?? 'Uncategorized',
                'price': p.sellingPrice.toStringAsFixed(2),
                'selected': false,
              }));
              _isLoading = false;
            });
          } else if (state is RetailerInventoryError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.failure.message)));
          }
        },
        child: _isLoading 
            ? const GenericListShimmer() 
            : Stack(
                children: [
                  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bulk Management', style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text('Update inventory and pricing for multiple products simultaneously.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
                    const SizedBox(height: 24),

                    // Search & Filter
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.neutral200),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.search, size: 18, color: AppColors.neutral400),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search products...',
                                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral400),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.neutral200),
                          ),
                          child: const Center(child: Icon(LucideIcons.listFilter, size: 20, color: AppColors.neutral600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.roleRetailerLight.withValues(alpha: 0.5),
                  border: Border(
                    top: BorderSide(color: AppColors.neutral200),
                    bottom: BorderSide(color: AppColors.neutral200),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _allSelected,
                        tristate: true,
                        onChanged: _toggleAll,
                        activeColor: AppColors.roleRetailer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 3, child: Text('PRODUCT', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w700))),
                    Expanded(flex: 2, child: Text('CATEGORY', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w700))),
                    Expanded(flex: 1, child: Text('PRICE', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                  ],
                ),
              ),

              // Table Body
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _products.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.neutral200),
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: p['selected'] as bool,
                              onChanged: (val) => _toggleItem(index, val),
                              activeColor: AppColors.roleRetailer,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(LucideIcons.image, size: 16, color: AppColors.neutral400),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(p['name'] as String, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(p['category'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(p['price'] as String, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Sticky Footer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.roleRetailerLight.withValues(alpha: 0.5), shape: BoxShape.circle),
                    child: Text('$_selectedCount', style: AppTextStyles.bodySmall.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Text('Selected', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600, fontWeight: FontWeight.w500)),
                  
                  const Spacer(),
                  
                  OutlinedButton(
                    onPressed: _selectedCount > 0 ? () {} : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      side: BorderSide(color: _selectedCount > 0 ? AppColors.roleRetailerLight : AppColors.neutral200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Review Changes', style: AppTextStyles.caption.copyWith(color: _selectedCount > 0 ? AppColors.roleRetailer : AppColors.neutral400, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedCount > 0 ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      backgroundColor: AppColors.roleRetailer,
                      disabledBackgroundColor: AppColors.neutral200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.save, size: 14, color: AppColors.white),
                        const SizedBox(width: 4),
                        Text('Apply to Selected', style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
                ],
              ),
      ),
    );
  }
}
