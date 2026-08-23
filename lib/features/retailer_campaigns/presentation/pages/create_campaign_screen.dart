import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/retailer_campaign_bloc.dart';
import '../bloc/retailer_campaign_event.dart';
import '../bloc/retailer_campaign_state.dart';
import '../../domain/repositories/retailer_campaign_repository.dart';

import '../../../retailer_inventory/presentation/bloc/retailer_inventory_bloc.dart';
import '../../../retailer_inventory/presentation/bloc/retailer_inventory_event.dart';
import '../../../retailer_inventory/presentation/bloc/retailer_inventory_state.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSpecificProduct = true;
  String _selectedProductId = '2';

  @override
  void initState() {
    super.initState();
    context.read<RetailerInventoryBloc>().add(const GetMyProductsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(LucideIcons.store, color: AppColors.primary500, size: 20),
            const SizedBox(width: 8),
            Text('ShopSpot Retail', style: AppTextStyles.h4.copyWith(color: AppColors.primary500)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              GestureDetector(
                onTap: () => context.pop(),
                child: Row(
                  children: [
                    const Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.primary500),
                    const SizedBox(width: 4),
                    Text('Back to Campaigns', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary500, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Create Influencer\nCampaign', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text('Step 1 of 4: Define what you want to promote.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 32),

              // Campaign Target Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral200),
                  boxShadow: [
                    BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Campaign Target', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    Text(
                      'Choose whether you want to promote a specific item from your catalog or run a broader store-wide event.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: 20),
                    
                    // Custom Toggle Segmented Control
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isSpecificProduct = true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isSpecificProduct ? AppColors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _isSpecificProduct ? [BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                                ),
                                margin: const EdgeInsets.all(4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isSpecificProduct ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      color: _isSpecificProduct ? AppColors.primary500 : AppColors.neutral400,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Specific\nProduct',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: _isSpecificProduct ? AppColors.primary600 : AppColors.neutral500,
                                        fontWeight: _isSpecificProduct ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isSpecificProduct = false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isSpecificProduct ? AppColors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !_isSpecificProduct ? [BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                                ),
                                margin: const EdgeInsets.all(4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      !_isSpecificProduct ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      color: !_isSpecificProduct ? AppColors.primary500 : AppColors.neutral400,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Shop Sale /\nEvent',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: !_isSpecificProduct ? AppColors.primary600 : AppColors.neutral500,
                                        fontWeight: !_isSpecificProduct ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (_isSpecificProduct) ...[
                      const SizedBox(height: 24),
                      Text('Select Product to Promote', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.neutral700)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutral300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.search, size: 18, color: AppColors.neutral400),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search your catalog...',
                                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral400),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      BlocBuilder<RetailerInventoryBloc, RetailerInventoryState>(
                        builder: (context, state) {
                          if (state is RetailerInventoryLoading) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ));
                          } else if (state is RetailerInventoryError) {
                            return Center(child: Text(state.failure.message));
                          } else if (state is RetailerInventoryLoaded) {
                            if (state.products.isEmpty) {
                              return const Center(child: Text('No products available.'));
                            }
                            return Column(
                              children: state.products.map((p) => _buildProductItem(
                                id: p.id,
                                name: p.name,
                                category: p.categoryId ?? 'Uncategorized',
                                price: '\$${p.sellingPrice}',
                                imageUrl: p.images.isNotEmpty ? p.images.first : 'https://placehold.co/200x200.png',
                              )).toList(),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // Action Button
              BlocConsumer<RetailerCampaignBloc, RetailerCampaignState>(
                listener: (context, state) {
                  if (state is RetailerCampaignSuccess) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                     context.pop();
                  } else if (state is RetailerCampaignError) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: state is RetailerCampaignLoading ? 'Creating...' : 'Create Campaign',
                      onPressed: state is RetailerCampaignLoading ? null : () {
                        final params = CreateCampaignParams(
                          title: 'Promote $_selectedProductId',
                          description: 'We are looking for influencers to promote this item.',
                          platforms: ['Instagram', 'YouTube'],
                          contentTypes: ['REEL', 'STORY'],
                          budgetType: 'PAID',
                          budgetMin: 1000,
                          budgetMax: 5000,
                          productId: _selectedProductId,
                        );
                        context.read<RetailerCampaignBloc>().add(CreateCampaignRequested(params));
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem({required String id, required String name, required String category, required String price, required String imageUrl}) {
    final isSelected = _selectedProductId == id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedProductId = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary500 : AppColors.neutral200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.neutral900)),
                  Text(category, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                  const SizedBox(height: 4),
                  Text(price, style: AppTextStyles.caption.copyWith(color: AppColors.primary500, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary500 : AppColors.neutral300,
            ),
          ],
        ),
      ),
    );
  }
}
