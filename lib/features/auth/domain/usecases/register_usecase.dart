import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/auth/data/repositories/auth_repository.dart';
import 'package:trip_wise_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:trip_wise_nepal/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String username;
  final String password;
  final String? profilePicture;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        username,
        password,
        profilePicture,
      ];
}

// Create Provider
final registerUsecaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUseCase(authRepository: authRepository);
});

class RegisterUseCase {
  final IAuthRepository _authRepository;

  RegisterUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<Either<Failure, bool>> call(RegisterParams params) async {
    final authEntity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      username: params.username,
      password: params.password,
      profilePicture: params.profilePicture,
    );

    return await _authRepository.register(authEntity);
  }
}