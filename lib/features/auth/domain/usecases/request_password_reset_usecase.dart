import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/auth/data/repositories/auth_repository.dart';
import 'package:trip_wise_nepal/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetParams extends Equatable {
  final String email;

  const RequestPasswordResetParams({required this.email});

  @override
  List<Object?> get props => [email];
}

// Create Provider
final requestPasswordResetUsecaseProvider = Provider<RequestPasswordResetUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RequestPasswordResetUseCase(authRepository: authRepository);
});

class RequestPasswordResetUseCase {
  final IAuthRepository _authRepository;

  RequestPasswordResetUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Either<Failure, bool>> call(RequestPasswordResetParams params) async {
    return await _authRepository.requestPasswordReset(params.email);
  }
}
