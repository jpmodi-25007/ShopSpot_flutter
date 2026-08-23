import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';

class InfluencerProfileScreen extends StatefulWidget {
  const InfluencerProfileScreen({super.key});

  @override
  State<InfluencerProfileScreen> createState() => _InfluencerProfileScreenState();
}

class _InfluencerProfileScreenState extends State<InfluencerProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isAvailable = true;
  late AnimationController _animController;

  final List<_PortfolioItem> _portfolio = [
    _PortfolioItem('ElectroHub Summer Campaign', '2.4M views', 'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=300&auto=format&fit=crop'),
    _PortfolioItem('Fashion Week Collab', '1.8M views', 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=300&auto=format&fit=crop'),
    _PortfolioItem('Organic Living Series', '980K views', 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=300&auto=format&fit=crop'),
    _PortfolioItem('Bakery Stories', '640K views', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=300&auto=format&fit=crop'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white, width: 3),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.secondary400,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.badgeCheck, color: Colors.white, size: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.select<InfluencerBloc, String>(
                            (b) => b.state is InfluencerLoaded ? (b.state as InfluencerLoaded).profile?.displayName ?? 'Creator' : 'Creator',
                          ),
                          style: AppTextStyles.h3.copyWith(color: AppColors.white),
                        ),
                        Text(
                          context.select<InfluencerBloc, String>(
                            (b) => b.state is InfluencerLoaded
                                ? '@${(b.state as InfluencerLoaded).profile?.username ?? 'creator'} · ${((b.state as InfluencerLoaded).profile?.categories ?? []).take(2).join(" & ")}'
                                : '@creator',
                          ),
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<InfluencerBloc, InfluencerState>(
                          builder: (context, state) {
                            final profile = state is InfluencerLoaded ? state.profile : null;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatPill(
                                  label: profile == null ? '—' : profile.followers >= 1000 ? '${(profile.followers / 1000).toStringAsFixed(0)}K' : '${profile.followers}',
                                  sublabel: 'Followers',
                                ),
                                _StatPill(label: '${profile?.completedCampaigns ?? 0}', sublabel: 'Campaigns'),
                                _StatPill(label: '${profile?.rating.toStringAsFixed(1) ?? '—'}★', sublabel: 'Rating'),
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
                onPressed: () {},
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
                            color: _isAvailable ? AppColors.success100 : AppColors.neutral100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.briefcase,
                            color: _isAvailable ? AppColors.success500 : AppColors.neutral400,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Open for Campaigns', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                              Text(
                                _isAvailable ? 'Brands can discover and contact you' : 'Hidden from brand discovery',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isAvailable,
                          onChanged: (val) => setState(() => _isAvailable = val),
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
                            Text('Bio', style: AppTextStyles.h4.copyWith(fontSize: 16)),
                            TextButton.icon(
                              icon: const Icon(LucideIcons.edit2, size: 14),
                              label: const Text('Edit'),
                              onPressed: () {},
                              style: TextButton.styleFrom(foregroundColor: AppColors.roleInfluencer),
                            ),
                          ],
                        ),
                        Text(
                          'Streetwear enthusiast & content creator based in Mumbai. I partner with local brands to bring authentic stories to my audience. 5 years creating content, 280K+ followers across platforms.',
                          style: AppTextStyles.body.copyWith(color: AppColors.neutral600, height: 1.6),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Fashion', 'Streetwear', 'Lifestyle', 'Local Brands']
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.roleInfluencerLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(t, style: AppTextStyles.caption.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w600)),
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
                        onPressed: () {},
                        child: Text('See All', style: AppTextStyles.bodySmall.copyWith(color: AppColors.roleInfluencer)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          child: Transform.scale(scale: 0.9 + 0.1 * val, child: child),
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
                        _ActionRow(LucideIcons.link2, 'Linked Social Accounts', () {}),
                        const Divider(height: 1),
                        _ActionRow(LucideIcons.fileText, 'Download Media Kit', () {}),
                        const Divider(height: 1),
                        _ActionRow(LucideIcons.shieldCheck, 'Privacy & Security', () {}),
                        const Divider(height: 1),
                        _ActionRow(LucideIcons.helpCircle, 'Help & Support', () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () async {
                      await getIt<LocalStorage>().clear();
                      if (context.mounted) context.go('/login');
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
                          const Icon(LucideIcons.logOut, color: AppColors.error500, size: 20),
                          const SizedBox(width: 8),
                          Text('Log Out', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.error500)),
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
          Text(label, style: AppTextStyles.h4.copyWith(color: AppColors.white, fontSize: 16)),
          Text(sublabel, style: AppTextStyles.caption.copyWith(color: Colors.white60)),
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
          Image.network(item.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: AppColors.neutral200)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
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
                Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    const Icon(LucideIcons.eye, color: Colors.white60, size: 12),
                    const SizedBox(width: 4),
                    Text(item.views, style: const TextStyle(color: Colors.white60, fontSize: 11)),
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
            Expanded(child: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500))),
            const Icon(LucideIcons.chevronRight, color: AppColors.neutral400, size: 18),
          ],
        ),
      ),
    );
  }
}


