import 'package:flutter/material.dart';
import 'package:mobile_web/core/widgets/shimmer_effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';

class InfluencerDashboardScreen extends StatefulWidget {
  const InfluencerDashboardScreen({super.key});

  @override
  State<InfluencerDashboardScreen> createState() => _InfluencerDashboardScreenState();
}

class _InfluencerDashboardScreenState extends State<InfluencerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InfluencerBloc>().add(const GetInfluencerProfileRequested());
    context.read<InfluencerBloc>().add(const GetMyBidsRequested());
  }

  Future<void> _refresh() async {
    context.read<InfluencerBloc>().add(const GetInfluencerProfileRequested());
    context.read<InfluencerBloc>().add(const GetMyBidsRequested());
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
        title: Text('Creator Hub', style: AppTextStyles.h3.copyWith(color: AppColors.roleInfluencer)),
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.roleInfluencerLight, AppColors.white],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
                ],
                border: Border.all(color: AppColors.roleInfluencer.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Earnings', style: AppTextStyles.body.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
                      const Icon(LucideIcons.award, color: AppColors.roleInfluencer, size: 24),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('\$42,500.00', style: AppTextStyles.h1.copyWith(color: AppColors.neutral900, fontSize: 36)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success50,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.trendingUp, size: 14, color: AppColors.success600),
                        const SizedBox(width: 6),
                        Text('+12% from last month', style: AppTextStyles.caption.copyWith(color: AppColors.success600, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pending Clearance', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                            const SizedBox(height: 4),
                            Text('\$3,200.50', style: AppTextStyles.h3.copyWith(color: AppColors.neutral900)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.roleInfluencer,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Active Bids from BLoC
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Bids', style: AppTextStyles.h3),
                Text('View All', style: AppTextStyles.bodySmall.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            BlocBuilder<InfluencerBloc, InfluencerState>(
              builder: (context, state) {
                final bids = state is InfluencerLoaded ? state.bids ?? [] : [];
                if (state is InfluencerLoaded && state.isLoading) {
                  return const GenericListShimmer();
                }
                if (bids.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('No active bids yet.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
                    ),
                  );
                }
                return Column(
                  children: bids.map((bid) {
                    Color statusColor;
                    switch (bid.status) {
                      case 'ACCEPTED': statusColor = AppColors.success500; break;
                      case 'REJECTED': statusColor = AppColors.error500; break;
                      case 'SHORTLISTED': statusColor = AppColors.success500; break;
                      default: statusColor = AppColors.warning600;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPremiumBidCard(
                        title: bid.campaignId,
                        brand: 'FashionNova',
                        statusLabel: bid.status,
                        statusColor: statusColor,
                        yourBid: '\$${bid.proposedAmount.toStringAsFixed(0)}',
                        brandOffer: bid.isShortlisted ? 'Shortlisted' : null,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 40),

            // Ongoing Campaigns
            Text('Ongoing Campaigns', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            _buildPremiumOngoingCampaignCard(
              title: 'Pro Series Launch',
              brand: 'TechNova',
              progressPercent: 33,
              dueDate: 'In 5 days',
              imageUrl: 'invalid', // Force errorBuilder
            ),
            const SizedBox(height: 80),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildPremiumBidCard({
    required String title,
    required String brand,
    required String statusLabel,
    required Color statusColor,
    required String yourBid,
    String? brandOffer,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(statusLabel, style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w800)),
              ),
              const Icon(LucideIcons.moreHorizontal, color: AppColors.neutral400),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 4),
          Text(brand, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Bid', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      const SizedBox(height: 4),
                      Text(yourBid, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.neutral900)),
                    ],
                  ),
                ),
              ),
              if (brandOffer != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.roleInfluencerLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Brand Status', style: AppTextStyles.caption.copyWith(color: AppColors.neutral600)),
                        const SizedBox(height: 4),
                        Text(brandOffer, style: AppTextStyles.body.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
          if (brandOffer != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neutral100,
                      foregroundColor: AppColors.neutral700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roleInfluencer,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: const Text('View Offer', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 14, color: AppColors.neutral500),
                const SizedBox(width: 6),
                Text('Awaiting brand decision', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPremiumOngoingCampaignCard({
    required String title,
    required String brand,
    required int progressPercent,
    required String dueDate,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => Image.asset(
                    'assets/images/web_hero_boutique.jpg',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.loader, size: 14, color: AppColors.roleInfluencer),
                      const SizedBox(width: 6),
                      Text('In Progress', style: AppTextStyles.caption.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w800)),
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
                Text(brand, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w600, letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deliverables: 1 of 3', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
                    Text('$progressPercent%', style: AppTextStyles.bodySmall.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(100)),
                    ),
                    FractionallySizedBox(
                      widthFactor: progressPercent / 100,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(color: AppColors.roleInfluencer, borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.neutral50, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(LucideIcons.calendar, size: 16, color: AppColors.neutral600),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deadline', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                            Text(dueDate, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.roleInfluencer,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.roleInfluencer, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {},
                      child: const Text('Submit Work', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
