import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/logout_dialog.dart';
import '../bloc/influencer_bloc.dart';
import '../bloc/influencer_event.dart';
import '../bloc/influencer_state.dart';

class InfluencerPendingScreen extends StatefulWidget {
  const InfluencerPendingScreen({super.key});

  @override
  State<InfluencerPendingScreen> createState() => _InfluencerPendingScreenState();
}

class _InfluencerPendingScreenState extends State<InfluencerPendingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Fetch profile on load to get status
    context.read<InfluencerBloc>().add(const GetInfluencerProfileRequested());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    setState(() => _isChecking = true);
    context.read<InfluencerBloc>().add(const GetInfluencerProfileRequested());
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (state is InfluencerLoaded && state.profile != null) {
          final status = state.profile!.verificationStatus;
          if (status == 'VERIFIED') {
            // Admin has approved — go to home
            context.go('/influencer/home');
          } else if (status == 'REJECTED') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your profile application has been rejected. Please contact support.'),
                backgroundColor: AppColors.error500,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1B4B), Color(0xFF3730A3), Color(0xFF6D28D9)],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // Top bar with logout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => LogoutDialog.show(context),
                          icon: const Icon(LucideIcons.logOut, size: 16, color: Colors.white60),
                          label: Text('Log Out', style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  BlocBuilder<InfluencerBloc, InfluencerState>(
                    builder: (context, state) {
                      final isRejected = state is InfluencerLoaded && state.profile?.verificationStatus == 'REJECTED';

                      return Column(
                        children: [
                          // Pulsing Icon
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: isRejected ? 1.0 : _pulseAnim.value, // No pulse if rejected
                                child: child,
                              );
                            },
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isRejected ? AppColors.error500 : const Color(0xFF7C3AED)).withValues(alpha: 0.5),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isRejected ? LucideIcons.xOctagon : LucideIcons.shieldCheck,
                                color: Colors.white,
                                size: 52,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isRejected ? AppColors.error500 : Colors.amber).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: (isRejected ? AppColors.error500 : Colors.amber).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isRejected ? LucideIcons.alertTriangle : LucideIcons.clock, size: 14, color: isRejected ? AppColors.error400 : Colors.amber),
                                const SizedBox(width: 6),
                                Text(
                                  isRejected ? 'APPLICATION REJECTED' : 'UNDER REVIEW',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isRejected ? AppColors.error400 : Colors.amber,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                Text(
                                  isRejected ? 'Profile Application Rejected' : 'Your Profile is Under Verification',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.h2.copyWith(
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isRejected 
                                      ? 'Unfortunately, your influencer profile did not meet our current requirements. Please contact support for more details or to appeal.'
                                      : 'Our team is currently reviewing your influencer profile. This usually takes 24–48 hours. You\'ll be able to access campaigns as soon as your profile is approved.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white70,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          if (!isRejected)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Row(
                                children: [
                                  Expanded(child: _InfoCard(icon: LucideIcons.userCheck, label: 'Profile Submitted', done: true)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _InfoCard(icon: LucideIcons.searchCheck, label: 'Admin Review', done: false)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _InfoCard(icon: LucideIcons.rocket, label: 'Go Live!', done: false)),
                                ],
                              ),
                            ),
                        ],
                      );
                    }
                  ),

                  const Spacer(flex: 3),

                  // Refresh Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isChecking ? null : _refreshStatus,
                        icon: _isChecking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6D28D9)),
                              )
                            : const Icon(LucideIcons.refreshCw, size: 18),
                        label: Text(_isChecking ? 'Checking...' : 'Refresh Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6D28D9),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Need help? Contact us at support@findivo.com',
                    style: AppTextStyles.caption.copyWith(color: Colors.white38),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool done;

  const _InfoCard({required this.icon, required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: done
            ? Colors.green.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? Colors.green.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: done ? Colors.greenAccent : Colors.white60),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: done ? Colors.greenAccent : Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
