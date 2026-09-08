import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_network_image.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event_state.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import '../../../authentication/presentation/bloc/authentication_state.dart';
import 'package:intl/intl.dart';

class DirectChatScreen extends StatefulWidget {
  final String targetUserId;
  final String? targetUserName;
  final String? targetUserAvatar;
  final String? contextType;
  final String? contextId;

  const DirectChatScreen({
    super.key,
    required this.targetUserId,
    this.targetUserName,
    this.targetUserAvatar,
    this.contextType,
    this.contextId,
  });

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
        hasText ? _fabAnimController.forward() : _fabAnimController.reverse();
      }
    });

    context.read<ChatBloc>().add(CreateOrGetRoomRequested(
      widget.targetUserId,
      contextType: widget.contextType,
      contextId: widget.contextId,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  String _getRoleBadge(String? role) {
    switch (role?.toUpperCase()) {
      case 'RETAILER': return 'Retailer';
      case 'INFLUENCER': return 'Influencer';
      default: return 'Customer';
    }
  }

  Color _getRoleColor(String? role) {
    switch (role?.toUpperCase()) {
      case 'RETAILER': return AppColors.roleRetailer;
      case 'INFLUENCER': return AppColors.roleInfluencer;
      default: return AppColors.roleCustomer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatRoomLoaded) {
          _scrollToBottom();
        } else if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0ED),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(child: _buildBody()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary300, AppColors.primary500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipOval(
                  child: AppNetworkImage(
                    url: widget.targetUserAvatar,
                    placeholderIcon: LucideIcons.user,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
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
                Text(
                  widget.targetUserName ?? 'Chat',
                  style: AppTextStyles.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatRoomLoaded) {
                      final authState = context.read<AuthenticationBloc>().state;
                      final myId = authState is AuthenticationLoaded ? authState.user.id : '';
                      final otherUser = state.room.participantA == myId ? state.room.userB : state.room.userA;
                      final role = otherUser['role']?.toString();
                      return _buildRoleBadge(role);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.phone, color: AppColors.neutral500),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(LucideIcons.moreVertical, color: AppColors.neutral500),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String? role) {
    final color = _getRoleColor(role);
    final label = _getRoleBadge(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading || state is ChatInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary500,
              strokeWidth: 2,
            ),
          );
        } else if (state is ChatRoomLoaded) {
          final messages = state.messages;
          final authState = context.read<AuthenticationBloc>().state;
          final myUserId = authState is AuthenticationLoaded ? authState.user.id : '';

          if (messages.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg.senderId == myUserId;
              final showDate = index == 0 ||
                  !_isSameDay(messages[index - 1].createdAt, msg.createdAt);
              final showAvatar = !isMe &&
                  (index == messages.length - 1 || messages[index + 1].senderId != msg.senderId);
              return Column(
                children: [
                  if (showDate) _buildDateSeparator(msg.createdAt),
                  _buildMessageBubble(msg.content, isMe, msg.createdAt, showAvatar),
                ],
              );
            },
          );
        } else if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.error100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(LucideIcons.wifiOff, color: AppColors.error500, size: 32),
                ),
                const SizedBox(height: 16),
                Text('Connection Error', style: AppTextStyles.h4.copyWith(color: AppColors.neutral900)),
                const SizedBox(height: 4),
                Text('Unable to load messages', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => context.read<ChatBloc>().add(CreateOrGetRoomRequested(
                    widget.targetUserId,
                    contextType: widget.contextType,
                    contextId: widget.contextId,
                  )),
                  child: Text('Retry', style: AppTextStyles.body.copyWith(color: AppColors.primary500, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary100, AppColors.primary200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(LucideIcons.messageCircle, color: AppColors.primary500, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No messages yet', style: AppTextStyles.h4.copyWith(color: AppColors.neutral700)),
          const SizedBox(height: 4),
          Text('Start the conversation!', style: AppTextStyles.body.copyWith(color: AppColors.neutral400)),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String label;
    if (_isSameDay(date, now)) {
      label = 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMM d, yyyy').format(date);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.neutral200)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
          ),
          Expanded(child: Divider(color: AppColors.neutral200)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildMessageBubble(String content, bool isMe, DateTime createdAt, bool showAvatar) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, val, child) => Opacity(
        opacity: val,
        child: Transform.translate(offset: Offset(isMe ? 20 * (1 - val) : -20 * (1 - val), 0), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              if (showAvatar)
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 8, bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary100,
                  ),
                  child: ClipOval(
                    child: AppNetworkImage(url: widget.targetUserAvatar, placeholderIcon: LucideIcons.user),
                  ),
                )
              else
                const SizedBox(width: 38),
            ],
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [AppColors.primary500, AppColors.primary600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : AppColors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                  bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? AppColors.primary500.withValues(alpha: 0.2)
                        : AppColors.neutral900.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: AppTextStyles.body.copyWith(
                      color: isMe ? AppColors.white : AppColors.neutral900,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('h:mm a').format(createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: isMe ? AppColors.white.withValues(alpha: 0.65) : AppColors.neutral400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        style: AppTextStyles.body.copyWith(color: AppColors.neutral900),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                          hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            ScaleTransition(
              scale: CurvedAnimation(parent: _fabAnimController, curve: Curves.elasticOut),
              child: GestureDetector(
                onTap: _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: _hasText
                        ? LinearGradient(
                            colors: [AppColors.primary400, AppColors.primary600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _hasText ? null : AppColors.neutral200,
                    shape: BoxShape.circle,
                    boxShadow: _hasText
                        ? [BoxShadow(color: AppColors.primary500.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Icon(
                    LucideIcons.send,
                    color: _hasText ? AppColors.white : AppColors.neutral400,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final state = context.read<ChatBloc>().state;
    if (state is ChatRoomLoaded) {
      context.read<ChatBloc>().add(
        SendMessageRequested(state.room.id, _messageController.text.trim()),
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }
}
