import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ComingSoonScreen extends StatefulWidget {
  final String? featureName;
  const ComingSoonScreen({super.key, this.featureName});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _starController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnim;
  late Animation<double> _starAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
    _starController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -18).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _starAnim = Tween<double>(begin: 0, end: 1).animate(_starController);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _starController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<Widget> _buildStars() {
    final positions = [
      const Offset(0.1, 0.1), const Offset(0.85, 0.05), const Offset(0.6, 0.08),
      const Offset(0.2, 0.25), const Offset(0.9, 0.3), const Offset(0.05, 0.55),
      const Offset(0.95, 0.65), const Offset(0.15, 0.8), const Offset(0.75, 0.85),
      const Offset(0.45, 0.92), const Offset(0.8, 0.15), const Offset(0.35, 0.15),
    ];
    return positions.asMap().entries.map((entry) {
      final i = entry.key;
      final pos = entry.value;
      return AnimatedBuilder(
        animation: _starAnim,
        builder: (context, _) {
          final opacity = (0.3 + 0.7 * (((_starAnim.value * 3 + i * 0.3) % 1.0))).clamp(0.2, 1.0);
          return Positioned(
            left: MediaQuery.of(context).size.width * pos.dx,
            top: MediaQuery.of(context).size.height * pos.dy,
            child: Opacity(opacity: opacity, child: const Icon(LucideIcons.star, size: 8, color: Colors.white)),
          );
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final featureName = widget.featureName ?? 'This Feature';
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ..._buildStars(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (ctx, ch) => Transform.scale(scale: _pulseAnim.value, child: ch),
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5), Color(0xFF312E81)],
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.roleInfluencer.withValues(alpha: 0.5), blurRadius: 60, spreadRadius: 10),
                        ],
                      ),
                      child: const Center(child: Text('🚀', style: TextStyle(fontSize: 72))),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.roleInfluencer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.roleInfluencer.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.sparkles, size: 14, color: AppColors.roleInfluencer),
                        const SizedBox(width: 8),
                        Text('COMING SOON', style: AppTextStyles.caption.copyWith(color: AppColors.roleInfluencer, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(featureName, textAlign: TextAlign.center,
                        style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.2)),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'We\'re working hard to bring you something amazing. This feature will be available in our next update.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.65), height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FeatureChip(icon: '✨', label: 'Exciting New Features'),
                      _FeatureChip(icon: '⚡', label: 'Better Performance'),
                      _FeatureChip(icon: '🎯', label: 'Smarter Insights'),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roleInfluencer,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.arrowLeft, size: 18),
                          const SizedBox(width: 10),
                          Text('Go Back', style: AppTextStyles.h4.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
