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
      setState(() {
        _data = results[0] as Map<String, dynamic>;
        _history = results[1] as List;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = _data?['currentTier'] as String? ?? 'FREE';
    final expiresAt = _data?['expiresAt'];
    final plan = _data?['plan'] as Map<String, dynamic>?;
    final usage = _data?['usage'] as Map<String, dynamic>?;

    final Map<String, Map<String, dynamic>> tierConfig = {
      'FREE': {'icon': '🆓', 'color': Colors.grey, 'name': 'Free'},
      'PRO': {'icon': '⭐', 'color': const Color(0xFF3B82F6), 'name': 'Pro'},
      'PREMIUM': {'icon': '👑', 'color': const Color(0xFFF59E0B), 'name': 'Premium'},
    };
    final config = tierConfig[tier] ?? tierConfig['FREE']!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0E0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Subscription', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current plan card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (config['color'] as Color).withOpacity(0.3),
                          (config['color'] as Color).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: (config['color'] as Color).withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(config['icon'] as String, style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${config['name']} Plan',
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                if (expiresAt != null)
                                  Text('Renews ${_formatDate(expiresAt.toString())}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        if (plan != null) ...[
                          const SizedBox(height: 16),
                          Text('₹${plan['price']}/month',
                            style: TextStyle(color: config['color'] as Color, fontSize: 24, fontWeight: FontWeight.w900)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Usage meters
                  if (usage != null) SubscriptionUsageCard(usage: usage),
                  const SizedBox(height: 16),

                  // Upgrade button (if not premium)
                  if (tier != 'PREMIUM')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary500,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SubscriptionPlansPage()));
                          if (result == true) _load();
                        },
                        icon: const Icon(Icons.rocket_launch, color: Colors.black),
                        label: const Text('Upgrade Plan',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Payment history
                  const Text('Payment History',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_history.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('No payment history yet',
                          style: TextStyle(color: Colors.white54)),
                      ),
                    ),
                  ..._history.map((p) => _paymentTile(p)),
                ],
              ),
            ),
          ),
    );
  }

  Widget _paymentTile(Map<String, dynamic> p) {
    final status = p['status'] as String? ?? '';
    final isPaid = status == 'paid';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isPaid ? Colors.green : Colors.red).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.error,
              color: isPaid ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${double.parse(p['amount'].toString()).toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(_formatDate(p['createdAt'].toString()),
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isPaid ? Colors.green : Colors.red).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status.toUpperCase(),
              style: TextStyle(
                color: isPaid ? Colors.green : Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              )),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

