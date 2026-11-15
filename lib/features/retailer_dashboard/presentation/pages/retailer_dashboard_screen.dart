import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/animated_fade_slide.dart';
import '../bloc/retailer_dashboard_bloc.dart';
import '../bloc/retailer_dashboard_event.dart';
import '../bloc/retailer_dashboard_state.dart';

import '../../../retailer_negotiation/presentation/bloc/retailer_negotiation_bloc.dart';
import '../../../retailer_negotiation/presentation/bloc/retailer_negotiation_state.dart';
import '../../../retailer_negotiation/presentation/bloc/retailer_negotiation_event.dart';

import '../../../retailer_campaigns/presentation/bloc/retailer_campaign_bloc.dart';
import '../../../retailer_campaigns/presentation/bloc/retailer_campaign_state.dart';
import '../../../retailer_campaigns/presentation/bloc/retailer_campaign_event.dart';

import '../../../dashboard/presentation/bloc/event_bloc.dart';
import '../../../dashboard/presentation/bloc/event_event.dart';
import '../../../dashboard/presentation/bloc/event_state.dart';

import '../../../../core/widgets/shimmer/skeletons/dashboard_stat_skeleton.dart';
import '../../../subscription/presentation/pages/my_subscription_page.dart';

class RetailerDashboardScreen extends StatefulWidget {
  const RetailerDashboardScreen({super.key});

  @override
  State<RetailerDashboardScreen> createState() =>
      _RetailerDashboardScreenState();
}

class _RetailerDashboardScreenState extends State<RetailerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    context.read<RetailerDashboardBloc>().add(const GetShopAnalyticsRequested());
    context.read<RetailerCampaignBloc>().add(const GetMyCampaignsRequested());
    context.read<EventBloc>().add(const GetShopEventsRequested());
    context.read<RetailerNegotiationBloc>().add(const GetShopNegotiationsRequested());
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
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(LucideIcons.store,
                    color: AppColors.roleRetailer),
                onPressed: () => context.go('/retailer/profile'),
              ),
            ),
            title: Text('Findivo Hub',
                style:
                    AppTextStyles.h3.copyWith(color: AppColors.roleRetailer)),
            centerTitle: true,
            actions: [
              IconButton(
                  icon:
                      const Icon(LucideIcons.bell, color: AppColors.neutral900),
                  onPressed: () => context.push('/notifications')),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.roleRetailer, width: 2),
                  ),
                  child: BlocBuilder<RetailerDashboardBloc,
                      RetailerDashboardState>(
                    builder: (context, state) {
                      final logoUrl = state is RetailerDashboardLoaded
                          ? state.shop?.logoUrl
                          : null;
                      return ClipOval(
                        child: AppNetworkImage(
                          url: logoUrl,
                          width: 28,
                          height: 28,
                          placeholderIcon: LucideIcons.store,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          body: BlocBuilder<RetailerDashboardBloc, RetailerDashboardState>(
            builder: (context, state) {
              bool isLoading = false;
              int views = 0;
              int inquiries = 0;
              int viewsTrend = 0;
              int ordersTrend = 0;

              if (state is RetailerDashboardLoaded) {
                isLoading = state.isLoading;
                if (state.analytics != null) {
                  views = state.analytics!['totalViews'] as int? ?? 0;
                  inquiries = state.analytics!['activeOrders'] as int? ?? 0;
                  viewsTrend = state.analytics!['viewsTrend'] as int? ?? 0;
                  ordersTrend = state.analytics!['ordersTrend'] as int? ?? 0;
                }
              }

              String formatTrend(int t) => t >= 0 ? '+$t%' : '$t%';

              final NumberFormat compactFormat = NumberFormat.compact();

              // Extract 7-day data from analytics if available
              List<double> sevenDayViews = [];
              List<String> chartDayLabels = [];
              if (state is RetailerDashboardLoaded && state.analytics != null) {
                final rawDaily = state.analytics!['dailyViews'];
                if (rawDaily is List && rawDaily.length == 7) {
                  sevenDayViews = rawDaily
                      .map((e) => (double.tryParse(e.toString()) ?? 0.0))
                      .toList();
                }
                final rawLabels = state.analytics!['dayLabels'];
                if (rawLabels is List && rawLabels.length == 7) {
                  chartDayLabels = rawLabels.map((e) => e.toString()).toList();
                }
              }

              // Fallback day labels if not provided by backend
              if (chartDayLabels.length != 7) {
                final now = DateTime.now();
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                chartDayLabels = List.generate(7, (i) {
                  final d = now.subtract(Duration(days: 6 - i));
                  return days[d.weekday - 1];
                });
              }

              // Fallback values if daily breakdown is not yet available but views exist
              if (sevenDayViews.length != 7) {
                if (views > 0) {
                  final avgDaily = views / 7.0;
                  sevenDayViews = List.generate(7, (i) {
                    final progress = i / 6.0;
                    return (avgDaily * (0.7 + 0.6 * progress))
                        .clamp(0.0, double.infinity);
                  });
                } else {
                  sevenDayViews = List.filled(7, 0.0);
                }
              }

              final bool hasPerformanceActivity = views > 0 ||
                  inquiries > 0 ||
                  sevenDayViews.any((v) => v > 0);
              final double maxVal = sevenDayViews.isEmpty
                  ? 5.0
                  : sevenDayViews.reduce((a, b) => a > b ? a : b);
              final double chartMaxY = maxVal > 0
                  ? (maxVal * 1.3).ceilToDouble().clamp(5.0, double.infinity)
                  : 5.0;

              final List<FlSpot> performanceSpots = List.generate(7, (index) {
                return FlSpot(index.toDouble(), sevenDayViews[index]);
              });

              return RefreshIndicator(
                color: AppColors.roleRetailer,
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedFadeSlide(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Good morning,\n${state.shop?.name ?? 'Retailer'} 👋",
                            style: AppTextStyles.h1.copyWith(
                                color: AppColors.neutral900, height: 1.2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Here\'s what\'s happening at your shop today.',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.neutral500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Premium Top Stats
                    Row(
                      children: [
                        Expanded(
                          child: isLoading
                              ? const DashboardStatSkeleton()
                              : AnimatedFadeSlide(
                                  delay: const Duration(milliseconds: 60),
                                  child: _buildPremiumStatCard(
                                      compactFormat.format(views),
                                      'Total Views',
                                      formatTrend(viewsTrend),
                                      viewsTrend >= 0),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: isLoading
                              ? const DashboardStatSkeleton()
                              : AnimatedFadeSlide(
                                  delay: const Duration(milliseconds: 120),
                                  child: _buildPremiumStatCard(
                                      compactFormat.format(inquiries),
                                      'Active Orders',
                                      formatTrend(ordersTrend),
                                      ordersTrend >= 0),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    Text('Quick Actions', style: AppTextStyles.h4),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionBtn(LucideIcons.plus, 'Add Product', true,
                            () => context.push('/retailer/add-product')),
                        _buildActionBtn(LucideIcons.packageSearch, 'Inventory',
                            false, () => context.go('/retailer/inventory')),
                        _buildActionBtn(LucideIcons.barChart2, 'Analytics',
                            false, () => context.push('/retailer/inventory')),
                        _buildActionBtn(LucideIcons.megaphone, 'Promote', false,
                            () => context.go('/retailer/campaigns')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // My Plan Card
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MySubscriptionPage()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2D1B13), Color(0xFF4E342E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.roleRetailer.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.crown, color: Colors.amber, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'My Plan',
                                        style: AppTextStyles.h4.copyWith(color: Colors.white, fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'MANAGE',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'View limits, event quota & upgrade options',
                                    style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Performance Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Performance', style: AppTextStyles.h3),
                        Text('Last 7 Days',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.roleRetailer,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!hasPerformanceActivity)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.neutral200.withValues(alpha: 0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neutral900.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.roleRetailer
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.trendingUp,
                                color: AppColors.roleRetailer,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No Store Views Yet',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.neutral900,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Performance metrics will automatically track your views and orders once customers start exploring your store.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.neutral500,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            InkWell(
                              onTap: () => context.go('/retailer/inventory'),
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.roleRetailerLight
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: AppColors.roleRetailer
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.package,
                                      size: 16,
                                      color: AppColors.roleRetailer,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add Products to Get Discovered',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.roleRetailer,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 240,
                        padding: const EdgeInsets.fromLTRB(16, 24, 20, 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neutral900.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: 6,
                            minY: 0,
                            maxY: chartMaxY,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: (chartMaxY / 4)
                                  .clamp(1.0, double.infinity),
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppColors.neutral200.withValues(alpha: 0.7),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: (chartMaxY / 4)
                                      .clamp(1.0, double.infinity),
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0 || value > chartMaxY) {
                                      return const SizedBox.shrink();
                                    }
                                    return Text(
                                      compactFormat.format(value.toInt()),
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.neutral400,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 24,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 ||
                                        idx >= chartDayLabels.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final isToday = idx == 6;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        chartDayLabels[idx],
                                        style: AppTextStyles.caption.copyWith(
                                          color: isToday
                                              ? AppColors.roleRetailer
                                              : AppColors.neutral500,
                                          fontWeight: isToday
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (_) => AppColors.neutral900,
                                tooltipBorderRadius: BorderRadius.circular(8),
                                tooltipPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final idx = spot.x.toInt();
                                    final day = (idx >= 0 &&
                                            idx < chartDayLabels.length)
                                        ? chartDayLabels[idx]
                                        : '';
                                    return LineTooltipItem(
                                      '$day: ${spot.y.toInt()} views',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: performanceSpots,
                                isCurved: true,
                                curveSmoothness: 0.35,
                                color: AppColors.roleRetailer,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  checkToShowDot: (spot, barData) {
                                    return spot.x == 6 || spot.y == maxVal;
                                  },
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                      strokeColor: AppColors.roleRetailer,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.roleRetailer
                                          .withValues(alpha: 0.25),
                                      AppColors.roleRetailer
                                          .withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),

                    // Action Items
                    Text('Needs Attention', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    const _RecentReservationsSection(),
                    const SizedBox(height: 16),
                    BlocBuilder<RetailerNegotiationBloc,
                        RetailerNegotiationState>(
                      builder: (context, negState) {
                        final negotiations =
                            negState is RetailerNegotiationLoaded
                                ? (negState.negotiations ?? [])
                                : [];
                        final pending = negotiations
                            .where((n) => n.status == 'PENDING')
                            .toList();
                        if (pending.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.neutral50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.neutral200),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.checkCircle2,
                                    color: AppColors.success500, size: 24),
                                const SizedBox(width: 12),
                                Text('All caught up! No pending inquiries.',
                                    style: AppTextStyles.body
                                        .copyWith(color: AppColors.neutral600)),
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: pending
                              .take(2)
                              .map((neg) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildPremiumActionItemCard(
                                      context: context,
                                      icon: LucideIcons.messageCircle,
                                      iconColor: AppColors.roleRetailer,
                                      title: 'Negotiation Request',
                                      subtitle: neg.productName ?? 'Product',
                                      timeText: neg.updatedAt != null
                                          ? "Updated ${DateFormat('hh:mm a').format(neg.updatedAt!)}"
                                          : 'Pending',
                                      buttonText: 'Reply',
                                      onTap: () => context.push(
                                          '/retailer/negotiations/${neg.id}'),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Influencer Campaigns & Bids
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Influencer Campaigns', style: AppTextStyles.h3),
                        GestureDetector(
                          onTap: () async {
                            await context.push('/retailer/create-campaign');
                            if (mounted) {
                              _loadDashboardData();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.roleRetailerLight
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text('Create New',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.roleRetailer,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<RetailerCampaignBloc, RetailerCampaignState>(
                      builder: (context, campState) {
                        final campaigns = campState is RetailerCampaignLoaded
                            ? campState.campaigns
                            : [];
                        if (campaigns.isEmpty) {
                          return GestureDetector(
                            onTap: () async {
                              await context.push('/retailer/create-campaign');
                              if (mounted) {
                                _loadDashboardData();
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.neutral50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.roleRetailerLight,
                                    style: BorderStyle.solid),
                              ),
                              child: Column(
                                children: [
                                  const Icon(LucideIcons.megaphone,
                                      size: 32, color: AppColors.roleRetailer),
                                  const SizedBox(height: 12),
                                  Text('Launch an Influencer Campaign',
                                      style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Connect with influencers to grow your business',
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.neutral500)),
                                ],
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: campaigns
                              .take(2)
                              .map((c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildPremiumCampaignCard(
                                      context: context,
                                      campaign: c,
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Shop Events
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shop Events', style: AppTextStyles.h3),
                        GestureDetector(
                          onTap: () async {
                            await context.push('/retailer/events/create');
                            if (mounted) {
                              _loadDashboardData();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: AppColors.roleRetailerLight
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(100)),
                            child: Text('Create Event',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.roleRetailer,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<EventBloc, EventState>(
                      builder: (context, eventState) {
                        final events = eventState is ShopEventsLoaded
                            ? eventState.events
                            : [];

                        if (events.isEmpty) {
                          return GestureDetector(
                            onTap: () async {
                              await context.push('/retailer/events/create');
                              if (mounted) {
                                _loadDashboardData();
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.neutral50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.neutral200),
                              ),
                              child: Column(
                                children: [
                                  const Icon(LucideIcons.calendarPlus,
                                      size: 32, color: AppColors.neutral400),
                                  const SizedBox(height: 12),
                                  Text('Host a sale or special event',
                                      style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Events appear on the customer home feed',
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.neutral500)),
                                ],
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 152,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            separatorBuilder: (context, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final event = events[index];
                              final dateFormat = DateFormat('MMM d, yyyy');
                              final startDate = event.startDate != null
                                  ? dateFormat.format(event.startDate!)
                                  : 'N/A';

                              return GestureDetector(
                                onTap: () async {
                                  await context.push('/retailer/events/edit',
                                      extra: event);
                                  if (mounted) _loadDashboardData();
                                },
                                child: Container(
                                  width: 270,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: AppColors.neutral200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neutral900
                                            .withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: event.isActive
                                                  ? AppColors.success50
                                                  : AppColors.neutral100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(LucideIcons.calendar,
                                                size: 16,
                                                color: event.isActive
                                                    ? AppColors.success600
                                                    : AppColors.neutral500),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.title,
                                                  style: AppTextStyles.body
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  startDate,
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                          color: AppColors
                                                              .neutral500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.roleRetailerLight
                                                  .withValues(alpha: 0.3),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppColors.roleRetailer
                                                      .withValues(alpha: 0.3)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(LucideIcons.pencil,
                                                    size: 11,
                                                    color:
                                                        AppColors.roleRetailer),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.roleRetailer,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: event.isActive
                                                  ? AppColors.success50
                                                  : AppColors.neutral100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              event.isActive
                                                  ? 'Active'
                                                  : 'Completed/Inactive',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                color: event.isActive
                                                    ? AppColors.success600
                                                    : AppColors.neutral500,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Edit Details',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  color: AppColors.roleRetailer,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              const Icon(
                                                  LucideIcons.chevronRight,
                                                  size: 14,
                                                  color:
                                                      AppColors.roleRetailer),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 80), // Bottom padding
                  ],
                ),
              ),
            );
          },
        ),
      );
  }

  Widget _buildPremiumStatCard(
      String value, String label, String trend, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            AppColors.neutral50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.success500.withValues(alpha: 0.1)
                      : AppColors.error500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                        isPositive
                            ? LucideIcons.trendingUp
                            : LucideIcons.trendingDown,
                        size: 14,
                        color: isPositive
                            ? AppColors.success600
                            : AppColors.error500),
                    const SizedBox(width: 4),
                    Text(trend,
                        style: AppTextStyles.caption.copyWith(
                            color: isPositive
                                ? AppColors.success600
                                : AppColors.error500,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: AppTextStyles.h1.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
      IconData icon, String label, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.roleRetailer : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isPrimary
                      ? AppColors.roleRetailer.withValues(alpha: 0.3)
                      : AppColors.neutral900.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ],
              border:
                  isPrimary ? null : Border.all(color: AppColors.neutral200),
            ),
            child: Icon(icon,
                color: isPrimary ? AppColors.white : AppColors.roleRetailer,
                size: 24),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.neutral700),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPremiumActionItemCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String timeText,
    required String buttonText,
    bool isWarning = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
            color: isWarning
                ? AppColors.warning500.withValues(alpha: 0.5)
                : AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: AppTextStyles.caption
                      .copyWith(color: iconColor, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Text(subtitle,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(timeText,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isWarning
                    ? AppColors.white
                    : AppColors.roleRetailerLight.withValues(alpha: 0.5),
                foregroundColor:
                    isWarning ? AppColors.warning600 : AppColors.roleRetailer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: isWarning
                    ? BorderSide(
                        color: AppColors.warning600.withValues(alpha: 0.5))
                    : BorderSide.none,
              ),
              onPressed: onTap ?? () => context.go('/retailer/negotiations'),
              child: Text(buttonText,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCampaignCard({
    required BuildContext context,
    required dynamic campaign,
  }) {
    final title = campaign.title ?? 'Untitled Campaign';
    final status = campaign.status ?? 'DRAFT';
    final budgetText =
        '₹${campaign.budgetMin.toStringAsFixed(0)} - ₹${campaign.budgetMax.toStringAsFixed(0)}';

    // Check if campaign is active
    final isActive = status == 'ACTIVE' || status == 'PUBLISHED';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.roleRetailer,
                      fontWeight: FontWeight.w800)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success500.withValues(alpha: 0.1)
                      : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status,
                    style: AppTextStyles.caption.copyWith(
                        color: isActive
                            ? AppColors.success600
                            : AppColors.neutral600,
                        fontWeight: FontWeight.w700)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.megaphone,
                    color: AppColors.roleRetailer, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget: $budgetText',
                        style: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        '${campaign.platforms.length} Platforms • ${campaign.targetCategories.length} Categories',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.neutral500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.neutral700,
                    elevation: 0,
                    side: const BorderSide(
                        color: AppColors.neutral200, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    context.push('/retailer/campaigns/${campaign.id}');
                  },
                  child: const Text('View Details',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roleRetailer,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    context.push('/retailer/campaigns/${campaign.id}/bids');
                  },
                  child: const Text('View Bids',
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

class _RecentReservationsSection extends StatefulWidget {
  const _RecentReservationsSection();

  @override
  State<_RecentReservationsSection> createState() => _RecentReservationsSectionState();
}

class _RecentReservationsSectionState extends State<_RecentReservationsSection> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    try {
      final response = await getIt<ApiClient>().get('/shopkeeper/reservations?limit=5');
      if (mounted) {
        setState(() {
          _reservations = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String id, String action) async {
    try {
      await getIt<ApiClient>().post('/shopkeeper/reservations/$id/$action');
      _fetchReservations();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reservation ${action == 'complete' ? 'confirmed' : 'cancelled'}'), backgroundColor: AppColors.success500));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update reservation'), backgroundColor: AppColors.error500));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final pending = _reservations.where((r) => r['status'] == 'ACTIVE').toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pending Reservations', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...pending.map((res) {
          final product = res['product'];
          final customer = res['customer'];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.shoppingCart, color: AppColors.roleRetailer, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(product?['name'] ?? 'Product', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
                    Text('₹${res['reservedPrice']}', style: AppTextStyles.h4.copyWith(color: AppColors.roleRetailer)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Customer: ${customer?['name'] ?? 'Guest'}', style: AppTextStyles.bodySmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(res['id'], 'cancel'),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success500),
                        onPressed: () => _updateStatus(res['id'], 'complete'),
                        child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
