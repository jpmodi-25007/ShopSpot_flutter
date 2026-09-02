import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/retailer_campaign_bloc.dart';
import '../bloc/retailer_campaign_state.dart';

class RetailerCampaignDetailScreen extends StatelessWidget {
  final String campaignId;
  const RetailerCampaignDetailScreen({super.key, required this.campaignId});

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
              final campaign = state.campaigns.firstWhere((c) => c.id == campaignId);
              
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
                          context.push('/retailer/campaigns/$campaignId/bids');
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
          return const Center(child: CircularProgressIndicator());
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
