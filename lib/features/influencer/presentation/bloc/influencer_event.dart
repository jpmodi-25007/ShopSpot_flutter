import 'package:equatable/equatable.dart';

sealed class InfluencerEvent extends Equatable {
  const InfluencerEvent();

  @override
  List<Object?> get props => [];
}

final class GetInfluencerProfileRequested extends InfluencerEvent {
  const GetInfluencerProfileRequested();
}

final class UpdateInfluencerProfileRequested extends InfluencerEvent {
  final Map<String, dynamic> data;
  const UpdateInfluencerProfileRequested(this.data);
  @override
  List<Object?> get props => [data];
}

final class GetEligibleCampaignsRequested extends InfluencerEvent {
  final int page;
  final int limit;
  final String? industry;
  final String? search;
  const GetEligibleCampaignsRequested({this.page = 1, this.limit = 20, this.industry, this.search});
  
  @override
  List<Object?> get props => [page, limit, industry, search];
}

final class GetMyBidsRequested extends InfluencerEvent {
  final int page;
  final int limit;
  const GetMyBidsRequested({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

final class SubmitBidRequested extends InfluencerEvent {
  final String campaignId;
  final Map<String, dynamic> data;

  const SubmitBidRequested({required this.campaignId, required this.data});

  @override
  List<Object?> get props => [campaignId, data];
}

final class GetInfluencerAnalyticsRequested extends InfluencerEvent {
  const GetInfluencerAnalyticsRequested();
}
