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
  String? _error;

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
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _subscribe(Map<String, dynamic> plan) async {
    final planId = (plan['id'] ?? plan['tier'] ?? '').toString();
    final price = double.tryParse(plan['price']?.toString() ?? '0') ?? 0;

    if (price == 0) {
      // Free plan — activate directly
      setState(() => _paymentProcessing = true);
      try {
        await _service.createOrder(planId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Free plan activated!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        _showError('Failed to activate plan');
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
      final orderData = await _service.createOrder(planId);
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
        'theme': {'color': '#4E342E'},
      };

      _razorpay.open(options);
    } catch (e) {
      _showError('Failed to create order: ${e.toString()}');
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
      }
    } catch (e) {
      setState(() => _paymentProcessing = false);
      _showError('Payment verification failed');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _paymentProcessing = false);
    _showError('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _paymentProcessing = false);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 20),
              const Text('Payment Successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your plan has been activated.',
                style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFF1A0E0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Choose Your Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : RefreshIndicator(
            onRefresh: _loadData,
            color: Colors.amber,
            backgroundColor: const Color(0xFF2D1B13),
            child: _buildBody(),
          ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header gradient
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0E0A), Color(0xFF2D1B13)],
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Supercharge Your Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reach more customers, grow faster',
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Yearly / Monthly toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
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

          // Plan cards
          Padding(
            padding: const EdgeInsets.all(16),
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

          // Current usage (if shopkeeper has a subscription)
          if (_mySubscription != null && _mySubscription!['usage'] is Map)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: SubscriptionUsageCard(
                usage: Map<String, dynamic>.from(_mySubscription!['usage'] as Map),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white70,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

