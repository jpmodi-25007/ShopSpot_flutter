import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WebContactPage extends StatefulWidget {
  const WebContactPage({super.key});

  @override
  State<WebContactPage> createState() => _WebContactPageState();
}

class _WebContactPageState extends State<WebContactPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isSuccess = false;

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });
      
      // Simulate network request
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _isSuccess = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Column(
      children: [
        _buildHeader(context),
        Container(
          color: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
          child: ResponsiveContainer(
            maxWidth: 1000,
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Get in touch', style: AppTextStyles.h2),
                      const SizedBox(height: 24),
                      Text(
                        'Our team is here to help. Send us a message and we will respond within 24 hours.',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.neutral600),
                      ),
                      const SizedBox(height: 48),
                      _buildContactMethod(
                        icon: LucideIcons.mail,
                        title: 'Email Us',
                        value: 'support@shopspot.com',
                      ),
                      const SizedBox(height: 32),
                      _buildContactMethod(
                        icon: LucideIcons.phone,
                        title: 'Call Us',
                        value: '+1 (555) 123-4567',
                      ),
                      const SizedBox(height: 32),
                      _buildContactMethod(
                        icon: LucideIcons.mapPin,
                        title: 'Visit Us',
                        value: '123 Market Street, San Francisco, CA',
                      ),
                    ],
                  ),
                ),
                if (isMobile) const SizedBox(height: 48),
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Container(
                    margin: EdgeInsets.only(left: isMobile ? 0 : 64),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neutral900.withValues(alpha: 0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: _isSuccess ? _buildSuccessMessage() : _buildForm(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.neutral50,
      padding: const EdgeInsets.symmetric(vertical: 80),
      width: double.infinity,
      child: ResponsiveContainer(
        child: Column(
          children: [
            Text(
              'Contact Us',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.neutral900),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod({required IconData icon, required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.neutral900),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h6),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.body.copyWith(color: AppColors.neutral600)),
          ],
        )
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputLabel('Name'),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'John Doe',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 24),
          _buildInputLabel('Email'),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'john@example.com',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!value.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildInputLabel('Message'),
          TextFormField(
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'How can we help you?',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter a message' : null,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neutral900,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                : const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const Icon(LucideIcons.checkCircle, color: AppColors.success500, size: 64),
        const SizedBox(height: 24),
        Text('Message Sent!', style: AppTextStyles.h4, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(
          'Thank you for reaching out. We will get back to you shortly.',
          style: AppTextStyles.body.copyWith(color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _isSuccess = false;
              _formKey.currentState?.reset();
            });
          },
          child: const Text('Send another message'),
        )
      ],
    );
  }
}
