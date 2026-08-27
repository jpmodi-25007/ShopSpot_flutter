import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../bloc/retailer_order_bloc.dart';

class RetailerOrdersScreen extends StatefulWidget {
  const RetailerOrdersScreen({super.key});

  @override
  State<RetailerOrdersScreen> createState() => _RetailerOrdersScreenState();
}

class _RetailerOrdersScreenState extends State<RetailerOrdersScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';

  final List<String> _statusFilters = [
    'All',
    'PENDING',
    'CONFIRMED',
    'PACKED',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED'
  ];

  @override
  void initState() {
    super.initState();
    context.read<RetailerOrderBloc>().add(const FetchShopOrdersRequested());
  }

  Future<void> _refresh() async {
    context.read<RetailerOrderBloc>().add(const FetchShopOrdersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text('Orders', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(LucideIcons.refreshCw), onPressed: _refresh),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: BlocBuilder<RetailerOrderBloc, RetailerOrderState>(
            builder: (context, state) {
              final orders = state is RetailerOrdersLoaded
                  ? state.orders
                  : <ShopOrderModel>[];
              final pending = orders.where((o) => o.status == 'PENDING').length;
              final active = orders
                  .where((o) =>
                      ['CONFIRMED', 'PACKED', 'SHIPPED'].contains(o.status))
                  .length;
              return Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                color: AppColors.white,
                child: Row(
                  children: [
                    _buildQuickStat(
                        'New', pending.toString(), AppColors.warning600),
                    const SizedBox(width: 10),
                    _buildQuickStat(
                        'Active', active.toString(), AppColors.roleRetailer),
                    const SizedBox(width: 10),
                    _buildQuickStat('Total', orders.length.toString(),
                        AppColors.neutral600),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _statusFilters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.roleRetailer
                              : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter == 'All'
                              ? 'All Orders'
                              : filter.replaceAll('_', ' '),
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.neutral600,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.neutral200),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.roleRetailer,
              child: BlocConsumer<RetailerOrderBloc, RetailerOrderState>(
                listener: (context, state) {
                  if (state is RetailerOrderUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Order status updated!'),
                        backgroundColor: AppColors.success500,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    _refresh();
                  } else if (state is RetailerOrderError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error500,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is RetailerOrderLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 5,
                      itemBuilder: (_, __) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 130,
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }

                  if (state is RetailerOrdersLoaded ||
                      state is RetailerOrderUpdating ||
                      state is RetailerOrderUpdated) {
                    final orders = state is RetailerOrdersLoaded
                        ? state.orders
                        : state is RetailerOrderUpdating
                            ? state.orders
                            : state is RetailerOrderUpdated
                                ? state.orders
                                : <ShopOrderModel>[];
                    final updatingId =
                        state is RetailerOrderUpdating ? state.orderId : null;

                    var filtered = _selectedFilter == 'All'
                        ? orders
                        : orders
                            .where((o) => o.status == _selectedFilter)
                            .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.roleRetailerLight
                                    .withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.shoppingBag,
                                  size: 48, color: AppColors.roleRetailer),
                            ),
                            const SizedBox(height: 20),
                            Text('No Orders Found', style: AppTextStyles.h3),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFilter == 'All'
                                  ? 'Orders from customers will appear here.'
                                  : 'No ${_selectedFilter.replaceAll("_", " ")} orders.',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.neutral500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _OrderCard(
                          order: filtered[index],
                          index: index,
                          isUpdating: updatingId == filtered[index].id,
                          onStatusChanged: (orderId, newStatus) {
                            context.read<RetailerOrderBloc>().add(
                                  UpdateOrderStatusRequested(
                                      orderId: orderId, status: newStatus),
                                );
                          },
                        );
                      },
                    );
                  }

                  if (state is RetailerOrderError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.alertCircle,
                              size: 48, color: AppColors.error500),
                          const SizedBox(height: 16),
                          Text('Error loading orders', style: AppTextStyles.h4),
                          const SizedBox(height: 8),
                          Text(state.message,
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.neutral500)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(LucideIcons.refreshCw, size: 16),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.roleRetailer,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTextStyles.h4.copyWith(color: color)),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final ShopOrderModel order;
  final int index;
  final bool isUpdating;
  final void Function(String orderId, String newStatus) onStatusChanged;

  const _OrderCard({
    required this.order,
    required this.index,
    required this.isUpdating,
    required this.onStatusChanged,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      duration: Duration(milliseconds: 250 + (widget.index * 60).clamp(0, 400)),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.order.status) {
      case 'PENDING':
        return AppColors.warning600;
      case 'CONFIRMED':
        return AppColors.roleRetailer;
      case 'PACKED':
        return const Color(0xFF0EA5E9);
      case 'SHIPPED':
        return AppColors.roleInfluencer;
      case 'DELIVERED':
        return AppColors.success500;
      case 'CANCELLED':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  List<String> get _nextStatuses {
    switch (widget.order.status) {
      case 'PENDING':
        return ['CONFIRMED', 'CANCELLED'];
      case 'CONFIRMED':
        return ['PACKED', 'CANCELLED'];
      case 'PACKED':
        return ['SHIPPED'];
      case 'SHIPPED':
        return ['DELIVERED'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.05),
                    borderRadius: _expanded
                        ? const BorderRadius.vertical(top: Radius.circular(16))
                        : BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(LucideIcons.shoppingBag,
                            size: 18, color: _statusColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.order.orderNumber,
                                style: AppTextStyles.h4),
                            Text(
                              widget.order.customerName,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.neutral500),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.order.status.replaceAll('_', ' '),
                              style: AppTextStyles.caption.copyWith(
                                color: _statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '₹${widget.order.total.toStringAsFixed(0)}',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.neutral900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedRotation(
                                turns: _expanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(LucideIcons.chevronDown,
                                    size: 14, color: AppColors.neutral400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded details
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.calendar,
                                    size: 13, color: AppColors.neutral400),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a')
                                      .format(widget.order.createdAt),
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.neutral500),
                                ),
                              ],
                            ),
                            if (widget.order.customerMobile != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(LucideIcons.phone,
                                      size: 13, color: AppColors.neutral400),
                                  const SizedBox(width: 6),
                                  Text(widget.order.customerMobile!,
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.neutral500)),
                                ],
                              ),
                            ],
                            const SizedBox(height: 10),
                            const Divider(
                                height: 1, color: AppColors.neutral100),
                            const SizedBox(height: 10),
                            ...widget.order.items.take(3).map((item) {
                              final name = item['name'] as String? ?? 'Item';
                              final qty = item['quantity']?.toString() ?? '1';
                              final price = item['price']?.toString() ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                          color: _statusColor,
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(name,
                                            style: AppTextStyles.caption,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis)),
                                    Text('x$qty',
                                        style: AppTextStyles.caption.copyWith(
                                            color: AppColors.neutral400)),
                                    if (price.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text('₹$price',
                                          style: AppTextStyles.caption.copyWith(
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ],
                                ),
                              );
                            }),
                            if (_nextStatuses.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: _nextStatuses.map((nextStatus) {
                                  final isCancel = nextStatus == 'CANCELLED';
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ElevatedButton(
                                        onPressed: widget.isUpdating
                                            ? null
                                            : () => widget.onStatusChanged(
                                                widget.order.id, nextStatus),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isCancel
                                              ? AppColors.error50
                                              : AppColors.roleRetailer,
                                          foregroundColor: isCancel
                                              ? AppColors.error500
                                              : AppColors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: isCancel
                                                ? const BorderSide(
                                                    color: AppColors.error100)
                                                : BorderSide.none,
                                          ),
                                        ),
                                        child: widget.isUpdating
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: isCancel
                                                      ? AppColors.error500
                                                      : AppColors.white,
                                                ),
                                              )
                                            : Text(
                                                _actionLabel(nextStatus),
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: isCancel
                                                      ? AppColors.error500
                                                      : AppColors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _actionLabel(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'Confirm Order';
      case 'PACKED':
        return 'Mark Packed';
      case 'SHIPPED':
        return 'Mark Shipped';
      case 'DELIVERED':
        return 'Mark Delivered';
      case 'CANCELLED':
        return 'Cancel Order';
      default:
        return status;
    }
  }
}
