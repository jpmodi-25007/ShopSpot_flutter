import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/theme/app_colors.dart';
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
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _subscribe(Map<String, dynamic> plan) async {
    final planTier = (plan['tier'] ?? '').toString().toUpperCase();
    if (planTier.isNotEmpty && planTier == _currentTier.toUpperCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already on this plan!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      return;
    }

    final planId = (plan['id'] ?? plan['tier'] ?? '').toString();
    final price = double.tryParse(plan['price']?.toString() ?? '0') ?? 0;

    if (price == 0) {
      // Free plan — activate directly
      setState(() => _paymentProcessing = true);
      try {
        await _service.createOrder(planId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Free Starter plan activated!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          _loadData();
        }
      } catch (e) {
        _showError('Failed to activate plan: ${e.toString()}');
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
      final orderData = await _service.createOrder(planId, planTier: plan['tier']?.toString());

      if (orderData['activatedDirectly'] == true ||
          orderData['simulated'] == true ||
          orderData['free'] == true) {
        setState(() => _paymentProcessing = false);
        if (mounted) {
          _showSuccessAnimation();
          _loadData();
        }
        return;
      }

      final amount = int.tryParse(orderData['amount']?.toString() ?? '0') ?? 0;
      final orderId = (orderData['orderId'] ?? '').toString();
      final keyId = (orderData['keyId'] ?? '').toString();
      _currentRazorpayOrderId = orderId;

      final options = {
        'key': keyId,
        'amount': amount,
        'name': 'ShopSpot',
        'description': '${plan['name'] ?? plan['tier']} Plan Subscription',
        'order_id': orderId,
        'currency': 'INR',
        'prefill': {
          'contact': '',
          'email': '',
        },
        'theme': {'color': '#F59E0B'},
      };

      _razorpay.open(options);
    } catch (e) {
      final msg = e.toString().contains('Exception:')
          ? e.toString().replaceAll('Exception:', '').trim()
          : 'Payment initialization failed. Please try again.';
      _showError(msg);
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
      setState(() => _paymentProcessing = false);
      if (mounted) {
        _showSuccessAnimation();
        _loadData();
      }
    } catch (e) {
      setState(() => _paymentProcessing = false);
      _showError('Payment verification failed. Please contact support.');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _paymentProcessing = false);
    _showError('Payment cancelled or failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _paymentProcessing = false);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessAnimation() {
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
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Plan Activated!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your subscription has been activated successfully. Your higher product limits and event promotions are now live.',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13.5, height: 1.4),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Go to Dashboard', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _currentTier => (_mySubscription?['currentTier'] ?? 'FREE').toString();

  @override
  Widget build(BuildContext context) {
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
          'Choose Your Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFF59E0B),
              backgroundColor: const Color(0xFF1E222D),
              child: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header Hero Banner
          Container(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F0B09), Color(0xFF1C130D)],
              ),
            ),
            child: Column(
              children: [
                // Top Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFFF59E0B), size: 14),
                      SizedBox(width: 6),
                      Text(
                        'GROW YOUR SHOP RETAIL REACH',
                        style: TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Supercharge Your Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Expand product catalogue, run featured home-screen banners, and get discovered by thousands of nearby customers.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Monthly / Yearly Segmented Control
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E222D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _toggleBtn('Monthly', !_isYearly, () => setState(() => _isYearly = false)),
                      _toggleBtn('Yearly (Save 20%)', _isYearly, () => setState(() => _isYearly = true)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Plan Cards List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: _plans.map<Widget>((p) {
                final plan = p is Map<String, dynamic>
                    ? p
                    : (p is Map ? Map<String, dynamic>.from(p) : <String, dynamic>{});
                final planTier = (plan['tier'] ?? '').toString().toUpperCase();
                return PlanCard(
                  plan: plan,
                  isCurrentPlan: planTier.isNotEmpty && planTier == _currentTier.toUpperCase(),
                  isYearly: _isYearly,
                  isProcessing: _paymentProcessing && _selectedPlanId == (plan['id']?.toString() ?? ''),
                  onSubscribe: _paymentProcessing ? null : () => _subscribe(plan),
                );
              }).toList(),
            ),
          ),

          // Current usage card if available
          if (_mySubscription != null && _mySubscription!['usage'] is Map)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
              child: SubscriptionUsageCard(
                usage: Map<String, dynamic>.from(_mySubscription!['usage'] as Map),
              ),
            ),

          // Trust Badges Footer
          Container(
            margin: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              children: [
                _trustItem(Icons.security_rounded, 'Bank-grade Razorpay payment security'),
                const SizedBox(height: 10),
                _trustItem(Icons.bolt_rounded, 'Instant limit increase upon payment'),
                const SizedBox(height: 10),
                _trustItem(Icons.receipt_long_rounded, 'Automated GST-compliant tax invoices'),
                const SizedBox(height: 10),
                _trustItem(Icons.autorenew_rounded, 'Upgrade, downgrade or cancel anytime'),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)])
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF1A1108) : Colors.white70,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _trustItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
          ),
        ),
      ],
    );
  }
}
