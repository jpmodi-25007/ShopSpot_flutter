import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../../features/dashboard/presentation/bloc/notification_bloc.dart';
import '../../features/dashboard/presentation/bloc/notification_event.dart';
import '../../features/dashboard/presentation/bloc/notification_state.dart';

class NotificationBell extends StatefulWidget {
  final Color color;

  const NotificationBell({super.key, this.color = AppColors.neutral900});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  void initState() {
    super.initState();
    final state = context.read<NotificationBloc>().state;
    if (state is NotificationInitial) {
      context.read<NotificationBloc>().add(const GetMyNotificationsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unread = state is NotificationLoaded
            ? state.notifications.where((item) => !item.isRead).length
            : 0;
        return IconButton(
          onPressed: () => context.push('/notifications'),
          icon: Badge(
            isLabelVisible: unread > 0,
            backgroundColor: AppColors.error500,
            label: Text(unread > 9 ? '9+' : '$unread'),
            child: Icon(LucideIcons.bell, color: widget.color),
          ),
        );
      },
    );
  }
}
