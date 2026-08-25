import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/responsive_container.dart';

// Category model
class FAQCategory {
  final String label;
  final IconData icon;
  final List<Map<String, String>> faqs;

  const FAQCategory({
    required this.label,
    required this.icon,
    required this.faqs,
  });
}

class FAQSection extends StatefulWidget {
  final List<Map<String, String>> faqs;

  const FAQSection({super.key, required this.faqs});

  @override
  State<FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<FAQSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContainer(
        maxWidth: 860,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Text(
                  'Frequently Asked Questions',
                  style: isMobile ? AppTextStyles.h2 : AppTextStyles.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Everything you need to know about the product and billing.',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.neutral600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ...widget.faqs.map((faq) => AnimatedFAQItem(
                  question: faq['question']!,
                  answer: faq['answer']!,
                  index: widget.faqs.indexOf(faq),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedFAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final int index;

  const AnimatedFAQItem({
    super.key,
    required this.question,
    required this.answer,
    required this.index,
  });

  @override
  State<AnimatedFAQItem> createState() => _AnimatedFAQItemState();
}

class _AnimatedFAQItemState extends State<AnimatedFAQItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + widget.index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _isExpanded
                ? AppColors.neutral100
                : (_isHovered ? AppColors.neutral50 : AppColors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isExpanded ? AppColors.neutral300 : AppColors.neutral200,
              width: _isExpanded ? 1.5 : 1,
            ),
            boxShadow: _isHovered || _isExpanded
                ? [
                    BoxShadow(
                      color: AppColors.neutral900.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              title: Text(
                widget.question,
                style: AppTextStyles.h6.copyWith(
                  color: _isExpanded ? AppColors.neutral900 : AppColors.neutral900,
                ),
              ),
              trailing: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _isExpanded ? AppColors.neutral900 : AppColors.neutral100,
                  shape: BoxShape.circle,
                ),
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    LucideIcons.chevronDown,
                    size: 18,
                    color: _isExpanded ? AppColors.white : AppColors.neutral500,
                  ),
                ),
              ),
              onExpansionChanged: (expanded) {
                setState(() => _isExpanded = expanded);
              },
              childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 1,
                  color: AppColors.neutral200,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                Text(
                  widget.answer,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.neutral600,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Standalone animated FAQ widget for use outside of pages
class AnimatedFAQSection extends StatelessWidget {
  final List<FAQCategory> categories;

  const AnimatedFAQSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return FAQSection(
      faqs: categories.expand((c) => c.faqs).toList(),
    );
  }
}
