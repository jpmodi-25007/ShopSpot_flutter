import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/influencer_bid_entity.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';

class BidDetailScreen extends StatefulWidget {
  final InfluencerBidEntity bid;
  const BidDetailScreen({super.key, required this.bid});

  @override
  State<BidDetailScreen> createState() => _BidDetailScreenState();
}

class _BidDetailScreenState extends State<BidDetailScreen> {
  final _contentUrlController = TextEditingController();
  bool _isSubmitting = false;
  String? _assignmentId;

  @override
  void initState() {
    super.initState();
    // Fetch assignments to find matching one for this bid
    context.read<InfluencerBloc>().add(const GetMyAssignmentsRequested());
  }

  @override
  void dispose() {
    _contentUrlController.dispose();
    super.dispose();
  }

  String get _statusColor {
    switch (widget.bid.status) {
      case 'ACCEPTED': return 'accepted';
      case 'REJECTED': return 'rejected';
      case 'SHORTLISTED': return 'shortlisted';
      case 'COUNTERED': return 'countered';
      default: return 'pending';
    }
  }

  Color get _statusBgColor {
    switch (widget.bid.status) {
      case 'ACCEPTED': return AppColors.success100;
      case 'REJECTED': return AppColors.error50;
      case 'SHORTLISTED': return const Color(0xFFEEF2FF);
      case 'COUNTERED': return AppColors.warning50;
      default: return AppColors.neutral100;
    }
  }

  Color get _statusTextColor {
    switch (widget.bid.status) {
      case 'ACCEPTED': return AppColors.success600;
      case 'REJECTED': return AppColors.error500;
      case 'SHORTLISTED': return const Color(0xFF4F46E5);
      case 'COUNTERED': return AppColors.warning600;
      default: return AppColors.neutral600;
    }
  }

  IconData get _statusIcon {
    switch (widget.bid.status) {
      case 'ACCEPTED': return LucideIcons.checkCircle2;
      case 'REJECTED': return LucideIcons.xCircle;
      case 'SHORTLISTED': return LucideIcons.star;
      case 'COUNTERED': return LucideIcons.arrowLeftRight;
      default: return LucideIcons.clock;
    }
  }

  void _showSubmitWorkSheet(String assignmentId, {String? initialUrl}) {
    _contentUrlController.text = initialUrl ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocListener<InfluencerBloc, InfluencerState>(
        listener: (context, state) {
          if (state is InfluencerLoaded && !state.isLoading && state.isSuccess) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(children: [
                  Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Work submitted! Shopkeeper has been notified.'),
                ]),
                backgroundColor: AppColors.success500,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is InfluencerLoaded && state.failure != null) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure!.message), backgroundColor: AppColors.error500),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.roleInfluencerLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.upload, color: AppColors.roleInfluencer, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Submit Your Work', style: AppTextStyles.h4),
                        Text('Paste your content URL below', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: TextField(
                    controller: _contentUrlController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      hintText: 'https://instagram.com/p/... or YouTube link',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                      prefixIcon: const Icon(LucideIcons.link, color: AppColors.neutral400, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.info, size: 16, color: AppColors.success600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'After submission, the shopkeeper will review your content and release payment.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.success600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<InfluencerBloc, InfluencerState>(
                  builder: (context, state) {
                    final loading = state is InfluencerLoaded && state.isLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : () {
                          final url = _contentUrlController.text.trim();
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your content URL')),
                            );
                            return;
                          }
                          context.read<InfluencerBloc>().add(SubmitDeliverableRequested(
                            assignmentId: assignmentId,
                            contentUrl: url,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.roleInfluencer,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Submit Work', style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bid = widget.bid;
    final deadlineText = '${bid.deliveryDate.day}/${bid.deliveryDate.month}/${bid.deliveryDate.year}';
    final availableText = '${bid.availableDate.day}/${bid.availableDate.month}/${bid.availableDate.year}';

    return BlocListener<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (state is InfluencerLoaded && state.assignments != null) {
          // Find assignment matching this bid's campaign safely
          try {
            final assignment = state.assignments!.firstWhere(
              (a) => a['campaignId'] == bid.campaignId || a['bidId'] == bid.id,
            );
            if (assignment['id'] != null) {
              setState(() => _assignmentId = assignment['id']);
            }
          } catch (_) {
            // No matching assignment found yet
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.neutral100, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
              title: Text('Bid Details', style: AppTextStyles.h4),
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── STATUS BANNER ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: _statusBgColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _statusTextColor.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(_statusIcon, color: _statusTextColor, size: 26),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bid.status,
                                  style: AppTextStyles.h4.copyWith(color: _statusTextColor),
                                ),
                                Text(
                                  bid.status == 'ACCEPTED'
                                      ? 'Congratulations! Your bid was accepted.'
                                      : bid.status == 'REJECTED'
                                          ? 'Your bid was not selected this time.'
                                          : bid.status == 'COUNTERED'
                                              ? 'The shopkeeper made a counter offer.'
                                              : bid.status == 'SHORTLISTED'
                                                  ? 'You\'ve been shortlisted! Awaiting final decision.'
                                                  : 'Your bid is under review.',
                                  style: AppTextStyles.caption.copyWith(color: _statusTextColor.withValues(alpha: 0.8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── CAMPAIGN INFO ──────────────────────────────────
                    _SectionCard(
                      title: 'Campaign',
                      icon: LucideIcons.megaphone,
                      children: [
                        _InfoRow(label: 'Campaign', value: bid.campaignTitle ?? 'Campaign #${bid.campaignId.substring(0, 8)}'),
                        if (bid.productName != null) _InfoRow(label: 'Product', value: bid.productName!),
                        _InfoRow(label: 'Campaign ID', value: bid.campaignId, monospace: true),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── SHOP / SHOPKEEPER ──────────────────────────────
                    _SectionCard(
                      title: 'Shop Details',
                      icon: LucideIcons.store,
                      children: [
                        Row(
                          children: [
                            if (bid.shopLogoUrl != null)
                              Container(
                                width: 48,
                                height: 48,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.neutral200),
                                  image: DecorationImage(
                                    image: NetworkImage(bid.shopLogoUrl!),
                                    fit: BoxFit.cover,
                                    onError: (e, s) {},
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bid.shopName ?? 'Shop',
                                    style: AppTextStyles.h4,
                                  ),
                                  if (bid.shopAddress != null)
                                    Text(
                                      bid.shopAddress!,
                                      style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (bid.shopEmail != null || bid.shopPhone != null) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.neutral100),
                          const SizedBox(height: 12),
                        ],
                        if (bid.shopEmail != null)
                          _ContactRow(
                            icon: LucideIcons.mail,
                            label: 'Email',
                            value: bid.shopEmail!,
                            onTap: () => launchUrl(Uri.parse('mailto:${bid.shopEmail}')),
                          ),
                        if (bid.shopPhone != null)
                          _ContactRow(
                            icon: LucideIcons.phone,
                            label: 'Phone',
                            value: bid.shopPhone!,
                            onTap: () => launchUrl(Uri.parse('tel:${bid.shopPhone}')),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── YOUR BID ───────────────────────────────────────
                    _SectionCard(
                      title: 'Your Bid',
                      icon: LucideIcons.indianRupee,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _StatBox(label: 'Bid Amount', value: '₹${bid.proposedAmount.toStringAsFixed(0)}', highlight: true)),
                            const SizedBox(width: 12),
                            Expanded(child: _StatBox(label: 'Available From', value: availableText)),
                            const SizedBox(width: 12),
                            Expanded(child: _StatBox(label: 'Deliver By', value: deadlineText)),
                          ],
                        ),
                        if (bid.proposal != null && bid.proposal!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: AppColors.neutral100),
                          const SizedBox(height: 12),
                          Text('Proposal', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(bid.proposal!, style: AppTextStyles.body.copyWith(color: AppColors.neutral700, height: 1.5)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── SUBMITTED CONTENT ──────────────────────────────
                    if (bid.submittedContentUrl != null) ...[
                      _SectionCard(
                        title: 'Submitted Content',
                        icon: LucideIcons.externalLink,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.success500.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.checkCircle2, color: AppColors.success500, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(bid.submittedContentUrl!,
                                    style: AppTextStyles.caption.copyWith(color: AppColors.success600),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.copy, size: 16, color: AppColors.success600),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: bid.submittedContentUrl!));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── ACTION BUTTONS ─────────────────────────────────
                    if (bid.status == 'ACCEPTED') ...[
                      BlocBuilder<InfluencerBloc, InfluencerState>(
                        builder: (context, state) {
                          // Re-check assignmentId from state
                          String? effectiveAssignmentId = _assignmentId;
                          String? currentSubmittedUrl = bid.submittedContentUrl;
                          if (state is InfluencerLoaded && state.assignments != null) {
                            try {
                              final a = state.assignments!.firstWhere(
                                (a) => a['campaignId'] == bid.campaignId || a['bidId'] == bid.id,
                              );
                              effectiveAssignmentId = a['id'];
                              if (a['submittedContentUrl'] != null) {
                                currentSubmittedUrl = a['submittedContentUrl'];
                              }
                            } catch (_) {
                              // Assignment not found
                            }
                          }
                          final alreadySubmitted = currentSubmittedUrl != null && currentSubmittedUrl.isNotEmpty;
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: effectiveAssignmentId == null
                                  ? null
                                  : () => _showSubmitWorkSheet(effectiveAssignmentId!, initialUrl: currentSubmittedUrl),
                              icon: Icon(alreadySubmitted ? LucideIcons.edit3 : LucideIcons.upload, size: 18),
                              label: Text(
                                alreadySubmitted ? 'Edit Submitted Work' : effectiveAssignmentId == null ? 'Loading Assignment...' : 'Submit Work',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: alreadySubmitted ? AppColors.neutral200 : AppColors.roleInfluencer,
                                foregroundColor: alreadySubmitted ? AppColors.neutral700 : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (bid.status != 'ACCEPTED' && bid.status != 'REJECTED')
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Withdraw Bid'),
                                content: const Text('Are you sure you want to withdraw this bid?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.read<InfluencerBloc>().add(WithdrawBidRequested(bid.id));
                                      context.pop();
                                    },
                                    child: const Text('Withdraw', style: TextStyle(color: AppColors.error500)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.trash2, size: 16),
                          label: const Text('Withdraw Bid', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error500,
                            side: const BorderSide(color: AppColors.error500),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.roleInfluencer),
              const SizedBox(width: 6),
              Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  const _InfoRow({required this.label, required this.value, this.monospace = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
          ),
          Expanded(
            child: Text(
              value,
              style: monospace
                  ? AppTextStyles.caption.copyWith(fontFamily: 'monospace', color: AppColors.neutral700)
                  : AppTextStyles.bodySmall.copyWith(color: AppColors.neutral800, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _ContactRow({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.roleInfluencerLight, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 14, color: AppColors.roleInfluencer),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
                Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            const Icon(LucideIcons.externalLink, size: 14, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _StatBox({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: highlight ? AppColors.roleInfluencerLight : AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w800,
                  color: highlight ? AppColors.roleInfluencer : AppColors.neutral900)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }
}
