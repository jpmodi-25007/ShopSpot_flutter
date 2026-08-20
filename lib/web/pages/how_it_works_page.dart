import 'package:flutter/material.dart';
import '../sections/how_it_works_section.dart';
import '../sections/cta_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

class WebHowItWorksPage extends StatelessWidget {
  const WebHowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const HowItWorksSection(),
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
              'How It Works',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.neutral900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Getting started is easier than you think.',
              style: AppTextStyles.h4.copyWith(color: AppColors.neutral700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
