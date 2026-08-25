import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/retailer_dashboard_bloc.dart';
import '../bloc/retailer_dashboard_event.dart';
import '../bloc/retailer_dashboard_state.dart';

class RetailerProfileScreen extends StatefulWidget {
  const RetailerProfileScreen({super.key});

  @override
  State<RetailerProfileScreen> createState() => _RetailerProfileScreenState();
}

class _RetailerProfileScreenState extends State<RetailerProfileScreen> {
  bool _isOpen = true;

  @override
  void initState() {
    super.initState();
    context.read<RetailerDashboardBloc>().add(const GetMyShopRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetailerDashboardBloc, RetailerDashboardState>(
      builder: (context, dashState) {
        final shop = dashState is RetailerDashboardLoaded ? dashState.shop : null;
        return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.roleRetailer,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
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
                  padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neutral900.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.store, color: AppColors.roleRetailer, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(shop?.name ?? 'My Shop', style: AppTextStyles.h3.copyWith(color: AppColors.white)),
                                const SizedBox(width: 6),
                                if (shop?.isKycVerified == true)
                                  const Icon(LucideIcons.badgeCheck, color: Colors.white, size: 18),
                              ],
                            ),
                            Text(shop?.city ?? 'Loading...', style: AppTextStyles.bodySmall.copyWith(color: AppColors.roleRetailerLight)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.edit2, color: Colors.white, size: 20),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => EditRetailerProfileBottomSheet(shop: shop),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      _StatCard(label: 'Products', value: '124', icon: LucideIcons.package, color: AppColors.info500),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Inquiries', value: '38', icon: LucideIcons.messageSquare, color: AppColors.warning500),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Rating', value: '4.8★', icon: LucideIcons.star, color: AppColors.success500),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Store Status Toggle
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
                            color: (_isOpen ? AppColors.success100 : AppColors.error100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.store,
                            color: _isOpen ? AppColors.success500 : AppColors.error500,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Store Status', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                              Text(
                                _isOpen ? 'Open • Customers can find you' : 'Closed • Hidden from search',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isOpen,
                          onChanged: (val) => setState(() => _isOpen = val),
                          activeThumbColor: AppColors.success500,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Shop Info Section
                  _SectionCard(
                    title: 'Shop Information',
                    icon: LucideIcons.info,
                    children: [
                      _InfoRow(LucideIcons.mapPin, 'Address', '102, Shivalik High St, Ahmedabad'),
                      _InfoRow(LucideIcons.phone, 'Phone', '+91 98765 43210'),
                      _InfoRow(LucideIcons.globe, 'Website', 'www.electrohub.in'),
                      _InfoRow(LucideIcons.clock, 'Hours', 'Mon–Sat: 10 AM – 9 PM'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Account Settings
                  _SectionCard(
                    title: 'Account Settings',
                    icon: LucideIcons.settings,
                    children: [
                      _SettingsRow(LucideIcons.creditCard, 'Payment & Billing', () {}),
                      _SettingsRow(LucideIcons.bellRing, 'Notification Preferences', () => context.push('/notifications')),
                      _SettingsRow(LucideIcons.shieldCheck, 'Privacy & Security', () {}),
                      _SettingsRow(LucideIcons.helpCircle, 'Help & Support', () {}),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Logout
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
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
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: AppColors.roleRetailer, size: 18),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.neutral700)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neutral400, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
              Text(value, style: AppTextStyles.body.copyWith(color: AppColors.neutral800, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsRow(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.roleRetailer, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500))),
            const Icon(LucideIcons.chevronRight, color: AppColors.neutral400, size: 18),
          ],
        ),
      ),
    );
  }
}

class EditRetailerProfileBottomSheet extends StatefulWidget {
  final dynamic shop;
  const EditRetailerProfileBottomSheet({super.key, required this.shop});

  @override
  State<EditRetailerProfileBottomSheet> createState() => _EditRetailerProfileBottomSheetState();
}

class _EditRetailerProfileBottomSheetState extends State<EditRetailerProfileBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop?.name ?? '');
    _descriptionController = TextEditingController(text: widget.shop?.description ?? '');
    _cityController = TextEditingController(text: widget.shop?.city ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _save() {
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text('Edit Shop Profile', style: AppTextStyles.h3),
                IconButton(icon: const Icon(LucideIcons.x), onPressed: () => context.pop()),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Shop Name',
                filled: true,
                fillColor: AppColors.neutral50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                filled: true,
                fillColor: AppColors.neutral50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                filled: true,
                fillColor: AppColors.neutral50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roleRetailer,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _save,
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
