import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<RetailerNegotiationBloc>().add(const GetShopNegotiationsRequested(limit: 50));
  }

  String _statusLabel(NegotiationStatus status) {
    switch (status) {
      case NegotiationStatus.PENDING:
        return 'Customer is waiting';
      case NegotiationStatus.COUNTERED:
        return 'Waiting for the customer';
      case NegotiationStatus.ACCEPTED:
        return 'Agreed';
      case NegotiationStatus.REJECTED:
        return 'Closed';
      case NegotiationStatus.EXPIRED:
        return 'Expired';
    }
  }

  void _sendCounter(String id, double current) {
    final controller = TextEditingController(text: current.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your price'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Price in ₹',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text.trim());
              if (price == null || price <= 0) return;
              context.read<RetailerNegotiationBloc>().add(
                    ShopkeeperCounterRequested(id: id, counterPrice: price),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text('Customer offer', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: BlocConsumer<RetailerNegotiationBloc, RetailerNegotiationState>(
        listener: (context, state) {
          if (state is RetailerNegotiationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error500),
            );
          }
        },
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
                          Text(negotiation.customerName ?? 'Customer', style: AppTextStyles.h4),
                          const Spacer(),
                          Text(_statusLabel(negotiation.status), style: AppTextStyles.caption.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w700)),
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
                              child: AppNetworkImage(
                                url: negotiation.product?.images.isNotEmpty == true
                                    ? negotiation.product!.images.first
                                    : null,
                                width: 40,
                                height: 40,
                                placeholderIcon: LucideIcons.package,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(negotiation.product?.name ?? 'Product', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('Listed ₹${negotiation.initialPrice.toStringAsFixed(0)}', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                                  Text('Customer offer ₹${negotiation.offeredPrice.toStringAsFixed(0)}', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                                  if (negotiation.counterPrice != null)
                                    Text('Your price ₹${negotiation.counterPrice!.toStringAsFixed(0)}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w700)),
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
                            onPressed: state.isSubmitting
                                ? null
                                : () => context.read<RetailerNegotiationBloc>().add(ShopkeeperAcceptRequested(negotiation.id)),
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
                            onPressed: state.isSubmitting
                                ? null
                                : () => _sendCounter(
                                      negotiation.id,
                                      negotiation.counterPrice ?? negotiation.offeredPrice,
                                    ),
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
