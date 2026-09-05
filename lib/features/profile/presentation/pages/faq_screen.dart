import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('FAQs', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildFAQItem(
            'How do I apply for a campaign?',
            'Navigate to the Discover tab, browse available campaigns, and tap "Submit Bid" on any campaign that matches your niche. You can set your proposed fee and expected delivery date.',
          ),
          _buildFAQItem(
            'When do I get paid?',
            'Payments are released automatically to your linked bank account 24-48 hours after the brand approves your submitted deliverable.',
          ),
          _buildFAQItem(
            'How can I increase my chances of getting selected?',
            'Ensure your profile is complete with a bio, connected social accounts, and past portfolio examples. Submitting personalized bids with a clear plan of action also helps.',
          ),
          _buildFAQItem(
            'Can I withdraw a bid?',
            'Yes, you can withdraw a bid at any time before the brand accepts it. Once accepted, it becomes an ongoing campaign.',
          ),
          _buildFAQItem(
            'What if the brand rejects my submission?',
            'If a brand requests changes or rejects a submission, you will receive a notification outlining the requested revisions. You can upload a new submission link from the Bid Details screen.',
          ),
          const SizedBox(height: 32),
          Text(
            'Still need help?',
            style: AppTextStyles.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse('mailto:support@shopspot.com');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: Text(
              'Contact us at support@shopspot.com',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary500,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              answer,
              style: AppTextStyles.body.copyWith(color: AppColors.neutral600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
