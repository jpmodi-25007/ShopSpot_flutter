import 'package:flutter/material.dart';
import 'package:mobile_web/core/widgets/shimmer_effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../negotiation/presentation/bloc/negotiation_bloc.dart';
import '../../../negotiation/presentation/bloc/negotiation_event.dart';
import '../../../negotiation/presentation/bloc/negotiation_state.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    context.read<NegotiationBloc>().add(const GetMyNegotiationsRequested());
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
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary500,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary500,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: BlocBuilder<NegotiationBloc, NegotiationState>(
        builder: (context, state) {
          if (state is NegotiationLoaded && state.isSubmitting) {
            return const GenericListShimmer();
          }
          final negotiations = state is NegotiationLoaded ? state.negotiations ?? [] : [];
          final active = negotiations.where((n) => n.status != 'COMPLETED' && n.status != 'REJECTED').toList();
          final completed = negotiations.where((n) => n.status == 'COMPLETED' || n.status == 'REJECTED').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _ChatList(chats: active.isNotEmpty 
                ? active.map((n) => _ChatItem(
                    id: n.id,
                    shopName: n.shop?.name ?? 'Shop',
                    lastMessage: 'Status: ${n.status}',
                    time: 'Now',
                    unreadCount: 0,
                    isOnline: true,
                    avatarColor: AppColors.primary500,
                    avatarLetter: (n.shop?.name ?? 'S')[0].toUpperCase(),
                    imageUrl: n.product?.images.first ?? '',
                    status: n.status.name,
                    statusColor: AppColors.warning500,
                  )).toList()
                : [], // Let it be empty if no data
              ),
              completed.isEmpty ? _buildEmptyCompleted() : _ChatList(
                chats: completed.map((n) => _ChatItem(
                  id: n.id,
                  shopName: n.shop?.name ?? 'Shop',
                  lastMessage: 'Status: ${n.status}',
                  time: 'Done',
                  unreadCount: 0,
                  isOnline: false,
                  avatarColor: AppColors.neutral500,
                  avatarLetter: (n.shop?.name ?? 'S')[0].toUpperCase(),
                  imageUrl: n.product?.images.first ?? '',
                  status: n.status.name,
                  statusColor: AppColors.neutral500,
                )).toList()
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCompleted() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(LucideIcons.checkCircle, color: AppColors.neutral400, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No completed chats', style: AppTextStyles.h4.copyWith(color: AppColors.neutral700)),
          const SizedBox(height: 4),
          Text('Your resolved negotiations will appear here', style: AppTextStyles.body.copyWith(color: AppColors.neutral400)),
        ],
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final List<_ChatItem> chats;
  const _ChatList({required this.chats});

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
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
              child: const Icon(LucideIcons.messageSquare, color: AppColors.primary500, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No conversations yet', style: AppTextStyles.h4.copyWith(color: AppColors.neutral700)),
            const SizedBox(height: 4),
            Text('Start a negotiation with a shop to chat', style: AppTextStyles.body.copyWith(color: AppColors.neutral400)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chats.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 250 + index * 60),
          curve: Curves.easeOut,
          builder: (context, val, child) => Opacity(
            opacity: val,
            child: Transform.translate(offset: Offset(20 * (1 - val), 0), child: child),
          ),
          child: _ChatTile(chat: chats[index]),
        );
      },
    );
  }
}

class _ChatItem {
  final String id;
  final String shopName;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final Color avatarColor;
  final String avatarLetter;
  final String imageUrl;
  final String status;
  final Color statusColor;

  _ChatItem({
    this.id = '',
    required this.shopName,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.avatarColor,
    required this.avatarLetter,
    required this.imageUrl,
    required this.status,
    required this.statusColor,
  });
}

class _ChatTile extends StatelessWidget {
  final _ChatItem chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (chat.id.isNotEmpty) {
          context.push('/negotiation/${chat.id}');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: chat.avatarColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      chat.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(chat.avatarLetter,
                            style: TextStyle(color: chat.avatarColor, fontSize: 20, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppColors.success500,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(chat.shopName,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.neutral900,
                          )),
                      Text(chat.time, style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: chat.unreadCount > 0 ? AppColors.neutral700 : AppColors.neutral400,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              chat.unreadCount.toString(),
                              style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (chat.status.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: chat.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        chat.status,
                        style: AppTextStyles.caption.copyWith(color: chat.statusColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
