import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_builder.dart';

import 'package:flutter/services.dart';

class InfluencerShellLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const InfluencerShellLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  State<InfluencerShellLayout> createState() => _InfluencerShellLayoutState();
}

class _InfluencerShellLayoutState extends State<InfluencerShellLayout> {
  DateTime? _lastPressedAt;

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // If not on the first tab, go back to the first tab instead of exiting
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
          return;
        }

        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning = _lastPressedAt == null || now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Double tap confirmed, exit app
        SystemNavigator.pop();
      },
      child: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _goBranch,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary500,
          unselectedItemColor: AppColors.neutral500,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(LucideIcons.compass), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.megaphone), label: 'Campaigns'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.pieChart), label: 'Earnings'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.white,
            selectedIconTheme: const IconThemeData(color: AppColors.primary500),
            unselectedIconTheme: const IconThemeData(color: AppColors.neutral500),
            selectedLabelTextStyle: const TextStyle(color: AppColors.primary500, fontSize: 12),
            unselectedLabelTextStyle: const TextStyle(color: AppColors.neutral500, fontSize: 12),
            useIndicator: true,
            indicatorColor: AppColors.primary100,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=100&auto=format&fit=crop'),
              ),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(LucideIcons.compass), label: Text('Discover')),
              NavigationRailDestination(icon: Icon(LucideIcons.megaphone), label: Text('Campaigns')),
              NavigationRailDestination(icon: Icon(LucideIcons.pieChart), label: Text('Earnings')),
              NavigationRailDestination(icon: Icon(LucideIcons.user), label: Text('Profile')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppColors.neutral300),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }
}
