import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class PerformSearchRequested extends SearchEvent {
  final String query;

  const PerformSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}
