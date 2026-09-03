import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';
import '../../domain/entities/influencer_bid_entity.dart';
import '../../domain/entities/influencer_campaign_entity.dart';

class InfluencerDashboardScreen extends StatefulWidget {
  const InfluencerDashboardScreen({super.key});

  @override
  State<InfluencerDashboardScreen> createState() =>
      _InfluencerDashboardScreenState();
}

class _InfluencerDashboardScreenState extends State<InfluencerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _earningsAnim;
  late Animation<double> _earningsCurve;

  @override
  void initState() {
    super.initState();
    _earningsAnim = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);
    _earningsCurve =
        CurvedAnimation(parent: _earningsAnim, curve: Curves.easeOutCubic);
    _earningsAnim.forward();
    context.read<InfluencerBloc>().add(const GetInfluencerProfileRequested());
    context.read<InfluencerBloc>().add(const GetMyBidsRequested());
    context.read<InfluencerBloc>().add(const GetInfluencerAnalyticsRequested());
  }

  @override
  void dispose() {
    _earningsAnim.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    context.read<InfluencerBloc>().add(const GetInfluencerProfileRequested());
    context.read<InfluencerBloc>().add(const GetMyBidsRequested());
    context.read<InfluencerBloc>().add(const GetInfluencerAnalyticsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (state is InfluencerLoaded) {
          if (state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.failure!.message),
                  backgroundColor: AppColors.error500),
            );
          } else if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: const Text('Action successful!'),
                  backgroundColor: AppColors.success500),
            );
          }
        }
      },
      child: Scaffold(
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
              child: BlocBuilder<InfluencerBloc, InfluencerState>(
                builder: (context, state) {
                  final avatarUrl = state is InfluencerLoaded
                      ? state.profile?.profileImage
                      : null;
                  return CircleAvatar(
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl) as ImageProvider
                        : const AssetImage(
                            'assets/images/web_hero_boutique.jpg'),
                  );
                },
              ),
            ),
          ),
          title: Text('Creator Hub',
              style:
                  AppTextStyles.h3.copyWith(color: AppColors.roleInfluencer)),
          centerTitle: true,
          actions: [
            IconButton(
                icon: const Icon(LucideIcons.bell, color: AppColors.neutral900),
                onPressed: () => context.push('/notifications')),
            const SizedBox(width: 8),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.roleInfluencer,
          backgroundColor: AppColors.white,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
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
                      BoxShadow(
                          color: AppColors.neutral900.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8)),
                    ],
                    border: Border.all(
                        color: AppColors.roleInfluencer.withValues(alpha: 0.3)),
                  ),
                  child: BlocBuilder<InfluencerBloc, InfluencerState>(
                    builder: (context, state) {
                      final analytics =
                          state is InfluencerLoaded ? state.analytics : null;
                      final isAnalyticsLoading = state is InfluencerLoaded &&
                          state.isLoading &&
                          analytics == null;
                      final totalEarnings =
                          (analytics?['totalEarnings'] as num?)?.toDouble() ??
                              0.0;
                      final payouts =
                          analytics?['payouts'] as List<dynamic>? ?? [];
                      final pendingClearance = payouts
                          .where((p) => p['status'] == 'Pending')
                          .fold<double>(
                              0,
                              (sum, p) =>
                                  sum +
                                  ((p['amount'] as num?)?.toDouble() ?? 0));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Earnings',
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.neutral700,
                                      fontWeight: FontWeight.w600)),
                              const Icon(LucideIcons.award,
                                  color: AppColors.roleInfluencer, size: 24),
                            ],
                          ),
                          const SizedBox(height: 12),
                          isAnalyticsLoading
                              ? Container(
                                  height: 40,
                                  width: 180,
                                  decoration: BoxDecoration(
                                      color: AppColors.neutral100,
                                      borderRadius: BorderRadius.circular(8)))
                              : AnimatedBuilder(
                                  animation: _earningsCurve,
                                  builder: (context, _) {
                                    final display =
                                        (totalEarnings * _earningsCurve.value)
                                            .toInt();
                                    return Text(
                                      '₹${display.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                      style: AppTextStyles.h1.copyWith(
                                          color: AppColors.neutral900,
                                          fontSize: 36),
                                    );
                                  },
                                ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success50,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.trendingUp,
                                    size: 14, color: AppColors.success600),
                                const SizedBox(width: 6),
                                Text(
                                  analytics != null
                                      ? '${(analytics['completedCampaigns'] ?? 0)} campaigns completed'
                                      : 'Calculating...',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.success600,
                                      fontWeight: FontWeight.w700),
                                ),
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
                                BoxShadow(
                                    color: AppColors.neutral900
                                        .withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pending Clearance',
                                        style: AppTextStyles.caption.copyWith(
                                            color: AppColors.neutral500)),
                                    const SizedBox(height: 4),
                                    isAnalyticsLoading
                                        ? Container(
                                            height: 20,
                                            width: 80,
                                            decoration: BoxDecoration(
                                                color: AppColors.neutral100,
                                                borderRadius:
                                                    BorderRadius.circular(4)))
                                        : Text(
                                            '₹${pendingClearance.toStringAsFixed(0)}',
                                            style: AppTextStyles.h3.copyWith(
                                                color: AppColors.neutral900),
                                          ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      context.go('/influencer/earnings'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.roleInfluencer,
                                    foregroundColor: AppColors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  child: const Text('View Earnings',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // Active Bids from BLoC
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Bids', style: AppTextStyles.h3),
                    GestureDetector(
                      onTap: () => context.go('/influencer/campaigns'),
                      child: Text('View All',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.roleInfluencer,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                BlocBuilder<InfluencerBloc, InfluencerState>(
                  builder: (context, state) {
                    final bids =
                        state is InfluencerLoaded ? state.bids ?? [] : [];
                    if (state is InfluencerLoaded && state.isLoading) {
                      return Column(
                        children: const [
                          BidCardSkeleton(),
                          SizedBox(height: 16),
                          BidCardSkeleton(),
                        ],
                      );
                    }
                    if (bids.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('No active bids yet.',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.neutral500)),
                        ),
                      );
                    }
                    return Column(
                      children: bids.map((bid) {
                        Color statusColor;
                        switch (bid.status) {
                          case 'ACCEPTED':
                            statusColor = AppColors.success500;
                            break;
                          case 'REJECTED':
                            statusColor = AppColors.error500;
                            break;
                          case 'SHORTLISTED':
                            statusColor = AppColors.success500;
                            break;
                          default:
                            statusColor = AppColors.warning600;
                        }
                        // Build a human-readable subtitle from the proposal or a short campaign reference
                        final subtitle = bid.proposal?.isNotEmpty == true
                            ? bid.proposal!
                            : 'Campaign ref: ${bid.campaignId.length > 8 ? bid.campaignId.substring(0, 8) : bid.campaignId}…';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildPremiumBidCard(
                            bid: bid,
                            subtitle: subtitle,
                            statusLabel: bid.status,
                            statusColor: statusColor,
                            yourBid:
                                '₹${bid.proposedAmount.toStringAsFixed(0)}',
                            brandStatus:
                                bid.isShortlisted ? 'Shortlisted' : null,
                            onTap: () {
                              // Try to find the campaign in state.campaigns
                              final campaign = state.campaigns
                                  ?.cast<InfluencerCampaignEntity?>()
                                  .firstWhere(
                                    (c) => c?.id == bid.campaignId,
                                    orElse: () => null,
                                  );
                              // We pass the campaign, or a dummy if not found, since campaign_details screen requires it.
                              // However, we only have campaignId here. The best way is to pass campaign if available.
                              if (campaign != null) {
                                context.push('/influencer/campaign-details',
                                    extra: campaign);
                              } else {
                                // Fetching or passing just the id might be needed later, for now we pass a dummy if missing
                                context.push('/influencer/campaign-details',
                                    extra: InfluencerCampaignEntity(
                                      id: bid.campaignId,
                                      shopkeeperId: '',
                                      shopId: '',
                                      title: 'Loading Campaign...',
                                      description:
                                          'Details will be loaded soon.',
                                      platforms: [],
                                      contentTypes: [],
                                      creatorCount: 1,
                                      budgetType: 'PER_CREATOR',
                                      budgetMin: 0,
                                      budgetMax: 0,
                                      targetCategories: [],
                                      status: 'PUBLISHED',
                                      createdAt: DateTime.now(),
                                    ));
                              }
                            },
                            onWithdraw: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Withdraw Bid'),
                                  content: const Text(
                                      'Are you sure you want to withdraw this bid?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        context
                                            .read<InfluencerBloc>()
                                            .add(WithdrawBidRequested(bid.id));
                                      },
                                      child: const Text('Withdraw',
                                          style: TextStyle(
                                              color: AppColors.error500)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Ongoing (Accepted) Campaigns — driven by real bid data
                Text('Ongoing Campaigns', style: AppTextStyles.h3),
                const SizedBox(height: 20),
                BlocBuilder<InfluencerBloc, InfluencerState>(
                  builder: (context, state) {
                    if (state is InfluencerLoaded && state.isLoading) {
                      return const BidCardSkeleton();
                    }
                    final bids =
                        state is InfluencerLoaded ? state.bids ?? [] : [];
                    final acceptedBids =
                        bids.where((b) => b.status == 'ACCEPTED').toList();
                    if (acceptedBids.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.neutral200),
                        ),
                        child: Column(
                          children: [
                            const Icon(LucideIcons.rocket,
                                size: 32, color: AppColors.neutral400),
                            const SizedBox(height: 12),
                            Text('No ongoing campaigns yet.',
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                                'Browse campaigns and submit a bid to get started.',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.neutral500)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.go('/influencer/home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.roleInfluencer,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Discover Campaigns',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: acceptedBids.map((bid) {
                        final deadlineText =
                            '${bid.deliveryDate.day}/${bid.deliveryDate.month}/${bid.deliveryDate.year}';
                        final campaignRef = bid.campaignId.length > 8
                            ? bid.campaignId.substring(0, 8)
                            : bid.campaignId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAcceptedCampaignCard(
                            campaignRef: 'Campaign #$campaignRef',
                            bid: '₹${bid.proposedAmount.toStringAsFixed(0)}',
                            deadlineText: deadlineText,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBidCard({
    required InfluencerBidEntity bid,
    required String subtitle,
    required String statusLabel,
    required Color statusColor,
    required String yourBid,
    String? brandStatus,
    VoidCallback? onTap,
    VoidCallback? onWithdraw,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 8)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(statusLabel,
                      style: AppTextStyles.caption.copyWith(
                          color: statusColor, fontWeight: FontWeight.w800)),
                ),
                Text(
                  '${bid.availableDate.day}/${bid.availableDate.month}/${bid.availableDate.year}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.neutral400),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Bid #${bid.id.length > 8 ? bid.id.substring(0, 8) : bid.id}…',
                style: AppTextStyles.h4),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Bid',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.neutral500)),
                        const SizedBox(height: 4),
                        Text(yourBid,
                            style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral900)),
                      ],
                    ),
                  ),
                ),
                if (brandStatus != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.roleInfluencerLight
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.neutral600)),
                          const SizedBox(height: 4),
                          Text(brandStatus,
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.roleInfluencer,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(LucideIcons.clock,
                    size: 14, color: AppColors.neutral500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    bid.status == 'ACCEPTED'
                        ? 'Campaign accepted — coordinate with brand'
                        : bid.status == 'REJECTED'
                            ? 'Bid not selected this time'
                            : 'Awaiting brand decision',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.neutral500),
                  ),
                ),
                if (bid.status != 'ACCEPTED')
                  TextButton(
                    onPressed: onWithdraw,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error500,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Withdraw',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedCampaignCard({
    required String campaignRef,
    required String bid,
    required String deadlineText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
        border:
            Border.all(color: AppColors.roleInfluencer.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.checkCircle2,
                        size: 12, color: AppColors.success600),
                    const SizedBox(width: 4),
                    Text('Accepted',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.success600,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Text(
                'Deliver by $deadlineText',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.neutral500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(campaignRef, style: AppTextStyles.h4),
          const SizedBox(height: 4),
          Text('Your accepted bid: $bid',
              style: AppTextStyles.body.copyWith(color: AppColors.neutral600)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.roleInfluencer,
                    elevation: 0,
                    side: const BorderSide(
                        color: AppColors.roleInfluencer, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            '📤 Submit your content URL to the shopkeeper via Chat.'),
                        backgroundColor: AppColors.roleInfluencer,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: const Text('Submit Work',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
