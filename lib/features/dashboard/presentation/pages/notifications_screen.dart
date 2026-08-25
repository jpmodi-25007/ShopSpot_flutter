import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _buildNotificationItem(
                  icon: LucideIcons.bell,
                  iconColor: AppColors.primary500,
                  iconBg: AppColors.primary50,
                  title: notification.title,
                  message: notification.message,
                  time: '${notification.createdAt.day}/${notification.createdAt.month}',
                  isUnread: !notification.isRead,
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
  }) {
    return Container(
      color: isUnread ? AppColors.primary50.withValues(alpha: 0.3) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUnread ? AppColors.primary50 : AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isUnread ? AppColors.primary500 : AppColors.neutral500),
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
              decoration: const BoxDecoration(
                color: AppColors.primary500,
                shape: BoxShape.circle,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
