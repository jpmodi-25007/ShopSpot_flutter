import 'package:flutter/material.dart';
import '../sections/cta_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

class WebAboutPage extends StatelessWidget {
  const WebAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        _buildStory(context),
        const CTASection(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.neutral50,
      padding: const EdgeInsets.symmetric(vertical: 80),
      width: double.infinity,
      child: ResponsiveContainer(
        child: Column(
          children: [
            Text(
              'About Us',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.neutral900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Empowering local commerce together.',
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStory(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContainer(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Mission',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 24),
            Text(
              'Findivo was built on a simple premise: local businesses are the heartbeat of our communities, but they often lack the digital tools to compete with e-commerce giants.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.neutral600, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              'We believe that shopping local should be as convenient, exciting, and rewarding as shopping online. By connecting shoppers, retailers, and local influencers, we are creating a thriving ecosystem that benefits everyone.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.neutral600, height: 1.6),
            ),
            const SizedBox(height: 64),
            Text(
              'What we do',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 24),
            Text(
              'We provide a seamless marketplace for customers to discover unique products from boutiques in their city. We equip store owners with a powerful dashboard to manage inventory and run targeted campaigns. And we give influencers a platform to monetize their local following by partnering with brands they genuinely love.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.neutral600, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
