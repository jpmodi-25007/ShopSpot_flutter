import 'package:flutter/material.dart';
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
    setState(() => _loading = true);
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

  // ── Derived state ─────────────────────────────────────────────────────────

  String get _tier =>
      (_data?['currentTier'] ??
          _data?['tier'] ??
          _data?['plan']?['tier'] ??
          'FREE')
          .toString()
          .toUpperCase();

  bool get _isPro => _tier == 'PRO';
  bool get _isPremium => _tier == 'PREMIUM';
  bool get _isFree => !_isPro && !_isPremium;

  Color get _accentColor => _isPremium
      ? const Color(0xFFF59E0B)
      : _isPro
          ? const Color(0xFF3B82F6)
          : const Color(0xFF94A3B8);

  IconData get _tierIcon => _isPremium
      ? Icons.workspace_premium_rounded
      : _isPro
          ? Icons.rocket_launch_rounded
          : Icons.storefront_rounded;

  String get _tierDisplayName =>
      _isPremium ? 'Premium VIP' : _isPro ? 'Pro Growth' : 'Free Starter';

  List<Color> get _cardGradient => _isPremium
      ? const [Color(0xFF26190C), Color(0xFF181008), Color(0xFF33200E)]
      : _isPro
          ? const [Color(0xFF131D36), Color(0xFF0C1322), Color(0xFF1E2D4E)]
          : const [Color(0xFF1D222C), Color(0xFF141720), Color(0xFF191D26)];

  String _priceLabel() {
    final planData = _data?['plan'];
    if (planData is Map) {
      final p = double.tryParse(planData['price']?.toString() ?? '');
      if (p != null) {
        return p == 0 ? '₹0 · Forever Free' : '₹${p.toStringAsFixed(0)} / month';
      }
    }
    return _isPremium
        ? '₹1,199 / month'
        : _isPro
            ? '₹499 / month'
            : '₹0 · Forever Free';
  }

  String _renewalLabel() {
    final expiresAt = _data?['expiresAt'];
    if (expiresAt != null && expiresAt.toString().isNotEmpty) {
      return 'Renews ${_formatDate(expiresAt.toString())}';
    }
    return _isFree ? 'Free tier — no expiry' : 'Auto-renews monthly';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final usage = _data?['usage'];
    final Map<String, dynamic> usageMap = usage is Map
        ? Map<String, dynamic>.from(usage)
        : {
            'productsCount': 0,
            'productLimit': _isFree ? 50 : _isPro ? 200 : 500,
            'eventsUsedThisMonth': 0,
            'eventLimit': _isFree ? 0 : _isPro ? 1 : 3,
          };

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 17),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'My Subscription',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: Colors.white.withAlpha(178)),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFF59E0B),
              backgroundColor: const Color(0xFF1E222D),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Current Plan Hero Card ───────────────────────────
                    _buildPlanHeroCard(),

                    const SizedBox(height: 16),

                    // ── Usage Meters ─────────────────────────────────────
                    SubscriptionUsageCard(usage: usageMap),

                    const SizedBox(height: 20),

                    // ── Upgrade CTA (not on Premium) ─────────────────────
                    if (!_isPremium) _buildUpgradeCTA(),

                    if (!_isPremium) const SizedBox(height: 28),

                    // ── Billing History ───────────────────────────────────
                    _buildBillingSection(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildPlanHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _cardGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentColor.withAlpha(178), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withAlpha(64),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon container
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _accentColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accentColor.withAlpha(102)),
                ),
                child: Icon(_tierIcon, color: _accentColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _tierDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ACTIVE badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF065F46),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF10B981)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle,
                                  color: Color(0xFF34D399), size: 7),
                              SizedBox(width: 4),
                              Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Color(0xFFD1FAE5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _renewalLabel(),
                      style: TextStyle(
                          color: Colors.white.withAlpha(165),
                          fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withAlpha(26)),
          const SizedBox(height: 14),

          // Plan rate row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.payments_outlined,
                      color: Colors.white.withAlpha(128), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Plan Rate',
                    style: TextStyle(
                        color: Colors.white.withAlpha(165),
                        fontSize: 13.5),
                  ),
                ],
              ),
              Text(
                _priceLabel(),
                style: TextStyle(
                  color: _isFree ? const Color(0xFF34D399) : _accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          // Show plan limits as quick stats
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip(Icons.inventory_2_outlined,
                  '${_isFree ? 50 : _isPro ? 200 : 500} Products'),
              const SizedBox(width: 10),
              _statChip(
                Icons.campaign_outlined,
                _isFree
                    ? '0 Events'
                    : _isPro
                        ? '1 Event/mo'
                        : '3 Events/mo',
              ),
              if (_isPro || _isPremium) ...[
                const SizedBox(width: 10),
                _statChip(
                  _isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.verified_rounded,
                  _isPremium ? '👑 VIP' : '🔵 Pro',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _accentColor.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accentColor.withAlpha(64)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: _accentColor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCTA() {
    final String ctaText = _isFree
        ? '⭐ Upgrade to Pro — ₹499/month'
        : '👑 Upgrade to Premium VIP — ₹1,199/month';

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withAlpha(90),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: const Color(0xFF1A1108),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SubscriptionPlansPage()),
            );
            if (result == true) _load();
          },
          icon: const Icon(Icons.rocket_launch_rounded,
              color: Color(0xFF1A1108)),
          label: Text(
            ctaText,
            style: const TextStyle(
              color: Color(0xFF1A1108),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Billing History',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800),
            ),
            if (_history.isNotEmpty)
              Text(
                '${_history.length} transaction${_history.length == 1 ? '' : 's'}',
                style: TextStyle(
                    color: Colors.white.withAlpha(128), fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1E2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      color: Colors.white.withAlpha(76), size: 38),
                  const SizedBox(height: 10),
                  const Text(
                    'No payment transactions yet',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 13.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your billing history will appear here.',
                    style: TextStyle(
                        color: Colors.white.withAlpha(76),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ..._history.map((p) => _paymentTile(
              p is Map<String, dynamic>
                  ? p
                  : Map<String, dynamic>.from(p as Map))),
      ],
    );
  }

  Widget _paymentTile(Map<String, dynamic> p) {
    final status = (p['status'] ?? '').toString().toLowerCase();
    final isPaid = status == 'paid';
    final amount = double.tryParse(p['amount']?.toString() ?? '0') ?? 0;
    final planName = p['shop']?['name']?.toString() ??
        p['planId']?.toString() ??
        'Subscription';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E2A),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isPaid
                      ? const Color(0xFF10B981)
                      : Colors.red)
                  .withAlpha(38),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isPaid
                        ? const Color(0xFF10B981)
                        : Colors.red)
                    .withAlpha(76),
              ),
            ),
            child: Icon(
              isPaid
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: isPaid
                  ? const Color(0xFF34D399)
                  : Colors.redAccent,
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
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(p['createdAt']?.toString() ?? ''),
                  style: TextStyle(
                      color: Colors.white.withAlpha(128),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: (isPaid
                      ? const Color(0xFF065F46)
                      : Colors.red.shade900)
                  .withAlpha(102),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isPaid
                        ? const Color(0xFF10B981)
                        : Colors.redAccent)
                    .withAlpha(128),
              ),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: isPaid
                    ? const Color(0xFFD1FAE5)
                    : Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w900,
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
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
