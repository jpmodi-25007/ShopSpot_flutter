import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/retailer_negotiation_bloc.dart';
import '../bloc/retailer_negotiation_event.dart';
import '../bloc/retailer_negotiation_state.dart';
import '../../../negotiation/domain/entities/negotiation_enums.dart';

class RetailerNegotiationChatScreen extends StatefulWidget {
  final String negotiationId;
  const RetailerNegotiationChatScreen({super.key, required this.negotiationId});

  @override
  State<RetailerNegotiationChatScreen> createState() => _RetailerNegotiationChatScreenState();
}

class _RetailerNegotiationChatScreenState extends State<RetailerNegotiationChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RetailerNegotiationBloc>().add(const GetShopNegotiationsRequested());
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
        title: Text('Customer Chat', style: AppTextStyles.h3.copyWith(color: AppColors.primary500)),
        centerTitle: true,
      ),
      body: BlocBuilder<RetailerNegotiationBloc, RetailerNegotiationState>(
        builder: (context, state) {
          if (state is RetailerNegotiationLoaded) {
            final negotiation = state.negotiations != null
                ? state.negotiations!.where((n) => n.id == widget.negotiationId).firstOrNull
                : state.activeNegotiation;

            if (negotiation == null) return const Center(child: Text("Loading..."));

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
                          Text('Customer', style: AppTextStyles.h4),
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
                                      Text('Offered: ₹${negotiation.offeredPrice.toStringAsFixed(0)}', style: AppTextStyles.body.copyWith(color: AppColors.primary500, fontWeight: FontWeight.w600)),
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
                      final isMe = m.senderRole == 'shopkeeper';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
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
                            child: Text(
                              m.content.isNotEmpty ? m.content : 'Offer updated',
                              style: AppTextStyles.body.copyWith(
                                color: isMe ? AppColors.white : AppColors.neutral800,
                              ),
                            ),
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
                              backgroundColor: AppColors.success500,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () {
                              context.read<RetailerNegotiationBloc>().add(ShopkeeperAcceptRequested(negotiation.id));
                              context.pop();
                            },
                            child: const Text('Accept Deal', style: TextStyle(fontWeight: FontWeight.w600)),
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
                               context.read<RetailerNegotiationBloc>().add(ShopkeeperCounterRequested(
                                 id: negotiation.id, 
                                 counterPrice: (negotiation.counterPrice ?? negotiation.offeredPrice) + 50
                               ));
                               context.pop();
                            },
                            child: const Text('Counter Offer', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
          return const Center(child: Text("Loading..."));
        },
      ),
    );
  }
}
