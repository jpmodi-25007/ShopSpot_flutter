import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/notification_entity.dart';
import '../../../influencer/presentation/bloc/influencer_bloc.dart';
import '../../../influencer/presentation/bloc/influencer_event.dart';
import '../../../influencer/presentation/bloc/influencer_state.dart';
import '../../../influencer/presentation/pages/bid_detail_screen.dart';
import '../../../influencer/presentation/pages/campaign_details_screen.dart';

void openNotification(BuildContext context, NotificationEntity notification, String role) {
  final data = notification.data ?? {};
  final type = notification.type ?? '';
  final shopkeeper = role == 'SHOPKEEPER' || role == 'RETAILER';
  final influencer = role == 'INFLUENCER';
  final campaignId = data['campaignId']?.toString();
  final bidId = data['bidId']?.toString();
  final negotiationId = data['negotiationId']?.toString();
  final productId = data['productId']?.toString();

  if (type.startsWith('NEGOTIATION_')) {
    if (shopkeeper) {
      context.push(negotiationId == null
          ? '/retailer/negotiations'
          : '/retailer/negotiations/$negotiationId');
    } else if (negotiationId != null) {
      context.push('/negotiation/$negotiationId');
    }
    return;
  }

  if (type.startsWith('RESERVATION_')) {
    context.push('/reservations');
    return;
  }

  if (type == 'NEW_ORDER' || type == 'ORDER_STATUS_CHANGED') {
    context.push(shopkeeper ? '/retailer/orders' : '/my-orders');
    return;
  }

  if (type == 'PRICE_DROP' || type == 'PRODUCT_OFFER') {
    if (productId != null) context.push('/product-detail/$productId');
    return;
  }

  if (type == 'STOCK_ALERT') {
    context.push('/retailer/inventory');
    return;
  }

  if (type == 'CAMPAIGN_PUBLISHED') {
    if (influencer && campaignId != null) {
      context.push('/influencer/campaign-details/$campaignId');
    } else if (shopkeeper && campaignId != null) {
      context.push('/retailer/campaigns/$campaignId');
    } else if (influencer) {
      context.push('/influencer/home');
    }
    return;
  }

  if (type.startsWith('BID_') || type.startsWith('CONTENT_') || type == 'REVISION_REQUESTED' || type == 'CAMPAIGN_COMPLETED') {
    if (shopkeeper) {
      context.push(campaignId == null
          ? '/retailer/campaigns'
          : '/retailer/campaigns/$campaignId/bids');
    } else if (influencer && bidId != null) {
      context.push('/influencer/bid-detail/$bidId');
    } else if (influencer) {
      context.push('/influencer/campaigns');
    }
    return;
  }

  if (type == 'SYSTEM') {
    if (influencer) context.push('/influencer/profile');
    return;
  }
}

class InfluencerBidByIdScreen extends StatefulWidget {
  final String bidId;
  const InfluencerBidByIdScreen({super.key, required this.bidId});

  @override
  State<InfluencerBidByIdScreen> createState() => _InfluencerBidByIdScreenState();
}

class _InfluencerBidByIdScreenState extends State<InfluencerBidByIdScreen> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    context.read<InfluencerBloc>().add(const GetMyBidsRequested(limit: 50));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (!state.isLoading && state is! InfluencerInitial && mounted) {
          setState(() => _checked = true);
        }
      },
      builder: (context, state) {
        final match = (state.bids ?? const []).where((bid) => bid.id == widget.bidId);
        if (match.isNotEmpty) {
          return BidDetailScreen(bid: match.first);
        }
        if (!_checked) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Bid')),
          body: const Center(child: Text('This bid is no longer available.')),
        );
      },
    );
  }
}

class InfluencerCampaignByIdScreen extends StatefulWidget {
  final String campaignId;
  const InfluencerCampaignByIdScreen({super.key, required this.campaignId});

  @override
  State<InfluencerCampaignByIdScreen> createState() => _InfluencerCampaignByIdScreenState();
}

class _InfluencerCampaignByIdScreenState extends State<InfluencerCampaignByIdScreen> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    context.read<InfluencerBloc>().add(const GetEligibleCampaignsRequested(limit: 50));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfluencerBloc, InfluencerState>(
      listener: (context, state) {
        if (!state.isLoading && state is! InfluencerInitial && mounted) {
          setState(() => _checked = true);
        }
      },
      builder: (context, state) {
        final match = (state.campaigns ?? const []).where((campaign) => campaign.id == widget.campaignId);
        if (match.isNotEmpty) {
          return CampaignDetailsScreen(campaign: match.first);
        }
        if (!_checked) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Campaign')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('This campaign is no longer open for new bids.'),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/influencer/home'),
                    child: const Text('Back to Discover'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
