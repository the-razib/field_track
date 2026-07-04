import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:field_track/core/storage/secure_storage.dart';
import 'package:field_track/core/usecases/usecase.dart';
import 'package:field_track/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:field_track/features/auth/domain/usecases/login_usecase.dart';
import 'package:field_track/features/auth/domain/usecases/logout_usecase.dart';
import 'package:field_track/features/auth/domain/usecases/register_usecase.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_event.dart';
import 'package:field_track/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SecureStorage secureStorage;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.secureStorage,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final hasTokens = await secureStorage.hasTokens();
    if (!hasTokens) {
      emit(const AuthUnauthenticated());
      return;
    }

    // Try to fetch user profile to validate tokens
    final result = await getCurrentUserUseCase(const NoParams());
    result.fold(
      (failure) {
        // Tokens are invalid — clear and go to login
        secureStorage.clearTokens();
        emit(const AuthUnauthenticated());
      },
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async {
        emit(AuthError(message: failure.message));
      },
      (token) async {
        // Fetch user profile after successful login
        final userResult = await getCurrentUserUseCase(const NoParams());
        userResult.fold(
          (failure) => emit(const AuthAuthenticated()),
          (user) => emit(AuthAuthenticated(user: user)),
        );
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AuthError(message: failure.message));
      },
      (token) async {
        // Fetch user profile after successful registration
        final userResult = await getCurrentUserUseCase(const NoParams());
        userResult.fold(
          (failure) => emit(const AuthAuthenticated()),
          (user) => emit(AuthAuthenticated(user: user)),
        );
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await logoutUseCase(const NoParams());
    emit(const AuthUnauthenticated());
  }
}
