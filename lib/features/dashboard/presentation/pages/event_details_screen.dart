import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import '../../../authentication/presentation/bloc/authentication_state.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(GetEventDetailRequested(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const DetailSkeleton();
          } else if (state is EventDetailLoaded) {
            final event = state.event;
            final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                      builder: (context, authState) {
                        if (authState is AuthenticationLoaded && authState.user.role == 'SHOPKEEPER') {
                          return Row(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.edit3, color: Colors.white),
                                onPressed: () {
                                  context.push('/retailer/events/create', extra: event);
                                },
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, color: Colors.white),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Event'),
                                      content: const Text('Are you sure you want to delete this event?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () {
                                            context.read<EventBloc>().add(DeleteEventRequested(event.id));
                                            Navigator.pop(context);
                                            context.pop(); // Go back to dashboard
                                          },
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                          Image.network(
                            event.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            color: AppColors.neutral200,
                            child: const Center(
                              child: Icon(LucideIcons.image, size: 64, color: AppColors.neutral400),
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.8)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title, style: AppTextStyles.h2),
                        const SizedBox(height: 16),
                        _buildInfoRow(LucideIcons.calendar, '${dateFormat.format(event.startDate)}\nuntil ${dateFormat.format(event.endDate)}'),
                        const SizedBox(height: 12),
                        _buildInfoRow(LucideIcons.mapPin, event.location ?? 'Online / TBD'),
                        if (event.shopName != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(LucideIcons.store, 'Hosted by ${event.shopName}'),
                        ],
                        const SizedBox(height: 32),
                        Text('About this Event', style: AppTextStyles.h4),
                        const SizedBox(height: 12),
                        Text(
                          event.description ?? 'No description provided.',
                          style: AppTextStyles.body.copyWith(height: 1.6, color: AppColors.neutral600),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to your calendar!'), backgroundColor: AppColors.primary500),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary500,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Add to Calendar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is EventError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading event', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: AppTextStyles.body.copyWith(color: AppColors.neutral700)),
        ),
      ],
    );
  }
}
