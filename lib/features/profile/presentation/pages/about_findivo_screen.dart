import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AboutFindivoScreen extends StatelessWidget {
  const AboutFindivoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('About Findivo', style: AppTextStyles.h3),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.store, size: 40, color: AppColors.primary500),
                  ),
                  const SizedBox(height: 16),
                  Text('Findivo', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0', style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Our Mission', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  Text(
                    'Findivo is dedicated to connecting local shoppers with nearby boutique stores. We believe in empowering local businesses by giving them a powerful digital presence, while offering customers unique deals they won\'t find anywhere else.',
                    style: AppTextStyles.body.copyWith(color: AppColors.neutral600, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  _buildLinkRow(LucideIcons.fileText, 'Terms of Service', () {}),
                  const Divider(height: 1),
                  _buildLinkRow(LucideIcons.shield, 'Privacy Policy', () {}),
                  const Divider(height: 1),
                  _buildLinkRow(LucideIcons.star, 'Rate us on App Store', () {}),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      '© 2026 Findivo, Inc.\nAll rights reserved.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkRow(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.neutral600),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
            ),
            const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }
}
