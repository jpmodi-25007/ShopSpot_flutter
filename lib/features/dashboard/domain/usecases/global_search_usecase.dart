import '../entities/search_result_entity.dart';
import '../repositories/search_repository.dart';

class GlobalSearchUseCase {
  final SearchRepository repository;

  GlobalSearchUseCase(this.repository);

  Future<SearchResultEntity> call(String query) {
    return repository.globalSearch(query);
  }
}
