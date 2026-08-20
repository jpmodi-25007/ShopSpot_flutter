import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
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

  const ShopEntity({
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

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        slug,
        description,
        categoryId,
        logoUrl,
        coverImageUrl,
        address,
        latitude,
        longitude,
        city,
        state,
        pincode,
        phone,
        whatsapp,
        email,
        gstNumber,
        isGstVerified,
        isKycVerified,
        businessHours,
        rating,
        reviewCount,
        subscriptionTier,
        subscriptionExpiresAt,
        status,
        isOpen,
        createdAt,
        updatedAt,
      ];
}
