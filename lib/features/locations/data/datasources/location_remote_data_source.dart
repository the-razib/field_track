import 'package:field_track/core/constants/api_constants.dart';
import 'package:field_track/core/network/api_client.dart';
import 'package:field_track/features/locations/data/models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<LocationModel>> getLocations();
  Future<LocationModel> addLocation(Map<String, dynamic> data);
  Future<LocationModel> updateLocation(String id, Map<String, dynamic> data);
  Future<void> deleteLocation(String id);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final ApiClient apiClient;

  LocationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<LocationModel>> getLocations() async {
    final response = await apiClient.dio.get(ApiConstants.locations);
    final data = response.data;

    // Handle { locations: [...] } or direct array
    final List<dynamic> list = data is Map<String, dynamic>
        ? (data['locations'] as List<dynamic>? ??
            data['data'] as List<dynamic>? ??
            [])
        : (data is List ? data : []);

    return list
        .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LocationModel> addLocation(Map<String, dynamic> data) async {
    final response = await apiClient.dio.post(
      ApiConstants.locations,
      data: data,
    );
    final resData = response.data;
    final locationData = resData is Map<String, dynamic>
        ? (resData.containsKey('location')
            ? resData['location'] as Map<String, dynamic>
            : resData)
        : <String, dynamic>{};
    return LocationModel.fromJson(locationData);
  }

  @override
  Future<LocationModel> updateLocation(
      String id, Map<String, dynamic> data) async {
    final response = await apiClient.dio.put(
      ApiConstants.locationById(id),
      data: data,
    );
    final resData = response.data;
    final locationData = resData is Map<String, dynamic>
        ? (resData.containsKey('location')
            ? resData['location'] as Map<String, dynamic>
            : resData)
        : <String, dynamic>{};
    return LocationModel.fromJson(locationData);
  }

  @override
  Future<void> deleteLocation(String id) async {
    await apiClient.dio.delete(ApiConstants.locationById(id));
  }
}
