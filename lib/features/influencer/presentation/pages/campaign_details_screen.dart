import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'package:mobile_web/core/widgets/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/influencer_campaign_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_state.dart';

class CampaignDetailsScreen extends StatelessWidget {
  final InfluencerCampaignEntity? campaign;
  const CampaignDetailsScreen({super.key, this.campaign});

  @override
  Widget build(BuildContext context) {
    if (campaign == null) {
      return Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(leading: const BackButton(), title: const Text('Campaign Info')),
        body: const Center(child: Text('Campaign details not available.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.white,
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(24),
                  child: Container(
                    height: 24,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.neutral50,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
                    onPressed: () => context.pop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(LucideIcons.share, color: AppColors.neutral900),
                      onPressed: () {
                        Share.share('Check out this campaign on Findivo!');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (campaign?.shopCoverUrl != null || campaign?.productImageUrl != null)
                        Image.network(
                          campaign!.shopCoverUrl ?? campaign!.productImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/web_hero_boutique.jpg', fit: BoxFit.cover),
                        )
                      else
                        Image.asset(
                          'assets/images/web_hero_boutique.jpg',
                          fit: BoxFit.cover,
                        ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [AppColors.neutral900.withValues(alpha: 0.8), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.roleInfluencer,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.star, size: 12, color: AppColors.white),
                              const SizedBox(width: 6),
                              Text('Premium Tier', style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.neutral50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(campaign!.title, style: AppTextStyles.h1),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('₹${campaign!.budgetMin.toInt()} - ₹${campaign!.budgetMax.toInt()}', style: AppTextStyles.h3.copyWith(color: AppColors.roleInfluencer)),
                                const SizedBox(height: 4),
                                Text('Est. Earnings', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (campaign!.targetCategories.isNotEmpty)
                              _buildPill(campaign!.targetCategories.first, AppColors.white, AppColors.neutral700, borderColor: AppColors.neutral200),
                            _buildPill(campaign!.budgetType, AppColors.white, AppColors.neutral700, borderColor: AppColors.neutral200),
                            if (campaign!.applicationDeadline != null)
                              _buildPill('Closes ${campaign!.applicationDeadline!.day}/${campaign!.applicationDeadline!.month}', AppColors.error50, AppColors.error500, borderColor: AppColors.error500.withValues(alpha: 0.3)),
                          ],
                        ),
                        const SizedBox(height: 40),
                        
                        Text('Brand Details', style: AppTextStyles.h3),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: AppColors.neutral200),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              if (campaign?.shopLogoUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    campaign!.shopLogoUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(color: AppColors.roleInfluencerLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(LucideIcons.store, color: AppColors.roleInfluencer, size: 24),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(color: AppColors.roleInfluencerLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(LucideIcons.store, color: AppColors.roleInfluencer, size: 24),
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(campaign!.shopName ?? 'Brand', style: AppTextStyles.h4),
                                    const SizedBox(height: 4),
                                    Text(campaign!.city ?? 'Global', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (campaign?.shopId != null) {
                                    context.push('/shop-detail/${campaign!.shopId}');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                  foregroundColor: AppColors.roleInfluencer,
                                  elevation: 0,
                                  side: const BorderSide(color: AppColors.roleInfluencer, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                child: const Text('View Profile', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        Text('Campaign Details', style: AppTextStyles.h3),
                        const SizedBox(height: 16),
                        Text(
                          campaign!.description,
                          style: AppTextStyles.body.copyWith(color: AppColors.neutral600, height: 1.6),
                        ),
                        const SizedBox(height: 40),
                        
                        Text('Requirements', style: AppTextStyles.h3),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.neutral200),
                          ),
                          child: Column(
                            children: [
                              if (campaign!.platforms.isNotEmpty)
                                _buildRequirementRow(LucideIcons.camera, 'Platform', campaign!.platforms.join(', ')),
                              if (campaign!.contentTypes.isNotEmpty) ...[
                                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                                _buildRequirementRow(LucideIcons.video, 'Content Type', campaign!.contentTypes.join(', ')),
                              ],
                              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                              _buildRequirementRow(LucideIcons.users, 'Creators Needed', '${campaign!.creatorCount} creators'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Sticky Bottom Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.8),
                    border: const Border(top: BorderSide(color: AppColors.neutral200)),
                  ),
                  child: BlocBuilder<InfluencerBloc, InfluencerState>(
                    builder: (context, state) {
                      final hasBid = state.bids?.any((b) => b.campaignId == campaign?.id) ?? false;
                      
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasBid ? AppColors.neutral300 : AppColors.roleInfluencer,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: hasBid ? null : () => context.push('/influencer/submit-bid', extra: campaign),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(hasBid ? LucideIcons.check : LucideIcons.send, size: 20),
                            const SizedBox(width: 12),
                            Text(hasBid ? 'Already Applied' : 'Place Bid', style: AppTextStyles.h4.copyWith(color: hasBid ? AppColors.neutral500 : AppColors.white)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color bgColor, Color textColor, {Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: textColor, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildRequirementRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: AppColors.neutral700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.neutral600)),
            ],
          ),
        ),
      ],
    );
  }
}
