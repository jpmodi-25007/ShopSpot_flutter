import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'dart:ui';
import 'responsive_container.dart';

class WebNavbar extends StatelessWidget implements PreferredSizeWidget {
  const WebNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.85),
            border: Border(bottom: BorderSide(color: AppColors.neutral200.withValues(alpha: 0.5))),
          ),
      child: ResponsiveContainer(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => context.go('/'),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.neutral900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.store, color: AppColors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Findivo',
                        style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation Links (Desktop)
              if (!isMobile) ...[
                Row(
                  children: [
                    _NavLink(title: 'Features', route: '/features'),
                    _NavLink(title: 'How It Works', route: '/how-it-works'),
                    _NavLink(title: 'About', route: '/about'),
                    _NavLink(title: 'FAQ', route: '/faq'),
                    _NavLink(title: 'Contact', route: '/contact'),
                  ],
                ),

                // CTAs
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Login'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neutral900,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Get Started'),
                    ),
                  ],
                ),
              ],

              // Mobile Menu Icon
              if (isMobile)
                IconButton(
                  icon: const Icon(LucideIcons.menu),
                  onPressed: () {
                    // Show mobile menu (can be a bottom sheet or end drawer)
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _NavLink extends StatelessWidget {
  final String title;
  final String route;

  const _NavLink({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    // Determine if active
    final currentRoute = GoRouterState.of(context).uri.path;
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go(route),
          child: Text(
            title,
            style: AppTextStyles.body.copyWith(
              color: isActive ? AppColors.neutral900 : AppColors.neutral500,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
