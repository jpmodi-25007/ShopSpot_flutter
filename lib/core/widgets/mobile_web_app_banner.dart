import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../network/api_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MobileWebAppBanner extends StatefulWidget {
  final Widget child;

  const MobileWebAppBanner({super.key, required this.child});

  @override
  State<MobileWebAppBanner> createState() => _MobileWebAppBannerState();
}

class _MobileWebAppBannerState extends State<MobileWebAppBanner> {
  bool _isVisible = true;

  bool get _isMobileWeb {
    if (!kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;
  }

  void _launchAppStore() async {
    final url = defaultTargetPlatform == TargetPlatform.iOS ? ApiConstants.appStoreUrl : ApiConstants.playStoreUrl;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMobileWeb || !_isVisible) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            elevation: 4,
            color: AppColors.white,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.neutral200)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.neutral500),
                      onPressed: () {
                        setState(() {
                          _isVisible = false;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ShopSpot', style: AppTextStyles.h4),
                          Text('Get the best experience in our app', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _launchAppStore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('OPEN'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
