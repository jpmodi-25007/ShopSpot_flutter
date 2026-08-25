import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../bloc/retailer_campaign_bloc.dart';
import '../bloc/retailer_campaign_event.dart';
import '../bloc/retailer_campaign_state.dart';
import '../../../influencer/domain/entities/influencer_bid_entity.dart';

class CampaignBidsScreen extends StatefulWidget {
  final String campaignId;
  const CampaignBidsScreen({super.key, required this.campaignId});

  @override
  State<CampaignBidsScreen> createState() => _CampaignBidsScreenState();
}

class _CampaignBidsScreenState extends State<CampaignBidsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RetailerCampaignBloc>().add(GetCampaignBidsRequested(widget.campaignId));
  }

  Future<void> _refresh() async {
    context.read<RetailerCampaignBloc>().add(GetCampaignBidsRequested(widget.campaignId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: Text('Review Bids', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.roleRetailer,
        backgroundColor: AppColors.white,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
          Text('Summer Local Treats', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text('12 Active Bids • 3 Shortlisted', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
          const SizedBox(height: 24),
          
          BlocConsumer<RetailerCampaignBloc, RetailerCampaignState>(
            listener: (context, state) {
              if (state is RetailerCampaignSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is RetailerCampaignError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is RetailerCampaignLoading) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: 4,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => const BidCardSkeleton(),
                );
              } else if (state is RetailerCampaignBidsLoaded && state.campaignId == widget.campaignId) {
                if (state.bids.isEmpty) {
                  return const Center(child: Text("No bids yet for this campaign."));
                }
                return Column(
                  children: state.bids.map((b) => Column(
                    children: [
                      _buildBidCard(context: context, bid: b),
                      const SizedBox(height: 16),
                    ],
                  )).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildBidCard({
    required BuildContext context,
    required InfluencerBidEntity bid,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network('https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop', width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Influencer', style: AppTextStyles.h4),
                    Text('View Profile', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.zap, size: 12, color: AppColors.success600),
                    const SizedBox(width: 4),
                    Text('Great Match', style: AppTextStyles.caption.copyWith(color: AppColors.success600, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bid.proposal != null && bid.proposal!.isNotEmpty) ...[
             Text(bid.proposal!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral700)),
             const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Date', '${bid.deliveryDate.day}/${bid.deliveryDate.month}'),
              Container(width: 1, height: 30, color: AppColors.neutral200),
              _buildStat('Bid Amount', '₹${bid.proposedAmount.toStringAsFixed(0)}', highlight: true),
              Container(width: 1, height: 30, color: AppColors.neutral200),
              _buildStat('Status', bid.status, color: bid.status == 'ACCEPTED' ? AppColors.success500 : AppColors.roleRetailer),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await context.push('/retailer/influencer-profile/${bid.influencerId}');
                    if (mounted) _refresh();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.neutral300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('View Profile', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: bid.status == 'ACCEPTED' ? null : () {
                     context.read<RetailerCampaignBloc>().add(AcceptBidRequested(bidId: bid.id, campaignId: widget.campaignId));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.roleRetailer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(bid.status == 'ACCEPTED' ? 'Accepted' : 'Accept Bid', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {bool highlight = false, Color? color}) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: color ?? (highlight ? AppColors.roleRetailer : AppColors.neutral900))),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
      ],
    );
  }
}
