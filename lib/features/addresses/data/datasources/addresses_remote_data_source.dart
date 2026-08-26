import '../../../../core/network/api_client.dart';

abstract class AddressesRemoteDataSource {
  Future<List<dynamic>> getAddresses();
  Future<void> createAddress(Map<String, dynamic> data);
  Future<void> updateAddress(String addressId, Map<String, dynamic> data);
  Future<void> deleteAddress(String addressId);
}

class AddressesRemoteDataSourceImpl implements AddressesRemoteDataSource {
  final ApiClient apiClient;

  AddressesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> getAddresses() async {
    final response = await apiClient.get('/addresses');
    final data = response.data is List ? response.data : response.data['data'];
    return data as List<dynamic>? ?? [];
  }

  @override
  Future<void> createAddress(Map<String, dynamic> data) async {
    await apiClient.post('/addresses', data: data);
  }

  @override
  Future<void> updateAddress(String addressId, Map<String, dynamic> data) async {
    await apiClient.put('/addresses/$addressId', data: data);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await apiClient.delete('/addresses/$addressId');
  }
}
