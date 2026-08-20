import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/retailer_campaign_usecases.dart';
import 'retailer_campaign_event.dart';
import 'retailer_campaign_state.dart';

class RetailerCampaignBloc extends Bloc<RetailerCampaignEvent, RetailerCampaignState> {
  final CreateCampaignUseCase createCampaign;
  final GetMyCampaignsUseCase getMyCampaigns;
  final GetCampaignBidsUseCase getCampaignBids;
  final AcceptBidUseCase acceptBid;

  RetailerCampaignBloc({
    required this.createCampaign,
    required this.getMyCampaigns,
    required this.getCampaignBids,
    required this.acceptBid,
  }) : super(RetailerCampaignInitial()) {
    on<GetMyCampaignsRequested>(_onGetMyCampaigns);
    on<CreateCampaignRequested>(_onCreateCampaign);
    on<GetCampaignBidsRequested>(_onGetCampaignBids);
    on<AcceptBidRequested>(_onAcceptBid);
  }

  Future<void> _onGetMyCampaigns(GetMyCampaignsRequested event, Emitter<RetailerCampaignState> emit) async {
    final isLoadMore = event.page > 1;
    if (!isLoadMore) {
      emit(RetailerCampaignLoading());
    }
    try {
      final campaigns = await getMyCampaigns(page: event.page, limit: event.limit);
      if (isLoadMore && state is RetailerCampaignLoaded) {
        final currentCampaigns = (state as RetailerCampaignLoaded).campaigns;
        emit(RetailerCampaignLoaded(
          campaigns: [...currentCampaigns, ...campaigns],
          hasReachedMax: campaigns.isEmpty || campaigns.length < event.limit,
          currentPage: event.page,
        ));
      } else {
        emit(RetailerCampaignLoaded(
          campaigns: campaigns,
          hasReachedMax: campaigns.isEmpty || campaigns.length < event.limit,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      if (!isLoadMore) emit(RetailerCampaignError(e.toString()));
    }
  }

  Future<void> _onCreateCampaign(CreateCampaignRequested event, Emitter<RetailerCampaignState> emit) async {
    emit(RetailerCampaignLoading());
    try {
      await createCampaign(event.params);
      emit(const RetailerCampaignSuccess("Campaign created successfully"));
      add(const GetMyCampaignsRequested());
    } catch (e) {
      emit(RetailerCampaignError(e.toString()));
    }
  }

  Future<void> _onGetCampaignBids(GetCampaignBidsRequested event, Emitter<RetailerCampaignState> emit) async {
    final isLoadMore = event.page > 1;
    if (!isLoadMore) {
      emit(RetailerCampaignLoading());
    }
    try {
      final bids = await getCampaignBids(event.campaignId, page: event.page, limit: event.limit);
      if (isLoadMore && state is RetailerCampaignBidsLoaded) {
        final currentBids = (state as RetailerCampaignBidsLoaded).bids;
        emit(RetailerCampaignBidsLoaded(
          bids: [...currentBids, ...bids],
          campaignId: event.campaignId,
          hasReachedMax: bids.isEmpty || bids.length < event.limit,
          currentPage: event.page,
        ));
      } else {
        emit(RetailerCampaignBidsLoaded(
          bids: bids,
          campaignId: event.campaignId,
          hasReachedMax: bids.isEmpty || bids.length < event.limit,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      if (!isLoadMore) emit(RetailerCampaignError(e.toString()));
    }
  }

  Future<void> _onAcceptBid(AcceptBidRequested event, Emitter<RetailerCampaignState> emit) async {
    emit(RetailerCampaignLoading());
    try {
      await acceptBid(event.bidId);
      emit(const RetailerCampaignSuccess("Bid accepted successfully"));
      add(GetCampaignBidsRequested(event.campaignId));
    } catch (e) {
      emit(RetailerCampaignError(e.toString()));
    }
  }
}
