import '../../../../core/widgets/logout_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/dependency_injection/injection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  final List<_PortfolioItem> _portfolio = [
    _PortfolioItem('ElectroHub Summer Campaign', '2.4M views',
        'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=300&auto=format&fit=crop'),
    _PortfolioItem('Fashion Week Collab', '1.8M views',
        'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=300&auto=format&fit=crop'),
    _PortfolioItem('Organic Living Series', '980K views',
        'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=300&auto=format&fit=crop'),
    _PortfolioItem('Bakery Stories', '640K views',
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=300&auto=format&fit=crop'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animController.forward();
    context.read<InfluencerBloc>().add(const GetInfluencerProfileRequested());
    context.read<InfluencerBloc>().add(const GetMyBidsRequested());
  }

  @override
  void dispose() {
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
          slivers: [
            // Gradient profile header
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: const Color(0xFF1E40AF),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E40AF), Color(0xFF7C3AED)],
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
                          color: Colors.white.withValues(alpha: 0.06),
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
                          color: Colors.white.withValues(alpha: 0.04),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BlocBuilder<InfluencerBloc, InfluencerState>(
                            builder: (context, state) {
                              final profile = state is InfluencerLoaded
                                  ? state.profile
                                  : null;
                              final avatarUrl = profile?.profileImage;
                              final isApproved =
                                  profile?.verificationStatus == 'APPROVED';
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
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.secondary400,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(LucideIcons.badgeCheck,
                                          color: Colors.white, size: 14),
                                    ),
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
                                .copyWith(color: AppColors.white),
                          ),
                          Text(
                            context.select<InfluencerBloc, String>(
                              (b) => b.state is InfluencerLoaded
                                  ? '@${(b.state as InfluencerLoaded).profile?.username ?? 'creator'} · ${((b.state as InfluencerLoaded).profile?.categories ?? []).take(2).join(" & ")}'
                                  : '@creator',
                            ),
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder<InfluencerBloc, InfluencerState>(
                            builder: (context, state) {
                              final profile = state is InfluencerLoaded
                                  ? state.profile
                                  : null;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _StatPill(
                                    label: profile == null
                                        ? '—'
                                        : profile.followers >= 1000
                                            ? '${(profile.followers / 1000).toStringAsFixed(0)}K'
                                            : '${profile.followers}',
                                    sublabel: 'Followers',
                                  ),
                                  _StatPill(
                                      label:
                                          '${profile?.completedCampaigns ?? 0}',
                                      sublabel: 'Campaigns'),
                                  _StatPill(
                                      label:
                                          '${profile?.rating.toStringAsFixed(1) ?? '—'}★',
                                      sublabel: 'Rating'),
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
                  icon: const Icon(LucideIcons.edit2, color: Colors.white),
                  onPressed: () {
                    final currentState = context.read<InfluencerBloc>().state;
                    if (currentState is InfluencerLoaded &&
                        currentState.profile != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<InfluencerBloc>(),
                          child: EditInfluencerProfileBottomSheet(
                              profile: currentState.profile!),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Edit bio feature coming soon!'),
                                      backgroundColor: AppColors.roleInfluencer,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  );
                                },
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
                                        if (profile.instagramUrl != null &&
                                            profile.instagramUrl!.isNotEmpty)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 12),
                                            child: Icon(Icons.camera_alt,
                                                color: AppColors.roleInfluencer,
                                                size: 20),
                                          ),
                                        if (profile.facebookUrl != null &&
                                            profile.facebookUrl!.isNotEmpty)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 12),
                                            child: Icon(Icons.facebook,
                                                color: AppColors.roleInfluencer,
                                                size: 20),
                                          ),
                                        if (profile.youtubeUrl != null &&
                                            profile.youtubeUrl!.isNotEmpty)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 12),
                                            child: Icon(Icons.video_library,
                                                color: AppColors.roleInfluencer,
                                                size: 20),
                                          ),
                                      ],
                                    ),
                                  ]
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'Fashion',
                              'Streetwear',
                              'Lifestyle',
                              'Local Brands'
                            ]
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'More portfolio items coming soon!'),
                                backgroundColor: AppColors.roleInfluencer,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: Text('See All',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.roleInfluencer)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _portfolio.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 300 + index * 80),
                          curve: Curves.easeOut,
                          builder: (ctx, val, child) => Opacity(
                            opacity: val,
                            child: Transform.scale(
                                scale: 0.9 + 0.1 * val, child: child),
                          ),
                          child: _PortfolioCard(item: _portfolio[index]),
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
                          _ActionRow(LucideIcons.fileText, 'Download Media Kit',
                              () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Generating Media Kit...'),
                                  backgroundColor: AppColors.roleInfluencer),
                            );
                            Future.delayed(const Duration(seconds: 2), () {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Media Kit downloaded successfully!'),
                                    backgroundColor: AppColors.success500),
                              );
                            });
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
          Text(label,
              style: AppTextStyles.h4
                  .copyWith(color: AppColors.white, fontSize: 16)),
          Text(sublabel,
              style: AppTextStyles.caption.copyWith(color: Colors.white60)),
        ],
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
          Image.network(item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
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
  const EditInfluencerProfileBottomSheet({super.key, required this.profile});

  @override
  State<EditInfluencerProfileBottomSheet> createState() =>
      _EditInfluencerProfileBottomSheetState();
}

class _EditInfluencerProfileBottomSheetState
    extends State<EditInfluencerProfileBottomSheet> {
  late TextEditingController _bioController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _nameController =
        TextEditingController(text: widget.profile.displayName ?? '');
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final data = {
      'bio': _bioController.text,
      'displayName': _nameController.text,
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
                content: Text('Profile updated!'),
                backgroundColor: AppColors.success500),
          );
        } else if (state is InfluencerLoaded && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(state.failure?.message ?? 'Failed to update profile'),
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
                  Text('Edit Profile', style: AppTextStyles.h3),
                  IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _nameController,
                label: 'Display Name',
                hintText: 'Your name',
              ),
              const SizedBox(height: 16),
              Text('Bio',
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell brands about yourself...',
                  filled: true,
                  fillColor: AppColors.neutral50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
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
                        : const Text('Save Changes',
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

  void _save() {
    final data = <String, dynamic>{};
    if (_instagramController.text.isNotEmpty)
      data['instagramUrl'] = _instagramController.text;
    if (_facebookController.text.isNotEmpty)
      data['facebookUrl'] = _facebookController.text;
    if (_youtubeController.text.isNotEmpty)
      data['youtubeUrl'] = _youtubeController.text;

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
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(LucideIcons.eyeOff, color: AppColors.neutral700),
            title: Text('Private Profile',
                style:
                    AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('Only approved brands can see your details',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.neutral500)),
            trailing: Switch(
              value: false,
              activeColor: AppColors.roleInfluencer,
              onChanged: (val) {},
            ),
          ),
          const SizedBox(height: 40),
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
            onTap: () {},
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
            onTap: () {},
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
