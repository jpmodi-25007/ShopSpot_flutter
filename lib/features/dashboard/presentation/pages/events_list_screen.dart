import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(const GetEventsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
        title: Text('Upcoming Events', style: AppTextStyles.h3),
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => const EventCardSkeleton(),
            );
          } else if (state is EventsLoaded) {
            if (state.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.calendar, size: 64, color: AppColors.neutral300),
                    const SizedBox(height: 16),
                    Text('No Events Found', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text('Check back later for new events in your area.',
                        style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = state.events[index];
                final dateFormat = DateFormat('MMM d, yyyy');
                return GestureDetector(
                  onTap: () => context.push('/events/${event.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          event.imageUrl ?? 'https://via.placeholder.com/600x300',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.title, style: AppTextStyles.h3),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(LucideIcons.calendar, size: 16, color: AppColors.primary500),
                                  const SizedBox(width: 8),
                                  Text('${dateFormat.format(event.startDate)} - ${dateFormat.format(event.endDate)}',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.neutral600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary500),
                                  const SizedBox(width: 8),
                                  Text(event.location ?? 'Online / TBD',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.neutral600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is EventError) {
            return Center(child: Text(state.failure.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
