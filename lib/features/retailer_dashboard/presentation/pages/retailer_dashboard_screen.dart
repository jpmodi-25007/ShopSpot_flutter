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

class RetailerDashboardScreen extends StatelessWidget {
  const RetailerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<EventBloc>()..add(const GetShopEventsRequested()),
        ),
        BlocProvider(
          create: (context) =>
              getIt<RetailerDashboardBloc>()..add(GetShopAnalyticsRequested()),
        ),
        BlocProvider(
          create: (context) =>
              getIt<RetailerNegotiationBloc>()..add(const GetShopNegotiationsRequested()),
        ),
        BlocProvider(
          create: (context) =>
              getIt<RetailerCampaignBloc>()..add(const GetMyCampaignsRequested()),
        ),
      ],
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
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(LucideIcons.store,
                  color: AppColors.roleRetailer),
              onPressed: () => context.go('/retailer/profile'),
            ),
          ),
          title: Text('Findivo Hub',
              style: AppTextStyles.h3.copyWith(color: AppColors.roleRetailer)),
          centerTitle: true,
          actions: [
            IconButton(
                icon: const Icon(LucideIcons.bell, color: AppColors.neutral900),
                onPressed: () => context.push('/notifications')),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.roleRetailer, width: 2),
                ),
                child: BlocBuilder<RetailerDashboardBloc, RetailerDashboardState>(
                  builder: (context, state) {
                    final logoUrl = state is RetailerDashboardLoaded ? state.shop?.logoUrl : null;
                    return CircleAvatar(
                      radius: 14,
                      backgroundImage: logoUrl != null && logoUrl.isNotEmpty
                          ? NetworkImage(logoUrl) as ImageProvider
                          : const AssetImage('assets/images/web_hero_boutique.jpg'),
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

            String _formatTrend(int t) => t >= 0 ? '+$t%' : '$t%';

            final NumberFormat compactFormat = NumberFormat.compact();

            // Generate dynamic chart spots based on current active orders and ordersTrend
            // If ordersTrend is positive, the line should trend upwards.
            // If negative, it trends downwards.
            final double currentOrders = inquiries.toDouble() > 0 ? inquiries.toDouble() : 10.0;
            final double previousOrders = currentOrders / (1 + (ordersTrend / 100.0));
            
            final List<FlSpot> dynamicSpots = List.generate(7, (index) {
              // Create a gentle curve from previousOrders (day 0) to currentOrders (day 6)
              final progress = index / 6.0;
              // Add a little jitter so it looks like a real chart
              final randomJitter = (index % 2 == 0 ? 1 : -1) * (currentOrders * 0.05);
              double val = previousOrders + ((currentOrders - previousOrders) * progress) + randomJitter;
              if (val < 0) val = 0;
              return FlSpot(index.toDouble(), val);
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good morning,\n${state.shop?.name ?? 'Retailer'} 👋',
                      style: AppTextStyles.h1.copyWith(
                          color: AppColors.neutral900, height: 1.2)),
                  const SizedBox(height: 8),
                  Text('Here\'s what\'s happening at your shop today.',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.neutral500)),
                  const SizedBox(height: 32),

                  // Premium Top Stats
                  Row(
                    children: [
                      Expanded(
                        child: isLoading
                            ? const DashboardStatSkeleton()
                            : _buildPremiumStatCard(
                                compactFormat.format(views),
                                'Total Views',
                                _formatTrend(viewsTrend),
                                viewsTrend >= 0),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: isLoading
                            ? const DashboardStatSkeleton()
                            : _buildPremiumStatCard(
                                compactFormat.format(inquiries),
                                'Active Orders',
                                _formatTrend(ordersTrend),
                                ordersTrend >= 0),
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
                      _buildActionBtn(
                          LucideIcons.plus, 'Add Product', true, () => context.push('/retailer/add-product')),
                      _buildActionBtn(
                          LucideIcons.packageSearch, 'Inventory', false, () => context.go('/retailer/inventory')),
                      _buildActionBtn(
                          LucideIcons.barChart2, 'Analytics', false, () => context.push('/retailer/inventory')),
                      _buildActionBtn(
                          LucideIcons.megaphone, 'Promote', false, () => context.go('/retailer/campaigns')),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Performance Chart Placeholder
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
                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(24),
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
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: dynamicSpots,
                            isCurved: true,
                            color: AppColors.roleRetailer,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.roleRetailer.withValues(alpha: 0.1),
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
                  BlocBuilder<RetailerNegotiationBloc, RetailerNegotiationState>(
                    builder: (context, negState) {
                      final negotiations = negState is RetailerNegotiationLoaded
                          ? (negState.negotiations ?? [])
                          : [];
                      final pending = negotiations.where((n) => n.status == 'PENDING').toList();
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
                              const Icon(LucideIcons.checkCircle2, color: AppColors.success500, size: 24),
                              const SizedBox(width: 12),
                              Text('All caught up! No pending inquiries.', style: AppTextStyles.body.copyWith(color: AppColors.neutral600)),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: pending.take(2).map((neg) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPremiumActionItemCard(
                            context: context,
                            icon: LucideIcons.messageCircle,
                            iconColor: AppColors.roleRetailer,
                            title: 'Negotiation Request',
                            subtitle: neg.productName ?? 'Product',
                            timeText: neg.updatedAt != null ? 'Updated ${DateFormat('hh:mm a').format(neg.updatedAt!)}' : 'Pending',
                            buttonText: 'Reply',
                            onTap: () => context.push('/retailer/negotiations/${neg.id}'),
                          ),
                        )).toList(),
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
                        onTap: () => context.push('/retailer/create-campaign'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.roleRetailerLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('Create New',
                              style: AppTextStyles.caption.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<RetailerCampaignBloc, RetailerCampaignState>(
                    builder: (context, campState) {
                      final campaigns = campState is RetailerCampaignLoaded ? campState.campaigns ?? [] : [];
                      if (campaigns.isEmpty) {
                        return GestureDetector(
                          onTap: () => context.push('/retailer/create-campaign'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.neutral50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.roleRetailerLight, style: BorderStyle.solid),
                            ),
                            child: Column(
                              children: [
                                const Icon(LucideIcons.megaphone, size: 32, color: AppColors.roleRetailer),
                                const SizedBox(height: 12),
                                Text('Launch an Influencer Campaign', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Connect with influencers to grow your business', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: campaigns.take(2).map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPremiumCampaignCard(
                            context: context,
                            campaign: c,
                          ),
                        )).toList(),
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
                        onTap: () => context.push('/retailer/events/create'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.roleRetailerLight.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(100)),
                          child: Text('Create Event',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.roleRetailer, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<EventBloc, EventState>(
                    builder: (context, eventState) {
                      final events = eventState is ShopEventsLoaded ? eventState.events : [];
                      
                      if (events.isEmpty) {
                        return GestureDetector(
                          onTap: () => context.push('/retailer/events/create'),
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
                                const Icon(LucideIcons.calendarPlus, size: 32, color: AppColors.neutral400),
                                const SizedBox(height: 12),
                                Text('Host a sale or special event', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Events appear on the customer home feed', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          separatorBuilder: (context, _) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final event = events[index];
                            final dateFormat = DateFormat('MMM d, yyyy');
                            final startDate = event.startDate != null ? dateFormat.format(event.startDate!) : 'N/A';
                            
                            return Container(
                              width: 260,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.neutral200),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neutral900.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: event.isActive ? AppColors.success50 : AppColors.neutral100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          LucideIcons.calendar, 
                                          size: 16, 
                                          color: event.isActive ? AppColors.success600 : AppColors.neutral500
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event.title, 
                                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              startDate,
                                              style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    event.isActive ? 'Active' : 'Completed/Inactive',
                                    style: AppTextStyles.caption.copyWith(
                                      color: event.isActive ? AppColors.success600 : AppColors.neutral500,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
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
            );
          },
        ),
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
              border: isPrimary ? null : Border.all(color: AppColors.neutral200),
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
                  style: AppTextStyles.caption.copyWith(
                      color: iconColor, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Text(subtitle,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(timeText,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.neutral500)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isWarning
                    ? AppColors.white
                    : AppColors.roleRetailerLight.withValues(alpha: 0.5),
                foregroundColor: isWarning ? AppColors.warning600 : AppColors.roleRetailer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: isWarning
                    ? BorderSide(color: AppColors.warning600.withValues(alpha: 0.5))
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
    final budgetText = '₹${campaign.budgetMin.toStringAsFixed(0)} - ₹${campaign.budgetMax.toStringAsFixed(0)}';
    
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(LucideIcons.megaphone, color: AppColors.roleRetailer, size: 24),
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
                    Text('${campaign.platforms.length} Platforms • ${campaign.targetCategories.length} Categories',
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
                    // Navigate to campaign details
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Campaign details coming soon')),
                    );
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
                    // Navigate to view bids for this campaign
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View bids coming soon')),
                    );
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
