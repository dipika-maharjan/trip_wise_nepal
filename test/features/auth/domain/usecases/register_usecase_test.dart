import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:trip_wise_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthEntity(
      fullName: 'fallback',
      email: 'fallback@email.com',
      username: 'fallback',
      password: 'fallback',
      profilePicture: null,
    ));
  });

  late RegisterUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUseCase(authRepository: mockRepository);
  });

  const tFullName = 'Test User';
  const tEmail = 'test@example.com';
  const tUsername = 'testuser';
  const tPassword = 'password123';

  group('RegisterUseCase', () {
    test('should return true when registration is successful', () async {
      when(() => mockRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      final result = await usecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          username: tUsername,
          password: tPassword,
        ),
      );

      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass AuthEntity with correct values to repository', () async {
      AuthEntity? capturedEntity;
      when(() => mockRepository.register(any())).thenAnswer((invocation) {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      await usecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          username: tUsername,
          password: tPassword,
        ),
      );

      expect(capturedEntity?.fullName, tFullName);
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.username, tUsername);
      expect(capturedEntity?.password, tPassword);
      expect(capturedEntity?.profilePicture, isNull);
    });

    test('should handle optional profilePicture as null', () async {
      AuthEntity? capturedEntity;
      when(() => mockRepository.register(any())).thenAnswer((invocation) {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      await usecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          username: tUsername,
          password: tPassword,
        ),
      );

      expect(capturedEntity?.profilePicture, isNull);
    });

    test('should return failure when registration fails', () async {
      const failure = ApiFailure(message: 'Email already exists');
      when(() => mockRepository.register(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const RegisterParams(
          fullName: tFullName,
          email: tEmail,
          username: tUsername,
          password: tPassword,
        ),
      );

      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('RegisterParams', () {
    test('should have correct props', () {
      const params = RegisterParams(
        fullName: tFullName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
      );
      expect(params.props, [
        tFullName,
        tEmail,
        tUsername,
        tPassword,
        null, // profilePicture
      ]);
    });

    test('two params with same values should be equal', () {
      const params1 = RegisterParams(
        fullName: tFullName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
      );
      const params2 = RegisterParams(
        fullName: tFullName,
        email: tEmail,
        username: tUsername,
        password: tPassword,
      );
      expect(params1, params2);
    });
  });
}