import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:trip_wise_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/get_current_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUserUseCase(authRepository: mockRepository);
  });

  const tUser = AuthEntity(
    authId: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    username: 'testuser',
    password: null,
    profilePicture: null,
  );

  group('GetCurrentUserUseCase', () {
    test('should return AuthEntity when user is authenticated', () async {
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(tUser));

      final result = await usecase();

      expect(result, const Right(tUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when user is not authenticated', () async {
      const failure = ApiFailure(message: 'User not authenticated');
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return LocalDatabaseFailure when local storage fails', () async {
      const failure = LocalDatabaseFailure(message: 'Failed to read user data');
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should return user with all fields populated', () async {
      const userWithAllFields = AuthEntity(
        authId: '1',
        fullName: 'Test User',
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
        profilePicture: 'https://example.com/pic.jpg',
      );
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(userWithAllFields));

      final result = await usecase();

      result.fold((failure) => fail('Should return user'), (user) {
        expect(user.authId, '1');
        expect(user.fullName, 'Test User');
        expect(user.email, 'test@example.com');
        expect(user.username, 'testuser');
        expect(user.password, 'password123');
        expect(user.profilePicture, 'https://example.com/pic.jpg');
      });
    });
  });
}