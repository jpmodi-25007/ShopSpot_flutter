import 'package:equatable/equatable.dart';

class InfluencerBidEntity extends Equatable {
  final String id;
  final String campaignId;
  final String influencerId;
  final double proposedAmount;
  final DateTime availableDate;
  final DateTime deliveryDate;
  final String? proposal;
  final String status;
  final bool isShortlisted;
  final DateTime createdAt;

  const InfluencerBidEntity({
    required this.id,
    required this.campaignId,
    required this.influencerId,
    required this.proposedAmount,
    required this.availableDate,
    required this.deliveryDate,
    this.proposal,
    required this.status,
    required this.isShortlisted,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, campaignId, influencerId, proposedAmount, availableDate,
        deliveryDate, proposal, status, isShortlisted, createdAt,
      ];
}
