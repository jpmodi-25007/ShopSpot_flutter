import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../influencer/domain/entities/influencer_bid_entity.dart';
import '../../../../core/widgets/app_network_image.dart';

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
                              Text('Global', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.zap, size: 12, color: AppColors.success600),
                                    const SizedBox(width: 4),
                                    Text('Match', style: AppTextStyles.caption.copyWith(color: AppColors.success600, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat(bid?.influencerFollowers?.toString() ?? '--', 'Followers'),
                              _buildStat('${bid?.influencerEngagement?.toStringAsFixed(1) ?? '--'}%', 'Engagement'),
                              _buildStat(bid?.influencerNiche ?? 'General', 'Niche'),
                            ],
                          ),
                          const SizedBox(height: 24),

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
                                  bid?.influencerBio ?? 'No bio provided.',
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
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            children: [
                              Container(color: AppColors.neutral200, child: const Icon(LucideIcons.image, color: AppColors.neutral400)),
                              Container(color: AppColors.neutral200, child: const Icon(LucideIcons.image, color: AppColors.neutral400)),
                              Container(color: AppColors.neutral200, child: const Icon(LucideIcons.image, color: AppColors.neutral400)),
                            ],
                          ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Messaging feature coming soon!'),
                      backgroundColor: AppColors.roleRetailer,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Bid accepted successfully!'),
                      backgroundColor: AppColors.roleRetailer,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) context.pop();
                  });
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
