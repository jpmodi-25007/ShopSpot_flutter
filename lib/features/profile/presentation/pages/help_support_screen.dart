import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Help & Support', style: AppTextStyles.h3),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(LucideIcons.headset,
                    size: 48, color: AppColors.primary500),
                const SizedBox(height: 16),
                Text('How can we help you?', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  'Our support team is here to help you 24/7. Browse our FAQs or contact us directly.',
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Frequently Asked Questions', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _buildFaqItem(
            'How do I negotiate a price?',
            'You can start a negotiation directly from the product page by tapping "Negotiate". Enter your offer, and the shopkeeper will respond.',
          ),
          _buildFaqItem(
            'How long does an order take to process?',
            'Most orders are processed within 24 hours. You can check the status in the "My Orders" section of your profile.',
          ),
          _buildFaqItem(
            'Can I return a purchased item?',
            'Returns depend on the individual shop policy. You can find return policies on the shop details page.',
          ),
          const SizedBox(height: 32),
          Text('Contact Us', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _buildContactCard(
              LucideIcons.mail, 'Email Support', 'support@findivo.com'),
          const SizedBox(height: 12),
          _buildContactCard(LucideIcons.phone, 'Call Us', '+1 (800) 123-4567'),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: ExpansionTile(
        title: Text(question,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        iconColor: AppColors.primary500,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(answer,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.neutral600)),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.neutral700, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text(detail,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary500)),
            ],
          ),
        ],
      ),
    );
  }
}
