import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  bool _hasMinimumSplashTimeElapsed = false;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (fade and scale up)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _entranceController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
          parent: _entranceController, curve: Curves.easeOutBack),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entranceController, curve: Curves.easeOutCubic));

    // 2. Pulse animation for the logo ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 3. Fake progress bar animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _entranceController, curve: Curves.easeInOut),
    );

    _entranceController.forward();

    // Enforce a minimum splash duration of 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hasMinimumSplashTimeElapsed = true;
        });
        _listenAndRoute();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _listenAndRoute() {
    if (!_hasMinimumSplashTimeElapsed) return;

    final state = context.read<AuthenticationBloc>().state;
    // If already resolved, route immediately
    if (state is AuthenticationLoaded) {
      _routeByRole(context, state.user.role);
    } else if (state is AuthenticationInfluencerPending) {
      context.go('/influencer/pending');
    } else if (state is AuthenticationGuest) {
      context.go('/home');
    } else if (state is AuthenticationUnauthenticated ||
        state is AuthenticationError) {
      context.go(kIsWeb ? '/login' : '/intro');
    }
    // Otherwise the BlocListener below will handle it when state changes
  }

  void _routeByRole(BuildContext context, String role) {
    switch (role.toUpperCase()) {
      case 'SHOPKEEPER':
        context.go('/retailer/home');
        break;
      case 'INFLUENCER':
        context.go('/influencer/home');
        break;
      case 'CUSTOMER':
      default:
        context.go('/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (!_hasMinimumSplashTimeElapsed) return;

        if (state is AuthenticationLoaded) {
          _routeByRole(context, state.user.role);
        } else if (state is AuthenticationInfluencerPending) {
          context.go('/influencer/pending');
        } else if (state is AuthenticationGuest) {
          context.go('/home');
        } else if (state is AuthenticationUnauthenticated ||
            state is AuthenticationError) {
          context.go(kIsWeb ? '/login' : '/intro');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral900,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full-bleed premium background
                  Image.asset(
                    'assets/images/login_panel_hero.jpg',
                    fit: BoxFit.cover,
                  ),
                  // Deep chocolate/green gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.neutral900.withValues(alpha: 0.1),
                          AppColors.neutral900.withValues(alpha: 0.7),
                          AppColors.panelGradientBottom.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Animated pulse logo
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.neutral900
                                      .withValues(alpha: 0.85),
                                  borderRadius:
                                      BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neutral900
                                          .withValues(
                                              alpha: 0.2 +
                                                  (_pulseController.value *
                                                      0.3)),
                                      blurRadius: 24 +
                                          (_pulseController.value * 12),
                                      spreadRadius: 4 +
                                          (_pulseController.value * 8),
                                    )
                                  ],
                                  border: Border.all(
                                    color: AppColors.white.withValues(
                                        alpha: 0.2 +
                                            (_pulseController.value *
                                                0.3)),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(LucideIcons.store,
                                      size: 36, color: AppColors.white),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),

                          // App Name
                          Text(
                            'Findivo',
                            style: AppTextStyles.display.copyWith(
                              color: AppColors.white,
                              letterSpacing: 1.5,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Animated Taglines
                          SlideTransition(
                            position: _textSlideAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Your local commerce hub',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.neutral100,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Connecting shoppers, retailers, and creators.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.neutral400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 56),

                          // Custom animated progress bar
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 200,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.white
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(2),
                                ),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral800,
                                      borderRadius:
                                          BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.neutral800
                                              .withValues(alpha: 0.5),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
