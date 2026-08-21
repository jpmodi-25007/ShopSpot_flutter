import 'package:flutter/material.dart';
import 'package:mobile_web/core/widgets/shimmer_effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/retailer_inventory_bloc.dart';
import '../bloc/retailer_inventory_event.dart';
import '../bloc/retailer_inventory_state.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  State<SupplierManagementScreen> createState() => _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  final _bloc = getIt<RetailerInventoryBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.add(const GetSuppliersRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.neutral50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.mapPin, color: AppColors.roleRetailer, size: 20),
            const SizedBox(width: 8),
            Text('ShopSpot', style: AppTextStyles.h3.copyWith(color: AppColors.roleRetailer)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.neutral900),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: BlocBuilder<RetailerInventoryBloc, RetailerInventoryState>(
        builder: (context, state) {
          if (state is RetailerInventoryLoading) {
            return const GenericListShimmer();
          }
          
          if (state is RetailerInventoryError) {
            return Center(child: Text(state.failure.message, style: AppTextStyles.body.copyWith(color: Colors.red)));
          }

          List<Map<String, dynamic>> suppliers = [];
          if (state is SuppliersLoaded) {
            suppliers = state.suppliers;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Supplier Management', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text('Manage your active suppliers, recent orders, and performance ratings.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  backgroundColor: AppColors.roleRetailer,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.plus, size: 18, color: AppColors.white),
                    const SizedBox(width: 8),
                    Text('Create Purchase Order', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (suppliers.isEmpty && state is SuppliersLoaded)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No suppliers found.'),
                  ),
                ),

              ...suppliers.map((supplier) {
                final orders = (supplier['purchaseOrders'] as List?)?.map((o) {
                  return {
                    'id': o['poNumber'],
                    'details': o['details'],
                    'status': o['status'],
                    'isDelivered': o['isDelivered'],
                  };
                }).toList() ?? [];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildSupplierCard(
                    name: supplier['name'] ?? 'Unknown',
                    location: supplier['location'] ?? 'Unknown',
                    rating: supplier['rating']?.toString() ?? '0.0',
                    ratingLabel: supplier['ratingLabel'] ?? 'New',
                    deliveryTime: supplier['deliveryTime'] ?? '-',
                    qualityMatch: supplier['qualityMatch'] ?? '-',
                    email: supplier['email'] ?? '',
                    phone: supplier['phone'],
                    orders: orders,
                  ),
                );
              }),
            ],
          );
        },
      ),
    ));
  }

  Widget _buildSupplierCard({
    required String name,
    required String location,
    required String rating,
    required String ratingLabel,
    required String deliveryTime,
    required String qualityMatch,
    required String email,
    String? phone,
    required List<Map<String, dynamic>> orders,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(name[0], style: AppTextStyles.h3.copyWith(color: AppColors.neutral500))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 12, color: AppColors.neutral400),
                        const SizedBox(width: 4),
                        Text(location, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.success50, borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.star, size: 10, color: AppColors.success600),
                        const SizedBox(width: 4),
                        Text(rating, style: AppTextStyles.caption.copyWith(color: AppColors.success600, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(ratingLabel, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Metrics
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery Time', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                    const SizedBox(height: 4),
                    Text(deliveryTime, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quality Rating', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                    const SizedBox(height: 4),
                    Text(qualityMatch, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contact Info
          Row(
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.mail, size: 14, color: AppColors.roleRetailer),
                  const SizedBox(width: 6),
                  Text(email, style: AppTextStyles.caption.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w500)),
                ],
              ),
              if (phone != null) ...[
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(LucideIcons.phone, size: 14, color: AppColors.roleRetailer),
                    const SizedBox(width: 6),
                    Text(phone, style: AppTextStyles.caption.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.neutral200),
          const SizedBox(height: 16),

          // Recent Orders
          Text('Recent Orders', style: AppTextStyles.caption.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...orders.map((order) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['id'], style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                      Text(order['details'], style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order['isDelivered'] ? AppColors.success50 : AppColors.warning50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status'],
                    style: AppTextStyles.caption.copyWith(
                      color: order['isDelivered'] ? AppColors.success600 : AppColors.warning600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
