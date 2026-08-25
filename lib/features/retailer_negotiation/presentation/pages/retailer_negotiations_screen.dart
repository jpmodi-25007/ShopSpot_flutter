import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/retailer_negotiation_bloc.dart';
import '../bloc/retailer_negotiation_event.dart';
import '../bloc/retailer_negotiation_state.dart';

class RetailerNegotiationsScreen extends StatefulWidget {
  const RetailerNegotiationsScreen({super.key});

  @override
  State<RetailerNegotiationsScreen> createState() => _RetailerNegotiationsScreenState();
}

class _RetailerNegotiationsScreenState extends State<RetailerNegotiationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RetailerNegotiationBloc>().add(const GetShopNegotiationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.store, color: AppColors.primary500),
          onPressed: () => context.go('/retailer/profile'),
        ),
        title: Text('Findivo', style: AppTextStyles.h3.copyWith(color: AppColors.primary500)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search), 
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Search negotiations feature coming soon!'),
                  backgroundColor: AppColors.roleRetailer,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Negotiations', style: AppTextStyles.h1),
                const SizedBox(height: 16),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.neutral300),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(LucideIcons.search, size: 20, color: AppColors.neutral500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search customers or products...',
                            hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.neutral300)),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabItem('Active', true)),
                Expanded(child: _buildTabItem('Accepted', false)),
                Expanded(child: _buildTabItem('Expired', false)),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Conversion banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.trendingUp, size: 16, color: AppColors.success500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('You\'ve converted 15 deals this week!', style: AppTextStyles.bodySmall.copyWith(color: AppColors.success500, fontWeight: FontWeight.w600)),
                            Text('Up 20% from last week', style: AppTextStyles.caption.copyWith(color: AppColors.success500)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Negotiation Cards
                BlocBuilder<RetailerNegotiationBloc, RetailerNegotiationState>(
                  builder: (context, state) {
                    if (state is RetailerNegotiationLoading) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => const OrderCardSkeleton(),
                      );
                    }
                    if (state is RetailerNegotiationLoaded) {
                      final negotiations = state.negotiations ?? [];
                      if (negotiations.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: Text("No negotiations found.")),
                        );
                      }
                      return Column(
                        children: negotiations.map((n) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildNegotiationCard(
                              statusLabel: n.status.name,
                              statusColor: AppColors.info500,
                              timeLabel: 'Now',
                              productName: n.product?.name ?? 'Product',
                              customerName: 'Customer', // Would come from Customer entity
                              offeredPrice: '₹${n.offeredPrice.toStringAsFixed(0)}',
                              askingPrice: '₹${n.initialPrice.toStringAsFixed(0)}',
                              imageUrl: n.product?.images.isNotEmpty == true ? n.product!.images.first : 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?q=80&w=100&auto=format&fit=crop',
                              actionBtnText: 'Review Offer',
                              actionBtnPrimary: true,
                              onActionPressed: () => context.push('/retailer/negotiations/${n.id}'),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isActive ? AppColors.primary500 : Colors.transparent, width: 2)),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isActive ? AppColors.primary500 : AppColors.neutral500,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildNegotiationCard({
    required String statusLabel,
    required Color statusColor,
    required String timeLabel,
    required String productName,
    required String customerName,
    required String offeredPrice,
    required String askingPrice,
    String offeredLabel = 'Offered',
    required String imageUrl,
    required String actionBtnText,
    required bool actionBtnPrimary,
    required VoidCallback onActionPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(statusLabel, style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
                Text(timeLabel, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                      Text('Customer: $customerName', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(offeredLabel, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                                Text(offeredPrice, style: AppTextStyles.h4.copyWith(color: AppColors.primary500)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Asking', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                                Text(askingPrice, style: AppTextStyles.h4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionBtnPrimary ? AppColors.primary500 : AppColors.neutral100,
                  foregroundColor: actionBtnPrimary ? AppColors.white : AppColors.primary500,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onActionPressed,
                child: Text(actionBtnText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
