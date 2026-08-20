import '../entities/search_result_entity.dart';

abstract class SearchRepository {
  Future<SearchResultEntity> globalSearch(String query);
}
