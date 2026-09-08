import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import '../../../authentication/presentation/bloc/authentication_state.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const GetMyNotificationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationBloc>().add(const MarkAllAsReadRequested());
            },
            child: Text('Mark all read', style: AppTextStyles.caption.copyWith(color: AppColors.primary500, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 8,
              itemBuilder: (context, index) => const NotificationCardSkeleton(),
            );
          } else if (state is NotificationError) {
            bool isAuthError = state.message.contains('401') || state.message.toLowerCase().contains('unauthorized') || state.message.contains('minified');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.error50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(isAuthError ? LucideIcons.lock : LucideIcons.alertCircle, size: 48, color: AppColors.error500),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isAuthError ? 'Authentication Required' : 'Oops! Something went wrong',
                      style: AppTextStyles.h4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isAuthError 
                        ? 'Please sign in to view your personalized notifications and alerts.' 
                        : 'We could not load your notifications right now. Please try again later.',
                      style: AppTextStyles.body.copyWith(color: AppColors.neutral500),
                      textAlign: TextAlign.center,
                    ),
                    if (isAuthError) ...[
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          minimumSize: const Size(200, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text("No notifications."));
            }

            final authState = context.read<AuthenticationBloc>().state;
            final userRole = authState is AuthenticationLoaded ? authState.user.role : 'CUSTOMER';
            
            Color primaryColor = AppColors.roleCustomer;
            Color lightColor = AppColors.roleCustomerLight;
            
            if (userRole == 'SHOPKEEPER') {
              primaryColor = AppColors.roleRetailer;
              lightColor = AppColors.roleRetailerLight;
            } else if (userRole == 'INFLUENCER') {
              primaryColor = AppColors.roleInfluencer;
              lightColor = AppColors.roleInfluencerLight;
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _buildNotificationItem(
                  icon: LucideIcons.bell,
                  iconColor: primaryColor,
                  iconBg: lightColor,
                  title: notification.title,
                  message: notification.message,
                  time: '${notification.createdAt.day}/${notification.createdAt.month}',
                  isUnread: !notification.isRead,
                  onTap: () {
                    if (!notification.isRead) {
                      context.read<NotificationBloc>().add(MarkNotificationAsReadRequested(notification.id));
                    }
                    
                    final type = notification.type;
                    final data = notification.data ?? {};
                    
                    if (type != null) {
                      if (type.startsWith('NEGOTIATION_')) {
                        final id = data['negotiationId'];
                        if (userRole == 'SHOPKEEPER') {
                          context.push(id != null ? '/retailer/negotiations/$id' : '/retailer/negotiations');
                        } else {
                          context.push(id != null ? '/negotiations/$id' : '/negotiations');
                        }
                      } else if (type.startsWith('RESERVATION_')) {
                        if (userRole == 'SHOPKEEPER') {
                          context.push('/retailer/reservations'); // or wherever reservations are
                        } else {
                          context.push('/profile'); // or wherever reservations are for customer
                        }
                      } else if (type == 'NEW_ORDER' || type == 'ORDER_STATUS_CHANGED') {
                        if (userRole == 'SHOPKEEPER') {
                          context.push('/retailer/orders');
                        } else {
                          context.push('/orders');
                        }
                      } else if (type == 'CAMPAIGN_PUBLISHED' && userRole == 'INFLUENCER') {
                        final id = data['campaignId'];
                        if (id != null) {
                          context.push('/influencer/campaigns/$id');
                        }
                      } else if (type.startsWith('BID_')) {
                        final id = data['campaignId'];
                        if (userRole == 'SHOPKEEPER') {
                          if (id != null) context.push('/retailer/campaigns/$id/bids');
                        } else if (userRole == 'INFLUENCER') {
                          if (id != null) context.push('/influencer/campaigns/$id');
                        }
                      }
                    }
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isUnread ? iconBg.withValues(alpha: 0.3) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnread ? iconBg : AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isUnread ? iconColor : AppColors.neutral500),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.neutral900)),
                      Text(time, style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600)),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
