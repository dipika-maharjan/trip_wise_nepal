import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/core/usecases/usecase.dart';
import 'package:trip_wise_nepal/features/profile/data/repositories/profile_repository.dart';

final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final profileRepository = ref.read(profileRepositoryProvider);
  return UploadPhotoUsecase(profileRepository: profileRepository);
});

class UploadPhotoUsecase implements UsecaseWithParms<String, File> {
  final IProfileRepository _profileRepository;
  UploadPhotoUsecase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  @override
  Future<Either<Failure, String>> call(File photo) {
    return _profileRepository.uploadProfileImage(photo);
  }
}


