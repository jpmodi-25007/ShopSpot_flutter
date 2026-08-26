import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        title: Text('Findivo', style: AppTextStyles.h3.copyWith(color: AppColors.primary500)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(LucideIcons.moreVertical), onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const _NegotiationSettingsBottomSheet(),
            );
          }),
        ],
      ),
      body: BlocConsumer<NegotiationBloc, NegotiationState>(
        listener: (context, state) {
          if (state is NegotiationError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is NegotiationLoading) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final isMe = index % 2 == 0;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: ShimmerBox(
                  width: 200, 
                  height: 60, 
                  borderRadius: 16,
                ),
              );
            },
          );
        }
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
                               showDialog(
                                 context: context,
                                 builder: (ctx) {
                                   final _priceController = TextEditingController(text: (negotiation.counterPrice ?? negotiation.offeredPrice).toStringAsFixed(0));
                                   return AlertDialog(
                                     title: const Text('Counter Offer'),
                                     content: TextField(
                                       controller: _priceController,
                                       keyboardType: TextInputType.number,
                                       decoration: const InputDecoration(
                                         labelText: 'Counter Price (₹)',
                                         border: OutlineInputBorder(),
                                       ),
                                     ),
                                     actions: [
                                       TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                       ElevatedButton(
                                         onPressed: () {
                                           final price = double.tryParse(_priceController.text);
                                           if (price != null) {
                                             context.read<NegotiationBloc>().add(CounterOfferRequested(id: negotiation.id, counterPrice: price));
                                             Navigator.pop(ctx);
                                           }
                                         },
                                         child: const Text('Submit'),
                                       )
                                     ],
                                   );
                                 },
                               );
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
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => const _AttachmentPickerBottomSheet(),
                            );
                          },
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
                            onPressed: () {
                              if (_messageController.text.trim().isNotEmpty) {
                                _messageController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Message sent'), backgroundColor: AppColors.primary500),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Fallback View
          return const SizedBox.shrink();
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

class _NegotiationSettingsBottomSheet extends StatelessWidget {
  const _NegotiationSettingsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.neutral200, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(LucideIcons.dollarSign, color: AppColors.primary500),
              title: const Text('Make Final Offer'),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offer created!'), backgroundColor: AppColors.success500));
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.info, color: AppColors.neutral700),
              title: const Text('View Product Details'),
              onTap: () => context.pop(),
            ),
            ListTile(
              leading: const Icon(LucideIcons.xCircle, color: AppColors.error500),
              title: const Text('Cancel Negotiation', style: TextStyle(color: AppColors.error500)),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Negotiation cancelled.'), backgroundColor: AppColors.neutral700));
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AttachmentPickerBottomSheet extends StatelessWidget {
  const _AttachmentPickerBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachmentOption(icon: LucideIcons.image, label: 'Photo', color: Colors.blue, onTap: () => context.pop()),
                  _AttachmentOption(icon: LucideIcons.camera, label: 'Camera', color: Colors.pink, onTap: () => context.pop()),
                  _AttachmentOption(icon: LucideIcons.fileText, label: 'Document', color: Colors.orange, onTap: () => context.pop()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
