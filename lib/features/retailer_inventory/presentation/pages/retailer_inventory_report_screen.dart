import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/retailer_inventory_bloc.dart';
import '../bloc/retailer_inventory_state.dart';

class RetailerInventoryReportScreen extends StatelessWidget {
  const RetailerInventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Inventory Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<RetailerInventoryBloc, RetailerInventoryState>(
        builder: (context, state) {
          if (state is! RetailerInventoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = state.products;
          final totalValue = products.fold<double>(
              0, (sum, p) => sum + (p.sellingPrice * p.stockQuantity));
          
          final lowStockCount = products.where((p) => p.stockQuantity > 0 && p.stockQuantity < 10).length;
          final outOfStockCount = products.where((p) => p.stockQuantity <= 0).length;
          final inStockCount = products.length - lowStockCount - outOfStockCount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard('Total Inventory Value', '₹${totalValue.toStringAsFixed(2)}', LucideIcons.wallet, AppColors.roleRetailer),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Total Products', '${products.length}', LucideIcons.package, AppColors.info500)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMetricCard('Out of Stock', '$outOfStockCount', LucideIcons.alertOctagon, AppColors.error500)),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Stock Health', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _buildHealthBar(inStockCount, lowStockCount, outOfStockCount, products.length),
                const SizedBox(height: 32),
                Text('Top Performing Categories', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                _buildCategoryList(products),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading Report as PDF...')),
                      );
                    },
                    icon: const Icon(LucideIcons.download),
                    label: const Text('Download Full Report'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.roleRetailer),
                      foregroundColor: AppColors.roleRetailer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.h1),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.neutral900.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }

  Widget _buildHealthBar(int inStock, int lowStock, int outOfStock, int total) {
    if (total == 0) return const SizedBox.shrink();
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Row(
            children: [
              Expanded(
                flex: inStock,
                child: Container(height: 12, color: AppColors.success500),
              ),
              Expanded(
                flex: lowStock,
                child: Container(height: 12, color: AppColors.warning500),
              ),
              Expanded(
                flex: outOfStock,
                child: Container(height: 12, color: AppColors.error500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem('Healthy', AppColors.success500),
            _buildLegendItem('Low Stock', AppColors.warning500),
            _buildLegendItem('Out of Stock', AppColors.error500),
          ],
        )
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildCategoryList(List<dynamic> products) {
    final Map<String, int> catCounts = {};
    for (var p in products) {
      final cat = p.categoryId ?? 'Uncategorized';
      catCounts[cat] = (catCounts[cat] ?? 0) + 1;
    }
    final sortedCats = catCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      children: sortedCats.take(3).map((cat) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cat.key, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            Text('${cat.value} items', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
          ],
        ),
      )).toList(),
    );
  }
}
