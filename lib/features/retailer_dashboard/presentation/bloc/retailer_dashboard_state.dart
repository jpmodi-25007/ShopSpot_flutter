import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../shop/domain/entities/shop_entity.dart';

sealed class RetailerDashboardState extends Equatable {
  final ShopEntity? shop;
  final Map<String, dynamic>? analytics;
  final bool isLoading;
  final Failure? failure;
  final bool isSuccess;

  const RetailerDashboardState({
    this.shop,
    this.analytics,
    this.isLoading = false,
    this.failure,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [shop, analytics, isLoading, failure, isSuccess];
}

final class RetailerDashboardInitial extends RetailerDashboardState {
  const RetailerDashboardInitial();
}

final class RetailerDashboardLoaded extends RetailerDashboardState {
  const RetailerDashboardLoaded({
    super.shop,
    super.analytics,
    super.isLoading,
    super.failure,
    super.isSuccess,
  });

  RetailerDashboardLoaded copyWith({
    ShopEntity? shop,
    Map<String, dynamic>? analytics,
    bool? isLoading,
    Failure? failure,
    bool? isSuccess,
  }) {
    return RetailerDashboardLoaded(
      shop: shop ?? this.shop,
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
