import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import '../../../../core/widgets/animated_fade_slide.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';
import '../../domain/entities/influencer_bid_entity.dart';

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
  bool _successShown = false;

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
    context.read<InfluencerBloc>().add(const GetMyAssignmentsRequested());
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
    context.read<InfluencerBloc>().add(const GetMyAssignmentsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (state is InfluencerLoaded) {
          if (state.failure != null) {
            // Only show error once per error object
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.failure!.message),
                  backgroundColor: AppColors.error500),
            );
          } else if (state.isSuccess && !_successShown) {
            // Guard so success toast only fires once
            _successShown = true;
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(children: [
                  Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Flexible(child: Text('Work submitted! Shopkeeper has been notified.')),
                ]),
                backgroundColor: AppColors.success500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 3),
              ),
            );
            // Reset after a delay so the flag can be used for future submissions
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) setState(() => _successShown = false);
            });
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

                // ─── ACTIVE BIDS ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Bids', style: AppTextStyles.h3),
                    GestureDetector(
                      onTap: () => context.push('/influencer/all-bids'),
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
                    if (state is InfluencerLoaded && state.isLoading && bids.isEmpty) {
                      return Column(
                        children: const [
                          BidCardSkeleton(),
                          SizedBox(height: 16),
                          BidCardSkeleton(),
                        ],
                      );
                    }
                    // Show all bids that are not in a final state (ACCEPTED/REJECTED/COMPLETED)
                    final activeBids = bids
                        .where((b) => b.status != 'ACCEPTED' && b.status != 'REJECTED' && b.status != 'COMPLETED')
                        .toList();
                    if (activeBids.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              const Icon(LucideIcons.inbox, size: 36, color: AppColors.neutral300),
                              const SizedBox(height: 12),
                              Text('No active bids yet.',
                                  style: AppTextStyles.body
                                      .copyWith(color: AppColors.neutral500)),
                            ],
                          ),
                        ),
                      );
                    }
                    final displayBids = activeBids.take(3).toList();
                    return Column(
                      children: displayBids.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final bid = entry.value;
                        Color statusColor;
                        switch (bid.status) {
                          case 'SHORTLISTED':
                            statusColor = const Color(0xFF4F46E5);
                            break;
                          case 'COUNTERED':
                            statusColor = AppColors.warning600;
                            break;
                          default:
                            statusColor = AppColors.neutral600;
                        }
                        return AnimatedFadeSlide(
                          delay: Duration(milliseconds: idx * 100),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildPremiumBidCard(
                              bid: bid,
                              statusColor: statusColor,
                              onTap: () => context.push('/influencer/bid-detail', extra: bid),
                              onWithdraw: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // ─── ONGOING CAMPAIGNS ──────────────────────────────────────
                Text('Ongoing Campaigns', style: AppTextStyles.h3),
                const SizedBox(height: 20),
                BlocBuilder<InfluencerBloc, InfluencerState>(
                  builder: (context, state) {
                    if (state is InfluencerLoaded && state.isLoading && (state.bids == null || state.bids!.isEmpty)) {
                      return const BidCardSkeleton();
                    }
                    final bids =
                        state is InfluencerLoaded ? state.bids ?? [] : [];
                    final assignments = state is InfluencerLoaded ? state.assignments ?? [] : [];
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
                      children: acceptedBids.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final bid = entry.value;
                        // Safe assignment lookup — no crash if missing
                        Map<String, dynamic>? assignment;
                        try {
                          assignment = assignments.firstWhere(
                            (a) => a['campaignId'] == bid.campaignId || a['bidId'] == bid.id,
                          );
                        } catch (_) {
                          assignment = null;
                        }
                        final assignmentId = assignment != null && assignment.isNotEmpty ? assignment['id'] as String? : null;
                        final submittedUrl = assignment != null && assignment.isNotEmpty
                            ? assignment['submittedContentUrl'] as String?
                            : bid.submittedContentUrl;
                        return AnimatedFadeSlide(
                          delay: Duration(milliseconds: idx * 100),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildAcceptedCampaignCard(
                              bid: bid,
                              assignmentId: assignmentId,
                              submittedContentUrl: submittedUrl,
                            ),
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

  // ─── ACTIVE BID CARD ────────────────────────────────────────────────────────
  Widget _buildPremiumBidCard({
    required InfluencerBidEntity bid,
    required Color statusColor,
    VoidCallback? onTap,
    VoidCallback? onWithdraw,
  }) {
    final statusBg = statusColor.withValues(alpha: 0.1);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
          border: Border.all(color: statusColor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: status badge + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(bid.status,
                      style: AppTextStyles.caption.copyWith(
                          color: statusColor, fontWeight: FontWeight.w800)),
                ),
                Text(
                  '${bid.createdAt.day}/${bid.createdAt.month}/${bid.createdAt.year}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Campaign title
            Text(
              bid.campaignTitle ?? 'Campaign #${bid.campaignId.length > 8 ? bid.campaignId.substring(0, 8) : bid.campaignId}',
              style: AppTextStyles.h4,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Shop + Product row
            if (bid.shopName != null || bid.productName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(LucideIcons.store, size: 12, color: AppColors.neutral400),
                  const SizedBox(width: 4),
                  if (bid.shopName != null)
                    Flexible(
                      child: Text(bid.shopName!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  if (bid.productName != null) ...[
                    Text(' • ', style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
                    Flexible(
                      child: Text(bid.productName!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 14),

            // Stats row
            Row(
              children: [
                _InfoChip(label: '₹${bid.proposedAmount.toStringAsFixed(0)}', icon: LucideIcons.indianRupee, color: AppColors.roleInfluencer),
                const SizedBox(width: 8),
                _InfoChip(label: 'Due ${bid.deliveryDate.day}/${bid.deliveryDate.month}', icon: LucideIcons.calendar, color: AppColors.neutral600),
                const Spacer(),
                if (bid.status != 'ACCEPTED' && bid.status != 'REJECTED')
                  TextButton(
                    onPressed: onWithdraw,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error500,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.neutral300),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── ONGOING CAMPAIGN CARD ───────────────────────────────────────────────────
  Widget _buildAcceptedCampaignCard({
    required InfluencerBidEntity bid,
    String? assignmentId,
    String? submittedContentUrl,
  }) {
    final deadlineText = '${bid.deliveryDate.day}/${bid.deliveryDate.month}/${bid.deliveryDate.year}';
    final alreadySubmitted = submittedContentUrl != null && submittedContentUrl.isNotEmpty;

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
        border: Border.all(color: AppColors.success500.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: alreadySubmitted ? AppColors.neutral100 : AppColors.success100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      alreadySubmitted ? LucideIcons.checkCheck : LucideIcons.checkCircle2,
                      size: 12,
                      color: alreadySubmitted ? AppColors.neutral600 : AppColors.success600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alreadySubmitted ? 'Submitted' : 'In Progress',
                      style: AppTextStyles.caption.copyWith(
                          color: alreadySubmitted ? AppColors.neutral600 : AppColors.success600,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Text('Deliver by $deadlineText',
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
            ],
          ),
          const SizedBox(height: 14),

          // Campaign Name
          Text(
            bid.campaignTitle ?? 'Campaign #${bid.campaignId.length > 8 ? bid.campaignId.substring(0, 8) : bid.campaignId}',
            style: AppTextStyles.h4,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (bid.productName != null) ...[
            const SizedBox(height: 2),
            Text(bid.productName!,
                style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 14),

          // Shop info card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (bid.shopLogoUrl != null)
                      Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.neutral200),
                          image: DecorationImage(
                            image: NetworkImage(bid.shopLogoUrl!),
                            fit: BoxFit.cover,
                            onError: (e, s) {},
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 36, height: 36,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.roleInfluencerLight,
                        ),
                        child: const Icon(LucideIcons.store, size: 16, color: AppColors.roleInfluencer),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bid.shopName ?? 'Shop', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                          if (bid.shopAddress != null)
                            Text(bid.shopAddress!, style: AppTextStyles.caption.copyWith(color: AppColors.neutral400), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                if (bid.shopEmail != null || bid.shopPhone != null) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.neutral200),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (bid.shopEmail != null)
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse('mailto:${bid.shopEmail}')),
                          child: _ContactChip(icon: LucideIcons.mail, text: bid.shopEmail!),
                        ),
                      if (bid.shopPhone != null)
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse('tel:${bid.shopPhone}')),
                          child: _ContactChip(icon: LucideIcons.phone, text: bid.shopPhone!),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Agreed amount chip
          Row(
            children: [
              _InfoChip(label: 'Agreed: ₹${bid.proposedAmount.toStringAsFixed(0)}', icon: LucideIcons.indianRupee, color: AppColors.success600),
            ],
          ),

          // Submitted content URL
          if (alreadySubmitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success500.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.link, color: AppColors.success500, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      submittedContentUrl!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.success600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Submit Work button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: assignmentId == null
                  ? null
                  : () => _showSubmitWorkSheet(assignmentId, initialUrl: submittedContentUrl),
              icon: Icon(
                alreadySubmitted ? LucideIcons.edit3 : LucideIcons.upload,
                size: 16,
              ),
              label: Text(
                alreadySubmitted
                    ? 'Edit Submitted Work'
                    : assignmentId == null
                        ? 'Loading...'
                        : 'Submit Work',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    alreadySubmitted ? AppColors.neutral200 : AppColors.roleInfluencer,
                foregroundColor: alreadySubmitted ? AppColors.neutral700 : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitWorkSheet(String assignmentId, {String? initialUrl}) {
    final urlController = TextEditingController(text: initialUrl);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.roleInfluencerLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.upload, color: AppColors.roleInfluencer, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Submit Your Work', style: AppTextStyles.h4),
                        Text('Paste your content URL below', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: TextField(
                    controller: urlController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      hintText: 'https://instagram.com/p/... or YouTube link',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                      prefixIcon: const Icon(LucideIcons.link, color: AppColors.neutral400, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.info, size: 16, color: AppColors.success600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'After submission, the shopkeeper will review your content and release payment.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.success600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                BlocConsumer<InfluencerBloc, InfluencerState>(
                  listener: (context, state) {
                    if (state is InfluencerLoaded && !state.isLoading && state.isSuccess) {
                      Navigator.pop(ctx);
                      // Refresh assignments
                      context.read<InfluencerBloc>().add(const GetMyAssignmentsRequested());
                    }
                  },
                  builder: (context, state) {
                    final loading = state is InfluencerLoaded && state.isLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : () {
                          final url = urlController.text.trim();
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your content URL')),
                            );
                            return;
                          }
                          context.read<InfluencerBloc>().add(SubmitDeliverableRequested(
                            assignmentId: assignmentId,
                            contentUrl: url,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.roleInfluencer,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Submit Work', style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SHARED HELPER WIDGETS ────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _InfoChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.roleInfluencerLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: AppColors.roleInfluencer),
        const SizedBox(width: 4),
        Text(text,
          style: AppTextStyles.caption.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }
}
