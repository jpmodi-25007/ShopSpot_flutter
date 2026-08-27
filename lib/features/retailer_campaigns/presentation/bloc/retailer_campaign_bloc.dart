import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/retailer_campaign_usecases.dart';
import 'retailer_campaign_event.dart';
import 'retailer_campaign_state.dart';

class RetailerCampaignBloc extends Bloc<RetailerCampaignEvent, RetailerCampaignState> {
  final CreateCampaignUseCase createCampaign;
  final GetMyCampaignsUseCase getMyCampaigns;
  final GetCampaignBidsUseCase getCampaignBids;
  final AcceptBidUseCase acceptBid;
  final CounterBidUseCase counterBid;
  final UpdateCampaignUseCase updateCampaign;
  final DeleteCampaignUseCase deleteCampaign;

  RetailerCampaignBloc({
    required this.createCampaign,
    required this.getMyCampaigns,
    required this.getCampaignBids,
    required this.acceptBid,
    required this.counterBid,
    required this.updateCampaign,
    required this.deleteCampaign,
  }) : super(RetailerCampaignInitial()) {
    on<GetMyCampaignsRequested>(_onGetMyCampaigns);
    on<CreateCampaignRequested>(_onCreateCampaign);
    on<GetCampaignBidsRequested>(_onGetCampaignBids);
    on<AcceptBidRequested>(_onAcceptBid);
    on<CounterBidRequested>(_onCounterBid);
    on<UpdateCampaignRequested>(_onUpdateCampaign);
    on<DeleteCampaignRequested>(_onDeleteCampaign);
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

  Future<void> _onCounterBid(CounterBidRequested event, Emitter<RetailerCampaignState> emit) async {
    emit(RetailerCampaignLoading());
    try {
      await counterBid(event.bidId, event.amount, message: event.message);
      emit(const RetailerCampaignSuccess("Counter offer sent"));
      add(GetCampaignBidsRequested(event.campaignId));
    } catch (e) {
      emit(RetailerCampaignError(e.toString()));
    }
  }

  Future<void> _onUpdateCampaign(UpdateCampaignRequested event, Emitter<RetailerCampaignState> emit) async {
    emit(RetailerCampaignLoading());
    try {
      await updateCampaign(event.campaignId, event.data);
      emit(const RetailerCampaignSuccess("Campaign updated successfully"));
      add(const GetMyCampaignsRequested());
    } catch (e) {
      emit(RetailerCampaignError(e.toString()));
    }
  }

  Future<void> _onDeleteCampaign(DeleteCampaignRequested event, Emitter<RetailerCampaignState> emit) async {
    emit(RetailerCampaignLoading());
    try {
      await deleteCampaign(event.campaignId);
      emit(const RetailerCampaignSuccess("Campaign deleted successfully"));
      add(const GetMyCampaignsRequested());
    } catch (e) {
      emit(RetailerCampaignError(e.toString()));
    }
  }
}
