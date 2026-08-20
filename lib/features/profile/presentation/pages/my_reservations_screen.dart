import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../reservation/presentation/bloc/reservation_bloc.dart';
import '../../../reservation/presentation/bloc/reservation_event.dart';
import '../../../reservation/presentation/bloc/reservation_state.dart';
import '../../../reservation/domain/entities/reservation_entity.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReservationBloc>()..add(FetchMyReservations()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.store, color: AppColors.primary500),
            onPressed: () {},
          ),
          title: Text('ShopSpot', style: AppTextStyles.h3.copyWith(color: AppColors.primary500)),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(LucideIcons.search), onPressed: () {}),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Reservations', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(
                    'Products held for you after successful negotiations.',
                    style: AppTextStyles.body.copyWith(color: AppColors.neutral700),
                  ),
                ],
              ),
            ),
            
            // Custom Tab Bar
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.neutral300)),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTabItem('Active', true)),
                  Expanded(child: _buildTabItem('Past', false)),
                ],
              ),
            ),

            // List
            Expanded(
              child: BlocBuilder<ReservationBloc, ReservationState>(
                builder: (context, state) {
                  if (state is ReservationLoading || state is ReservationInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ReservationError) {
                    return Center(
                      child: Text(state.failure.message, style: AppTextStyles.body.copyWith(color: AppColors.error500)),
                    );
                  } else if (state is ReservationsLoaded) {
                    if (state.reservations.isEmpty) {
                      return Center(
                        child: Text('No reservations found.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.reservations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildReservationCard(state.reservations[index]);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isActive ? AppColors.primary500 : Colors.transparent, width: 2)),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isActive ? AppColors.primary500 : AppColors.neutral500,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildReservationCard(ReservationEntity reservation) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    final difference = reservation.expiresAt.difference(DateTime.now());
    final isExpiringSoon = difference.inHours < 2;
    String expiryText;
    if (difference.isNegative) {
      expiryText = 'Expired';
    } else {
      expiryText = 'Expires in ${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    }

    final imageUrl = reservation.productImage.isNotEmpty 
        ? reservation.productImage 
        : 'https://via.placeholder.com/150';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reservation.productName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.store, size: 14, color: AppColors.neutral500),
                          const SizedBox(width: 4),
                          Expanded(child: Text(reservation.shopName, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Negotiated Price (x${reservation.quantity})', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      Text(currencyFormat.format(reservation.reservedPrice), style: AppTextStyles.h3.copyWith(color: AppColors.primary500)),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: difference.isNegative ? AppColors.error50 : AppColors.info100, // Light blueish footer
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.timer, size: 16, color: isExpiringSoon || difference.isNegative ? AppColors.warning500 : AppColors.neutral700),
                    const SizedBox(width: 8),
                    Text(expiryText, style: AppTextStyles.bodySmall.copyWith(color: isExpiringSoon || difference.isNegative ? AppColors.warning500 : AppColors.neutral700, fontWeight: FontWeight.w500)),
                  ],
                ),
                if (!difference.isNegative && reservation.status != 'COMPLETED')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {},
                    icon: const Icon(LucideIcons.qrCode, size: 16),
                    label: const Text('View QR'),
                  )
                else if (reservation.status == 'COMPLETED')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Completed', style: AppTextStyles.caption.copyWith(color: AppColors.success600, fontWeight: FontWeight.w600)),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
