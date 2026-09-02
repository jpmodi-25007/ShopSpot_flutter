import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';

class InfluencerEarningsScreen extends StatefulWidget {
  const InfluencerEarningsScreen({super.key});

  @override
  State<InfluencerEarningsScreen> createState() =>
      _InfluencerEarningsScreenState();
}

class _InfluencerEarningsScreenState extends State<InfluencerEarningsScreen>
    with TickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<double> _counterAnim;
  int _selectedMonth = 0;

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _counterAnim =
        CurvedAnimation(parent: _counterController, curve: Curves.easeOut);
    _counterController.forward();
    context.read<InfluencerBloc>().add(const GetInfluencerAnalyticsRequested());
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.roleInfluencer,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: AppColors.roleInfluencer,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('My Earnings',
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.white)),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _counterAnim,
                          builder: (context, _) {
                            return BlocBuilder<InfluencerBloc, InfluencerState>(
                              builder: (context, state) {
                                double totalEarnings = 0;
                                double pendingEarnings = 0;

                                if (state is InfluencerLoaded &&
                                    state.analytics != null) {
                                  totalEarnings =
                                      (state.analytics!['totalEarnings']
                                                  as num?)
                                              ?.toDouble() ??
                                          0;
                                  final payouts = state.analytics!['payouts']
                                          as List<dynamic>? ??
                                      [];
                                  for (var p in payouts) {
                                    if (p['status'] == 'Pending') {
                                      pendingEarnings +=
                                          (p['amount'] as num?)?.toDouble() ??
                                              0;
                                    }
                                  }
                                }

                                final displayValue =
                                    (totalEarnings * _counterAnim.value)
                                        .toInt();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '₹$displayValue',
                                      style: AppTextStyles.display.copyWith(
                                          color: AppColors.white, fontSize: 40),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        _EarningsChip(
                                            label: 'Total Earned',
                                            value:
                                                '₹${totalEarnings.toStringAsFixed(0)}',
                                            icon: LucideIcons.trendingUp),
                                        const SizedBox(width: 12),
                                        _EarningsChip(
                                            label: 'Pending',
                                            value:
                                                '₹${pendingEarnings.toStringAsFixed(0)}',
                                            icon: LucideIcons.clock),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Monthly chart
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neutral900.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: BlocBuilder<InfluencerBloc, InfluencerState>(
                      builder: (context, state) {
                        final payouts = state is InfluencerLoaded
                            ? (state.analytics?['payouts'] as List<dynamic>? ??
                                [])
                            : [];
                        final isLoadingAnalytics =
                            state is InfluencerLoaded && state.isLoading;

                        // Build _MonthBar list from real payout data
                        final List<_MonthBar> monthBars = payouts.map((p) {
                          final month = (p['month'] as String?) ?? '';
                          final amount =
                              ((p['amount'] as num?)?.toDouble() ?? 0.0);
                          return _MonthBar(month, amount);
                        }).toList();

                        // Normalize to percentage of max (for bar heights)
                        double maxAmount = 0;
                        for (final b in monthBars) {
                          if (b.value > maxAmount) maxAmount = b.value;
                        }
                        final List<_MonthBar> normalizedBars =
                            monthBars.map((b) {
                          final pct = maxAmount > 0
                              ? ((b.value / maxAmount) * 100).clamp(5.0, 100.0)
                              : 0.0;
                          return _MonthBar(b.month, pct);
                        }).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monthly Performance',
                                style: AppTextStyles.h4.copyWith(fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Payout history by month',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.neutral400)),
                            const SizedBox(height: 20),
                            if (isLoadingAnalytics)
                              AppShimmer(
                                child: ShimmerBox(
                                  height: 120,
                                  width: double.infinity,
                                  borderRadius: 8,
                                ),
                              )
                            else if (normalizedBars.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text('No monthly payout data yet.',
                                      style: AppTextStyles.body.copyWith(
                                          color: AppColors.neutral500)),
                                ),
                              )
                            else
                              SizedBox(
                                height: 120,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: List.generate(normalizedBars.length,
                                      (index) {
                                    return GestureDetector(
                                      onTap: () => setState(
                                          () => _selectedMonth = index),
                                      child: _BarChart(
                                        bar: normalizedBars[index],
                                        isSelected: _selectedMonth == index,
                                        animController: _counterController,
                                        delay: index * 0.15,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text('Payout History', style: AppTextStyles.h4),
                  const SizedBox(height: 12),

                  BlocBuilder<InfluencerBloc, InfluencerState>(
                    builder: (context, state) {
                      if (state is InfluencerLoaded && state.isLoading) {
                        return Column(
                          children: const [
                            PayoutCardSkeleton(),
                            PayoutCardSkeleton(),
                            PayoutCardSkeleton(),
                          ],
                        );
                      }
                      final payouts = state is InfluencerLoaded
                          ? (state.analytics?['payouts'] as List<dynamic>? ??
                              [])
                          : [];
                      if (payouts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                              child: Text('No payouts yet.',
                                  style: TextStyle(color: Colors.grey))),
                        );
                      }

                      return Column(
                        children: payouts.map((p) {
                          final isPaid = p['status'] == 'Paid';
                          final monthStr = p['month'] ?? '';
                          final amount = (p['amount'] as num?)?.toInt() ?? 0;

                          return _PayoutCard(
                            payout: _PayoutItem(
                              'Payout for $monthStr',
                              monthStr,
                              amount,
                              isPaid,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBar {
  final String month;
  final double value; // normalized percentage 0–100 for bar height
  const _MonthBar(this.month, this.value);
}

class _BarChart extends StatelessWidget {
  final _MonthBar bar;
  final bool isSelected;
  final AnimationController animController;
  final double delay;
  const _BarChart(
      {required this.bar,
      required this.isSelected,
      required this.animController,
      required this.delay});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isSelected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${bar.value.toStringAsFixed(0)}%',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: animController,
          builder: (context, child) {
            final h = (bar.value.toDouble() * animController.value)
                .clamp(0, 100)
                .toDouble();
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 36,
              height: h * 0.9,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isSelected
                      ? [const Color(0xFF7C3AED), const Color(0xFF6D28D9)]
                      : [
                          AppColors.roleInfluencerLight,
                          AppColors.roleInfluencerLight.withValues(alpha: 0.5)
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          bar.month,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? const Color(0xFF7C3AED) : AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}

class _PayoutItem {
  final String label;
  final String date;
  final int amount;
  final bool isPaid;
  const _PayoutItem(this.label, this.date, this.amount, this.isPaid);
}

class _PayoutCard extends StatelessWidget {
  final _PayoutItem payout;
  const _PayoutCard({required this.payout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  payout.isPaid ? AppColors.success100 : AppColors.warning100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              payout.isPaid ? LucideIcons.checkCircle : LucideIcons.clock,
              color:
                  payout.isPaid ? AppColors.success500 : AppColors.warning500,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payout.label,
                    style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(payout.date,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.neutral400)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${payout.amount}',
                  style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: payout.isPaid
                      ? AppColors.success100
                      : AppColors.warning100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  payout.isPaid ? 'Paid' : 'Pending',
                  style: AppTextStyles.caption.copyWith(
                    color: payout.isPaid
                        ? AppColors.success500
                        : AppColors.warning500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningsChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _EarningsChip(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.caption.copyWith(color: Colors.white60)),
              Text(value,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
