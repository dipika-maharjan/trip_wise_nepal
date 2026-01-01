import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/auth/data/repositories/auth_repository.dart';
import 'package:trip_wise_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:trip_wise_nepal/features/auth/domain/repositories/auth_repository.dart';

// Create Provider
final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUserUseCase(authRepository: authRepository);
});

class GetCurrentUserUseCase {
  final IAuthRepository _authRepository;

  GetCurrentUserUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Either<Failure, AuthEntity>> call() async {
    return await _authRepository.getCurrentUser();
  }
}