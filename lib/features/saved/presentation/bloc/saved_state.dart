import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';

abstract class SavedState extends Equatable {
  const SavedState();

  @override
  List<Object?> get props => [];
}

class SavedInitial extends SavedState {
  const SavedInitial();
}

class SavedLoaded extends SavedState {
  final bool isLoading;
  final bool isSuccess;
  final Failure? failure;
  final List<dynamic>? savedProducts;
  final List<dynamic>? savedShops;

  const SavedLoaded({
    this.isLoading = false,
    this.isSuccess = false,
    this.failure,
    this.savedProducts,
    this.savedShops,
  });

  SavedLoaded copyWith({
    bool? isLoading,
    bool? isSuccess,
    Failure? failure,
    List<dynamic>? savedProducts,
    List<dynamic>? savedShops,
  }) {
    return SavedLoaded(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false, // reset to false by default on actions unless overridden
      failure: failure,
      savedProducts: savedProducts ?? this.savedProducts,
      savedShops: savedShops ?? this.savedShops,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, failure, savedProducts, savedShops];
}
