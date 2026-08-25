import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../order/presentation/bloc/order_bloc.dart';
import '../../../order/presentation/bloc/order_event.dart';
import '../../../order/presentation/bloc/order_state.dart';
import '../../../order/domain/entities/order_entity.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderBloc>()..add(FetchMyOrders()),
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          title: Text('My Orders', style: AppTextStyles.h4),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading || state is OrderInitial) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 8,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) => const OrderCardSkeleton(),
              );
            } else if (state is OrderError) {
              return Center(child: Text(state.failure.message, style: AppTextStyles.body.copyWith(color: AppColors.error500)));
            } else if (state is OrdersLoaded) {
              if (state.orders.isEmpty) {
                return Center(
                  child: Text('No orders found.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return _buildOrderItem(order);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderEntity order) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final itemName = order.items.isNotEmpty 
        ? (order.items.first['name'] ?? 'Item') 
        : 'Unknown Item';
        
    final itemImage = order.items.isNotEmpty && order.items.first['image'] != null
        ? order.items.first['image']
        : 'https://via.placeholder.com/150';

    Color statusColor;
    Color statusBgColor;
    
    switch(order.status.toUpperCase()) {
      case 'DELIVERED':
        statusColor = AppColors.success600;
        statusBgColor = AppColors.success50;
        break;
      case 'CANCELLED':
        statusColor = AppColors.error500;
        statusBgColor = AppColors.error50;
        break;
      case 'PENDING':
      case 'CONFIRMED':
      case 'PACKED':
      case 'SHIPPED':
      default:
        statusColor = AppColors.warning600;
        statusBgColor = AppColors.warning50;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${order.orderNumber}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(itemImage),
                    fit: BoxFit.cover,
                  )
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('Sold by: ${order.shopName}', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
              Text(currencyFormat.format(order.total), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary500)),
            ],
          ),
        ],
      ),
    );
  }
}
