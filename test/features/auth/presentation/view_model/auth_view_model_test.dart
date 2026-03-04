import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/login_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/register_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:trip_wise_nepal/features/auth/presentation/state/auth_state.dart';
import 'package:trip_wise_nepal/features/auth/presentation/view_model/auth_view_model.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockRequestPasswordResetUseCase extends Mock
    implements RequestPasswordResetUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

void main() {
  late ProviderContainer container;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockRequestPasswordResetUseCase mockRequestPasswordResetUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;

  const tUser = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    username: 'testuser',
    password: 'password',
    profilePicture: null,
  );

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockRequestPasswordResetUseCase = MockRequestPasswordResetUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUseCase),
        loginUsecaseProvider.overrideWithValue(mockLoginUseCase),
        getCurrentUserUsecaseProvider
            .overrideWithValue(mockGetCurrentUserUseCase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUseCase),
        requestPasswordResetUsecaseProvider
            .overrideWithValue(mockRequestPasswordResetUseCase),
        resetPasswordUsecaseProvider
            .overrideWithValue(mockResetPasswordUseCase),
      ],
    );
    addTearDown(container.dispose);
  });

  test('login sets state to authenticated on success', () async {
    when(
      () => mockLoginUseCase(
        const LoginParams(email: 'test@example.com', password: 'password'),
      ),
    ).thenAnswer((_) async => const Right(tUser));

    final viewModel = container.read(authViewModelProvider.notifier);

    await viewModel.login(email: 'test@example.com', password: 'password');

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user, tUser);
    expect(state.errorMessage, isNull);
  });

  test('login sets state to error on failure', () async {
    const failure = ApiFailure(message: 'Invalid credentials');

    when(
      () => mockLoginUseCase(
        const LoginParams(email: 'test@example.com', password: 'password'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final viewModel = container.read(authViewModelProvider.notifier);

    await viewModel.login(email: 'test@example.com', password: 'password');

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, failure.message);
    expect(state.user, isNull);
  });
}