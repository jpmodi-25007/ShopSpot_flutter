import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/influencer_campaign_entity.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';

class InfluencerDiscoverScreen extends StatefulWidget {
  const InfluencerDiscoverScreen({super.key});

  @override
  State<InfluencerDiscoverScreen> createState() => _InfluencerDiscoverScreenState();
}

class _InfluencerDiscoverScreenState extends State<InfluencerDiscoverScreen> {
  String _selectedFilter = 'All Campaigns';

  @override
  void initState() {
    super.initState();
    context.read<InfluencerBloc>().add(const GetEligibleCampaignsRequested());
  }

  Future<void> _refresh() async {
    context.read<InfluencerBloc>().add(const GetEligibleCampaignsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.roleInfluencer, width: 2),
            ),
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/web_hero_boutique.jpg'),
            ),
          ),
        ),
        title: Text('Discover', style: AppTextStyles.h3.copyWith(color: AppColors.roleInfluencer)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell, color: AppColors.neutral900), onPressed: () => context.push('/notifications')),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.roleInfluencer,
        backgroundColor: AppColors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Floating Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    const Icon(LucideIcons.search, size: 24, color: AppColors.neutral400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search campaigns, brands...',
                          hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                        ),
                      ),
                    ),
                    Container(
                      height: 48,
                      width: 48,
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.roleInfluencer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.slidersHorizontal, color: AppColors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPremiumChip('All Campaigns'),
                  const SizedBox(width: 12),
                  _buildPremiumChip('Fashion & Apparel'),
                  const SizedBox(width: 12),
                  _buildPremiumChip('Food & Beverage'),
                  const SizedBox(width: 12),
                  _buildPremiumChip('Tech & Gadgets'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recommended for You', style: AppTextStyles.h3),
                  Text('See All', style: AppTextStyles.bodySmall.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Campaigns from BLoC
            BlocBuilder<InfluencerBloc, InfluencerState>(
              builder: (context, state) {
                if (state is InfluencerLoaded && state.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator(color: AppColors.roleInfluencer)),
                  );
                }
                final campaigns = state is InfluencerLoaded ? state.campaigns ?? [] : [];
                if (campaigns.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text('No campaigns available right now.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500))),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 600;
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: campaigns.map((campaign) {
                          return SizedBox(
                            width: isDesktop ? (constraints.maxWidth / 2) - 12 : constraints.maxWidth,
                            child: _buildPremiumCampaignCard(
                              context,
                              campaign: campaign,
                              title: campaign.title,
                              brand: campaign.city ?? 'Brand',
                              matchPercent: '98%',
                              budget: '\$${campaign.budgetMin.toStringAsFixed(0)} - \$${campaign.budgetMax.toStringAsFixed(0)}',
                              platforms: campaign.platforms,
                              imageUrl: 'invalid', // force errorBuilder
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // High Budget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('High Budget Opportunities', style: AppTextStyles.h3),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPremiumMiniCard('Premium Watch Review', 'Chronos Lux', '\$2,000+', 'invalid'),
                  const SizedBox(width: 16),
                  _buildPremiumMiniCard('Skincare Routine Reel', 'Glow Botanica', '\$1,200', 'invalid'),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildPremiumChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.roleInfluencer : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.roleInfluencer : AppColors.neutral200),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.roleInfluencer.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? AppColors.white : AppColors.neutral700,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCampaignCard(BuildContext context, {
    required InfluencerCampaignEntity campaign,
    required String title,
    required String brand,
    required String matchPercent,
    required String budget,
    required List<String> platforms,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () async {
        await context.push('/influencer/campaign-details', extra: campaign);
        if (mounted) _refresh();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  imageUrl, 
                  height: 200, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => Image.asset(
                    'assets/images/web_lifestyle_shopping.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success500,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.sparkles, size: 12, color: AppColors.white),
                        const SizedBox(width: 4),
                        Text('$matchPercent Match', style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.neutral900.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 10, backgroundColor: AppColors.white, child: Icon(LucideIcons.store, size: 10, color: AppColors.neutral900)),
                        const SizedBox(width: 8),
                        Text(brand, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  Row(
                    children: platforms.map((p) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.roleInfluencerLight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(p.contains('Instagram') ? LucideIcons.camera : LucideIcons.video, size: 14, color: AppColors.roleInfluencer),
                            const SizedBox(width: 6),
                            Text(p, style: AppTextStyles.caption.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Budget Range', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                          const SizedBox(height: 4),
                          Text(budget, style: AppTextStyles.h3.copyWith(color: AppColors.neutral900)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.roleInfluencer,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                        onPressed: () async {
                          await context.push('/influencer/campaign-details', extra: campaign);
                          if (mounted) _refresh();
                        },
                        child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMiniCard(String title, String brand, String budget, String imageUrl) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl, 
              width: 100, 
              height: 120, 
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Image.asset(
                'assets/images/web_hero_boutique.jpg',
                width: 100,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(brand, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success50, borderRadius: BorderRadius.circular(6)),
                  child: Text(budget, style: AppTextStyles.caption.copyWith(color: AppColors.success600, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
