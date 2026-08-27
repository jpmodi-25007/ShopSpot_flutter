import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import '../../features/authentication/presentation/bloc/authentication_bloc.dart';
import '../../features/authentication/presentation/bloc/authentication_event.dart';

class LogoutDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.error50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.logOut,
                    color: AppColors.error500,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  "Log Out",
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Are you sure you want to log out of your account?",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.neutral600),
                ),
                const SizedBox(height: 32.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AppButton(
                        text: "Cancel",
                        variant: AppButtonVariant.outline,
                        color: AppColors.neutral600,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: "Log Out",
                        variant: AppButtonVariant.danger,
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<AuthenticationBloc>().add(const LogoutRequested());
                          context.go('/login');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
