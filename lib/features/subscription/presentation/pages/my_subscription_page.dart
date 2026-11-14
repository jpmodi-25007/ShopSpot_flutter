import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/subscription_service.dart';
import 'subscription_plans_page.dart';
import '../widgets/subscription_usage_card.dart';
import 'package:get_it/get_it.dart';

class MySubscriptionPage extends StatefulWidget {
  const MySubscriptionPage({super.key});

  @override
  State<MySubscriptionPage> createState() => _MySubscriptionPageState();
}

class _MySubscriptionPageState extends State<MySubscriptionPage> {
  final _service = GetIt.I<SubscriptionService>();
  Map<String, dynamic>? _data;
  List<dynamic> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _service.getMySubscription(),
        _service.getPaymentHistory(),
      ]);
      if (mounted) {
        setState(() {
          _data = results[0] as Map<String, dynamic>?;
          _history = (results[1] as List?) ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = (_data?['currentTier'] ?? 'FREE').toString().toUpperCase();
    final expiresAt = _data?['expiresAt'];
    final plan = _data?['plan'] is Map ? Map<String, dynamic>.from(_data!['plan'] as Map) : null;
    final usage = _data?['usage'] is Map ? Map<String, dynamic>.from(_data!['usage'] as Map) : null;

    final isPro = tier == 'PRO';
    final isPremium = tier == 'PREMIUM';
    final isFree = !isPro && !isPremium;

    final Color accentColor = isPremium
        ? const Color(0xFFF59E0B)
        : isPro
            ? const Color(0xFF3B82F6)
            : const Color(0xFF94A3B8);

    final IconData tierIcon = isPremium
        ? Icons.workspace_premium_rounded
        : isPro
            ? Icons.rocket_launch_rounded
            : Icons.storefront_rounded;

    final String tierDisplayName = isPremium
        ? 'Premium VIP'
        : isPro
            ? 'Pro Growth'
            : 'Free Starter';

    final String priceLabel = isPremium
        ? '₹1,199 / month'
        : isPro
            ? '₹499 / month'
            : '₹0 · Forever Free';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B09),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'My Subscription',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFF59E0B),
              backgroundColor: const Color(0xFF1E222D),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Plan Hero Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isPremium
                              ? const [Color(0xFF26190C), Color(0xFF181008), Color(0xFF33200E)]
                              : isPro
                                  ? const [Color(0xFF131D36), Color(0xFF0C1322), Color(0xFF1E2D4E)]
                                  : const [Color(0xFF1D222C), Color(0xFF141720), Color(0xFF191D26)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: accentColor.withOpacity(0.7), width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: accentColor.withOpacity(0.4)),
                                ),
                                child: Icon(tierIcon, color: accentColor, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          tierDisplayName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF065F46),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xFF10B981)),
                                          ),
                                          child: const Text(
                                            'ACTIVE',
                                            style: TextStyle(
                                              color: Color(0xFFD1FAE5),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      expiresAt != null
                                          ? 'Renews ${_formatDate(expiresAt.toString())}'
                                          : isFree
                                              ? 'Free Starter tier (unlimited duration)'
                                              : 'Auto-renews monthly',
                                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Divider(color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Plan Rate',
                                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13.5),
                              ),
                              Text(
                                plan != null ? '₹${plan['price']} / month' : priceLabel,
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Usage meters
                    SubscriptionUsageCard(
                      usage: usage ??
                          const {
                            'productsCount': 0,
                            'productLimit': 50,
                            'eventsUsedThisMonth': 0,
                            'eventLimit': 0,
                          },
                    ),

                    const SizedBox(height: 20),

                    // Upgrade Plan Banner / Button
                    if (tier != 'PREMIUM')
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SubscriptionPlansPage()),
                              );
                              if (result == true) _load();
                            },
                            icon: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF1A1108)),
                            label: const Text(
                              'Upgrade Plan & Increase Limits',
                              style: TextStyle(
                                color: Color(0xFF1A1108),
                                fontWeight: FontWeight.w900,
                                fontSize: 15.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    // Payment history section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Billing History',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        if (_history.isNotEmpty)
                          Text(
                            '${_history.length} transactions',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_history.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E222D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, color: Colors.white.withOpacity(0.3), size: 36),
                              const SizedBox(height: 8),
                              const Text(
                                'No payment transactions yet',
                                style: TextStyle(color: Colors.white54, fontSize: 13.5),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._history.map((p) => _paymentTile(p is Map<String, dynamic> ? p : Map<String, dynamic>.from(p as Map))),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _paymentTile(Map<String, dynamic> p) {
    final status = (p['status'] ?? '').toString();
    final isPaid = status.toLowerCase() == 'paid';
    final amount = double.tryParse(p['amount']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isPaid ? const Color(0xFF10B981) : Colors.red).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (isPaid ? const Color(0xFF10B981) : Colors.red).withOpacity(0.3)),
            ),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: isPaid ? const Color(0xFF34D399) : Colors.redAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(p['createdAt']?.toString() ?? ''),
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: (isPaid ? const Color(0xFF065F46) : Colors.red.shade900).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (isPaid ? const Color(0xFF10B981) : Colors.redAccent).withOpacity(0.5)),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: isPaid ? const Color(0xFFD1FAE5) : Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
