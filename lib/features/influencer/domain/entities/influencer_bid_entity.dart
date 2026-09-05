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

  // Influencer info (used in shopkeeper view)
  final String? influencerName;
  final String? influencerAvatar;
  final String? influencerInstagram;
  final String? influencerBio;
  final int? influencerFollowers;
  final double? influencerEngagement;
  final String? influencerNiche;

  // Campaign info (populated from nested campaign in GET /influencer/bids)
  final String? campaignTitle;
  final String? campaignStatus;
  final String? productName;
  final String? productImageUrl;

  // Shop / shopkeeper contact info
  final String? shopName;
  final String? shopEmail;
  final String? shopPhone;
  final String? shopLogoUrl;
  final String? shopAddress;

  // Assignment (created when bid accepted)
  final String? assignmentId;
  final String? submittedContentUrl;

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
    this.influencerName,
    this.influencerAvatar,
    this.influencerInstagram,
    this.influencerBio,
    this.influencerFollowers,
    this.influencerEngagement,
    this.influencerNiche,
    this.campaignTitle,
    this.campaignStatus,
    this.productName,
    this.productImageUrl,
    this.shopName,
    this.shopEmail,
    this.shopPhone,
    this.shopLogoUrl,
    this.shopAddress,
    this.assignmentId,
    this.submittedContentUrl,
  });

  @override
  List<Object?> get props => [
        id, campaignId, influencerId, proposedAmount, availableDate,
        deliveryDate, proposal, status, isShortlisted, createdAt,
        influencerName, influencerAvatar, influencerInstagram, influencerBio,
        influencerFollowers, influencerEngagement, influencerNiche,
        campaignTitle, campaignStatus, productName, productImageUrl,
        shopName, shopEmail, shopPhone, shopLogoUrl, shopAddress,
        assignmentId, submittedContentUrl,
      ];
}
