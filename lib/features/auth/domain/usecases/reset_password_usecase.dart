import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/auth/data/repositories/auth_repository.dart';
import 'package:trip_wise_nepal/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordParams({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
}

// Create Provider
final resetPasswordUsecaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ResetPasswordUseCase(authRepository: authRepository);
});

class ResetPasswordUseCase {
  final IAuthRepository _authRepository;

  ResetPasswordUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Either<Failure, bool>> call(ResetPasswordParams params) async {
    return await _authRepository.resetPassword(params.token, params.newPassword);
  }
}
