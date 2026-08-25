import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../../features/authentication/presentation/bloc/authentication_bloc.dart';
import '../../features/authentication/presentation/bloc/authentication_state.dart';

class GuestHelper {
  /// Checks if the user is a guest. If so, shows a login prompt bottom sheet and returns true.
  /// If the user is fully authenticated, returns false (meaning the action can proceed).
  static bool checkGuestAndPrompt(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    
    if (authState is AuthenticationGuest) {
      _showGuestBottomSheet(context);
      return true;
    }
    
    return false;
  }

  static void _showGuestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.roleCustomerLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.userPlus,
                  size: 40,
                  color: AppColors.roleCustomer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Unlock All Features',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Create an account or log in to save your favorite products, negotiate prices, and start shopping local.',
                style: AppTextStyles.body.copyWith(color: AppColors.neutral500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Login / Sign Up',
                size: AppButtonSize.fullWidth,
                onPressed: () {
                  context.pop(); // Close bottom sheet
                  context.go('/login'); // Route back to login
                },
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Maybe Later',
                variant: AppButtonVariant.outline,
                size: AppButtonSize.fullWidth,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
