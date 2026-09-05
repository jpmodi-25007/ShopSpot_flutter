import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';
import '../../domain/entities/influencer_bid_entity.dart';
import '../../../../core/widgets/animated_fade_slide.dart';

class InfluencerAllBidsScreen extends StatefulWidget {
  const InfluencerAllBidsScreen({super.key});

  @override
  State<InfluencerAllBidsScreen> createState() => _InfluencerAllBidsScreenState();
}

class _InfluencerAllBidsScreenState extends State<InfluencerAllBidsScreen> {
  String _selectedFilter = 'ALL';
  final List<String> _filters = ['ALL', 'SUBMITTED', 'SHORTLISTED', 'COUNTERED', 'ACCEPTED', 'REJECTED'];

  @override
  void initState() {
    super.initState();
    context.read<InfluencerBloc>().add(const GetMyBidsRequested());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACCEPTED': return AppColors.success500;
      case 'REJECTED': return AppColors.error500;
      case 'SHORTLISTED': return const Color(0xFF4F46E5);
      case 'COUNTERED': return AppColors.warning600;
      default: return AppColors.neutral600;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'ACCEPTED': return AppColors.success100;
      case 'REJECTED': return AppColors.error50;
      case 'SHORTLISTED': return const Color(0xFFEEF2FF);
      case 'COUNTERED': return AppColors.warning50;
      default: return AppColors.neutral100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: Text('All My Bids', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  final color = f == 'ALL' ? AppColors.roleInfluencer : _statusColor(f);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? color : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          f == 'ALL' ? 'All Bids' : f[0] + f.substring(1).toLowerCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? Colors.white : AppColors.neutral600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<InfluencerBloc, InfluencerState>(
              builder: (context, state) {
                if (state is InfluencerLoaded && state.isLoading && (state.bids == null || state.bids!.isEmpty)) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.roleInfluencer));
                }

                final allBids = state is InfluencerLoaded ? state.bids ?? [] : [];
                final filtered = _selectedFilter == 'ALL'
                    ? allBids
                    : allBids.where((b) => b.status == _selectedFilter).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/empty_campaigns.jpg', height: 130, fit: BoxFit.contain),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'ALL' ? 'No bids yet' : 'No ${_selectedFilter.toLowerCase()} bids',
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: 6),
                        Text('Go discover campaigns and submit your first bid!',
                            style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<InfluencerBloc>().add(const GetMyBidsRequested());
                  },
                  color: AppColors.roleInfluencer,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) => AnimatedFadeSlide(
                      delay: Duration(milliseconds: 60 * index),
                      child: _BidListCard(
                        bid: filtered[index],
                        statusColor: _statusColor(filtered[index].status),
                        statusBgColor: _statusBgColor(filtered[index].status),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BidListCard extends StatelessWidget {
  final InfluencerBidEntity bid;
  final Color statusColor;
  final Color statusBgColor;
  const _BidListCard({required this.bid, required this.statusColor, required this.statusBgColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/influencer/bid-detail', extra: bid),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6)),
          ],
          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(100)),
                  child: Text(
                    bid.status,
                    style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${bid.createdAt.day}/${bid.createdAt.month}/${bid.createdAt.year}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bid.campaignTitle ?? 'Campaign #${bid.campaignId.length > 8 ? bid.campaignId.substring(0, 8) : bid.campaignId}',
              style: AppTextStyles.h4,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (bid.shopName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(LucideIcons.store, size: 12, color: AppColors.neutral400),
                  const SizedBox(width: 4),
                  Text(bid.shopName!, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                  if (bid.productName != null) ...[
                    Text(' • ', style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
                    Expanded(
                      child: Text(bid.productName!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                _Chip(label: '₹${bid.proposedAmount.toStringAsFixed(0)}', icon: LucideIcons.indianRupee, color: AppColors.roleInfluencer),
                const SizedBox(width: 8),
                _Chip(label: 'Due ${bid.deliveryDate.day}/${bid.deliveryDate.month}/${bid.deliveryDate.year}', icon: LucideIcons.calendar, color: AppColors.neutral600),
                const Spacer(),
                const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.neutral300),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Chip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
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
