import '../../domain/entities/shop_entity.dart';

class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final String slug;
  final String? description;
  final String? categoryId;
  final String? logoUrl;
  final String? coverImageUrl;
  final String address;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? pincode;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? gstNumber;
  final bool isGstVerified;
  final bool isKycVerified;
  final Map<String, dynamic>? businessHours;
  final double rating;
  final int reviewCount;
  final String subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final String status;
  final bool isOpen;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.slug,
    this.description,
    this.categoryId,
    this.logoUrl,
    this.coverImageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    this.whatsapp,
    this.email,
    this.gstNumber,
    required this.isGstVerified,
    required this.isKycVerified,
    this.businessHours,
    required this.rating,
    required this.reviewCount,
    required this.subscriptionTier,
    this.subscriptionExpiresAt,
    required this.status,
    required this.isOpen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: json['categoryId']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      address: json['address']?.toString() ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : 0.0,
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      phone: json['phone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      email: json['email']?.toString(),
      gstNumber: json['gstNumber']?.toString(),
      isGstVerified: json['isGstVerified'] ?? false,
      isKycVerified: json['isKycVerified'] ?? false,
      businessHours: json['businessHours'] as Map<String, dynamic>?,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      subscriptionTier: json['subscriptionTier']?.toString() ?? 'FREE',
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.tryParse(json['subscriptionExpiresAt'].toString())
          : null,
      status: json['status']?.toString() ?? 'ACTIVE',
      isOpen: json['isOpen'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }


  ShopEntity toEntity() {
    return ShopEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      slug: slug,
      description: description,
      categoryId: categoryId,
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
      address: address,
      latitude: latitude,
      longitude: longitude,
      city: city,
      state: state,
      pincode: pincode,
      phone: phone,
      whatsapp: whatsapp,
      email: email,
      gstNumber: gstNumber,
      isGstVerified: isGstVerified,
      isKycVerified: isKycVerified,
      businessHours: businessHours,
      rating: rating,
      reviewCount: reviewCount,
      subscriptionTier: subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt,
      status: status,
      isOpen: isOpen,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
