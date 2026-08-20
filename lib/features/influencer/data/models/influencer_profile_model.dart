import '../../domain/entities/influencer_profile_entity.dart';

class InfluencerProfileModel {
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

  InfluencerProfileModel({
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

  factory InfluencerProfileModel.fromJson(Map<String, dynamic> json) {
    return InfluencerProfileModel(
      id: json['id'],
      userId: json['userId'],
      displayName: json['displayName'],
      username: json['username'],
      bio: json['bio'],
      profileImage: json['profileImage'],
      city: json['city'],
      languages: List<String>.from(json['languages'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      instagramUrl: json['instagramUrl'],
      facebookUrl: json['facebookUrl'],
      youtubeUrl: json['youtubeUrl'],
      followers: json['followers'] ?? 0,
      avgViews: json['avgViews'] ?? 0,
      engagementRate: double.tryParse(json['engagementRate']?.toString() ?? '0') ?? 0.0,
      verificationStatus: json['verificationStatus'] ?? 'PENDING',
      creatorScore: json['creatorScore'] ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      completedCampaigns: json['completedCampaigns'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  InfluencerProfileEntity toEntity() => InfluencerProfileEntity(
        id: id,
        userId: userId,
        displayName: displayName,
        username: username,
        bio: bio,
        profileImage: profileImage,
        city: city,
        languages: languages,
        categories: categories,
        instagramUrl: instagramUrl,
        facebookUrl: facebookUrl,
        youtubeUrl: youtubeUrl,
        followers: followers,
        avgViews: avgViews,
        engagementRate: engagementRate,
        verificationStatus: verificationStatus,
        creatorScore: creatorScore,
        rating: rating,
        completedCampaigns: completedCampaigns,
        isActive: isActive,
        createdAt: createdAt,
      );
}
