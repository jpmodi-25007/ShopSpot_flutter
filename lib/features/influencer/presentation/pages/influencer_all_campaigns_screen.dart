import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_state.dart';
import '../bloc/influencer_event.dart';
import '../../domain/entities/influencer_campaign_entity.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';

class InfluencerAllCampaignsScreen extends StatefulWidget {
  const InfluencerAllCampaignsScreen({super.key});

  @override
  State<InfluencerAllCampaignsScreen> createState() =>
      _InfluencerAllCampaignsScreenState();
}

class _InfluencerAllCampaignsScreenState
    extends State<InfluencerAllCampaignsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InfluencerBloc>().add(const GetEligibleCampaignsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('All Campaigns', style: AppTextStyles.h3),
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(LucideIcons.chevronLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<InfluencerBloc, InfluencerState>(
        builder: (context, state) {
          if (state is InfluencerLoaded && state.isLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.roleInfluencer));
          }
          final campaigns =
              state is InfluencerLoaded ? state.campaigns ?? [] : [];
          if (campaigns.isEmpty) {
            return const Center(child: Text('No campaigns available.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<InfluencerBloc>()
                  .add(const GetEligibleCampaignsRequested());
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                final campaign = campaigns[index];
                return _buildPremiumCampaignCard(
                  context,
                  campaign: campaign,
                  title: campaign.title,
                  brand: campaign.shopName ?? 'Brand',
                  matchPercent: '98%',
                  budget: '₹${campaign.budgetMax.toStringAsFixed(0)}',
                  platforms: campaign.platforms,
                  imageUrl: campaign.shopLogo ?? 'invalid',
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumCampaignCard(
    BuildContext context, {
    required InfluencerCampaignEntity campaign,
    required String title,
    required String brand,
    required String matchPercent,
    required String budget,
    required List<String> platforms,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () =>
          context.push('/influencer/campaigns/${campaign.id}', extra: campaign),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.neutral200,
                    child: const Center(
                        child: Icon(LucideIcons.image,
                            color: AppColors.neutral400)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(brand,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.neutral500)),
                  const SizedBox(height: 8),
                  Text(budget,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.roleInfluencer,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
