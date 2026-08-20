import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitted = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOutCubic));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: _animController, curve: Curves.easeOutBack));

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final emailOrPhone = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = getIt<ApiClient>();
      await apiClient.post(
        ApiConstants.forgotPassword,
        data: {'emailOrPhone': emailOrPhone},
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitted = true;
        });
        
        // Retrigger animations for success state
        _animController.reset();
        _animController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to send instructions. Please try again.'),
              backgroundColor: AppColors.error500),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral900),
          onPressed: () => context.pop(),
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
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
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
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Icon container
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _isSubmitted
                                  ? AppColors.success50
                                  : AppColors.neutral100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isSubmitted
                                  ? LucideIcons.mailCheck
                                  : LucideIcons.key,
                              color: _isSubmitted
                                  ? AppColors.success600
                                  : AppColors.neutral900,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        Text(
                          _isSubmitted ? 'Check your mail' : 'Forgot Password',
                          style: AppTextStyles.h1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          _isSubmitted
                              ? 'We have sent password recovery instructions to your email.'
                              : 'No worries! Enter your email or phone below and we will send you recovery instructions.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.neutral500,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),

                        if (!_isSubmitted) ...[
                          Form(
                            key: _formKey,
                            child: AppTextField(
                              label: 'Email or Phone',
                              hintText: 'e.g. john@example.com or 9876543210',
                              prefixIcon:
                                  const Icon(LucideIcons.user, size: 20),
                              controller: _emailController,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'This field is required';
                                }
                                if (val.contains('@')) {
                                  return ValidationUtils.validateEmail(val);
                                }
                                return ValidationUtils.validatePhone(val);
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neutral900,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _isLoading ? null : _submitForgotPassword,
                            child: _isLoading 
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                                : Text('Send Reset Link', style: AppTextStyles.button.copyWith(color: AppColors.white)),
                          ),
                        ] else ...[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neutral900,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => context.pop(),
                            child: Text('Back to Login', style: AppTextStyles.button.copyWith(color: AppColors.white)),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() => _isSubmitted = false);
                              _animController.reset();
                              _animController.forward();
                            },
                            child: Text(
                              'Resend Email',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.neutral900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
