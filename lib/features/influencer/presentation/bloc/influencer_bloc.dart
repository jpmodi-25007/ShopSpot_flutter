import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/influencer_use_cases.dart';
import '../../domain/usecases/get_influencer_analytics_use_case.dart';
import 'influencer_event.dart';
import 'influencer_state.dart';
import '../../domain/entities/influencer_bid_entity.dart';

class InfluencerBloc extends Bloc<InfluencerEvent, InfluencerState> {
  final GetInfluencerProfileUseCase _getProfile;
  final UpdateInfluencerProfileUseCase _updateProfile;
  final GetEligibleCampaignsUseCase _getCampaigns;
  final GetMyBidsUseCase _getMyBids;
  final SubmitBidUseCase _submitBid;
  final WithdrawBidUseCase _withdrawBid;
  final GetInfluencerAnalyticsUseCase _getAnalytics;

  InfluencerBloc({
    required GetInfluencerProfileUseCase getProfile,
    required UpdateInfluencerProfileUseCase updateProfile,
    required GetEligibleCampaignsUseCase getCampaigns,
    required GetMyBidsUseCase getMyBids,
    required SubmitBidUseCase submitBid,
    required WithdrawBidUseCase withdrawBid,
    required GetInfluencerAnalyticsUseCase getAnalytics,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _getCampaigns = getCampaigns,
        _getMyBids = getMyBids,
        _submitBid = submitBid,
        _withdrawBid = withdrawBid,
        _getAnalytics = getAnalytics,
        super(const InfluencerInitial()) {
    on<GetInfluencerProfileRequested>(_onGetProfile);
    on<UpdateInfluencerProfileRequested>(_onUpdateProfile);
    on<GetEligibleCampaignsRequested>(_onGetCampaigns);
    on<GetMyBidsRequested>(_onGetMyBids);
    on<SubmitBidRequested>(_onSubmitBid);
    on<WithdrawBidRequested>(_onWithdrawBid);
    on<GetInfluencerAnalyticsRequested>(_onGetAnalytics);
  }

  InfluencerLoaded get _current =>
      state is InfluencerLoaded ? state as InfluencerLoaded : const InfluencerLoaded();

  Future<void> _onGetAnalytics(GetInfluencerAnalyticsRequested event, Emitter<InfluencerState> emit) async {
    emit(_current.copyWith(isLoading: true, failure: null));
    final result = await _getAnalytics.execute();
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (analytics) => emit(_current.copyWith(isLoading: false, analytics: analytics)),
    );
  }

  Future<void> _onGetProfile(GetInfluencerProfileRequested event, Emitter<InfluencerState> emit) async {
    emit(_current.copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _getProfile.execute();
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (profile) => emit(_current.copyWith(isLoading: false, profile: profile)),
    );
  }

  Future<void> _onUpdateProfile(UpdateInfluencerProfileRequested event, Emitter<InfluencerState> emit) async {
    emit(_current.copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _updateProfile.execute(event.data);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (profile) => emit(_current.copyWith(isLoading: false, profile: profile, isSuccess: true)),
    );
  }

  Future<void> _onGetCampaigns(GetEligibleCampaignsRequested event, Emitter<InfluencerState> emit) async {
    final isLoadMore = event.page > 1;
    if (!isLoadMore) {
      emit(_current.copyWith(isLoading: true, failure: null));
    }
    final result = await _getCampaigns.execute(page: event.page, limit: event.limit, industry: event.industry, search: event.search);
    result.fold(
      (f) {
        if (!isLoadMore) emit(_current.copyWith(isLoading: false, failure: f));
      },
      (campaigns) {
        if (isLoadMore) {
          final currentCampaigns = _current.campaigns ?? [];
          emit(_current.copyWith(
            isLoading: false,
            campaigns: [...currentCampaigns, ...campaigns],
            campaignsHasReachedMax: campaigns.isEmpty || campaigns.length < event.limit,
            campaignsCurrentPage: event.page,
          ));
        } else {
          emit(_current.copyWith(
            isLoading: false,
            campaigns: campaigns,
            campaignsHasReachedMax: campaigns.isEmpty || campaigns.length < event.limit,
            campaignsCurrentPage: event.page,
          ));
        }
      },
    );
  }

  Future<void> _onGetMyBids(GetMyBidsRequested event, Emitter<InfluencerState> emit) async {
    final isLoadMore = event.page > 1;
    if (!isLoadMore) {
      emit(_current.copyWith(isLoading: true, failure: null));
    }
    final result = await _getMyBids.execute(page: event.page, limit: event.limit);
    result.fold(
      (f) {
        if (!isLoadMore) emit(_current.copyWith(isLoading: false, failure: f));
      },
      (bids) {
        if (isLoadMore) {
          final currentBids = _current.bids ?? [];
          emit(_current.copyWith(
            isLoading: false,
            bids: [...currentBids, ...bids],
            bidsHasReachedMax: bids.isEmpty || bids.length < event.limit,
            bidsCurrentPage: event.page,
          ));
        } else {
          emit(_current.copyWith(
            isLoading: false,
            bids: bids,
            bidsHasReachedMax: bids.isEmpty || bids.length < event.limit,
            bidsCurrentPage: event.page,
          ));
        }
      },
    );
  }

  Future<void> _onSubmitBid(SubmitBidRequested event, Emitter<InfluencerState> emit) async {
    emit(_current.copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _submitBid.execute(campaignId: event.campaignId, data: event.data);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (bid) {
        // Append to bids list
        final updatedBids = <InfluencerBidEntity>[...(_current.bids ?? []), bid];
        emit(_current.copyWith(isLoading: false, bids: updatedBids, isSuccess: true));
      },
    );
  }

  Future<void> _onWithdrawBid(WithdrawBidRequested event, Emitter<InfluencerState> emit) async {
    emit(_current.copyWith(isLoading: true, failure: null, isSuccess: false));
    final result = await _withdrawBid.execute(event.bidId);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (_) {
        // Remove from bids list
        final updatedBids = _current.bids?.where((b) => b.id != event.bidId).toList() ?? [];
        emit(_current.copyWith(isLoading: false, bids: updatedBids, isSuccess: true));
      },
    );
  }
}
