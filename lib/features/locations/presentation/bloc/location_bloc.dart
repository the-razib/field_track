import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/locations/domain/entities/location.dart';
import 'package:field_track/features/locations/domain/usecases/add_location_usecase.dart';
import 'package:field_track/features/locations/domain/usecases/delete_location_usecase.dart';
import 'package:field_track/features/locations/domain/usecases/get_locations_usecase.dart';
import 'package:field_track/features/locations/domain/usecases/update_location_usecase.dart';
import 'package:field_track/features/locations/presentation/bloc/location_event.dart';
import 'package:field_track/features/locations/presentation/bloc/location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetLocationsUseCase getLocationsUseCase;
  final AddLocationUseCase addLocationUseCase;
  final UpdateLocationUseCase updateLocationUseCase;
  final DeleteLocationUseCase deleteLocationUseCase;

  List<GeoLocation> _cachedLocations = [];

  LocationBloc({
    required this.getLocationsUseCase,
    required this.addLocationUseCase,
    required this.updateLocationUseCase,
    required this.deleteLocationUseCase,
  }) : super(const LocationInitial()) {
    on<LocationsFetchRequested>(_onFetch);
    on<LocationAddRequested>(_onAdd);
    on<LocationUpdateRequested>(_onUpdate);
    on<LocationDeleteRequested>(_onDelete);
  }

  Future<void> _onFetch(
    LocationsFetchRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    final result = await getLocationsUseCase(const NoParams());
    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (locations) {
        _cachedLocations = locations;
        emit(LocationLoaded(locations: locations));
      },
    );
  }

  Future<void> _onAdd(
    LocationAddRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    final result = await addLocationUseCase(AddLocationParams(
      locationName: event.locationName,
      latitude: event.latitude,
      longitude: event.longitude,
      radiusM: event.radiusM,
      isActive: event.isActive,
    ));
    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (location) {
        _cachedLocations = [..._cachedLocations, location];
        emit(const LocationActionSuccess(message: 'Location added'));
        emit(LocationLoaded(locations: _cachedLocations));
      },
    );
  }

  Future<void> _onUpdate(
    LocationUpdateRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    final result = await updateLocationUseCase(UpdateLocationParams(
      id: event.id,
      locationName: event.locationName,
      latitude: event.latitude,
      longitude: event.longitude,
      radiusM: event.radiusM,
      isActive: event.isActive,
    ));
    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (updated) {
        _cachedLocations = _cachedLocations
            .map((l) => l.id == updated.id ? updated : l)
            .toList();
        emit(const LocationActionSuccess(message: 'Location updated'));
        emit(LocationLoaded(locations: _cachedLocations));
      },
    );
  }

  Future<void> _onDelete(
    LocationDeleteRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    final result =
        await deleteLocationUseCase(DeleteLocationParams(id: event.id));
    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (_) {
        _cachedLocations =
            _cachedLocations.where((l) => l.id != event.id).toList();
        emit(const LocationActionSuccess(message: 'Location deleted'));
        emit(LocationLoaded(locations: _cachedLocations));
      },
    );
  }
}
