import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../bloc/retailer_campaign_bloc.dart';
import '../bloc/retailer_campaign_event.dart';
import '../bloc/retailer_campaign_state.dart';
import '../../../influencer/domain/entities/influencer_campaign_entity.dart';

class RetailerCampaignsScreen extends StatefulWidget {
  const RetailerCampaignsScreen({super.key});

  @override
  State<RetailerCampaignsScreen> createState() => _RetailerCampaignsScreenState();
}

class _RetailerCampaignsScreenState extends State<RetailerCampaignsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RetailerCampaignBloc>().add(const GetMyCampaignsRequested());
  }

  Future<void> _refresh() async {
    context.read<RetailerCampaignBloc>().add(const GetMyCampaignsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.store, color: AppColors.roleRetailer),
          onPressed: () => context.go('/retailer/profile'),
        ),
        title: Text('Influencer Campaigns', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell), onPressed: () => context.push('/notifications')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.roleRetailer,
        backgroundColor: AppColors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage your brand partnerships and track performance.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'New Campaign',
                icon: LucideIcons.plus,
                onPressed: () => context.push('/retailer/create-campaign'),
              ),
            ),
            const SizedBox(height: 32),
            BlocBuilder<RetailerCampaignBloc, RetailerCampaignState>(
              builder: (context, state) {
                if (state is RetailerCampaignLoading) {
                  return Column(
                    children: List.generate(4, (index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: CampaignCardSkeleton(),
                    )),
                  );
                } else if (state is RetailerCampaignLoaded) {
                  final activeCampaigns = state.campaigns.where((c) => c.status != 'COMPLETED' && c.status != 'CANCELLED').length;
                  final totalBudget = state.campaigns.fold<double>(0, (sum, c) => sum + c.budgetMax);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Performance Overview', style: AppTextStyles.h4),
                      const SizedBox(height: 16),
                      _buildPerformanceCard('ACTIVE CAMPAIGNS', activeCampaigns.toString(), null, LucideIcons.megaphone, AppColors.roleRetailer),
                      const SizedBox(height: 12),
                      _buildPerformanceCard('TOTAL BUDGET DEPLOYED', '₹${totalBudget.toStringAsFixed(0)}', null, LucideIcons.wallet, AppColors.success500),
                      const SizedBox(height: 32),
                      Text('Your Campaigns', style: AppTextStyles.h4),
                      const SizedBox(height: 16),
                      if (state.campaigns.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text("No campaigns found. Create one above!"),
                        ))
                      else
                        ...state.campaigns.map((c) => Column(
                          children: [
                            _buildCampaignCard(context, c),
                            const SizedBox(height: 12),
                          ],
                        )),
                    ],
                  );
                } else if (state is RetailerCampaignError) {
                  return Center(child: Text("Error: ${state.message}"));
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(String title, String value, String? trend, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text(value, style: AppTextStyles.h1.copyWith(color: color)),
              if (trend != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.trendingUp, size: 14, color: AppColors.success500),
                    const SizedBox(width: 4),
                    Text(trend, style: AppTextStyles.caption.copyWith(color: AppColors.success500)),
                  ],
                ),
              ],
            ],
          ),
          Icon(icon, size: 48, color: AppColors.neutral200),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, InfluencerCampaignEntity campaign) {
    // Status badge config
    final statusColors = {
      'PUBLISHED': AppColors.roleRetailer,
      'ACTIVE': AppColors.roleRetailer,
      'DRAFT': AppColors.neutral500,
      'COMPLETED': AppColors.success500,
      'CANCELLED': AppColors.error500,
      'CREATOR_SELECTED': AppColors.info500,
    };
    final statusColor = statusColors[campaign.status] ?? AppColors.neutral500;
    final statusLabel = campaign.status == 'PUBLISHED' ? 'Active' : campaign.status.replaceAll('_', ' ');

    return GestureDetector(
      onTap: () => context.push('/retailer/campaigns/${campaign.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral200),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row + status + edit/delete
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    campaign.title,
                    style: AppTextStyles.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _showEditCampaignSheet(context, campaign),
                      child: const Icon(LucideIcons.pencil, size: 16, color: AppColors.neutral500),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _showDeleteConfirmation(context, campaign.id),
                      child: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error500),
                    ),
                  ],
                ),
              ],
            ),

            // Product info row
            if (campaign.productName != null || campaign.productImageUrl != null) ...
            [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AppNetworkImage(
                        url: campaign.productImageUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        placeholderIcon: LucideIcons.package,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured Product',
                            style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                          ),
                          Text(
                            campaign.productName ?? 'Unnamed Product',
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            // Campaign stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCampaignStat('Platform', campaign.platforms.isNotEmpty ? campaign.platforms.first : 'Web'),
                Container(width: 1, height: 30, color: AppColors.neutral200),
                _buildCampaignStat('Budget', '₹${campaign.budgetMax.toStringAsFixed(0)}'),
                Container(width: 1, height: 30, color: AppColors.neutral200),
                _buildCampaignStat('Creators', campaign.creatorCount.toString()),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1, color: AppColors.neutral100),
            ),

            // Bottom actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/retailer/campaigns/${campaign.id}'),
                    icon: const Icon(LucideIcons.eye, size: 14),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.roleRetailer,
                      side: BorderSide(color: AppColors.roleRetailer.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.push('/retailer/campaigns/${campaign.id}/bids');
                      if (mounted) _refresh();
                    },
                    icon: const Icon(LucideIcons.users, size: 14),
                    label: const Text('Review Bids'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roleRetailer,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignStat(String label, String value) {
    return Flexible(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h4,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String campaignId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: const Text('Are you sure you want to delete this campaign? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<RetailerCampaignBloc>().add(DeleteCampaignRequested(campaignId));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error500)),
          ),
        ],
      ),
    );
  }

  void _showEditCampaignSheet(BuildContext context, InfluencerCampaignEntity campaign) {
    final titleController = TextEditingController(text: campaign.title);
    final descController = TextEditingController(text: campaign.description);
    final budgetController = TextEditingController(text: campaign.budgetMax.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Campaign', style: AppTextStyles.h2),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Campaign Title',
                hintText: 'Enter title',
                controller: titleController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                hintText: 'Enter description',
                controller: descController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Max Budget (₹)',
                hintText: 'Enter budget',
                controller: budgetController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Save Changes',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx);
                      context.read<RetailerCampaignBloc>().add(UpdateCampaignRequested(
                        campaignId: campaign.id,
                        data: {
                          'title': titleController.text.trim(),
                          'description': descController.text.trim(),
                          'budgetMax': double.tryParse(budgetController.text.trim()) ?? 0,
                          'budgetMin': 0,
                        },
                      ));
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
