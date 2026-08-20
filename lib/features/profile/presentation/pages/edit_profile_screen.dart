import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import '../../../authentication/presentation/bloc/authentication_event.dart';
import '../../../authentication/presentation/bloc/authentication_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthenticationBloc>().state;
    String initialName = '';
    String initialEmail = '';
    String initialPhone = '';

    if (authState is AuthenticationLoaded) {
      initialName = authState.user.name;
      initialEmail = authState.user.email;
      initialPhone = authState.user.mobile ?? '';
    }

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: initialEmail);
    _phoneController = TextEditingController(text: initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.h4),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.camera, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    controller: _nameController,
                    prefixIcon: const Icon(LucideIcons.user),
                    validator: (val) => ValidationUtils.validateRequired(val, fieldName: 'Full Name'),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Email Address',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    prefixIcon: const Icon(LucideIcons.mail),
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Phone Number',
                    hintText: 'Enter your phone number',
                    controller: _phoneController,
                    prefixIcon: const Icon(LucideIcons.phone),
                    keyboardType: TextInputType.phone,
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            BlocConsumer<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                if (state is AuthenticationLoaded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.success500),
                  );
                  Navigator.of(context).pop();
                } else if (state is AuthenticationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.failure.message), backgroundColor: AppColors.error500),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthenticationLoading;
                return AppButton(
                  text: 'Save Changes',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : () {
                    if (_formKey.currentState?.validate() ?? false) {
                      context.read<AuthenticationBloc>().add(
                        UpdateProfileRequested(name: _nameController.text.trim()),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
