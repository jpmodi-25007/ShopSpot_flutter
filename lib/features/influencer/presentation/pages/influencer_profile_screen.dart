import '../../../../core/widgets/logout_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/network/api_client.dart';
import 'package:image_picker/image_picker.dart';

class InfluencerProfileScreen extends StatefulWidget {
  const InfluencerProfileScreen({super.key});

  @override
  State<InfluencerProfileScreen> createState() =>
      _InfluencerProfileScreenState();
}

class _InfluencerProfileScreenState extends State<InfluencerProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isAvailable = true;
  late AnimationController _animController;
  bool _isUploadingAvatar = false;
  final CloudinaryService _cloudinary = getIt<CloudinaryService>();
  final ImagePicker _picker = ImagePicker();

  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;
  List<String> _categoryOptions = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animController.forward();
    
    _scrollController.addListener(() {
      final isCollapsed = _scrollController.offset > 120;
      if (isCollapsed != _isHeaderCollapsed) {
        setState(() => _isHeaderCollapsed = isCollapsed);
      }
    });

    context.read<InfluencerBloc>().add(const GetInfluencerProfileRequested());
    context.read<InfluencerBloc>().add(const GetMyBidsRequested());
    context.read<InfluencerBloc>().add(const GetInfluencerAnalyticsRequested());
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await getIt<ApiClient>().get('/categories');
      final raw = response.data;
      final names = raw is List
          ? raw.whereType<Map>().map((item) => item['name']?.toString() ?? '').where((name) => name.isNotEmpty).toList()
          : <String>[];
      if (!mounted) return;
      setState(() => _categoryOptions = names);
    } catch (_) {}
  }

  bool _isGeneratedUsername(String? username) {
    if (username == null || username.isEmpty) return true;
    return RegExp(r'^user_[a-z0-9]+_\d+$').hasMatch(username);
  }

  String _subtitle(dynamic profile) {
    if (profile == null) return 'Loading profile...';
    final parts = <String>[];
    if (!_isGeneratedUsername(profile.username)) parts.add('@${profile.username}');
    if ((profile.city ?? '').toString().isNotEmpty) parts.add(profile.city as String);
    final categories = (profile.categories as List?)?.take(2).join(' · ') ?? '';
    if (categories.isNotEmpty) parts.add(categories);
    if (parts.isEmpty) return 'Add a username, city, and categories';
    return parts.join('   ·   ');
  }

  void _openEditor() {
    final currentState = context.read<InfluencerBloc>().state;
    if (currentState is! InfluencerLoaded || currentState.profile == null) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => BlocProvider.value(
          value: context.read<InfluencerBloc>(),
          child: EditInfluencerProfileBottomSheet(
            profile: currentState.profile!,
            categories: _categoryOptions,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final result = await _cloudinary.uploadImage(
        imageFile: image,
        folder: 'influencer/avatars',
      );
      if (mounted) {
        context.read<InfluencerBloc>().add(
          UpdateInfluencerProfileRequested({'profileImage': result.secureUrl}),
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile photo updated!'),
          backgroundColor: AppColors.roleInfluencer,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to upload image. Please try again.'),
          backgroundColor: AppColors.error500,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (state is InfluencerLoaded && state.profile != null) {
          setState(() {
            _isAvailable = state.profile!.isActive;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Gradient profile header
            SliverAppBar(
              expandedHeight: 253,
              pinned: true,
              title: _isHeaderCollapsed ? BlocBuilder<InfluencerBloc, InfluencerState>(
                builder: (context, state) {
                  final profile = state is InfluencerLoaded ? state.profile : null;
                  return Text(
                    profile?.displayName ?? 'Creator',
                    style: AppTextStyles.h3.copyWith(color: AppColors.neutral900),
                  );
                },
              ) : null,
              backgroundColor: const Color(0xFFFFF7ED),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFFBF5), Color(0xFFFFF1D6), Color(0xFFFDE68A)],
                        ),
                      ),
                    ),
                    // Decorative circles
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -40,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 77, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BlocBuilder<InfluencerBloc, InfluencerState>(
                            builder: (context, state) {
                              final profile = state is InfluencerLoaded
                                  ? state.profile
                                  : null;
                              final avatarUrl = profile?.profileImage;
                              final isApproved =
                                  profile?.verificationStatus == 'VERIFIED';
                              return Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  GestureDetector(
                                    onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        Container(
                                          width: 76,
                                          height: 76,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppColors.white, width: 3),
                                            boxShadow: [
                                              BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
                                            ],
                                          ),
                                          child: _isUploadingAvatar
                                              ? const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.roleInfluencer)
                                              : AppNetworkImage(
                                                  url: avatarUrl,
                                                  width: 76,
                                                  height: 76,
                                                  fit: BoxFit.cover,
                                                  borderRadius: BorderRadius.circular(38),
                                                  placeholderIcon: LucideIcons.user,
                                                ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.roleInfluencer,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                          child: const Icon(LucideIcons.camera,
                                              color: Colors.white, size: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isApproved)
                                    const SizedBox.shrink(),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.select<InfluencerBloc, String>(
                              (b) => b.state is InfluencerLoaded
                                  ? (b.state as InfluencerLoaded)
                                          .profile
                                          ?.displayName ??
                                      'Creator'
                                  : 'Creator',
                            ),
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.neutral900),
                          ),
                          BlocBuilder<InfluencerBloc, InfluencerState>(
                            builder: (context, state) {
                              final profile = state is InfluencerLoaded ? state.profile : null;
                              final verified = profile?.verificationStatus == 'VERIFIED';
                              return Column(
                                children: [
                                  Text(
                                    _subtitle(profile),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
                                  ),
                                  if (verified) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.badgeCheck, color: AppColors.roleInfluencer, size: 14),
                                          const SizedBox(width: 4),
                                          Text('Verified creator', style: AppTextStyles.caption.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.edit2, color: AppColors.neutral800),
                  onPressed: _openEditor,
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: BlocBuilder<InfluencerBloc, InfluencerState>(
                        builder: (context, state) {
                          final profile = state is InfluencerLoaded ? state.profile : null;
                          final bids = state is InfluencerLoaded ? (state.bids?.length ?? 0) : 0;
                          final followers = profile?.followers ?? 0;
                          final followerLabel = followers >= 1000 ? '${(followers / 1000).toStringAsFixed(1)}K' : '$followers';
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF92400E).withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 10)),
                              ],
                            ),
                            child: Row(
                              children: [
                                _StatPill(label: followerLabel, sublabel: 'Followers'),
                                Container(width: 1, height: 36, color: AppColors.neutral200),
                                _StatPill(label: '$bids', sublabel: 'Bids'),
                                Container(width: 1, height: 36, color: AppColors.neutral200),
                                _StatPill(label: (profile?.rating ?? 0).toStringAsFixed(1), sublabel: 'Rating'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Availability Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neutral900.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _isAvailable
                                  ? AppColors.success100
                                  : AppColors.neutral100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              LucideIcons.briefcase,
                              color: _isAvailable
                                  ? AppColors.success500
                                  : AppColors.neutral400,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Open for Campaigns',
                                    style: AppTextStyles.body
                                        .copyWith(fontWeight: FontWeight.w600)),
                                Text(
                                  _isAvailable
                                      ? 'Brands can discover and contact you'
                                      : 'Hidden from brand discovery',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.neutral500),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isAvailable,
                            onChanged: (val) {
                              setState(() => _isAvailable = val);
                              context.read<InfluencerBloc>().add(
                                    UpdateInfluencerProfileRequested(
                                        {'isActive': val}),
                                  );
                            },
                            activeTrackColor: AppColors.success500,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bio
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neutral900.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bio',
                                  style:
                                      AppTextStyles.h4.copyWith(fontSize: 16)),
                              TextButton.icon(
                                icon: const Icon(LucideIcons.edit2, size: 14),
                                label: const Text('Edit'),
                                onPressed: _openEditor,
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.roleInfluencer),
                              ),
                            ],
                          ),
                          BlocBuilder<InfluencerBloc, InfluencerState>(
                            builder: (context, state) {
                              final profile = state is InfluencerLoaded
                                  ? state.profile
                                  : null;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile?.bio ?? 'No bio provided.',
                                    style: AppTextStyles.body.copyWith(
                                        color: AppColors.neutral600,
                                        height: 1.6),
                                  ),
                                  if (profile != null &&
                                      (profile.instagramUrl != null ||
                                          profile.facebookUrl != null ||
                                          profile.youtubeUrl != null)) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if ((profile.instagramUrl ?? '').isNotEmpty)
                                          _SocialButton(icon: Icons.camera_alt, url: profile.instagramUrl!),
                                        if ((profile.facebookUrl ?? '').isNotEmpty)
                                          _SocialButton(icon: Icons.facebook, url: profile.facebookUrl!),
                                        if ((profile.youtubeUrl ?? '').isNotEmpty)
                                          _SocialButton(icon: Icons.smart_display, url: profile.youtubeUrl!),
                                      ],
                                    ),
                                  ]
                                ],
                              );
                            },
                          ),
                          BlocBuilder<InfluencerBloc, InfluencerState>(
                            builder: (context, catState) {
                              final profile = catState is InfluencerLoaded ? catState.profile : null;
                              final categories = profile?.categories ?? [];
                              if (categories.isEmpty) return const SizedBox.shrink();
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: categories
                                    .map((t) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: AppColors.roleInfluencerLight,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(t,
                                              style: AppTextStyles.caption.copyWith(
                                                  color: AppColors.roleInfluencer,
                                                  fontWeight: FontWeight.w600)),
                                        ))
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Portfolio Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Portfolio', style: AppTextStyles.h4),
                        TextButton(
                          onPressed: () {
                            context.push('/influencer/all-bids');
                          },
                          child: Text('See All',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.roleInfluencer)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<InfluencerBloc, InfluencerState>(
                      builder: (context, state) {
                        final bids = state is InfluencerLoaded ? (state.bids ?? []) : [];
                        final completedBids = bids.where((b) => b.status == 'ACCEPTED' || b.status == 'COMPLETED').toList();
                        
                        if (completedBids.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.neutral200),
                            ),
                            child: Column(
                              children: [
                                const Icon(LucideIcons.image, size: 32, color: AppColors.neutral400),
                                const SizedBox(height: 12),
                                Text('No portfolio items yet',
                                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Complete campaigns to build your portfolio.',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          );
                        }
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: completedBids.length,
                          itemBuilder: (context, index) {
                            final bid = completedBids[index];
                            final imageUrl = bid.productImageUrl ?? '';
                            
                            final item = _PortfolioItem(
                              bid.campaignTitle ?? 'Campaign', 
                              'Completed', 
                              imageUrl,
                            );

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(milliseconds: 300 + index * 80),
                              curve: Curves.easeOut,
                              builder: (ctx, val, child) => Opacity(
                                opacity: val,
                                child: Transform.scale(scale: 0.9 + 0.1 * val, child: child),
                              ),
                              child: _PortfolioCard(item: item),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Account Actions
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neutral900.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _ActionRow(
                              LucideIcons.link2, 'Linked Social Accounts', () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => BlocProvider.value(
                                value: context.read<InfluencerBloc>(),
                                child: const LinkedSocialAccountsBottomSheet(),
                              ),
                            );
                          }),
                          const Divider(height: 1),
                          _ActionRow(LucideIcons.fileText, 'Share Media Kit',
                              () {
                            final current = context.read<InfluencerBloc>().state;
                            final profile = current is InfluencerLoaded ? current.profile : null;
                            final lines = <String>[
                              profile?.displayName ?? 'Creator',
                              if ((profile?.username ?? '').isNotEmpty) '@${profile!.username}',
                              if ((profile?.bio ?? '').isNotEmpty) profile!.bio!,
                              if ((profile?.city ?? '').isNotEmpty) profile!.city!,
                              if ((profile?.instagramUrl ?? '').isNotEmpty) 'Instagram: ${profile!.instagramUrl}',
                              if ((profile?.facebookUrl ?? '').isNotEmpty) 'Facebook: ${profile!.facebookUrl}',
                              if ((profile?.youtubeUrl ?? '').isNotEmpty) 'YouTube: ${profile!.youtubeUrl}',
                              'Followers: ${profile?.followers ?? 0}',
                            ];
                            SharePlus.instance.share(ShareParams(text: lines.join('\n')));
                          }),
                          const Divider(height: 1),
                          _ActionRow(
                              LucideIcons.shieldCheck, 'Privacy & Security',
                              () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) =>
                                  const PrivacyAndSecurityBottomSheet(),
                            );
                          }),
                          const Divider(height: 1),
                          _ActionRow(LucideIcons.helpCircle, 'Help & Support',
                              () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) =>
                                  const HelpAndSupportBottomSheet(),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () {
                        LogoutDialog.show(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.error100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.logOut,
                                color: AppColors.error500, size: 20),
                            const SizedBox(width: 8),
                            Text('Log Out',
                                style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error500)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
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

class _StatPill extends StatelessWidget {
  final String label;
  final String sublabel;
  const _StatPill({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.h3.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: 2),
          Text(sublabel, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String url;
  const _SocialButton({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        borderRadius: BorderRadius.circular(21),
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.roleInfluencerLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.roleInfluencer, size: 18),
        ),
      ),
    );
  }
}

class _PortfolioItem {
  final String title;
  final String views;
  final String imageUrl;
  const _PortfolioItem(this.title, this.views, this.imageUrl);
}

class _PortfolioCard extends StatelessWidget {
  final _PortfolioItem item;
  const _PortfolioCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
              url: item.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholderIcon: LucideIcons.image,
              errorWidget:
                  Container(color: AppColors.neutral200)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    const Icon(LucideIcons.eye,
                        color: Colors.white60, size: 12),
                    const SizedBox(width: 4),
                    Text(item.views,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionRow(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.roleInfluencer, size: 18),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w500))),
            const Icon(LucideIcons.chevronRight,
                color: AppColors.neutral400, size: 18),
          ],
        ),
      ),
    );
  }
}

class EditInfluencerProfileBottomSheet extends StatefulWidget {
  final dynamic profile;
  final List<String> categories;
  const EditInfluencerProfileBottomSheet({super.key, required this.profile, this.categories = const []});

  @override
  State<EditInfluencerProfileBottomSheet> createState() =>
      _EditInfluencerProfileBottomSheetState();
}

class _EditInfluencerProfileBottomSheetState
    extends State<EditInfluencerProfileBottomSheet> {
  late TextEditingController _bioController;
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _cityController;
  late TextEditingController _followersController;
  late Set<String> _selectedCategories;
  bool _awaitingSave = false;

  bool get _generatedUsername {
    final username = widget.profile.username?.toString() ?? '';
    return RegExp(r'^user_[a-z0-9]+_\d+$').hasMatch(username);
  }

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _nameController = TextEditingController(text: widget.profile.displayName ?? '');
    _usernameController = TextEditingController(text: _generatedUsername ? '' : (widget.profile.username ?? ''));
    _cityController = TextEditingController(text: widget.profile.city ?? '');
    _followersController = TextEditingController(text: '${widget.profile.followers ?? 0}');
    _selectedCategories = {...(widget.profile.categories as List? ?? const []).map((item) => item.toString())};
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _cityController.dispose();
    _followersController.dispose();
    super.dispose();
  }

  void _save() {
    final username = _usernameController.text.trim().toLowerCase().replaceAll(' ', '');
    if (username.isNotEmpty && !RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username needs 3-30 letters, numbers, or underscores.')));
      return;
    }
    final data = <String, dynamic>{
      'bio': _bioController.text.trim(),
      'displayName': _nameController.text.trim(),
      'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      'followers': int.tryParse(_followersController.text.trim()) ?? 0,
      'categories': _selectedCategories.toList(),
      if (username.isNotEmpty) 'username': username,
    };
    setState(() => _awaitingSave = true);
    context.read<InfluencerBloc>().add(UpdateInfluencerProfileRequested(data));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return BlocListener<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (!_awaitingSave || state is! InfluencerLoaded || state.isLoading) return;
        setState(() => _awaitingSave = false);
        if (state.isSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile updated'),
                backgroundColor: AppColors.success500),
          );
        } else if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.failure?.message ?? 'Failed to update profile'),
                backgroundColor: AppColors.error500),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBF5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFBF5),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(LucideIcons.x, color: AppColors.neutral900),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Edit Profile', style: AppTextStyles.h3),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Display Name',
              hintText: 'Your name',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _usernameController,
              label: 'Username',
              hintText: 'jaymodi',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _cityController,
              label: 'City',
              hintText: 'Mumbai',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _followersController,
              label: 'Followers',
              hintText: '0',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text('Categories', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.categories.map((name) {
                final selected = _selectedCategories.contains(name);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedCategories.remove(name);
                      } else {
                        _selectedCategories.add(name);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.roleInfluencer : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.roleInfluencer : AppColors.neutral300),
                    ),
                    child: Text(
                      name,
                      style: AppTextStyles.caption.copyWith(
                        color: selected ? AppColors.white : AppColors.neutral800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Bio', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tell brands about yourself...',
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neutral300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neutral300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.roleInfluencer, width: 2),
                ),
              ),
            ),
            SizedBox(height: bottomInset),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset > 0 ? bottomInset : 12),
            child: BlocBuilder<InfluencerBloc, InfluencerState>(
              builder: (context, state) {
                final isLoading = _awaitingSave && state is InfluencerLoaded && state.isLoading;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roleInfluencer,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isLoading ? null : _save,
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class LinkedSocialAccountsBottomSheet extends StatefulWidget {
  const LinkedSocialAccountsBottomSheet({super.key});

  @override
  State<LinkedSocialAccountsBottomSheet> createState() =>
      _LinkedSocialAccountsBottomSheetState();
}

class _LinkedSocialAccountsBottomSheetState
    extends State<LinkedSocialAccountsBottomSheet> {
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _youtubeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<InfluencerBloc>().state;
    if (state is InfluencerLoaded && state.profile != null) {
      _instagramController.text = state.profile!.instagramUrl ?? '';
      _facebookController.text = state.profile!.facebookUrl ?? '';
      _youtubeController.text = state.profile!.youtubeUrl ?? '';
    }
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _facebookController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  String? _socialUrl(String raw, String host) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    if (text.startsWith('http://') || text.startsWith('https://')) return text;
    final handle = text.startsWith('@') ? text.substring(1) : text;
    if (handle.contains('.')) return 'https://$handle';
    return 'https://$host/$handle';
  }

  void _save() {
    final data = <String, dynamic>{
      'instagramUrl': _socialUrl(_instagramController.text, 'instagram.com'),
      'facebookUrl': _socialUrl(_facebookController.text, 'facebook.com'),
      'youtubeUrl': _socialUrl(_youtubeController.text, 'youtube.com'),
    };

    context.read<InfluencerBloc>().add(UpdateInfluencerProfileRequested(data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (state is InfluencerLoaded && state.isSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Social links updated!'),
                backgroundColor: AppColors.success500),
          );
        } else if (state is InfluencerLoaded && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(state.failure?.message ?? 'Failed to update links'),
                backgroundColor: AppColors.error500),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Linked Social Accounts', style: AppTextStyles.h3),
                  IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _instagramController,
                label: 'Instagram URL',
                hintText: 'https://instagram.com/username',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _facebookController,
                label: 'Facebook URL',
                hintText: 'https://facebook.com/username',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _youtubeController,
                label: 'YouTube URL',
                hintText: 'https://youtube.com/channel',
              ),
              const SizedBox(height: 32),
              BlocBuilder<InfluencerBloc, InfluencerState>(
                builder: (context, state) {
                  final isLoading =
                      state is InfluencerLoaded && state.isLoading;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roleInfluencer,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : _save,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: AppColors.white, strokeWidth: 2))
                        : const Text('Save Links',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyAndSecurityBottomSheet extends StatelessWidget {
  const PrivacyAndSecurityBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Privacy & Security', style: AppTextStyles.h3),
              IconButton(
                icon: const Icon(LucideIcons.x, color: AppColors.neutral500),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.lock, color: AppColors.neutral700),
            title: Text('Change Password',
                style:
                    AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            trailing: const Icon(LucideIcons.chevronRight,
                color: AppColors.neutral400),
            onTap: () => context.push('/change-password'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class HelpAndSupportBottomSheet extends StatelessWidget {
  const HelpAndSupportBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Help & Support', style: AppTextStyles.h3),
              IconButton(
                icon: const Icon(LucideIcons.x, color: AppColors.neutral500),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.mail, color: AppColors.neutral700),
            title: Text('Contact Us',
                style:
                    AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('support@shopspot.com',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.neutral500)),
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'support@shopspot.com',
                queryParameters: {'subject': 'ShopSpot Influencer Support'},
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              }
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(LucideIcons.helpCircle, color: AppColors.neutral700),
            title: Text('FAQs',
                style:
                    AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            trailing: const Icon(LucideIcons.chevronRight,
                color: AppColors.neutral400),
            onTap: () => context.push('/faqs'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

}
