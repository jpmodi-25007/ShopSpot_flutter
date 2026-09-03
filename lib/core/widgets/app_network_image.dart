import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../utils/cloudinary_url_builder.dart';

/// A null-safe, shimmer-loading network image widget.
///
/// Handles all edge cases:
///   - null / empty URL → shows [placeholder]
///   - loading          → shows shimmer animation
///   - error            → shows [errorWidget]
///
/// Usage:
/// ```dart
/// AppNetworkImage(
///   url: campaign.productImageUrl,
///   width: 80,
///   height: 80,
///   fit: BoxFit.cover,
///   borderRadius: BorderRadius.circular(12),
/// )
/// ```
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final IconData? placeholderIcon;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.placeholderIcon,
  });

  bool get _isValidUrl {
    if (url == null || url!.isEmpty) return false;
    final trimmed = url!.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: backgroundColor ?? AppColors.neutral100,
          child: Center(
            child: Icon(
              placeholderIcon ?? LucideIcons.image,
              color: AppColors.neutral400,
              size: 24,
            ),
          ),
        );
  }

  Widget _buildError() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: backgroundColor ?? AppColors.neutral100,
          child: const Center(
            child: Icon(
              LucideIcons.imageOff,
              color: AppColors.neutral400,
              size: 24,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: _buildPlaceholder(),
      );
    }

    final optimizedUrl = CloudinaryUrlBuilder.buildUrl(
      secureUrl: url!,
      width: width?.toInt(),
      height: height?.toInt(),
      cropMode: 'fill',
    );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        optimizedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _AppImageShimmer(width: width, height: height);
        },
        errorBuilder: (context, error, stackTrace) => _buildError(),
      ),
    );
  }
}

/// Internal animated shimmer used while images load.
class _AppImageShimmer extends StatefulWidget {
  final double? width;
  final double? height;

  const _AppImageShimmer({this.width, this.height});

  @override
  State<_AppImageShimmer> createState() => _AppImageShimmerState();
}

class _AppImageShimmerState extends State<_AppImageShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        color: Color.lerp(AppColors.neutral100, AppColors.neutral200, _animation.value),
      ),
    );
  }
}
