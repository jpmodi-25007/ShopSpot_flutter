import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'responsive_container.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral900,
      padding: const EdgeInsets.symmetric(vertical: 64.0),
      child: ResponsiveContainer(
        child: Column(
          children: [
            Wrap(
              spacing: 64,
              runSpacing: 48,
              children: [
                // Brand Column
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.neutral800,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(LucideIcons.store, color: AppColors.white),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ShopSpot',
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Empowering local commerce. Connecting customers, businesses, and influencers in one seamless platform.',
                        style: AppTextStyles.body.copyWith(color: AppColors.neutral400),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _SocialIcon(icon: LucideIcons.messageCircle, onPressed: () {}),
                          _SocialIcon(icon: LucideIcons.camera, onPressed: () {}),
                          _SocialIcon(icon: LucideIcons.briefcase, onPressed: () {}),
                        ],
                      ),
                    ],
                  ),
                ),

                // Links Columns
                _FooterColumn(
                  title: 'Platform',
                  links: const [
                    {'title': 'Features', 'route': '/features'},
                    {'title': 'How It Works', 'route': '/how-it-works'},
                    {'title': 'Pricing', 'route': '/pricing'},
                  ],
                ),
                _FooterColumn(
                  title: 'Company',
                  links: const [
                    {'title': 'About Us', 'route': '/about'},
                    {'title': 'Contact', 'route': '/contact'},
                    {'title': 'Careers', 'route': '/careers'},
                  ],
                ),
                _FooterColumn(
                  title: 'Resources',
                  links: const [
                    {'title': 'Help Center', 'route': '/faq'},
                    {'title': 'Blog', 'route': '/blog'},
                    {'title': 'Community', 'route': '/community'},
                  ],
                ),
                _FooterColumn(
                  title: 'Legal',
                  links: const [
                    {'title': 'Privacy Policy', 'route': '/privacy'},
                    {'title': 'Terms of Service', 'route': '/terms'},
                  ],
                ),
              ],
            ),
            const SizedBox(height: 64),
            Container(
              padding: const EdgeInsets.only(top: 24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.neutral800)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© ${DateTime.now().year} ShopSpot. All rights reserved.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
                  ),
                  Row(
                    children: [
                      const Icon(LucideIcons.globe, size: 16, color: AppColors.neutral500),
                      const SizedBox(width: 8),
                      Text(
                        'English (US)',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialIcon({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.neutral400),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.neutral800,
          hoverColor: AppColors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<Map<String, String>> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h6.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ...links.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if (link['route'] != null) {
                        context.go(link['route']!);
                      }
                    },
                    child: Text(
                      link['title']!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
