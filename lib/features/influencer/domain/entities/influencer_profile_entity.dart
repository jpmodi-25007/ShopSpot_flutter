import 'package:equatable/equatable.dart';

class InfluencerProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String username;
  final String? bio;
  final String? profileImage;
  final String? city;
  final List<String> languages;
  final List<String> categories;
  final String? instagramUrl;
  final String? facebookUrl;
  final String? youtubeUrl;
  final int followers;
  final int avgViews;
  final double engagementRate;
  final String verificationStatus;
  final int creatorScore;
  final double rating;
  final int completedCampaigns;
  final bool isActive;
  final DateTime createdAt;

  const InfluencerProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.username,
    this.bio,
    this.profileImage,
    this.city,
    required this.languages,
    required this.categories,
    this.instagramUrl,
    this.facebookUrl,
    this.youtubeUrl,
    required this.followers,
    required this.avgViews,
    required this.engagementRate,
    required this.verificationStatus,
    required this.creatorScore,
    required this.rating,
    required this.completedCampaigns,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, userId, displayName, username, bio, profileImage, city,
        languages, categories, instagramUrl, facebookUrl, youtubeUrl,
        followers, avgViews, engagementRate, verificationStatus,
        creatorScore, rating, completedCampaigns, isActive, createdAt,
      ];
}
