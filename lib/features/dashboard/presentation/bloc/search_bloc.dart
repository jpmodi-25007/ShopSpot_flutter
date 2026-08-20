import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/global_search_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GlobalSearchUseCase globalSearch;

  SearchBloc({required this.globalSearch}) : super(SearchInitial()) {
    on<PerformSearchRequested>(_onPerformSearch);
  }

  Future<void> _onPerformSearch(PerformSearchRequested event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());
    try {
      final results = await globalSearch(event.query);
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
