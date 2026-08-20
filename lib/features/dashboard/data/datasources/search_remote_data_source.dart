import '../../../../core/network/api_client.dart';
import '../models/search_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResultModel> globalSearch(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient apiClient;

  SearchRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SearchResultModel> globalSearch(String query) async {
    final response = await apiClient.get('/search', queryParameters: {'q': query});
    return SearchResultModel.fromJson(response.data);
  }
}
