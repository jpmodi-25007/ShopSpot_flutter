import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../negotiation/presentation/bloc/negotiation_bloc.dart';
import '../../../negotiation/presentation/bloc/negotiation_event.dart';
import '../../../negotiation/presentation/bloc/negotiation_state.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event_state.dart';
import '../../../chat/domain/entities/chat_entity.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import '../../../authentication/presentation/bloc/authentication_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'package:intl/intl.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<NegotiationBloc>().add(const GetMyNegotiationsRequested());
    context.read<ChatBloc>().add(const LoadChatRoomsRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Messages', style: AppTextStyles.h3.copyWith(color: AppColors.neutral900)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit, color: AppColors.primary500),
            tooltip: 'New direct chat',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => const _NewChatBottomSheet(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary500,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary500,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Direct'),
            Tab(text: 'Active'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DirectChatsTab(),
          _NegotiationsTab(showCompleted: false),
          _NegotiationsTab(showCompleted: true),
        ],
      ),
    );
  }
}

// ── Direct Chats Tab ─────────────────────────────────────────────────────────

class _DirectChatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: 6,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
            itemBuilder: (_, __) => const ChatListTileSkeleton(),
          );
        }

        if (state is ChatRoomsLoaded) {
          if (state.rooms.isEmpty) {
            return _buildEmptyDirectChats(context);
          }

          final authState = context.read<AuthenticationBloc>().state;
          final myId = authState is AuthenticationLoaded ? authState.user.id : '';

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.rooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final room = state.rooms[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 200 + index * 50),
                curve: Curves.easeOut,
                builder: (context, val, child) => Opacity(
                  opacity: val,
                  child: Transform.translate(offset: Offset(20 * (1 - val), 0), child: child),
                ),
                child: _DirectChatTile(room: room, myId: myId),
              );
            },
          );
        }

        return _buildEmptyDirectChats(context);
      },
    );
  }

  Widget _buildEmptyDirectChats(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(LucideIcons.messageCircle, color: AppColors.primary500, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No direct chats yet', style: AppTextStyles.h4.copyWith(color: AppColors.neutral700)),
          const SizedBox(height: 4),
          Text('Tap the edit icon above to start a conversation', style: AppTextStyles.body.copyWith(color: AppColors.neutral400), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _DirectChatTile extends StatelessWidget {
  final ChatRoomEntity room;
  final String myId;

  const _DirectChatTile({required this.room, required this.myId});

  @override
  Widget build(BuildContext context) {
    // Determine the other user
    final isParticipantA = room.participantA == myId;
    final otherUser = isParticipantA ? room.userB : room.userA;
    final otherName = otherUser['name']?.toString() ?? 'User';
    final otherAvatar = otherUser['avatarUrl']?.toString();
    final otherRole = otherUser['role']?.toString();
    final otherId = (isParticipantA ? room.participantB : room.participantA);

    final lastMsg = room.lastMessage;
    final lastContent = lastMsg?.content ?? 'Start chatting!';
    final lastTime = lastMsg != null ? _formatTime(lastMsg.createdAt) : '';

    Color roleColor;
    String roleLabel;
    switch (otherRole?.toUpperCase()) {
      case 'RETAILER':
        roleColor = AppColors.roleRetailer;
        roleLabel = 'Retailer';
        break;
      case 'INFLUENCER':
        roleColor = AppColors.roleInfluencer;
        roleLabel = 'Influencer';
        break;
      default:
        roleColor = AppColors.roleCustomer;
        roleLabel = 'Customer';
    }

    return InkWell(
      onTap: () => context.push('/chat/$otherId', extra: {
        'targetUserName': otherName,
        'targetUserAvatar': otherAvatar,
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: roleColor.withValues(alpha: 0.12),
                  ),
                  child: ClipOval(
                    child: AppNetworkImage(url: otherAvatar, placeholderIcon: LucideIcons.user),
                  ),
                ),
                if (room.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(color: AppColors.primary500, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          room.unreadCount > 9 ? '9+' : room.unreadCount.toString(),
                          style: AppTextStyles.caption.copyWith(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: room.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                      if (lastTime.isNotEmpty)
                        Text(lastTime, style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(roleLabel, style: AppTextStyles.caption.copyWith(color: roleColor, fontWeight: FontWeight.w600, fontSize: 9)),
                      ),
                      Expanded(
                        child: Text(
                          lastContent,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: room.unreadCount > 0 ? AppColors.neutral700 : AppColors.neutral400,
                            fontWeight: room.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.neutral300),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) return DateFormat('h:mm a').format(dt);
    if (now.difference(dt).inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }
}

// ── Negotiations Tab ──────────────────────────────────────────────────────────

class _NegotiationsTab extends StatelessWidget {
  final bool showCompleted;
  const _NegotiationsTab({required this.showCompleted});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NegotiationBloc, NegotiationState>(
      builder: (context, state) {
        if (state is NegotiationLoaded && state.isSubmitting) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: 8,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
            itemBuilder: (_, __) => const ChatListTileSkeleton(),
          );
        }

        final negotiations = state is NegotiationLoaded ? state.negotiations ?? [] : [];
        final filtered = showCompleted
            ? negotiations.where((n) => n.status == 'COMPLETED' || n.status == 'REJECTED').toList()
            : negotiations.where((n) => n.status != 'COMPLETED' && n.status != 'REJECTED').toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: showCompleted ? AppColors.neutral100 : AppColors.primary100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    showCompleted ? LucideIcons.checkCircle : LucideIcons.messageSquare,
                    color: showCompleted ? AppColors.neutral400 : AppColors.primary500,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  showCompleted ? 'No completed negotiations' : 'No active negotiations',
                  style: AppTextStyles.h4.copyWith(color: AppColors.neutral700),
                ),
                const SizedBox(height: 4),
                Text(
                  showCompleted ? 'Resolved negotiations will appear here' : 'Start a negotiation with a shop',
                  style: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
          itemBuilder: (context, index) {
            final n = filtered[index];
            final statusColor = showCompleted ? AppColors.neutral500 : AppColors.warning500;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 200 + index * 50),
              curve: Curves.easeOut,
              builder: (context, val, child) => Opacity(
                opacity: val,
                child: Transform.translate(offset: Offset(20 * (1 - val), 0), child: child),
              ),
              child: InkWell(
                onTap: () => context.push('/negotiation/${n.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: n.product?.images.isNotEmpty == true
                              ? Image.network(n.product!.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(LucideIcons.package, color: statusColor))
                              : Icon(LucideIcons.package, color: statusColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(n.shop?.name ?? 'Shop', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.neutral900)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(n.status, style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(n.product?.name ?? 'Product', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral400), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.neutral300),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── New Chat Bottom Sheet ────────────────────────────────────────────────────

class _NewChatBottomSheet extends StatelessWidget {
  const _NewChatBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  Text('New Direct Chat', style: AppTextStyles.h3),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => context.pop()),
                ],
              ),
              const SizedBox(height: 8),
              Text('Chat directly with retailers, customers, or influencers.', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for a user or shop...',
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.neutral400),
                  filled: true,
                  fillColor: AppColors.neutral50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Text('Role-based chats are started from:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.neutral500)),
              const SizedBox(height: 12),
              _RoleTip(color: AppColors.roleRetailer, icon: LucideIcons.store, label: 'Retailer', description: 'Shop detail page → "Chat" button'),
              _RoleTip(color: AppColors.roleInfluencer, icon: LucideIcons.star, label: 'Influencer', description: 'Campaign detail page → "Message Retailer"'),
              _RoleTip(color: AppColors.roleCustomer, icon: LucideIcons.user, label: 'Customer', description: 'Shop detail page → "Message Shop"'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTip extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String description;

  const _RoleTip({required this.color, required this.icon, required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.neutral900)),
              Text(description, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
            ],
          ),
        ],
      ),
    );
  }
}


