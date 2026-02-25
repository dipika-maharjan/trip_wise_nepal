import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/login_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/register_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:trip_wise_nepal/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  late final RegisterUseCase _registerUsecase;
  late final LoginUseCase _loginUsecase;
  late final GetCurrentUserUseCase _getCurrentUserUsecase;
  late final LogoutUseCase _logoutUsecase;
  late final RequestPasswordResetUseCase _requestPasswordResetUsecase;
  late final ResetPasswordUseCase _resetPasswordUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _requestPasswordResetUsecase = ref.read(requestPasswordResetUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    String? profilePicture,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterParams(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
        profilePicture: profilePicture,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      },
    );
  }

  Future<void> getCurrentUser() async {
    print('[DEBUG] AuthViewModel.getCurrentUser: called');
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();
    print('[DEBUG] AuthViewModel.getCurrentUser: result = $result');

    result.fold(
      (failure) {
        print('[DEBUG] AuthViewModel.getCurrentUser: failure = ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        );
      },
      (user) {
        print('[DEBUG] AuthViewModel.getCurrentUser: user restored = $user');
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> requestPasswordReset({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _requestPasswordResetUsecase(
      RequestPasswordResetParams(email: email),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.passwordResetRequested,
      ),
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _resetPasswordUsecase(
      ResetPasswordParams(token: token, newPassword: newPassword),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.passwordResetSuccess,
      ),
    );
  }
}