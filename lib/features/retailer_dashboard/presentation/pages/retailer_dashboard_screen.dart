import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/retailer_dashboard_bloc.dart';
import '../bloc/retailer_dashboard_event.dart';
import '../bloc/retailer_dashboard_state.dart';

class RetailerDashboardScreen extends StatelessWidget {
  const RetailerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<RetailerDashboardBloc>()..add(GetShopAnalyticsRequested()),
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
              onPressed: () {},
            ),
          ),
          title: Text('ShopSpot Hub',
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
                child: const CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage('assets/images/web_hero_boutique.jpg'),
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

            if (state is RetailerDashboardLoaded) {
              isLoading = state.isLoading;
              if (state.analytics != null) {
                views = state.analytics!['totalViews'] as int? ?? 0;
                inquiries = state.analytics!['activeOrders'] as int? ?? 0;
              }
            }

            final NumberFormat compactFormat = NumberFormat.compact();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good morning,\nElectroHub 👋',
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
                        child: _buildPremiumStatCard(
                            isLoading ? '-' : compactFormat.format(views),
                            'Total Views',
                            '+12%',
                            true),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPremiumStatCard(
                            isLoading ? '-' : compactFormat.format(inquiries),
                            'Active Orders',
                            '+5%',
                            true),
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
                          LucideIcons.plus, 'Add Product', true, () {}),
                      _buildActionBtn(
                          LucideIcons.packageSearch, 'Inventory', false, () {}),
                      _buildActionBtn(
                          LucideIcons.barChart2, 'Analytics', false, () {}),
                      _buildActionBtn(
                          LucideIcons.megaphone, 'Promote', false, () {}),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.lineChart,
                            size: 48, color: AppColors.roleRetailerLight),
                        const SizedBox(height: 16),
                        Text('Chart Placeholder',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.neutral400,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Action Items
                  Text('Needs Attention', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  _buildPremiumActionItemCard(
                    icon: LucideIcons.messageCircle,
                    iconColor: AppColors.roleRetailer,
                    title: 'New Inquiry',
                    subtitle: 'Samsung 55" Neo QLED',
                    timeText: '2 mins ago • Rahul S.',
                    buttonText: 'Reply',
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumActionItemCard(
                    icon: LucideIcons.timer,
                    iconColor: AppColors.warning600,
                    title: 'Expiring in 15 mins',
                    subtitle: 'iPhone 14 Pro Max - 256GB Deep Purple',
                    timeText: 'Reserved for pickup',
                    buttonText: 'View Details',
                    isWarning: true,
                  ),
                  const SizedBox(height: 40),

                  // Influencer Campaigns & Bids
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Influencer Campaigns', style: AppTextStyles.h3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.roleRetailerLight
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(100)),
                        child: Text('Create New',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.roleRetailer,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumCampaignBidCard(
                    campaignTitle: 'Summer Mega Sale Push',
                    influencerName: 'Elena Rivers (@elenastyles)',
                    influencerImage: 'invalid',
                    bidAmount: '\$1,500',
                    status: 'Pending Review',
                  ),
                  const SizedBox(height: 16),
                  _buildPremiumCampaignBidCard(
                    campaignTitle: 'Artisan Espresso Maker Launch',
                    influencerName: 'Mark D. (@coffee_mark)',
                    influencerImage: 'invalid',
                    bidAmount: '\$800',
                    status: 'Counter Offer Sent',
                    isCounter: true,
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
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String timeText,
    required String buttonText,
    bool isWarning = false,
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
              onPressed: () {},
              child: Text(buttonText,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCampaignBidCard({
    required String campaignTitle,
    required String influencerName,
    required String influencerImage,
    required String bidAmount,
    required String status,
    bool isCounter = false,
  }) {
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
        border: Border.all(
            color: isCounter
                ? AppColors.warning500.withValues(alpha: 0.6)
                : AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(campaignTitle,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.roleRetailer,
                      fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCounter
                      ? AppColors.warning500.withValues(alpha: 0.1)
                      : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status,
                    style: AppTextStyles.caption.copyWith(
                        color: isCounter
                            ? AppColors.warning600
                            : AppColors.neutral600,
                        fontWeight: FontWeight.w700)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.neutral100,
                backgroundImage: const AssetImage('assets/images/web_hero_boutique.jpg'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(influencerName,
                        style: AppTextStyles.bodySmall
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Bid Amount: ',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.neutral500)),
                        Text(bidAmount,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.neutral900,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.neutral200),
                  ),
                  onPressed: () {},
                  child: const Text('View Profile'),
                ),
              ),
            ],
          ),
          if (!isCounter) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neutral100,
                      foregroundColor: AppColors.neutral700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: const Text('Counter'),
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
                    ),
                    onPressed: () {},
                    child: const Text('Accept Bid',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
