import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/profile/domain/usecases/upload_image_usecase.dart';
import 'package:trip_wise_nepal/features/profile/presentation/state/profile_state.dart';
import 'package:trip_wise_nepal/core/services/storage/user_session_service.dart';
import 'package:trip_wise_nepal/features/profile/data/repositories/profile_repository.dart';

final profileViewModelProvider = NotifierProvider<ProfileViewModel, ProfileState>(
  ProfileViewModel.new,
);

class ProfileViewModel extends Notifier<ProfileState> {
  UploadPhotoUsecase get _uploadPhotoUsecase => ref.read(uploadPhotoUsecaseProvider);
  IProfileRepository get _profileRepository => ref.read(profileRepositoryProvider);
  UserSessionService get _userSessionService => ref.read(userSessionServiceProvider);

  @override
  ProfileState build() {
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

  Future<void> updateProfile(String name, String email) async {
    state = state.copyWith(status: ProfileStatus.loading);
    final result = await _profileRepository.updateProfile(name, email);
    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) async {
        if (success) {
          // Update only the stored name/email so profile picture remains unchanged
          await _userSessionService.updateUserDetails(
            fullName: name,
            email: email,
          );
          state = state.copyWith(status: ProfileStatus.loaded);
        } else {
          state = state.copyWith(
            status: ProfileStatus.error,
            errorMessage: 'Profile update failed',
          );
        }
      },
    );
  }
}
