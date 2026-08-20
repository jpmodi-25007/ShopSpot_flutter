import 'package:equatable/equatable.dart';
import '../../../shop/domain/entities/shop_entity.dart';

class RetailerDashboardAnalytics extends Equatable {
  final int totalProducts;
  final int totalInquiries;
  final double rating;
  final int reviewCount;
  final int todayViews;

  const RetailerDashboardAnalytics({
    required this.totalProducts,
    required this.totalInquiries,
    required this.rating,
    required this.reviewCount,
    required this.todayViews,
  });

  @override
  List<Object?> get props => [totalProducts, totalInquiries, rating, reviewCount, todayViews];
}

class RetailerDashboardEntity extends Equatable {
  final ShopEntity? shop;
  final RetailerDashboardAnalytics? analytics;

  const RetailerDashboardEntity({this.shop, this.analytics});

  @override
  List<Object?> get props => [shop, analytics];
}
