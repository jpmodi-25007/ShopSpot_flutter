import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/web_navbar.dart';
import '../widgets/web_footer.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class WebLayout extends StatelessWidget {
  final Widget child;

  const WebLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: WebNavbar(),
      ),
      endDrawer: isMobile ? _buildMobileDrawer(context) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            child,
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.neutral900,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.store, color: AppColors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'Findivo',
                  style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700, color: AppColors.white),
                ),
              ],
            ),
          ),
          _DrawerItem(title: 'Features', route: '/features', icon: LucideIcons.star),
          _DrawerItem(title: 'How It Works', route: '/how-it-works', icon: LucideIcons.helpCircle),
          _DrawerItem(title: 'About', route: '/about', icon: LucideIcons.info),
          _DrawerItem(title: 'FAQ', route: '/faq', icon: LucideIcons.messageCircle),
          _DrawerItem(title: 'Contact', route: '/contact', icon: LucideIcons.mail),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/login'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('/signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neutral900,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Get Started'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final String route;
  final IconData icon;

  const _DrawerItem({required this.title, required this.route, required this.icon});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final isActive = currentRoute == route;

    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.neutral900 : AppColors.neutral500),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: isActive ? AppColors.neutral900 : AppColors.neutral700,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      onTap: () {
        context.pop(); // Close drawer
        context.go(route);
      },
    );
  }
}
