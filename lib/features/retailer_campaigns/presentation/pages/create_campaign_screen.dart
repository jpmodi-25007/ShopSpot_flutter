import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/retailer_campaign_bloc.dart';
import '../bloc/retailer_campaign_event.dart';
import '../bloc/retailer_campaign_state.dart';
import '../../domain/repositories/retailer_campaign_repository.dart';
import '../../../influencer/domain/entities/influencer_campaign_entity.dart';

import '../../../retailer_inventory/presentation/bloc/retailer_inventory_bloc.dart';
import '../../../retailer_inventory/presentation/bloc/retailer_inventory_event.dart';
import '../../../retailer_inventory/presentation/bloc/retailer_inventory_state.dart';
import '../../../../core/widgets/app_network_image.dart';

class CreateCampaignScreen extends StatefulWidget {
  final InfluencerCampaignEntity? existing;

  const CreateCampaignScreen({super.key, this.existing});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSpecificProduct = true;
  String _selectedProductId = '';

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _applicationDeadline;
  DateTime? _publishByDate;

  bool get _isEditing => widget.existing != null;

  DateTime? _dateOnly(DateTime? value) {
    if (value == null) return null;
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController.text = existing.title;
      _descriptionController.text = existing.description;
      _budgetController.text = existing.budgetMax.toStringAsFixed(0);
      _applicationDeadline = _dateOnly(existing.applicationDeadline);
      _publishByDate = _dateOnly(existing.publishByDate);
      _isSpecificProduct =
          existing.productId != null && existing.productId!.isNotEmpty;
      _selectedProductId = existing.productId ?? '';
    }
    context.read<RetailerInventoryBloc>().add(const GetMyProductsRequested());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {required bool isApplicationDeadline}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = isApplicationDeadline ? _applicationDeadline : _publishByDate;
    final initial = current != null && !current.isBefore(today) ? current : today;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.roleRetailer,
              onPrimary: AppColors.white,
              onSurface: AppColors.neutral900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isApplicationDeadline) {
          _applicationDeadline = picked;
        } else {
          _publishByDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: AppColors.roleRetailer,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.roleRetailer,
            ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const Icon(LucideIcons.store,
                  color: AppColors.roleRetailer, size: 20),
              const SizedBox(width: 8),
              Text('Findivo Retail',
                  style:
                      AppTextStyles.h4.copyWith(color: AppColors.roleRetailer)),
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
                      const Icon(LucideIcons.arrowLeft,
                          size: 16, color: AppColors.roleRetailer),
                      const SizedBox(width: 4),
                      Text('Back to Campaigns',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.roleRetailer,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                    _isEditing
                        ? 'Edit Influencer\nCampaign'
                        : 'Create Influencer\nCampaign',
                    style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                    _isEditing
                        ? 'Update the product, budget, and dates for this campaign.'
                        : 'Step 1 of 4: Define what you want to promote.',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.neutral500)),
                const SizedBox(height: 32),

                // Campaign Target Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neutral200),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.neutral900.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Campaign Target', style: AppTextStyles.h3),
                      const SizedBox(height: 12),
                      Text(
                        'Choose whether you want to promote a specific item from your catalog or run a broader store-wide event.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.neutral600),
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
                                onTap: () =>
                                    setState(() => _isSpecificProduct = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _isSpecificProduct
                                        ? AppColors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _isSpecificProduct
                                        ? [
                                            BoxShadow(
                                                color: AppColors.neutral900
                                                    .withValues(alpha: 0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2))
                                          ]
                                        : null,
                                  ),
                                  margin: const EdgeInsets.all(4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isSpecificProduct
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: _isSpecificProduct
                                            ? AppColors.roleRetailer
                                            : AppColors.neutral400,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Specific\nProduct',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: _isSpecificProduct
                                              ? AppColors.primary600
                                              : AppColors.neutral500,
                                          fontWeight: _isSpecificProduct
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isSpecificProduct = false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_isSpecificProduct
                                        ? AppColors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !_isSpecificProduct
                                        ? [
                                            BoxShadow(
                                                color: AppColors.neutral900
                                                    .withValues(alpha: 0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2))
                                          ]
                                        : null,
                                  ),
                                  margin: const EdgeInsets.all(4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        !_isSpecificProduct
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: !_isSpecificProduct
                                            ? AppColors.roleRetailer
                                            : AppColors.neutral400,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Shop Sale /\nEvent',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: !_isSpecificProduct
                                              ? AppColors.primary600
                                              : AppColors.neutral500,
                                          fontWeight: !_isSpecificProduct
                                              ? FontWeight.w700
                                              : FontWeight.w500,
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
                        Text('Select Product to Promote',
                            style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral700)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neutral300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.search,
                                  size: 18, color: AppColors.neutral400),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search your catalog...',
                                    hintStyle: AppTextStyles.bodySmall
                                        .copyWith(color: AppColors.neutral400),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<RetailerInventoryBloc,
                            RetailerInventoryState>(
                          builder: (context, state) {
                            if (state is RetailerInventoryLoading) {
                              return const Center(
                                  child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ));
                            } else if (state is RetailerInventoryError) {
                              return Center(child: Text(state.failure.message));
                            } else if (state is RetailerInventoryLoaded) {
                              if (state.products.isEmpty) {
                                return const Center(
                                    child: Text('No products available.'));
                              }
                              return Column(
                                children: state.products
                                    .map((p) => _buildProductItem(
                                          id: p.id,
                                          name: p.name,
                                          category:
                                              p.categoryId ?? 'Uncategorized',
                                          price: '₹${p.sellingPrice}',
                                          imageUrl: p.images.isNotEmpty
                                              ? p.images.first
                                              : '',
                                        ))
                                    .toList(),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Campaign Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neutral200),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.neutral900.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Campaign Details', style: AppTextStyles.h3),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Campaign Title',
                        hintText: 'e.g. Summer Collection Promotion',
                        controller: _titleController,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Description',
                        hintText: 'Describe what you are looking for...',
                        controller: _descriptionController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Max Budget (₹)',
                        hintText: 'e.g. 5000',
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Last Date to Apply', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.neutral700)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context, isApplicationDeadline: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neutral200),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _applicationDeadline != null ? '${_applicationDeadline!.day}/${_applicationDeadline!.month}/${_applicationDeadline!.year}' : 'Select Date',
                                style: AppTextStyles.body.copyWith(color: _applicationDeadline != null ? AppColors.neutral900 : AppColors.neutral400),
                              ),
                              const Icon(LucideIcons.calendar, size: 20, color: AppColors.neutral400),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Live By Date', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.neutral700)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context, isApplicationDeadline: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neutral200),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _publishByDate != null ? '${_publishByDate!.day}/${_publishByDate!.month}/${_publishByDate!.year}' : 'Select Date',
                                style: AppTextStyles.body.copyWith(color: _publishByDate != null ? AppColors.neutral900 : AppColors.neutral400),
                              ),
                              const Icon(LucideIcons.calendar, size: 20, color: AppColors.neutral400),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Button
                BlocConsumer<RetailerCampaignBloc, RetailerCampaignState>(
                  listener: (context, state) {
                    if (state is RetailerCampaignSuccess) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(state.message)));
                      context.pop();
                    } else if (state is RetailerCampaignError) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: state is RetailerCampaignLoading
                            ? 'Saving...'
                            : _isEditing
                                ? 'Save Changes'
                                : 'Create Campaign',
                        onPressed: state is RetailerCampaignLoading
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) return;
                                if (_isSpecificProduct && _selectedProductId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Select a product to promote')),
                                  );
                                  return;
                                }

                                String? categoryName;
                                if (_isSpecificProduct) {
                                  final inventoryState = context.read<RetailerInventoryBloc>().state;
                                  if (inventoryState is RetailerInventoryLoaded) {
                                    try {
                                      final product = inventoryState.products.firstWhere((p) => p.id == _selectedProductId);
                                      categoryName = product.categoryName;
                                    } catch (_) {}
                                  }
                                }

                                final existing = widget.existing;
                                final params = CreateCampaignParams(
                                  title: _titleController.text.trim(),
                                  description:
                                      _descriptionController.text.trim(),
                                  platforms: existing != null && existing.platforms.isNotEmpty
                                      ? existing.platforms
                                      : const ['Instagram', 'YouTube'],
                                  contentTypes: existing != null && existing.contentTypes.isNotEmpty
                                      ? existing.contentTypes
                                      : const ['REEL', 'STORY'],
                                  budgetType: existing?.budgetType ?? 'PER_CREATOR',
                                  budgetMin: existing?.budgetMin ?? 0,
                                  budgetMax: double.tryParse(_budgetController.text) ?? 0,
                                  productId: _isSpecificProduct ? _selectedProductId : null,
                                  targetCategories: categoryName == null || categoryName.isEmpty
                                      ? const []
                                      : [categoryName],
                                  applicationDeadline: _applicationDeadline,
                                  publishByDate: _publishByDate,
                                );
                                final data = params.toJson();
                                if (!_isSpecificProduct) {
                                  data['productId'] = null;
                                  data['targetCategories'] = <String>[];
                                }
                                if (existing != null) {
                                  data['creatorCount'] = existing.creatorCount;
                                  context.read<RetailerCampaignBloc>().add(
                                        UpdateCampaignRequested(
                                          campaignId: existing.id,
                                          data: data,
                                        ),
                                      );
                                } else {
                                  context
                                      .read<RetailerCampaignBloc>()
                                      .add(CreateCampaignRequested(params));
                                }
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
      ),
    );
  }

  Widget _buildProductItem(
      {required String id,
      required String name,
      required String category,
      required String price,
      required String imageUrl}) {
    final isSelected = _selectedProductId == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedProductId = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppColors.roleRetailer : AppColors.neutral200,
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(
                url: imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900)),
                  Text(category,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.neutral500)),
                  const SizedBox(height: 4),
                  Text(price,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.roleRetailer,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.roleRetailer : AppColors.neutral300,
            ),
          ],
        ),
      ),
    );
  }
}
