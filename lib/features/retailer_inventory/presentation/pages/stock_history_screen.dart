import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/retailer_inventory_bloc.dart';
import '../bloc/retailer_inventory_event.dart';
import '../bloc/retailer_inventory_state.dart';

class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  final _bloc = getIt<RetailerInventoryBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.add(const GetStockHistoryRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          backgroundColor: AppColors.neutral50,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
            onPressed: () => context.pop(),
          ),
          title: Text('Stock History', style: AppTextStyles.h3),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.moreVertical, color: AppColors.neutral900),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const _StockFilterBottomSheet(),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<RetailerInventoryBloc, RetailerInventoryState>(
          builder: (context, state) {
            if (state is RetailerInventoryLoading) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  StockHistoryItemSkeleton(),
                  SizedBox(height: 20),
                  StockHistoryItemSkeleton(),
                  SizedBox(height: 20),
                  StockHistoryItemSkeleton(),
                ],
              );
            }
            if (state is RetailerInventoryError) {
              return Center(child: Text(state.failure.message, style: AppTextStyles.body.copyWith(color: Colors.red)));
            }

            List<Map<String, dynamic>> history = [];
            if (state is StockHistoryLoaded) {
              history = state.stockHistory;
            }

            return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Filter Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date Range', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutral300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.calendar, size: 16, color: AppColors.neutral400),
                            const SizedBox(width: 8),
                            Text('Oct 1, 2023 - Oct 31, 2023', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Reason', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutral300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.alignLeft, size: 16, color: AppColors.neutral400),
                                const SizedBox(width: 8),
                                Text('All Reasons', style: AppTextStyles.bodySmall),
                              ],
                            ),
                            const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.neutral400),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Preparing export...'), backgroundColor: AppColors.neutral700),
                            );
                            await Future.delayed(const Duration(seconds: 1));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Export saved to documents!'), backgroundColor: AppColors.success500),
                              );
                            }
                          },
                          icon: const Icon(LucideIcons.download, size: 16, color: AppColors.roleRetailer),
                          label: Text('Export', style: AppTextStyles.bodySmall.copyWith(color: AppColors.roleRetailer, fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.roleRetailerLight.withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (history.isEmpty && state is StockHistoryLoaded)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No stock history found.'),
                    ),
                  ),

                ...history.map((item) {
                  final qty = item['quantity'] ?? 0;
                  final isIncrease = qty > 0;
                  final qtyStr = isIncrease ? '+$qty' : qty.toString();
                  final dt = DateTime.parse(item['createdAt']);
                  final formattedDate = DateFormat('MMM dd, yyyy, hh:mm a').format(dt);
                  final product = item['product'] ?? {};

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildHistoryItem(
                      time: formattedDate,
                      productName: product['name'] ?? 'Unknown',
                      sku: product['sku'] ?? 'N/A',
                      qtyChange: qtyStr,
                      isIncrease: isIncrease,
                      reason: item['reason'] ?? 'Unknown',
                      reasonColor: isIncrease ? AppColors.success600 : Colors.red,
                      reasonBgColor: isIncrease ? AppColors.success50 : AppColors.error50,
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Pagination Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: const Border(top: BorderSide(color: AppColors.neutral200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing 1 to 3 of 124 entries', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.neutral200), borderRadius: BorderRadius.circular(4)),
                      child: const Icon(LucideIcons.chevronLeft, size: 16, color: AppColors.neutral400),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.neutral200), borderRadius: BorderRadius.circular(4)),
                      child: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.neutral900),
                    ),
                  ],
                ),
              ],
            ),
          ),
            ],
          );
        },
      ),
    ));
  }

  Widget _buildHistoryItem({
    required String time,
    required String productName,
    required String sku,
    required String qtyChange,
    required bool isIncrease,
    required String reason,
    Color? reasonColor,
    Color? reasonBgColor,
  }) {
    final defaultReasonColor = isIncrease ? AppColors.roleRetailer : AppColors.roleRetailer; // Mockup shows blue/primary for Sale and Purchase
    final defaultReasonBg = isIncrease ? AppColors.roleRetailerLight.withValues(alpha: 0.5) : AppColors.roleRetailerLight.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.clock, size: 14, color: AppColors.neutral400),
            const SizedBox(width: 6),
            Text(time, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(color: AppColors.neutral900.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(productName[0], style: AppTextStyles.h4.copyWith(color: AppColors.neutral400)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productName, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        Text('SKU: $sku', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Qty:', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                  Row(
                    children: [
                      Icon(isIncrease ? LucideIcons.arrowUp : LucideIcons.arrowDown, size: 14, color: isIncrease ? AppColors.success500 : AppColors.error500),
                      const SizedBox(width: 4),
                      Text(qtyChange, style: AppTextStyles.bodySmall.copyWith(color: isIncrease ? AppColors.success500 : AppColors.error500, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reason:', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: reasonBgColor ?? defaultReasonBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(reason, style: AppTextStyles.caption.copyWith(color: reasonColor ?? defaultReasonColor, fontWeight: FontWeight.w600, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Staff:', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                  const Icon(LucideIcons.userCircle, size: 16, color: AppColors.neutral600),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StockFilterBottomSheet extends StatefulWidget {
  const _StockFilterBottomSheet();

  @override
  State<_StockFilterBottomSheet> createState() => _StockFilterBottomSheetState();
}

class _StockFilterBottomSheetState extends State<_StockFilterBottomSheet> {
  String _selectedRange = 'Last 7 Days';

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  Text('Filter Stock History', style: AppTextStyles.h3),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => context.pop()),
                ],
              ),
              const SizedBox(height: 24),
              Text('Date Range', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Today', 'Last 7 Days', 'Last 30 Days', 'This Year', 'Custom Range']
                    .map((s) => ChoiceChip(
                          label: Text(s),
                          selected: _selectedRange == s,
                          onSelected: (val) {
                            if (val) setState(() => _selectedRange = s);
                          },
                          selectedColor: AppColors.roleRetailerLight.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: _selectedRange == s ? AppColors.roleRetailer : AppColors.neutral700,
                            fontWeight: _selectedRange == s ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roleRetailer,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => context.pop(),
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

