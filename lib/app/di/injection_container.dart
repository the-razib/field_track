import 'package:get_it/get_it.dart';

import 'package:field_track/core/network/api_client.dart';
import 'package:field_track/core/network/connectivity_service.dart';
import 'package:field_track/core/storage/local_database.dart';
import 'package:field_track/core/storage/secure_storage.dart';
import 'package:field_track/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:field_track/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:field_track/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:field_track/features/auth/domain/repositories/auth_repository.dart';
import 'package:field_track/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:field_track/features/auth/domain/usecases/login_usecase.dart';
import 'package:field_track/features/auth/domain/usecases/logout_usecase.dart';
import 'package:field_track/features/auth/domain/usecases/register_usecase.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:field_track/features/locations/data/datasources/location_remote_data_source.dart';
import 'package:field_track/features/locations/data/repositories/location_repository_impl.dart';
import 'package:field_track/features/locations/domain/repositories/location_repository.dart';
import 'package:field_track/features/locations/domain/usecases/add_location_usecase.dart';
import 'package:field_track/features/locations/domain/usecases/delete_location_usecase.dart';
import 'package:field_track/features/locations/domain/usecases/get_locations_usecase.dart';
import 'package:field_track/features/locations/domain/usecases/update_location_usecase.dart';
import 'package:field_track/features/locations/presentation/bloc/location_bloc.dart';
import 'package:field_track/features/todos/data/datasources/todo_local_data_source.dart';
import 'package:field_track/features/todos/data/datasources/todo_remote_data_source.dart';
import 'package:field_track/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:field_track/features/todos/domain/repositories/todo_repository.dart';
import 'package:field_track/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:field_track/features/todos/domain/usecases/sync_todos_usecase.dart';
import 'package:field_track/features/todos/domain/usecases/toggle_todo_usecase.dart';
import 'package:field_track/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:field_track/features/geofence/data/services/geofence_service.dart';

final sl = GetIt.instance;

/// Initialize all dependencies.
Future<void> initDependencies() async {
  // ─── Core ───────────────────────────────────────────────────────
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  sl.registerLazySingleton<LocalDatabase>(() => LocalDatabase());
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(secureStorage: sl<SecureStorage>()),
  );

  // ─── Auth ───────────────────────────────────────────────────────
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl<SecureStorage>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      connectivityService: sl<ConnectivityService>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  // ─── Locations ──────────────────────────────────────────────────
  // Data sources
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: sl<LocationRemoteDataSource>(),
      connectivityService: sl<ConnectivityService>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLocationsUseCase(sl<LocationRepository>()));
  sl.registerLazySingleton(() => AddLocationUseCase(sl<LocationRepository>()));
  sl.registerLazySingleton(
    () => UpdateLocationUseCase(sl<LocationRepository>()),
  );
  sl.registerLazySingleton(
    () => DeleteLocationUseCase(sl<LocationRepository>()),
  );

  // BLoC
  sl.registerFactory(
    () => LocationBloc(
      getLocationsUseCase: sl<GetLocationsUseCase>(),
      addLocationUseCase: sl<AddLocationUseCase>(),
      updateLocationUseCase: sl<UpdateLocationUseCase>(),
      deleteLocationUseCase: sl<DeleteLocationUseCase>(),
    ),
  );

  // ─── Todos ──────────────────────────────────────────────────────
  // Data sources
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(localDatabase: sl<LocalDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      remoteDataSource: sl<TodoRemoteDataSource>(),
      localDataSource: sl<TodoLocalDataSource>(),
      connectivityService: sl<ConnectivityService>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodosUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => ToggleTodoUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => SyncTodosUseCase(sl<TodoRepository>()));

  // BLoC
  sl.registerFactory(
    () => TodoBloc(
      getTodosUseCase: sl<GetTodosUseCase>(),
      toggleTodoUseCase: sl<ToggleTodoUseCase>(),
      syncTodosUseCase: sl<SyncTodosUseCase>(),
      connectivityService: sl<ConnectivityService>(),
    ),
  );

  // ─── Geofencing ──────────────────────────────────────────────────
  sl.registerLazySingleton<GeofenceService>(
    () => GeofenceService(locationRepository: sl<LocationRepository>()),
  );
}

