import 'package:equatable/equatable.dart';

sealed class RetailerDashboardEvent extends Equatable {
  const RetailerDashboardEvent();

  @override
  List<Object?> get props => [];
}

final class GetMyShopRequested extends RetailerDashboardEvent {
  const GetMyShopRequested();
}

final class GetShopAnalyticsRequested extends RetailerDashboardEvent {
  const GetShopAnalyticsRequested();
}

final class CreateShopRequested extends RetailerDashboardEvent {
  final Map<String, dynamic> data;
  const CreateShopRequested(this.data);

  @override
  List<Object?> get props => [data];
}

final class UpdateShopRequested extends RetailerDashboardEvent {
  final Map<String, dynamic> data;
  const UpdateShopRequested(this.data);

  @override
  List<Object?> get props => [data];
}
