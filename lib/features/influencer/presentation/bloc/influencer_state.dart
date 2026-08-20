import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/influencer_profile_entity.dart';
import '../../domain/entities/influencer_campaign_entity.dart';
import '../../domain/entities/influencer_bid_entity.dart';

sealed class InfluencerState extends Equatable {
  final InfluencerProfileEntity? profile;
  final List<InfluencerCampaignEntity>? campaigns;
  final List<InfluencerBidEntity>? bids;
  final bool campaignsHasReachedMax;
  final int campaignsCurrentPage;
  final bool bidsHasReachedMax;
  final int bidsCurrentPage;
  final bool isLoading;
  final Failure? failure;
  final bool isSuccess;

  const InfluencerState({
    this.profile,
    this.campaigns,
    this.bids,
    this.campaignsHasReachedMax = false,
    this.campaignsCurrentPage = 1,
    this.bidsHasReachedMax = false,
    this.bidsCurrentPage = 1,
    this.isLoading = false,
    this.failure,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [
        profile,
        campaigns,
        bids,
        campaignsHasReachedMax,
        campaignsCurrentPage,
        bidsHasReachedMax,
        bidsCurrentPage,
        isLoading,
        failure,
        isSuccess
      ];
}

final class InfluencerInitial extends InfluencerState {
  const InfluencerInitial();
}

final class InfluencerLoaded extends InfluencerState {
  final Map<String, dynamic>? analytics;

  const InfluencerLoaded({
    super.profile,
    super.campaigns,
    super.bids,
    super.campaignsHasReachedMax,
    super.campaignsCurrentPage,
    super.bidsHasReachedMax,
    super.bidsCurrentPage,
    super.isLoading,
    super.failure,
    super.isSuccess,
    this.analytics,
  });

  InfluencerLoaded copyWith({
    InfluencerProfileEntity? profile,
    List<InfluencerCampaignEntity>? campaigns,
    List<InfluencerBidEntity>? bids,
    bool? campaignsHasReachedMax,
    int? campaignsCurrentPage,
    bool? bidsHasReachedMax,
    int? bidsCurrentPage,
    bool? isLoading,
    Failure? failure,
    bool? isSuccess,
    Map<String, dynamic>? analytics,
  }) {
    return InfluencerLoaded(
      profile: profile ?? this.profile,
      campaigns: campaigns ?? this.campaigns,
      bids: bids ?? this.bids,
      campaignsHasReachedMax: campaignsHasReachedMax ?? this.campaignsHasReachedMax,
      campaignsCurrentPage: campaignsCurrentPage ?? this.campaignsCurrentPage,
      bidsHasReachedMax: bidsHasReachedMax ?? this.bidsHasReachedMax,
      bidsCurrentPage: bidsCurrentPage ?? this.bidsCurrentPage,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
      isSuccess: isSuccess ?? this.isSuccess,
      analytics: analytics ?? this.analytics,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        campaigns,
        bids,
        campaignsHasReachedMax,
        campaignsCurrentPage,
        bidsHasReachedMax,
        bidsCurrentPage,
        isLoading,
        failure,
        isSuccess,
        analytics
      ];
}
