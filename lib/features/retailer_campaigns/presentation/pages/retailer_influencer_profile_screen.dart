import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../influencer/domain/entities/influencer_bid_entity.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/repositories/retailer_campaign_repository.dart';

class RetailerInfluencerProfileScreen extends StatelessWidget {
  final String influencerId;
  final InfluencerBidEntity? bid;
  const RetailerInfluencerProfileScreen({super.key, required this.influencerId, this.bid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.roleRetailer.withValues(alpha: 0.1), AppColors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 60), // Space for avatar overlap
                    Container(
                      color: AppColors.neutral50,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(bid?.influencerName ?? 'Influencer #$influencerId', style: AppTextStyles.h2, textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          if (bid?.influencerInstagram != null) ...[
                            Text('@${bid!.influencerInstagram}', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
                            const SizedBox(height: 8),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.mapPin, size: 14, color: AppColors.neutral500),
                              const SizedBox(width: 4),
                              Text(
                                bid?.influencerCity?.trim().isNotEmpty == true
                                    ? bid!.influencerCity!
                                    : 'City not set',
                                style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat(
                                bid?.influencerFollowers?.toString() ?? '--',
                                'Followers',
                              ),
                              _buildStat(
                                bid?.influencerEngagement == null
                                    ? '--'
                                    : '${bid!.influencerEngagement!.toStringAsFixed(1)}%',
                                'Engagement',
                              ),
                              _buildStat(
                                bid?.influencerNiche?.trim().isNotEmpty == true
                                    ? bid!.influencerNiche!
                                    : 'Not set',
                                'Niche',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (bid != null) ...[
                            _buildBidDetails(bid!),
                            const SizedBox(height: 24),
                          ],

                          // Bio
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.neutral200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('About ${bid?.influencerName ?? 'Influencer'}', style: AppTextStyles.h4),
                                const SizedBox(height: 12),
                                Text(
                                  bid?.influencerBio?.trim().isNotEmpty == true
                                      ? bid!.influencerBio!
                                      : 'No bio provided.',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Portfolio
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Work', style: AppTextStyles.h4),
                              if (bid?.influencerInstagram != null)
                                GestureDetector(
                                  onTap: () async {
                                    final url = Uri.parse('https://instagram.com/${bid!.influencerInstagram}');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  },
                                  child: Text('View Instagram', style: AppTextStyles.caption.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w600)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildPortfolio(bid),
                          const SizedBox(height: 100), // padding for sticky bottom bar
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: AppNetworkImage(
                        url: bid?.influencerAvatar,
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(56),
                        placeholderIcon: LucideIcons.user,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final userId = bid?.influencerUserId;
                  if (userId == null || userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('This creator has no user account to message')),
                    );
                    return;
                  }
                  context.push('/chat/$userId', extra: {
                    'targetUserName': bid?.influencerName ?? 'Influencer',
                    'targetUserAvatar': bid?.influencerAvatar,
                    'targetUserPhone': bid?.influencerPhone,
                    'contextType': 'CAMPAIGN',
                    'contextId': bid?.campaignId,
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.neutral300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.messageCircle, size: 18, color: AppColors.neutral700),
                    const SizedBox(width: 8),
                    Text('Message', style: AppTextStyles.body.copyWith(color: AppColors.neutral700, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: bid == null || bid!.status == 'ACCEPTED'
                    ? null
                    : () async {
                        try {
                          await getIt<RetailerCampaignRepository>().acceptBid(bid!.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Bid accepted'),
                              backgroundColor: AppColors.roleRetailer,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          context.pop();
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.toString()),
                              backgroundColor: AppColors.error500,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.roleRetailer,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Accept Bid', style: AppTextStyles.body.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  Widget _buildBidDetails(InfluencerBidEntity bid) {
    final proposal = bid.proposal?.trim() ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This bid', style: AppTextStyles.h4),
          const SizedBox(height: 12),
          Text('₹${bid.proposedAmount.toStringAsFixed(0)}', style: AppTextStyles.h3.copyWith(color: AppColors.roleRetailer)),
          const SizedBox(height: 8),
          Text('${bid.status.replaceAll('_', ' ')} · ${_formatDate(bid.availableDate)} to ${_formatDate(bid.deliveryDate)}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600)),
          if (proposal.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(proposal, style: AppTextStyles.body.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _buildPortfolio(InfluencerBidEntity? bid) {
    final links = <(IconData, String, String)>[
      if (bid?.influencerInstagram?.trim().isNotEmpty == true)
        (LucideIcons.camera, 'Instagram', 'https://instagram.com/${bid!.influencerInstagram}'),
      if (bid?.influencerYoutube?.trim().isNotEmpty == true)
        (LucideIcons.play, 'YouTube', bid!.influencerYoutube!),
      if (bid?.influencerFacebook?.trim().isNotEmpty == true)
        (LucideIcons.link, 'Facebook', bid!.influencerFacebook!),
    ];
    if (links.isEmpty) {
      return Text(
        'No portfolio links yet.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
      );
    }
    return Column(
      children: links
          .map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () async {
                  final uri = Uri.tryParse(link.$3.startsWith('http') ? link.$3 : 'https://${link.$3}');
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: Row(
                    children: [
                      Icon(link.$1, size: 18, color: AppColors.roleRetailer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(link.$2, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      const Icon(LucideIcons.externalLink, size: 16, color: AppColors.neutral400),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.roleRetailer)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
      ],
    );
  }


}
