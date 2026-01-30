import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:trip_wise_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  const tUser = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: tEmail,
    username: 'testuser',
    password: null,
    profilePicture: null,
  );

  group('LoginUseCase', () {
    test('should return AuthEntity when login is successful', () async {
      // Arrange
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await usecase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when login fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Invalid credentials');
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct email and password to repository', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tUser));

      // Act
      await usecase(const LoginParams(email: tEmail, password: tPassword));

      // Assert
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    test(
      'should succeed with correct credentials and fail with wrong credentials',
      () async {
        // Arrange
        const wrongEmail = 'wrong@example.com';
        const wrongPassword = 'wrongpassword';
        const failure = ApiFailure(message: 'Invalid credentials');

        when(() => mockRepository.login(any(), any())).thenAnswer(
          (invocation) async {
            final email = invocation.positionalArguments[0] as String;
            final password = invocation.positionalArguments[1] as String;

            if (email == tEmail && password == tPassword) {
              return const Right(tUser);
            }
            return const Left(failure);
          },
        );

        // Act & Assert - success
        final successResult = await usecase(
          const LoginParams(email: tEmail, password: tPassword),
        );
        expect(successResult, const Right(tUser));

        // Act & Assert - wrong email
        final wrongEmailResult = await usecase(
          const LoginParams(email: wrongEmail, password: tPassword),
        );
        expect(wrongEmailResult, const Left(failure));

        // Act & Assert - wrong password
        final wrongPasswordResult = await usecase(
          const LoginParams(email: tEmail, password: wrongPassword),
        );
        expect(wrongPasswordResult, const Left(failure));
      },
    );
  });

  group('LoginParams', () {
    test('should have correct props', () {
      const params = LoginParams(email: tEmail, password: tPassword);
      expect(params.props, [tEmail, tPassword]);
    });

    test('two params with same values should be equal', () {
      const params1 = LoginParams(email: tEmail, password: tPassword);
      const params2 = LoginParams(email: tEmail, password: tPassword);
      expect(params1, params2);
    });

    test('two params with different values should not be equal', () {
      const params1 = LoginParams(email: tEmail, password: tPassword);
      const params2 = LoginParams(email: 'other@email.com', password: tPassword);
      expect(params1, isNot(params2));
    });
  });
}