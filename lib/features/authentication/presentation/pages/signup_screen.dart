import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/legal_document_bottom_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/utils/responsive_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../bloc/authentication_state.dart';
import '../../../../core/utils/validation_utils.dart';

// ─── Role config (shared with login) ──────────────────────────────────────────
class _RoleConfig {
  final String id;
  final String label;
  final IconData icon;
  final String benefit;
  final Color color;
  final Color lightColor;
  const _RoleConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.benefit,
    required this.color,
    required this.lightColor,
  });
}

const _roles = [
  _RoleConfig(
    id: 'CUSTOMER',
    label: 'Customer',
    icon: LucideIcons.shoppingBag,
    benefit: 'Discover & shop local boutiques',
    color: AppColors.roleCustomer,
    lightColor: AppColors.roleCustomerLight,
  ),
  _RoleConfig(
    id: 'SHOPKEEPER',
    label: 'Retailer',
    icon: LucideIcons.store,
    benefit: 'Sell products & run campaigns',
    color: AppColors.roleRetailer,
    lightColor: AppColors.roleRetailerLight,
  ),
  _RoleConfig(
    id: 'INFLUENCER',
    label: 'Influencer',
    icon: LucideIcons.trendingUp,
    benefit: 'Partner with brands & earn',
    color: AppColors.roleInfluencer,
    lightColor: AppColors.roleInfluencerLight,
  ),
];

class SignupScreen extends StatefulWidget {
  final String? initialRole;
  const SignupScreen({super.key, this.initialRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;
  late String _selectedRole;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _businessNameController =
      TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController();

  late AnimationController _formController;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  _RoleConfig get _currentRole =>
      _roles.firstWhere((r) => r.id == _selectedRole);

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'CUSTOMER';
    if (_selectedRole == 'customer') _selectedRole = 'CUSTOMER';
    if (_selectedRole == 'retailer') _selectedRole = 'SHOPKEEPER';
    if (_selectedRole == 'influencer') _selectedRole = 'INFLUENCER';

    _formController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _formFade =
        CurvedAnimation(parent: _formController, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _formController, curve: Curves.easeOutCubic));
    _formController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _usernameController.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _switchRole(String role) {
    if (role == _selectedRole) return;
    setState(() => _selectedRole = role);
    _formController.reset();
    _formController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: ResponsiveBuilder(
          mobile: _buildMobileLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  // ── Mobile layout ───────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        // Fixed background hero
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 380, // Fixed height that works well on all screens
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/login_panel_hero.jpg',
                  fit: BoxFit.cover),
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _currentRole.color.withValues(alpha: 0.3),
                      AppColors.neutral900.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft,
                      color: AppColors.white),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Scrollable content
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Transparent spacer to reveal the background image
              Container(
                height: 150,
                color: Colors.transparent,
              ),
              // Welcome text inside the scroll view so it scrolls naturally
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _currentRole.color.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_currentRole.icon,
                          color: AppColors.white, size: 22),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedRole == 'SHOPKEEPER'
                          ? 'Open Your Store'
                          : _selectedRole == 'INFLUENCER'
                              ? 'Join as a Creator'
                              : 'Create an Account',
                      style: AppTextStyles.h2.copyWith(
                          color: AppColors.white, fontSize: 26),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // The form card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.neutral900.withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, -4))
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 150 - 150,
                ),
                child: _buildFormContent(isMobile: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Desktop layout ──────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.panelBackground,
              image: DecorationImage(
                image: AssetImage('assets/images/login_panel_hero.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.panelGradientBottom,
                    AppColors.panelGradientMid,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.45, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.store,
                      color: AppColors.white, size: 48),
                  const SizedBox(height: 16),
                  Text('Join Findivo',
                      style: AppTextStyles.h1.copyWith(
                          color: AppColors.white, fontSize: 32)),
                  const SizedBox(height: 10),
                  Text(
                    'Connect with your neighbourhood — as a shopper, retailer, or creator.',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                        height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 8),
                    _buildFormContent(isMobile: false),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared form content ─────────────────────────────────────────────────────
  Widget _buildFormContent({required bool isMobile}) {
    final isRetailer = _selectedRole == 'SHOPKEEPER';
    final isInfluencer = _selectedRole == 'INFLUENCER';

    return FadeTransition(
      opacity: _formFade,
      child: SlideTransition(
        position: _formSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Text(
                isRetailer
                    ? 'Start Selling Locally'
                    : isInfluencer
                        ? 'Join as a Creator'
                        : 'Create an Account',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 8),
              Text(
                isRetailer
                    ? 'List products, manage inventory, and launch influencer campaigns.'
                    : isInfluencer
                        ? 'Partner with local brands and grow your community.'
                        : 'Sign up to discover the best local products near you.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.neutral500),
              ),
              const SizedBox(height: 32),
            ],

            // Role cards
            _buildRoleCards(),
            const SizedBox(height: 28),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Full Name',
                    hintText: 'e.g. Jane Doe',
                    prefixIcon:
                        const Icon(LucideIcons.user, size: 20),
                    controller: _nameController,
                    validator: ValidationUtils.validateRequired,
                  ),
                  const SizedBox(height: 16),
                  if (isInfluencer) ...[
                    AppTextField(
                      label: 'Username',
                      hintText: 'e.g. @janedoe_styles',
                      prefixIcon:
                          const Icon(LucideIcons.atSign, size: 20),
                      controller: _usernameController,
                      validator: ValidationUtils.validateRequired,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (isRetailer) ...[
                    AppTextField(
                      label: 'Business Name',
                      hintText: "e.g. Jane's Artisan Goods",
                      prefixIcon:
                          const Icon(LucideIcons.store, size: 20),
                      controller: _businessNameController,
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    label: 'Email',
                    hintText: 'e.g. jane@example.com',
                    prefixIcon:
                        const Icon(LucideIcons.mail, size: 20),
                    controller: _emailController,
                    validator: ValidationUtils.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  if (!isInfluencer) ...[
                    AppTextField(
                      label: 'Phone Number',
                      hintText: '9876543210',
                      prefixIcon:
                          const Icon(LucideIcons.phone, size: 20),
                      controller: _phoneController,
                      validator: ValidationUtils.validatePhone,
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    label: 'Password',
                    hintText: '••••••••',
                    prefixIcon:
                        const Icon(LucideIcons.lock, size: 20),
                    obscureText: true,
                    suffixIcon:
                        const Icon(LucideIcons.eyeOff, size: 20),
                    controller: _passwordController,
                    validator: ValidationUtils.validatePassword,
                  ),
                  if (isRetailer) ...[
                    const SizedBox(height: 16),
                    const AppTextField(
                      label: 'Business Category',
                      hintText: 'Select Category',
                      prefixIcon:
                          Icon(LucideIcons.layers, size: 20),
                      suffixIcon:
                          Icon(LucideIcons.chevronDown, size: 20),
                    ),
                    const SizedBox(height: 16),
                    const AppTextField(
                      label: 'Shop Address',
                      hintText: '123 Market St, City',
                      prefixIcon:
                          Icon(LucideIcons.mapPin, size: 20),
                      suffixIcon: Icon(LucideIcons.map, size: 20),
                    ),
                    const SizedBox(height: 16),
                    const AppTextField(
                      label: 'GST Number (Optional)',
                      hintText: '22AAAAA0000A1Z5',
                      prefixIcon:
                          Icon(LucideIcons.fileText, size: 20),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Terms checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) =>
                        setState(() => _agreedToTerms = val ?? false),
                    activeColor: _currentRole.color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.neutral700),
                      children: [
                        TextSpan(
                            text: isRetailer
                                ? 'Terms of Service for Merchants'
                                : 'Terms of Service',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: _currentRole.color,
                                fontWeight: FontWeight.w600),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                LegalDocumentBottomSheet.show(
                                  context,
                                  role: _selectedRole.toLowerCase(),
                                  documentType: 'terms',
                                );
                              }),
                        const TextSpan(text: ' and '),
                        TextSpan(
                            text: 'Privacy Policy',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: _currentRole.color,
                                fontWeight: FontWeight.w600),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                LegalDocumentBottomSheet.show(
                                  context,
                                  role: _selectedRole.toLowerCase(),
                                  documentType: 'privacy',
                                );
                              }),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            BlocConsumer<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                if (state is AuthenticationLoaded) {
                  if (_selectedRole == 'SHOPKEEPER') {
                    context.go('/retailer/home');
                  } else if (_selectedRole == 'INFLUENCER') {
                    context.go('/influencer/home');
                  } else {
                    context.go('/home');
                  }
                } else if (state is AuthenticationError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.failure.message),
                      backgroundColor: AppColors.error500));
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentRole.color,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _agreedToTerms
                      ? () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final emailOrPhone = _emailController.text.trim().isNotEmpty
                                ? _emailController.text.trim()
                                : _phoneController.text.trim();
                            context.read<AuthenticationBloc>().add(RegisterSubmitted(
                                  emailOrPhone: emailOrPhone,
                                  password: _passwordController.text,
                                  role: _selectedRole,
                                  name: _nameController.text.trim(),
                                ));
                          }
                        }
                      : null,
                  child: state is AuthenticationLoading
                      ? const SizedBox(height: 24, width: 24, child: CupertinoActivityIndicator(color: AppColors.white))
                      : Text(isRetailer ? 'Register Your Shop' : isInfluencer ? 'Join as Creator' : 'Create Account', style: AppTextStyles.button.copyWith(color: AppColors.white)),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ',
                    style: AppTextStyles.body),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text('Log in',
                      style: AppTextStyles.body.copyWith(
                          color: _currentRole.color,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 3-card role selector ─────────────────────────────────────────────────
  Widget _buildRoleCards() {
    return Row(
      children: _roles.asMap().entries.map((entry) {
        final role = entry.value;
        final isSelected = role.id == _selectedRole;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: entry.key < _roles.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => _switchRole(role.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 10),
                decoration: BoxDecoration(
                  color: isSelected ? role.lightColor : AppColors.neutral50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? role.color
                        : AppColors.neutral200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: role.color.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? role.color
                                : AppColors.neutral200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(role.icon,
                              size: 18,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.neutral500),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: role.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.white, width: 2),
                              ),
                              child: const Icon(LucideIcons.check,
                                  size: 9, color: AppColors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      role.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? role.color
                            : AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.benefit,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutral500, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
