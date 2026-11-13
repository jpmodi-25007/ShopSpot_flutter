import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<NegotiationBloc>().add(GetNegotiationDetailRequested(widget.negotiationId));
  }

  String _statusLabel(NegotiationStatus status) {
    switch (status) {
      case NegotiationStatus.PENDING:
        return 'Waiting for the shop';
      case NegotiationStatus.COUNTERED:
        return 'The shop sent a price';
      case NegotiationStatus.ACCEPTED:
        return 'Agreed';
      case NegotiationStatus.REJECTED:
        return 'Closed';
      case NegotiationStatus.EXPIRED:
        return 'Expired';
    }
  }

  String _clock(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _sendNewPrice(String id, double current) {
    final controller = TextEditingController(text: current.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your new price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Price in ₹', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text.trim());
              if (price == null || price <= 0) return;
              context.read<NegotiationBloc>().add(CounterOfferRequested(id: id, counterPrice: price));
              Navigator.pop(ctx);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _cancelOffer(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this offer?'),
        content: const Text('The shop will no longer be able to accept it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep it')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<NegotiationBloc>().add(RejectDealRequested(id));
            },
            child: const Text('Cancel offer', style: TextStyle(color: AppColors.error500)),
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            final state = context.read<NegotiationBloc>().state;
            final productId = state is NegotiationLoaded ? state.activeNegotiation?.productId : null;
            if (productId != null && productId.isNotEmpty) {
              context.go('/product-detail/$productId');
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text('Your offer', style: AppTextStyles.h3),
        centerTitle: true,
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
                child: const ShimmerBox(
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
            final open = negotiation.status == NegotiationStatus.PENDING || negotiation.status == NegotiationStatus.COUNTERED;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AppNetworkImage(
                              url: negotiation.product?.images.isNotEmpty == true ? negotiation.product!.images.first : null,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              placeholderIcon: LucideIcons.package,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(negotiation.product?.name ?? 'Product', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(negotiation.shop?.name ?? 'Shop', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_statusLabel(negotiation.status), style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary600)),
                      ),
                      const SizedBox(height: 12),
                      _PriceRow(label: 'Listed price', value: negotiation.initialPrice),
                      _PriceRow(label: 'Your offer', value: negotiation.offeredPrice, emphasized: negotiation.counterPrice == null && negotiation.finalPrice == null),
                      if (negotiation.counterPrice != null)
                        _PriceRow(label: 'Shop price', value: negotiation.counterPrice!, emphasized: negotiation.finalPrice == null),
                      if (negotiation.finalPrice != null)
                        _PriceRow(label: 'Agreed price', value: negotiation.finalPrice!, emphasized: true),
                      if ((negotiation.customerMessage ?? '').isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Your note', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(negotiation.customerMessage!, style: AppTextStyles.body),
                      ],
                      if ((negotiation.shopkeeperMessage ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Shop note', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(negotiation.shopkeeperMessage!, style: AppTextStyles.body),
                      ],
                      if (negotiation.messages.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('Updates', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ...negotiation.messages.map((message) {
                          final mine = message.senderRole == 'customer';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${mine ? 'You' : 'Shop'} · ${_clock(message.createdAt)}\n${message.content}',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral700),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                if (open || negotiation.product != null)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Column(
                        children: [
                          if (negotiation.status == NegotiationStatus.COUNTERED)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary500,
                                      foregroundColor: AppColors.white,
                                      minimumSize: const Size.fromHeight(48),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => context.read<NegotiationBloc>().add(AcceptDealRequested(negotiation.id)),
                                    child: Text('Accept ₹${negotiation.counterPrice?.toStringAsFixed(0) ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                    onPressed: () => _sendNewPrice(negotiation.id, negotiation.counterPrice ?? negotiation.offeredPrice),
                                    child: const Text('New price'),
                                  ),
                                ),
                              ],
                            ),
                          if (negotiation.status == NegotiationStatus.PENDING)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  foregroundColor: AppColors.error500,
                                  side: const BorderSide(color: AppColors.error100),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _cancelOffer(negotiation.id),
                                child: const Text('Cancel offer'),
                              ),
                            ),
                          if (negotiation.status == NegotiationStatus.COUNTERED)
                            TextButton(
                              onPressed: () => _cancelOffer(negotiation.id),
                              child: const Text('Decline', style: TextStyle(color: AppColors.error500)),
                            ),
                          if (negotiation.product != null && !open)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => context.push('/product-detail/${negotiation.product!.id}'),
                                child: const Text('View product'),
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

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasized;
  const _PriceRow({required this.label, required this.value, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.neutral600)),
          const Spacer(),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: AppTextStyles.body.copyWith(
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
              color: emphasized ? AppColors.primary600 : AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

