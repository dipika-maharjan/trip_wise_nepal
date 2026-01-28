import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/profile/domain/usecases/upload_image_usecase.dart';
import 'package:trip_wise_nepal/features/profile/presentation/state/profile_state.dart';

final profileViewModelProvider = NotifierProvider<ProfileViewModel, ProfileState>(
  ProfileViewModel.new,
);

class ProfileViewModel extends Notifier<ProfileState> {
  late final UploadPhotoUsecase _uploadPhotoUsecase;

  @override
  ProfileState build() {
    _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);
    return const ProfileState();
  }

  Future<void> uploadProfileImage(File imageFile) async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _uploadPhotoUsecase(imageFile);

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ),
      (imageUrl) => state = state.copyWith(
        status: ProfileStatus.loaded,
        imageUrl: imageUrl,
        errorMessage: null,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetState() {
    state = const ProfileState();
  }
}
