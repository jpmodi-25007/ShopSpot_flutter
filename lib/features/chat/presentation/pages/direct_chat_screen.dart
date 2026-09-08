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

class _DirectChatScreenState extends State<DirectChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatRoomLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        } else if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error500));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neutral100),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AppNetworkImage(
                    url: widget.targetUserAvatar,
                    placeholderIcon: LucideIcons.user,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.targetUserName ?? 'Chat',
                  style: AppTextStyles.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading || state is ChatInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatRoomLoaded) {
                    final messages = state.messages;
                    final authState = context.read<AuthenticationBloc>().state;
                    final myUserId = authState is AuthenticationLoaded ? authState.user.id : '';

                    if (messages.isEmpty) {
                      return Center(
                        child: Text('No messages yet. Say hi!', style: AppTextStyles.body.copyWith(color: AppColors.neutral500)),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == myUserId;
                        return _buildMessageBubble(msg.content, isMe, msg.createdAt);
                      },
                    );
                  }
                  return const Center(child: Text('Something went wrong'));
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isMe, DateTime createdAt) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary500 : AppColors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: AppTextStyles.body.copyWith(color: isMe ? AppColors.white : AppColors.neutral900),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(createdAt),
              style: AppTextStyles.caption.copyWith(color: isMe ? AppColors.white.withValues(alpha: 0.7) : AppColors.neutral500, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: AppColors.primary500, shape: BoxShape.circle),
                child: const Icon(LucideIcons.send, color: AppColors.white, size: 20),
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
      context.read<ChatBloc>().add(SendMessageRequested(state.room.id, _messageController.text.trim()));
      _messageController.clear();
    }
  }
}
