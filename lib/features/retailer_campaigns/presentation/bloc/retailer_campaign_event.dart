import 'package:equatable/equatable.dart';

import '../../domain/repositories/retailer_campaign_repository.dart';

abstract class RetailerCampaignEvent extends Equatable {
  const RetailerCampaignEvent();

  @override
  List<Object?> get props => [];
}

class GetMyCampaignsRequested extends RetailerCampaignEvent {
  final int page;
  final int limit;

  const GetMyCampaignsRequested({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class CreateCampaignRequested extends RetailerCampaignEvent {
  final CreateCampaignParams params;

  const CreateCampaignRequested(this.params);

  @override
  List<Object?> get props => [params];
}

class GetCampaignBidsRequested extends RetailerCampaignEvent {
  final String campaignId;
  final int page;
  final int limit;

  const GetCampaignBidsRequested(this.campaignId, {this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [campaignId, page, limit];
}

class AcceptBidRequested extends RetailerCampaignEvent {
  final String bidId;
  final String campaignId; // to refresh bids after accept

  const AcceptBidRequested({required this.bidId, required this.campaignId});

  @override
  List<Object?> get props => [bidId, campaignId];
}

class CounterBidRequested extends RetailerCampaignEvent {
  final String bidId;
  final String campaignId;
  final double amount;
  final String? message;

  const CounterBidRequested({
    required this.bidId,
    required this.campaignId,
    required this.amount,
    this.message,
  });

  @override
  List<Object?> get props => [bidId, campaignId, amount, message];
}

class DeleteCampaignRequested extends RetailerCampaignEvent {
  final String campaignId;

  const DeleteCampaignRequested(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

class UpdateCampaignRequested extends RetailerCampaignEvent {
  final String campaignId;
  final Map<String, dynamic> data;

  const UpdateCampaignRequested({required this.campaignId, required this.data});

  @override
  List<Object?> get props => [campaignId, data];
}
