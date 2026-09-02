import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/widgets/logout_dialog.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        final shop =
            dashState is RetailerDashboardLoaded ? dashState.shop : null;
        return Scaffold(
          backgroundColor: AppColors.neutral50,
          body: CustomScrollView(
            slivers: [
              // Gradient Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.roleRetailer,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final top = constraints.biggest.height;
                    final isCollapsed = top <=
                        kToolbarHeight +
                            MediaQuery.of(context).padding.top +
                            20;

                    return FlexibleSpaceBar(
                      centerTitle: true,
                      title: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isCollapsed ? 1.0 : 0.0,
                        child: Text(
                          shop?.name ?? 'Findivo Retail',
                          style:
                              AppTextStyles.h4.copyWith(color: AppColors.white),
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.neutral200,
                              image: shop?.coverImageUrl != null &&
                                      shop!.coverImageUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(shop.coverImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              gradient: shop?.coverImageUrl == null ||
                                      shop!.coverImageUrl!.isEmpty
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF0F766E),
                                        Color(0xFF14B8A6)
                                      ],
                                    )
                                  : null,
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
                                        color: AppColors.neutral900
                                            .withValues(alpha: 0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: shop?.logoUrl != null &&
                                            shop!.logoUrl!.isNotEmpty
                                        ? Image.network(shop.logoUrl!,
                                            fit: BoxFit.cover)
                                        : const Icon(LucideIcons.store,
                                            color: AppColors.roleRetailer,
                                            size: 36),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(shop?.name ?? 'My Shop',
                                              style: AppTextStyles.h3.copyWith(
                                                  color: AppColors.white)),
                                          const SizedBox(width: 6),
                                          if (shop?.isKycVerified == true)
                                            const Icon(LucideIcons.badgeCheck,
                                                color: Colors.white, size: 18),
                                        ],
                                      ),
                                      Text(shop?.city ?? 'Loading...',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                  color: AppColors
                                                      .roleRetailerLight)),
                                      if (shop?.description != null &&
                                          shop!.description!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          shop.description!,
                                          style: AppTextStyles.caption.copyWith(
                                              color: AppColors.white
                                                  .withValues(alpha: 0.9)),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.edit2,
                                      color: Colors.white, size: 20),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) =>
                                          EditRetailerProfileBottomSheet(
                                              shop: shop),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                          _StatCard(
                              label: 'Products',
                              value: '124',
                              icon: LucideIcons.package,
                              color: AppColors.info500),
                          const SizedBox(width: 12),
                          _StatCard(
                              label: 'Inquiries',
                              value: '38',
                              icon: LucideIcons.messageSquare,
                              color: AppColors.warning500),
                          const SizedBox(width: 12),
                          _StatCard(
                              label: 'Rating',
                              value: '4.8★',
                              icon: LucideIcons.star,
                              color: AppColors.success500),
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
                              color:
                                  AppColors.neutral900.withValues(alpha: 0.04),
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
                                color: (_isOpen
                                    ? AppColors.success100
                                    : AppColors.error100),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                LucideIcons.store,
                                color: _isOpen
                                    ? AppColors.success500
                                    : AppColors.error500,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Store Status',
                                      style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    _isOpen
                                        ? 'Open • Customers can find you'
                                        : 'Closed • Hidden from search',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: AppColors.neutral500),
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
                          _InfoRow(LucideIcons.mapPin, 'Address',
                              shop?.address ?? 'Not set'),
                          _InfoRow(LucideIcons.phone, 'Phone',
                              shop?.phone ?? 'Not set'),
                          _InfoRow(LucideIcons.mail, 'Email',
                              shop?.email ?? 'Not set'),
                          _InfoRow(LucideIcons.globe, 'Website',
                              'www.${(shop?.name ?? 'shop').toLowerCase().replaceAll(' ', '')}.com'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Account Settings
                      _SectionCard(
                        title: 'Account Settings',
                        icon: LucideIcons.settings,
                        children: [
                          _SettingsRow(LucideIcons.creditCard,
                              'Payment & Billing', () {}),
                          _SettingsRow(
                              LucideIcons.bellRing,
                              'Notification Preferences',
                              () => context.push('/notifications')),
                          _SettingsRow(LucideIcons.shieldCheck,
                              'Privacy & Security', () {}),
                          _SettingsRow(
                              LucideIcons.helpCircle, 'Help & Support', () {}),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Logout
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
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

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
            Text(value,
                style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.neutral500)),
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
  const _SectionCard(
      {required this.title, required this.icon, required this.children});

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
                Text(title,
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral700)),
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
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.neutral500)),
              Text(value,
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.neutral800,
                      fontWeight: FontWeight.w500)),
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

class EditRetailerProfileBottomSheet extends StatefulWidget {
  final dynamic shop;
  const EditRetailerProfileBottomSheet({super.key, required this.shop});

  @override
  State<EditRetailerProfileBottomSheet> createState() =>
      _EditRetailerProfileBottomSheetState();
}

class _EditRetailerProfileBottomSheetState
    extends State<EditRetailerProfileBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _logoUrlController;
  late TextEditingController _coverUrlController;
  final _formKey = GlobalKey<FormState>();

  double? _latitude;
  double? _longitude;
  static const String _placesApiKey = "AIzaSyDf6rMHr8A9ZPYYoszRwB8arfjLbrxnQnk";

  Future<List<Map<String, dynamic>>> _getSuggestions(String query) async {
    if (query.isEmpty) return [];
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_placesApiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;
        return predictions
            .map((p) => {
                  'description': p['description'],
                  'place_id': p['place_id'],
                })
            .toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  Future<void> _getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_placesApiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];
        setState(() {
          _latitude = location['lat'];
          _longitude = location['lng'];
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.shop?.description ?? '');
    _cityController = TextEditingController(text: widget.shop?.city ?? '');
    _addressController =
        TextEditingController(text: widget.shop?.address ?? '');
    _phoneController = TextEditingController(text: widget.shop?.phone ?? '');
    _emailController = TextEditingController(text: widget.shop?.email ?? '');
    _logoUrlController =
        TextEditingController(text: widget.shop?.logoUrl ?? '');
    _coverUrlController =
        TextEditingController(text: widget.shop?.coverImageUrl ?? '');
    _latitude = widget.shop?.latitude;
    _longitude = widget.shop?.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _logoUrlController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final city = _cityController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Shop Name is required.'),
            backgroundColor: AppColors.error500),
      );
      return;
    }

    final data = {
      'name': name,
      'description': description,
      'city': city,
      'address': address,
      'phone': phone,
      'email': email,
      'logoUrl': _logoUrlController.text.trim().isEmpty
          ? null
          : _logoUrlController.text.trim(),
      'coverImageUrl': _coverUrlController.text.trim().isEmpty
          ? null
          : _coverUrlController.text.trim(),
      if (_latitude != null) 'latitude': _latitude,
      if (_longitude != null) 'longitude': _longitude,
    };

    if (widget.shop == null) {
      context.read<RetailerDashboardBloc>().add(CreateShopRequested(data));
    } else {
      context.read<RetailerDashboardBloc>().add(UpdateShopRequested(data));
    }
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
      child: BlocConsumer<RetailerDashboardBloc, RetailerDashboardState>(
        listener: (context, state) {
          if (state is RetailerDashboardLoaded) {
            if (state.isSuccess) {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Shop details saved successfully!'),
                    backgroundColor: AppColors.success500),
              );
            } else if (state.failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error: ${state.failure}'),
                    backgroundColor: AppColors.error500),
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading =
              state is RetailerDashboardLoaded ? state.isLoading : false;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          widget.shop == null
                              ? 'Add Shop Details'
                              : 'Edit Shop Profile',
                          style: AppTextStyles.h3),
                      IconButton(
                          icon: const Icon(LucideIcons.x),
                          onPressed: () => context.pop()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Shop name is required'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Shop Name',
                      filled: true,
                      fillColor: AppColors.neutral50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: AppColors.neutral50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Autocomplete<Map<String, dynamic>>(
                    initialValue:
                        TextEditingValue(text: _addressController.text),
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      return await _getSuggestions(textEditingValue.text);
                    },
                    displayStringForOption: (Map<String, dynamic> option) =>
                        option['description'],
                    onSelected: (Map<String, dynamic> selection) {
                      _addressController.text = selection['description'];
                      _getPlaceDetails(selection['place_id']);
                    },
                    fieldViewBuilder: (context, textEditingController,
                        focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onChanged: (val) {
                          _addressController.text = val;
                          _latitude = null;
                          _longitude = null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Full Address',
                          filled: true,
                          fillColor: AppColors.neutral50,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (_latitude == null || _longitude == null)
                            return 'Please select a valid address from the dropdown';
                          return null;
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          child: SizedBox(
                            height: 200,
                            width: MediaQuery.of(context).size.width - 48,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option['description']),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            filled: true,
                            fillColor: AppColors.neutral50,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            filled: true,
                            fillColor: AppColors.neutral50,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      filled: true,
                      fillColor: AppColors.neutral50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _logoUrlController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'Logo Image URL',
                      filled: true,
                      fillColor: AppColors.neutral50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _coverUrlController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'Cover Image URL',
                      filled: true,
                      fillColor: AppColors.neutral50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roleRetailer,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: AppColors.white, strokeWidth: 2))
                        : const Text('Save Changes',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
