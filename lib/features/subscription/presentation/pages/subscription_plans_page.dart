import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../widgets/plan_card.dart';
import '../widgets/subscription_usage_card.dart';
import '../../data/subscription_service.dart';
import 'package:get_it/get_it.dart';

class SubscriptionPlansPage extends StatefulWidget {
  final bool showCurrentPlan;
  const SubscriptionPlansPage({super.key, this.showCurrentPlan = false});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage>
    with SingleTickerProviderStateMixin {
  final _service = GetIt.I<SubscriptionService>();
  late final Razorpay _razorpay;

  List<dynamic> _plans = [];
  Map<String, dynamic>? _mySubscription;
  bool _loading = true;
  bool _paymentProcessing = false;
  bool _isYearly = false;
  String? _selectedPlanId;
  String? _currentRazorpayOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final plans = await _service.getPlans();
      final mySub = await _service.getMySubscription();
      if (mounted) {
        setState(() {
          _plans = plans;
          _mySubscription = mySub;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Subscription helpers ──────────────────────────────────────────────────

  String get _currentTier =>
      (_mySubscription?['currentTier'] ??
          _mySubscription?['tier'] ??
          _mySubscription?['plan']?['tier'] ??
          'FREE')
          .toString()
          .toUpperCase();

  Future<void> _subscribe(Map<String, dynamic> plan) async {
    final planTier = (plan['tier'] ?? '').toString().toUpperCase();
    if (planTier.isNotEmpty && planTier == _currentTier) {
      _showInfo('You are already on this plan!');
      return;
    }

    final planId = (plan['id'] ?? plan['tier'] ?? '').toString();
    final price = double.tryParse(plan['price']?.toString() ?? '0') ?? 0;

    // Free plan — activate directly
    if (price == 0) {
      setState(() => _paymentProcessing = true);
      try {
        await _service.createOrder(planId);
        if (mounted) {
          _showInfo('✅ Free Starter plan activated!');
          _loadData();
        }
      } catch (e) {
        _showError(_cleanError(e));
      } finally {
        if (mounted) setState(() => _paymentProcessing = false);
      }
      return;
    }

    // Paid plan — create Razorpay order
    setState(() {
      _paymentProcessing = true;
      _selectedPlanId = planId;
    });
    try {
      final orderData =
          await _service.createOrder(planId, planTier: plan['tier']?.toString());

      // Simulated / direct activation (no real Razorpay gateway needed)
      if (orderData['activatedDirectly'] == true ||
          orderData['simulated'] == true ||
          orderData['free'] == true) {
        if (mounted) setState(() => _paymentProcessing = false);
        if (mounted) {
          _showSuccessDialog();
          _loadData();
        }
        return;
      }

      // Real Razorpay checkout
      final amount = int.tryParse(orderData['amount']?.toString() ?? '0') ?? 0;
      final orderId = (orderData['orderId'] ?? '').toString();
      final keyId = (orderData['keyId'] ?? '').toString();
      _currentRazorpayOrderId = orderId;

      _razorpay.open({
        'key': keyId,
        'amount': amount,
        'name': 'ShopSpot',
        'description': '${plan['name'] ?? plan['tier']} Plan Subscription',
        'order_id': orderId,
        'currency': 'INR',
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#F59E0B'},
      });
    } catch (e) {
      _showError(_cleanError(e));
      if (mounted) setState(() => _paymentProcessing = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final orderId = (response.orderId != null && response.orderId!.isNotEmpty)
        ? response.orderId!
        : (_currentRazorpayOrderId ?? '');
    try {
      await _service.verifyPayment(
        razorpayOrderId: orderId,
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );
      if (mounted) setState(() => _paymentProcessing = false);
      if (mounted) {
        _showSuccessDialog();
        _loadData();
      }
    } catch (_) {
      if (mounted) setState(() => _paymentProcessing = false);
      _showError('Payment verification failed. Please contact support.');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) setState(() => _paymentProcessing = false);
    _showError('Payment cancelled or failed: ${response.message ?? 'Unknown error'}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) setState(() => _paymentProcessing = false);
  }

  String _cleanError(Object e) {
    final raw = e.toString();
    if (raw.contains('Exception:')) {
      return raw.replaceAll('Exception:', '').trim();
    }
    return raw.isNotEmpty ? raw : 'Something went wrong. Please try again.';
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
      backgroundColor: Colors.red.shade800,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 5),
    ));
  }

  void _showInfo(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
      backgroundColor: const Color(0xFF059669),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showSuccessDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1E222D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(38),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF34D399), size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                '🎉 Plan Activated!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                'Your new subscription is live. Higher product limits and event promotions are now available.',
                style: TextStyle(
                    color: Colors.white.withAlpha(178),
                    fontSize: 13.5,
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: const Color(0xFF1A1108),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Go to Dashboard',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
          'Choose Your Plan',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFF59E0B),
              backgroundColor: const Color(0xFF1E222D),
              child: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    final usage = _mySubscription?['usage'];
    final hasUsage = usage is Map && (usage as Map).isNotEmpty;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // ── Hero Header ─────────────────────────────────────────────────
          _buildHeroHeader(),

          // ── Plan Cards ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _plans.map<Widget>((p) {
                final plan = p is Map<String, dynamic>
                    ? p
                    : (p is Map
                        ? Map<String, dynamic>.from(p)
                        : <String, dynamic>{});
                final planTier =
                    (plan['tier'] ?? '').toString().toUpperCase();
                final isCurrent =
                    planTier.isNotEmpty && planTier == _currentTier;
                return PlanCard(
                  plan: plan,
                  isCurrentPlan: isCurrent,
                  isYearly: _isYearly,
                  isProcessing: _paymentProcessing &&
                      _selectedPlanId ==
                          (plan['id']?.toString() ?? ''),
                  onSubscribe:
                      _paymentProcessing ? null : () => _subscribe(plan),
                );
              }).toList(),
            ),
          ),

          // ── Usage Card (shown below plans if data available) ─────────────
          if (hasUsage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: SubscriptionUsageCard(
                usage: Map<String, dynamic>.from(usage as Map),
              ),
            ),

          // ── Trust / Security Footer ───────────────────────────────────────
          _buildTrustFooter(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0D14), Color(0xFF131820)],
        ),
      ),
      child: Column(
        children: [
          // Top pill tag
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withAlpha(38),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFF59E0B).withAlpha(102)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome,
                    color: Color(0xFFF59E0B), size: 14),
                SizedBox(width: 6),
                Text(
                  'GROW YOUR SHOP\'S RETAIL REACH',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Supercharge Your Shop',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'List more products, run promoted events on the\ncustomer home screen, and get discovered by thousands.',
            style: TextStyle(
              color: Colors.white.withAlpha(178),
              fontSize: 13.5,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),

          // ── Monthly / Yearly Toggle ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1E2A),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _toggleBtn('Monthly', !_isYearly,
                    () => setState(() => _isYearly = false)),
                _toggleBtn('Yearly (Save 20%)', _isYearly,
                    () => setState(() => _isYearly = true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustFooter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        children: [
          _trustRow(Icons.security_rounded,
              'Bank-grade Razorpay payment security'),
          const SizedBox(height: 11),
          _trustRow(Icons.bolt_rounded,
              'Product & event limits increase instantly on payment'),
          const SizedBox(height: 11),
          _trustRow(Icons.receipt_long_rounded,
              'Automated GST-compliant tax invoices'),
          const SizedBox(height: 11),
          _trustRow(Icons.autorenew_rounded,
              'Upgrade, downgrade or cancel anytime'),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)])
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color:
                        const Color(0xFFF59E0B).withAlpha(90),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF1A1108) : Colors.white60,
            fontWeight:
                active ? FontWeight.w900 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _trustRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF94A3B8), size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white.withAlpha(165), fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
