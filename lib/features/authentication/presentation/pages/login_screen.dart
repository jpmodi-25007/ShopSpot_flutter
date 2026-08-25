import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/utils/responsive_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../bloc/authentication_state.dart';
import '../../../../core/utils/validation_utils.dart';

// Role config
class _RoleConfig {
  final String id;
  final String label;
  final IconData icon;
  final String tagline;
  final Color color;
  final Color lightColor;
  const _RoleConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.tagline,
    required this.color,
    required this.lightColor,
  });
}

const _roles = [
  _RoleConfig(
    id: 'CUSTOMER',
    label: 'Customer',
    icon: LucideIcons.shoppingBag,
    tagline: 'Shop local boutiques',
    color: AppColors.roleCustomer,
    lightColor: AppColors.roleCustomerLight,
  ),
  _RoleConfig(
    id: 'SHOPKEEPER',
    label: 'Retailer',
    icon: LucideIcons.store,
    tagline: 'Manage your store',
    color: AppColors.roleRetailer,
    lightColor: AppColors.roleRetailerLight,
  ),
  _RoleConfig(
    id: 'INFLUENCER',
    label: 'Influencer',
    icon: LucideIcons.trendingUp,
    tagline: 'Earn from campaigns',
    color: AppColors.roleInfluencer,
    lightColor: AppColors.roleInfluencerLight,
  ),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String _selectedRole = 'CUSTOMER';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  late AnimationController _formController;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  _RoleConfig get _currentRole =>
      _roles.firstWhere((r) => r.id == _selectedRole);

  @override
  void initState() {
    super.initState();
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
    _emailController.dispose();
    _passwordController.dispose();
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

  // ── Mobile: full-bleed hero image + card pulled up ─────────────────────────
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
              Image.asset(
                'assets/images/login_panel_hero.jpg',
                fit: BoxFit.cover,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _currentRole.color.withValues(alpha: 0.25),
                      AppColors.neutral900.withValues(alpha: 0.6),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _currentRole.color.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_currentRole.icon,
                          color: AppColors.white, size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text('Welcome back',
                        style: AppTextStyles.h1.copyWith(
                            color: AppColors.white, fontSize: 26)),
                    Text(_currentRole.tagline,
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8))),
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
                      offset: const Offset(0, -4),
                    )
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

  // ── Desktop: 50/50 split ────────────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left panel — image
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.panelBadgeBackground,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.mapPin,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Your local commerce hub',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(LucideIcons.store,
                      color: AppColors.white, size: 48),
                  const SizedBox(height: 16),
                  Text('Welcome to Findivo',
                      style: AppTextStyles.h1.copyWith(
                          color: AppColors.white, fontSize: 32)),
                  const SizedBox(height: 10),
                  Text(
                    'Discover curated products from independent boutiques in your neighbourhood.',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white.withValues(alpha: 0.82),
                        height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _TrustChip(
                          icon: LucideIcons.shieldCheck,
                          label: 'Secure Payments'),
                      _TrustChip(
                          icon: LucideIcons.users,
                          label: '10k+ Users'),
                      _TrustChip(
                          icon: LucideIcons.store,
                          label: '500+ Shops'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Right panel — form
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
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
    return FadeTransition(
      opacity: _formFade,
      child: SlideTransition(
        position: _formSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Text('Welcome back', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue to your account.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.neutral500),
              ),
              const SizedBox(height: 32),
            ],

            // Role selector
            _buildRoleSelector(),
            const SizedBox(height: 28),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Email or Phone',
                    hintText: 'e.g. john@example.com or 9876543210',
                    prefixIcon:
                        const Icon(LucideIcons.mail, size: 20),
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
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Password',
                    hintText: '••••••••',
                    prefixIcon:
                        const Icon(LucideIcons.lock, size: 20),
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isPasswordVisible
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 20),
                      onPressed: () => setState(() =>
                          _isPasswordVisible = !_isPasswordVisible),
                    ),
                    controller: _passwordController,
                    validator: ValidationUtils.validatePassword,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: Text('Forgot Password?',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: _currentRole.color,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),

            // Login button + BLoC
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
                } else if (state is AuthenticationGuest) {
                  context.go('/home');
                } else if (state is AuthenticationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.failure.message),
                        backgroundColor: AppColors.error500),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthenticationLoading;
                return Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentRole.color,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: isLoading ? null : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<AuthenticationBloc>().add(LoginSubmitted(
                            emailOrPhone: _emailController.text.trim(),
                            password: _passwordController.text,
                            role: _selectedRole,
                          ));
                        }
                      },
                      child: isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CupertinoActivityIndicator(color: AppColors.white))
                          : Text(_selectedRole == 'SHOPKEEPER' ? 'Login to Dashboard' : 'Login', style: AppTextStyles.button.copyWith(color: AppColors.white)),
                    ),
                    if (_selectedRole == 'CUSTOMER') ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _currentRole.color,
                          side: BorderSide(color: _currentRole.color),
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: isLoading ? null : () => context.read<AuthenticationBloc>().add(const GuestLoginRequested()),
                        child: Text('Skip / Continue as Guest', style: AppTextStyles.button.copyWith(color: _currentRole.color)),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ",
                    style: AppTextStyles.body),
                GestureDetector(
                  onTap: () =>
                      context.push('/signup?role=$_selectedRole'),
                  child: Text('Sign up',
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

  // ── Role selector (pill tabs with icon + colour) ───────────────────────────
  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _roles.map((role) {
          final isSelected = role.id == _selectedRole;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchRole(role.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? role.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: role.color.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      role.icon,
                      size: 18,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.neutral500,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.label,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Trust chip ────────────────────────────────────────────────────────────────
class _TrustChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
