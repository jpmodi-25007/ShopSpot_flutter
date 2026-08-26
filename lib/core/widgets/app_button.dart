import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/authentication/presentation/bloc/authentication_bloc.dart';
import '../../features/authentication/presentation/bloc/authentication_state.dart';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }
enum AppButtonSize { small, medium, large, fullWidth }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final Color? color;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    // Dynamically determine primary color based on auth role if none provided
    Color getPrimaryColor() {
      if (color != null) return color!;
      try {
        final authState = context.read<AuthenticationBloc>().state;
        if (authState is AuthenticationLoaded) {
          switch (authState.user.role) {
            case 'SHOPKEEPER': return AppColors.roleRetailer;
            case 'INFLUENCER': return AppColors.roleInfluencer;
            case 'CUSTOMER': return AppColors.roleCustomer;
          }
        }
      } catch (_) {
        // Fallback if bloc is not available or not loaded
      }
      return AppColors.primary500;
    }

    final activeColor = getPrimaryColor();

    Color getBackgroundColor() {
      if (isDisabled && variant != AppButtonVariant.outline && variant != AppButtonVariant.ghost) {
        return AppColors.neutral300;
      }
      switch (variant) {
        case AppButtonVariant.primary:
          return activeColor;
        case AppButtonVariant.secondary:
          return AppColors.secondary500;
        case AppButtonVariant.danger:
          return AppColors.error500;
        case AppButtonVariant.outline:
        case AppButtonVariant.ghost:
          return Colors.transparent;
      }
    }

    Color getTextColor() {
      if (isDisabled) return AppColors.neutral500;
      switch (variant) {
        case AppButtonVariant.primary:
        case AppButtonVariant.secondary:
        case AppButtonVariant.danger:
          return AppColors.white;
        case AppButtonVariant.outline:
          return activeColor;
        case AppButtonVariant.ghost:
          return AppColors.neutral700;
      }
    }

    BorderSide? getBorder() {
      if (variant == AppButtonVariant.outline) {
        return BorderSide(color: isDisabled ? AppColors.neutral300 : activeColor);
      }
      return null;
    }

    double getHeight() {
      switch (size) {
        case AppButtonSize.small:
          return 32.0;
        case AppButtonSize.medium:
          return 44.0;
        case AppButtonSize.large:
        case AppButtonSize.fullWidth:
          return 56.0;
      }
    }

    TextStyle getTextStyle() {
      switch (size) {
        case AppButtonSize.small:
          return AppTextStyles.caption;
        case AppButtonSize.medium:
          return AppTextStyles.button;
        case AppButtonSize.large:
        case AppButtonSize.fullWidth:
          return AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600);
      }
    }

    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 20, color: getTextColor()),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: getTextStyle().copyWith(color: getTextColor()),
        ),
      ],
    );

    return SizedBox(
      height: getHeight(),
      width: size == AppButtonSize.fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBackgroundColor(),
          foregroundColor: getTextColor(),
          elevation: (variant == AppButtonVariant.ghost || variant == AppButtonVariant.outline || isDisabled) ? 0 : 2,
          shadowColor: AppColors.neutral900.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size == AppButtonSize.small ? 4 : 8),
            side: getBorder() ?? BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == AppButtonSize.small ? 12 : (size == AppButtonSize.large || size == AppButtonSize.fullWidth ? 24 : 16),
          ),
        ),
        child: buttonContent,
      ),
    );
  }
}
