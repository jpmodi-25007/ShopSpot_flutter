import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';

/// Second step of the forgot-password flow: the user enters the 6-digit code
/// that was sent to them together with a new password.
class ResetPasswordScreen extends StatefulWidget {
  final String emailOrPhone;

  const ResetPasswordScreen({super.key, required this.emailOrPhone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _errorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        return msg is List ? msg.join('\n') : msg.toString();
      }
    }
    return 'Failed to reset password. Please try again.';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await getIt<ApiClient>().post(
        ApiConstants.resetPassword,
        data: {
          'emailOrPhone': widget.emailOrPhone,
          'code': _codeController.text.trim(),
          'newPassword': _passwordController.text,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully. Please log in.'),
          backgroundColor: AppColors.success600,
        ),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage(e)),
          backgroundColor: AppColors.error500,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neutral900.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.lock,
                            color: AppColors.neutral900, size: 48),
                      ),
                      const SizedBox(height: 28),
                      Text('Reset Password',
                          style: AppTextStyles.h1, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(
                        'Enter the 6-digit code we sent you and choose a new password.',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.neutral500, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AppTextField(
                        label: 'Reset Code',
                        hintText: '6-digit code',
                        prefixIcon: const Icon(LucideIcons.hash, size: 20),
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || !RegExp(r'^\d{6}$').hasMatch(val.trim())) {
                            return 'Enter the 6-digit code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'New Password',
                        hintText: 'At least 8 characters',
                        prefixIcon: const Icon(LucideIcons.lock, size: 20),
                        controller: _passwordController,
                        obscureText: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? LucideIcons.eyeOff : LucideIcons.eye, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: ValidationUtils.validatePassword,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Confirm Password',
                        hintText: 'Re-enter new password',
                        prefixIcon: const Icon(LucideIcons.lock, size: 20),
                        controller: _confirmController,
                        obscureText: _obscure,
                        validator: (val) => val != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neutral900,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CupertinoActivityIndicator(color: AppColors.white))
                            : Text('Reset Password',
                                style: AppTextStyles.button
                                    .copyWith(color: AppColors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
