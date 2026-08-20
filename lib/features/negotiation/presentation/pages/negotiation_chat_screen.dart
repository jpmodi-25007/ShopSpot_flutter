import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/negotiation_bloc.dart';
import '../bloc/negotiation_event.dart';
import '../bloc/negotiation_state.dart';
import '../../domain/entities/negotiation_enums.dart';

class NegotiationChatScreen extends StatefulWidget {
  final String negotiationId;
  const NegotiationChatScreen({super.key, required this.negotiationId});

  @override
  State<NegotiationChatScreen> createState() => _NegotiationChatScreenState();
}

class _NegotiationChatScreenState extends State<NegotiationChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NegotiationBloc>().add(GetNegotiationDetailRequested(widget.negotiationId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text('ShopSpot', style: AppTextStyles.h3.copyWith(color: AppColors.primary500)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(LucideIcons.moreVertical), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<NegotiationBloc, NegotiationState>(
        builder: (context, state) {
          if (state is NegotiationLoaded && state.activeNegotiation != null) {
            final negotiation = state.activeNegotiation!;
            return Column(
              children: [
                // Header info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.neutral300)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(negotiation.shop?.name ?? 'Shop', style: AppTextStyles.h4),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.primary500),
                          const Spacer(),
                          Text(negotiation.status.name, style: AppTextStyles.caption.copyWith(color: AppColors.primary500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                negotiation.product?.images.isNotEmpty == true ? negotiation.product!.images.first : 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?q=80&w=100&auto=format&fit=crop',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(negotiation.product?.name ?? 'Product', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                  Row(
                                    children: [
                                      Text('₹${negotiation.initialPrice.toStringAsFixed(0)}', style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.neutral500)),
                                      const Spacer(),
                                      Text('₹${(negotiation.counterPrice ?? negotiation.offeredPrice).toStringAsFixed(0)}', style: AppTextStyles.body.copyWith(color: AppColors.primary500, fontWeight: FontWeight.w600)),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                // Chat Area
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: negotiation.messages.length,
                    itemBuilder: (context, index) {
                      final m = negotiation.messages[index];
                      final isMe = m.senderRole == 'customer';
                      
                      if (m.messageType == MessageType.PRICE_COUNTER || m.messageType == MessageType.PRICE_OFFER) {
                         return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: _OfferBubble(
                                amount: '₹${negotiation.counterPrice ?? negotiation.offeredPrice}',
                                status: negotiation.status.name,
                                time: 'Now',
                                isMe: isMe,
                              ),
                            ),
                          );
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: _ChatBubble(
                            message: m.content,
                            time: 'Now',
                            isMe: isMe,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Actions if pending/countered
                if (negotiation.status != NegotiationStatus.ACCEPTED && negotiation.status != NegotiationStatus.REJECTED)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary500,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () {
                              context.read<NegotiationBloc>().add(AcceptDealRequested(negotiation.id));
                            },
                            child: const Text('Accept Offer', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.neutral700,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.neutral300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () {
                               // Counter offer logic
                               context.read<NegotiationBloc>().add(CounterOfferRequested(id: negotiation.id, counterPrice: (negotiation.counterPrice ?? negotiation.offeredPrice) - 50));
                            },
                            child: const Text('Counter', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Input Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(top: BorderSide(color: AppColors.neutral200)),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.plus, color: AppColors.neutral500),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type a message...',
                                hintStyle: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(LucideIcons.send, color: AppColors.white, size: 20),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Loading View
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const _ChatBubble({
    required this.message,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary500 : AppColors.white,
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(16),
        ),
        boxShadow: isMe ? [] : [
          BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: isMe ? AppColors.white : AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppTextStyles.caption.copyWith(
              color: isMe ? AppColors.primary100 : AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferBubble extends StatelessWidget {
  final String amount;
  final String status;
  final String time;
  final bool isMe;

  const _OfferBubble({
    required this.amount,
    required this.status,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(16),
        ),
        border: Border.all(color: AppColors.primary100),
        boxShadow: [
          BoxShadow(color: AppColors.primary500.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.tag, size: 16, color: AppColors.primary500),
              const SizedBox(width: 8),
              Text(status, style: AppTextStyles.caption.copyWith(color: AppColors.primary500, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(amount, style: AppTextStyles.h3.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: 8),
          Text(time, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }
}
