import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_builder.dart';

import 'package:flutter/services.dart';

class ShellLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ShellLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  State<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends State<ShellLayout> {
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
      bottomNavigationBar: _AnimatedBottomBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _goBranch,
        items: const [
          _NavItem(icon: LucideIcons.home, label: 'Home'),
          _NavItem(icon: LucideIcons.search, label: 'Search'),
          _NavItem(icon: LucideIcons.mapPin, label: 'Map'),
          _NavItem(icon: LucideIcons.messageSquare, label: 'Chats'),
          _NavItem(icon: LucideIcons.user, label: 'Profile'),
        ],
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
              child: Icon(LucideIcons.store, color: AppColors.primary500, size: 32),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(LucideIcons.home), label: Text('Home')),
              NavigationRailDestination(icon: Icon(LucideIcons.search), label: Text('Search')),
              NavigationRailDestination(icon: Icon(LucideIcons.mapPin), label: Text('Map')),
              NavigationRailDestination(icon: Icon(LucideIcons.messageSquare), label: Text('Chats')),
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _AnimatedBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _AnimatedBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary100 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            items[index].icon,
                            size: 22,
                            color: isSelected ? AppColors.primary500 : AppColors.neutral400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected ? AppColors.primary500 : AppColors.neutral400,
                          ),
                          child: Text(items[index].label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
