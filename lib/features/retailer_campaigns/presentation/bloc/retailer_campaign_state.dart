import 'package:equatable/equatable.dart';
import '../../../influencer/domain/entities/influencer_campaign_entity.dart';
import '../../../influencer/domain/entities/influencer_bid_entity.dart';

abstract class RetailerCampaignState extends Equatable {
  const RetailerCampaignState();

  @override
  List<Object?> get props => [];
}

class RetailerCampaignInitial extends RetailerCampaignState {}

class RetailerCampaignLoading extends RetailerCampaignState {}

class RetailerCampaignLoaded extends RetailerCampaignState {
  final List<InfluencerCampaignEntity> campaigns;
  final bool hasReachedMax;
  final int currentPage;

  const RetailerCampaignLoaded({
    required this.campaigns,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [campaigns, hasReachedMax, currentPage];
}

class RetailerCampaignBidsLoaded extends RetailerCampaignState {
  final List<InfluencerBidEntity> bids;
  final String campaignId;
  final bool hasReachedMax;
  final int currentPage;

  const RetailerCampaignBidsLoaded({
    required this.bids,
    required this.campaignId,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [bids, campaignId, hasReachedMax, currentPage];
}

class RetailerCampaignSuccess extends RetailerCampaignState {
  final String message;

  const RetailerCampaignSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RetailerCampaignError extends RetailerCampaignState {
  final String message;

  const RetailerCampaignError(this.message);

  @override
  List<Object?> get props => [message];
}
