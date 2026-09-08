import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../reservation/presentation/bloc/reservation_bloc.dart';
import '../../../reservation/presentation/bloc/reservation_event.dart';
import '../../../reservation/presentation/bloc/reservation_state.dart';
import '../../../reservation/domain/entities/reservation_entity.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  int _tabIndex = 0; // 0 for Active, 1 for Past
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReservationBloc>()..add(FetchMyReservations()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search reservations...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                )
              : Text('Findivo', style: AppTextStyles.h3.copyWith(color: AppColors.primary500)),
          centerTitle: !_isSearching,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? LucideIcons.x : LucideIcons.search),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isSearching)
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
                  Expanded(child: _buildTabItem('Active', 0)),
                  Expanded(child: _buildTabItem('Past', 1)),
                ],
              ),
            ),

            // List
            Expanded(
              child: BlocBuilder<ReservationBloc, ReservationState>(
                builder: (context, state) {
                  if (state is ReservationLoading || state is ReservationInitial) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: 8,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => const OrderCardSkeleton(),
                    );
                  } else if (state is ReservationError) {
                    return Center(
                      child: Text(state.failure.message, style: AppTextStyles.body.copyWith(color: AppColors.error500)),
                    );
                  } else if (state is ReservationsLoaded) {
                    final now = DateTime.now();
                    final filtered = state.reservations.where((r) {
                      final isExpired = r.expiresAt.difference(now).isNegative;
                      final matchesTab = _tabIndex == 0 ? !isExpired : isExpired;
                      if (!matchesTab) return false;
                      
                      if (_searchQuery.isEmpty) return true;
                      
                      final productName = (r.productName).toLowerCase();
                      final shopName = (r.shopName).toLowerCase();
                      
                      return productName.contains(_searchQuery) || shopName.contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text('No reservations found.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ReservationBloc>().add(FetchMyReservations());
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildReservationCard(context, filtered[index]);
                        },
                      ),
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

  Widget _buildTabItem(String label, int index) {
    final isActive = _tabIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _tabIndex = index;
        });
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, ReservationEntity reservation) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    final difference = reservation.expiresAt.difference(DateTime.now());
    final isExpiringSoon = difference.inHours < 2;
    String expiryText;
    if (difference.isNegative) {
      expiryText = 'Expired';
    } else {
      expiryText = 'Expires in ${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    }

    final String? imageUrl = reservation.productImage.isNotEmpty 
        ? reservation.productImage 
        : null;

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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(12),
                    image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: imageUrl == null ? const Icon(LucideIcons.package, color: AppColors.neutral400) : null,
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
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const _RescheduleBottomSheet(),
                      );
                    },
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

class _RescheduleBottomSheet extends StatefulWidget {
  const _RescheduleBottomSheet();

  @override
  State<_RescheduleBottomSheet> createState() => _RescheduleBottomSheetState();
}

class _RescheduleBottomSheetState extends State<_RescheduleBottomSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary500,
              onPrimary: AppColors.white,
              onSurface: AppColors.neutral900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary500,
                onPrimary: AppColors.white,
                onSurface: AppColors.neutral900,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  String get _formattedDateTime {
    if (_selectedDate == null || _selectedTime == null) {
      return 'Tap to select date and time';
    }
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = _selectedTime!.hour == 0 ? 12 : (_selectedTime!.hour > 12 ? _selectedTime!.hour - 12 : _selectedTime!.hour);
    final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    return '${months[_selectedDate!.month - 1]} ${_selectedDate!.day}, $hour:$minute $period';
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reschedule Visit', style: AppTextStyles.h3),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => context.pop()),
                ],
              ),
              const SizedBox(height: 24),
              Text('Select New Date & Time', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendar, color: AppColors.neutral500),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formattedDateTime,
                          style: AppTextStyles.body.copyWith(
                            color: _selectedDate == null ? AppColors.neutral500 : AppColors.neutral900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reservation rescheduled!'), backgroundColor: AppColors.success500));
                },
                child: const Text('Confirm Reschedule', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error500,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reservation cancelled.'), backgroundColor: AppColors.neutral700));
                },
                child: const Text('Cancel Reservation', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
