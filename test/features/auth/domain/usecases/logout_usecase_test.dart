import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:trip_wise_nepal/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LogoutUseCase(authRepository: mockRepository);
  });

  group('LogoutUseCase', () {
    test('should return true when logout is successful', () async {
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Right(true));

      final result = await usecase();

      expect(result, const Right(true));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when logout fails', () async {
      const failure = ApiFailure(message: 'Logout failed');
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return LocalDatabaseFailure when clearing local data fails', () async {
      const failure = LocalDatabaseFailure(message: 'Failed to clear local data');
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.logout()).called(1);
    });
  });
}