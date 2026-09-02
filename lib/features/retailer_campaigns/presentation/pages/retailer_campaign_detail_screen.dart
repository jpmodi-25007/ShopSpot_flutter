import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/retailer_campaign_bloc.dart';
import '../bloc/retailer_campaign_event.dart';
import '../bloc/retailer_campaign_state.dart';

class RetailerCampaignDetailScreen extends StatefulWidget {
  final String campaignId;
  const RetailerCampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<RetailerCampaignDetailScreen> createState() => _RetailerCampaignDetailScreenState();
}

class _RetailerCampaignDetailScreenState extends State<RetailerCampaignDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<RetailerCampaignBloc>().state;
      if (state is! RetailerCampaignLoaded) {
        context.read<RetailerCampaignBloc>().add(const GetMyCampaignsRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Campaign Details'),
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<RetailerCampaignBloc, RetailerCampaignState>(
        builder: (context, state) {
          if (state is RetailerCampaignLoaded) {
            try {
              final campaign = state.campaigns.firstWhere((c) => c.id == widget.campaignId);
              
              final isPublished = campaign.status == 'PUBLISHED' || campaign.status == 'ACTIVE';
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPublished ? AppColors.success50 : AppColors.neutral100,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        campaign.status ?? 'DRAFT',
                        style: AppTextStyles.caption.copyWith(
                          color: isPublished ? AppColors.success600 : AppColors.neutral600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      campaign.title ?? 'Untitled Campaign',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      campaign.description ?? 'No description provided.',
                      style: AppTextStyles.body.copyWith(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Budget & Requirements'),
                    const SizedBox(height: 16),
                    _buildDetailRow(LucideIcons.wallet, 'Budget', '₹${campaign.budgetMin} - ₹${campaign.budgetMax}'),
                    _buildDetailRow(LucideIcons.users, 'Creator Count', '${campaign.creatorCount} creators'),
                    _buildDetailRow(LucideIcons.smartphone, 'Platforms', campaign.platforms.join(', ')),
                    _buildDetailRow(LucideIcons.fileVideo, 'Content Types', campaign.contentTypes.join(', ')),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('Dates'),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      LucideIcons.calendar, 
                      'Application Deadline', 
                      campaign.applicationDeadline != null 
                          ? DateFormat('MMM dd, yyyy').format(campaign.applicationDeadline!) 
                          : 'Not set'
                    ),
                    _buildDetailRow(
                      LucideIcons.clock, 
                      'Publish By', 
                      campaign.publishByDate != null 
                          ? DateFormat('MMM dd, yyyy').format(campaign.publishByDate!) 
                          : 'Not set'
                    ),
                    
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.roleRetailer,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                          )
                        ),
                        onPressed: () {
                          context.push('/retailer/campaigns/${widget.campaignId}/bids');
                        },
                        child: Text(
                          'View Campaign Bids',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.white),
                        ),
                      ),
                    )
                  ],
                ),
              );
            } catch (e) {
              return const Center(child: Text('Campaign not found in local state.'));
            }
          }
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100))),
                  const SizedBox(height: 16),
                  Container(width: double.infinity, height: 32, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 16, color: Colors.white),
                  Container(width: 200, height: 16, color: Colors.white, margin: const EdgeInsets.only(top: 4)),
                  const SizedBox(height: 24),
                  Container(width: 150, height: 24, color: Colors.white),
                  const SizedBox(height: 16),
                  for (int i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: 100, height: 12, color: Colors.white),
                                const SizedBox(height: 4),
                                Container(width: double.infinity, height: 16, color: Colors.white),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.roleRetailerLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.roleRetailer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
