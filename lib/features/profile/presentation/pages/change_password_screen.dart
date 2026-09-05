import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../authentication/data/datasources/auth_remote_data_source.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authDataSource = getIt<AuthRemoteDataSource>();
      await authDataSource.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: AppColors.success500, // or success600
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: AppColors.error500,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text('Change Password', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a New Password',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 8),
              Text(
                'Your new password must be different from previous used passwords.',
                style: AppTextStyles.body.copyWith(color: AppColors.neutral600),
              ),
              const SizedBox(height: 32),
              
              // Old Password
              Text('Old Password', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  hintText: 'Enter old password',
                  prefixIcon: const Icon(LucideIcons.lock, color: AppColors.neutral500),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOld ? LucideIcons.eyeOff : LucideIcons.eye, color: AppColors.neutral500),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              
              // New Password
              Text('New Password', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  hintText: 'Enter new password',
                  prefixIcon: const Icon(LucideIcons.lock, color: AppColors.neutral500),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? LucideIcons.eyeOff : LucideIcons.eye, color: AppColors.neutral500),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Confirm Password
              Text('Confirm New Password', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  prefixIcon: const Icon(LucideIcons.lock, color: AppColors.neutral500),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye, color: AppColors.neutral500),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Reset Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
