import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import '../../../authentication/presentation/bloc/authentication_event.dart';
import '../../../authentication/presentation/bloc/authentication_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          context.go('/login');
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          if (authState is AuthenticationGuest || authState is AuthenticationUnauthenticated) {
            return _buildGuestProfile(context);
          }

          final user = authState is AuthenticationLoaded ? authState.user : null;
          return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        slivers: [
          // Gradient Profile Header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary500,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary500, AppColors.primary600],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: user?.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(user!.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(user?.name ?? 'Loading...', style: AppTextStyles.h3.copyWith(color: AppColors.white)),
                        Text(
                          user?.mobile ?? user?.email ?? '',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
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
                onPressed: () => context.push('/edit-profile'),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards (Removed temporarily until backend supports them)


                  // Quick Links
                  _buildSectionContainer(
                    children: [
                      _buildListTile(LucideIcons.shoppingBag, 'My Orders', badge: 'NEW', onTap: () => context.push('/my-orders')),
                      const Divider(height: 1),
                      _buildListTile(LucideIcons.calendarClock, 'My Reservations', badgeCount: 2, onTap: () => context.push('/reservations')),
                      const Divider(height: 1),
                      _buildListTile(LucideIcons.heart, 'Saved Products', onTap: () => context.push('/saved-products')),
                      const Divider(height: 1),
                      _buildListTile(LucideIcons.store, 'Saved Shops', onTap: () => context.push('/saved-shops')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Account Settings
                  Text('ACCOUNT SETTINGS', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildSectionContainer(
                    children: [
                      _buildListTile(LucideIcons.mapPin, 'Manage Addresses', onTap: () => context.push('/manage-addresses')),
                      const Divider(height: 1),
                      _buildListTile(LucideIcons.bellRing, 'Notification Preferences', onTap: () => context.push('/notifications')),
                      const Divider(height: 1),
                      _buildListTile(LucideIcons.globe, 'Language', trailingText: 'English'),
                      const Divider(height: 1),
                      _buildListTile(LucideIcons.helpCircle, 'Help & Support'),
                      const Divider(height: 1),
                      _buildListTile(LucideIcons.info, 'About Findivo'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  GestureDetector(
                    onTap: () {
                      context.read<AuthenticationBloc>().add(const LogoutRequested());
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
      ), // CustomScrollView
    ); // Scaffold
  }, // builder
), // BlocBuilder
); // BlocListener
}

  Widget _buildGuestProfile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: AppColors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.user, size: 60, color: AppColors.primary500),
              ),
              const SizedBox(height: 32),
              Text('Welcome to Findivo!', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              Text(
                'Log in to view your orders, manage saved products, and personalize your experience.',
                style: AppTextStyles.body.copyWith(color: AppColors.neutral500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Login or Register', style: AppTextStyles.body.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {String? badge, int? badgeCount, String? trailingText, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary500, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
            ),
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.warning500, borderRadius: BorderRadius.circular(6)),
                child: Text(badge, style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 10)),
              ),
            if (badgeCount != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primary500, shape: BoxShape.circle),
                child: Text(badgeCount.toString(), style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 10)),
              ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(trailingText, style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
              ),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }
}
