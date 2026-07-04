import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:field_track/core/error/exceptions.dart';
import 'package:field_track/core/error/failures.dart';
import 'package:field_track/core/network/connectivity_service.dart';
import 'package:field_track/features/auth/domain/entities/auth_token.dart';
import 'package:field_track/features/auth/domain/entities/user.dart';
import 'package:field_track/features/auth/domain/repositories/auth_repository.dart';
import 'package:field_track/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:field_track/features/auth/data/datasources/auth_remote_data_source.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  }) async {
    if (!await connectivityService.isOnline) {
      return const Left(NetworkFailure());
    }

    try {
      final tokenModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.saveTokens(tokenModel);
      return Right(tokenModel);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (!await connectivityService.isOnline) {
      return const Left(NetworkFailure());
    }

    try {
      final tokenModel = await remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      await localDataSource.saveTokens(tokenModel);
      return Right(tokenModel);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Try server-side logout (ignore failures — still clear local tokens)
      if (await connectivityService.isOnline) {
        try {
          await remoteDataSource.logout();
        } catch (_) {
          // Server logout failure shouldn't block local cleanup
        }
      }
      await localDataSource.clearTokens();
      return const Right(null);
    } catch (e) {
      // Always clear local tokens, even on error
      await localDataSource.clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (!await connectivityService.isOnline) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return localDataSource.hasTokens();
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure(
        message: 'Connection timed out. Please try again.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message = 'Something went wrong. Please try again.';

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          message;
    }

    if (statusCode == 401) {
      return AuthFailure(message: message, statusCode: statusCode);
    }

    return ServerFailure(message: message, statusCode: statusCode);
  }
}
