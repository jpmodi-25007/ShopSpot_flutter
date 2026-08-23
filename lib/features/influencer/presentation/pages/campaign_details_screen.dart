import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import 'package:mobile_web/core/widgets/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/influencer_campaign_entity.dart';

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
                expandedHeight: MediaQuery.of(context).size.height * 0.45,
                pinned: true,
                backgroundColor: AppColors.white.withValues(alpha: 0.9),
                elevation: 0,
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
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
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
                        bottom: 16,
                        left: 16,
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
                  decoration: const BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  transform: Matrix4.translationValues(0, -32, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
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
                                Text('\$${campaign!.budgetMin.toInt()} - \$${campaign!.budgetMax.toInt()}', style: AppTextStyles.h3.copyWith(color: AppColors.roleInfluencer)),
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
                                    Text('FashionNova', style: AppTextStyles.h4),
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
                                _buildRequirementRow(LucideIcons.instagram, 'Platform', campaign!.platforms.join(', ')),
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roleInfluencer,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => context.push('/influencer/submit-bid'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.send, size: 20),
                        const SizedBox(width: 12),
                        Text('Place Bid', style: AppTextStyles.h4.copyWith(color: AppColors.white)),
                      ],
                    ),
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

class SubmitBidScreen extends StatelessWidget {
  const SubmitBidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Text('Urban Tech Smartwatch', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Suggested Budget: \$450 - \$800', style: AppTextStyles.caption.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w700)),
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
            const AppTextField(
              label: 'Total Fee (USD)',
              hintText: '\$ 0.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            Text('Timeline', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text('When can you start and deliver the final content?', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Available to Start',
              hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(LucideIcons.calendar, size: 20),
            ),
            const SizedBox(height: 16),
            const AppTextField(
              label: 'Estimated Delivery',
              hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(LucideIcons.calendar, size: 20),
            ),
            const SizedBox(height: 32),

            Text('Proposal Message', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text('Briefly explain why you\'re a great fit for this campaign.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
            const SizedBox(height: 16),
            TextField(
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
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roleInfluencer,
                foregroundColor: AppColors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                context.pop();
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Proposal submitted successfully!', style: AppTextStyles.body.copyWith(color: AppColors.white)), backgroundColor: AppColors.success500),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.send, size: 20),
                  const SizedBox(width: 12),
                  Text('Submit Proposal', style: AppTextStyles.h4.copyWith(color: AppColors.white)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
