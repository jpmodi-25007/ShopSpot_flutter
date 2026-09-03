import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/influencer_campaign_entity.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';

class SubmitBidScreen extends StatefulWidget {
  final InfluencerCampaignEntity? campaign;

  const SubmitBidScreen({super.key, this.campaign});

  @override
  State<SubmitBidScreen> createState() => _SubmitBidScreenState();
}

class _SubmitBidScreenState extends State<SubmitBidScreen> {
  final _feeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _feeController.dispose();
    _startDateController.dispose();
    _deliveryDateController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitProposal() {
    if (_feeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a proposed price.')));
      return;
    }
    
    final price = double.tryParse(_feeController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid price format.')));
      return;
    }

    final data = {
      'proposedAmount': price,
      'proposal': _messageController.text,
      'availableDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'deliveryDate': DateTime.now().add(const Duration(days: 8)).toIso8601String(),
    };

    context.read<InfluencerBloc>().add(
      SubmitBidRequested(campaignId: widget.campaign?.id ?? 'test_campaign_id', data: data)
    );
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.checkCircle, color: AppColors.success500, size: 48),
              ),
              const SizedBox(height: 16),
              Text('Proposal Submitted!', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text('The retailer will review your proposal shortly.', textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roleInfluencer,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  context.pop(); // Close dialog
                  context.pop(); // Pop submit bid
                  context.pop(); // Pop campaign details
                },
                child: const Text('Back to Discover', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (state is InfluencerLoaded && state.isSuccess) {
          _showSuccessModal();
        } else if (state is InfluencerLoaded && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure?.message ?? 'An error occurred'), backgroundColor: AppColors.error500),
          );
        }
      },
      child: Theme(
        data: Theme.of(context).copyWith(primaryColor: AppColors.roleInfluencer),
        child: Scaffold(
          backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          backgroundColor: AppColors.neutral50,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: Text('Submit Proposal', style: AppTextStyles.h3),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Row(
                  children: [
                    if (widget.campaign?.shopCoverUrl != null || widget.campaign?.productImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.campaign!.shopCoverUrl ?? widget.campaign!.productImageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/web_hero_boutique.jpg', width: 60, height: 60, fit: BoxFit.cover),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/web_hero_boutique.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.campaign?.title ?? 'Campaign Details', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('Budget Max: ₹${widget.campaign?.budgetMax ?? 'Flexible'}', style: AppTextStyles.caption.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text('Your Proposed Price', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text('Enter your total fee for completing all required deliverables.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 16),
              AppTextField(
                controller: _feeController,
                label: 'Total Fee (USD)',
                hintText: 'e.g. 150',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              Text('Timeline', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text('When can you start and deliver the final content?', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 16),
              AppTextField(
                controller: _startDateController,
                label: 'Available to Start',
                hintText: 'dd/mm/yyyy',
                suffixIcon: const Icon(LucideIcons.calendar, size: 20),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.roleInfluencer,
                            onPrimary: AppColors.white,
                            onSurface: AppColors.neutral900,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    _startDateController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                  }
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _deliveryDateController,
                label: 'Estimated Delivery',
                hintText: 'dd/mm/yyyy',
                suffixIcon: const Icon(LucideIcons.calendar, size: 20),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.roleInfluencer,
                            onPrimary: AppColors.white,
                            onSurface: AppColors.neutral900,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    _deliveryDateController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                  }
                },
              ),
              const SizedBox(height: 32),

              Text('Proposal Message', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text('Briefly explain why you\'re a great fit for this campaign.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Hi team! I love the new smartwatch design...',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neutral200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neutral200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.roleInfluencer, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 40),
              
              BlocBuilder<InfluencerBloc, InfluencerState>(
                builder: (context, state) {
                  final isLoading = state is InfluencerLoaded && state.isLoading;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roleInfluencer,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: isLoading ? null : _submitProposal,
                    child: isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.send, size: 20),
                              const SizedBox(width: 12),
                              Text('Submit Proposal', style: AppTextStyles.h4.copyWith(color: AppColors.white)),
                            ],
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
}
