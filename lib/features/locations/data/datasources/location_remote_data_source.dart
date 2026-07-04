import 'package:field_track/core/constants/api_constants.dart';
import 'package:field_track/core/error/exceptions.dart';
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
    try {
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
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LocationModel> addLocation(Map<String, dynamic> data) async {
    try {
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
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LocationModel> updateLocation(
      String id, Map<String, dynamic> data) async {
    try {
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
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    try {
      await apiClient.dio.delete(ApiConstants.locationById(id));
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
