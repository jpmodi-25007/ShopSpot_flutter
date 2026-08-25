import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/retailer_campaign_bloc.dart';
import '../bloc/retailer_campaign_event.dart';
import '../bloc/retailer_campaign_state.dart';
import '../../../influencer/domain/entities/influencer_campaign_entity.dart';

class RetailerCampaignsScreen extends StatefulWidget {
  const RetailerCampaignsScreen({super.key});

  @override
  State<RetailerCampaignsScreen> createState() => _RetailerCampaignsScreenState();
}

class _RetailerCampaignsScreenState extends State<RetailerCampaignsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RetailerCampaignBloc>().add(const GetMyCampaignsRequested());
  }

  Future<void> _refresh() async {
    context.read<RetailerCampaignBloc>().add(const GetMyCampaignsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.store, color: AppColors.roleRetailer),
          onPressed: () => context.go('/retailer/profile'),
        ),
        title: Text('Influencer Campaigns', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell), onPressed: () => context.push('/notifications')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.roleRetailer,
        backgroundColor: AppColors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage your brand partnerships and track performance.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'New Campaign',
                icon: LucideIcons.plus,
                onPressed: () => context.push('/retailer/create-campaign'),
              ),
            ),
            const SizedBox(height: 32),
            Text('Performance Overview', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            _buildPerformanceCard('TOTAL VIEWS', '245.8K', '+12.4% vs last week', LucideIcons.eye, AppColors.roleRetailer),
            const SizedBox(height: 12),
            _buildPerformanceCard('ENGAGEMENT RATE', '4.8%', '+0.8% vs last week', LucideIcons.heart, AppColors.secondary500),
            const SizedBox(height: 12),
            _buildPerformanceCard('LINK CLICKS', '12,450', null, LucideIcons.mousePointerClick, AppColors.info500),
            const SizedBox(height: 32),
            Text('Active Campaigns', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            BlocBuilder<RetailerCampaignBloc, RetailerCampaignState>(
              builder: (context, state) {
                if (state is RetailerCampaignLoading) {
                  return Column(
                    children: List.generate(4, (index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: CampaignCardSkeleton(),
                    )),
                  );
                } else if (state is RetailerCampaignLoaded) {
                  if (state.campaigns.isEmpty) {
                    return const Center(child: Text("No campaigns found. Create one above!"));
                  }
                  return Column(
                    children: state.campaigns.map((c) => Column(
                      children: [
                        _buildCampaignCard(context, c),
                        const SizedBox(height: 12),
                      ],
                    )).toList(),
                  );
                } else if (state is RetailerCampaignError) {
                  return Center(child: Text("Error: ${state.message}"));
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(String title, String value, String? trend, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text(value, style: AppTextStyles.h1.copyWith(color: color)),
              if (trend != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.trendingUp, size: 14, color: AppColors.success500),
                    const SizedBox(width: 4),
                    Text(trend, style: AppTextStyles.caption.copyWith(color: AppColors.success500)),
                  ],
                ),
              ],
            ],
          ),
          Icon(icon, size: 48, color: AppColors.neutral200),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, InfluencerCampaignEntity campaign) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(campaign.title, style: AppTextStyles.h4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.roleRetailerLight, borderRadius: BorderRadius.circular(12)),
                child: Text('Active', style: AppTextStyles.caption.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCampaignStat('Platform', campaign.platforms.isNotEmpty ? campaign.platforms.first : 'Web'),
              Container(width: 1, height: 30, color: AppColors.neutral300),
              _buildCampaignStat('Budget', '₹${campaign.budgetMax.toStringAsFixed(0)}'),
              Container(width: 1, height: 30, color: AppColors.neutral300),
              _buildCampaignStat('Status', campaign.status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                await context.push('/retailer/campaigns/${campaign.id}/bids');
                if (mounted) _refresh();
              },
              child: Text('Review Bids', style: AppTextStyles.body.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCampaignStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
      ],
    );
  }
}
