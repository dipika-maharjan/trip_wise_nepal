import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/core/services/storage/user_session_service.dart';
import 'package:trip_wise_nepal/features/profile/data/repositories/profile_repository.dart';
import 'package:trip_wise_nepal/features/profile/domain/usecases/upload_image_usecase.dart';
import 'package:trip_wise_nepal/features/profile/presentation/state/profile_state.dart';
import 'package:trip_wise_nepal/features/profile/presentation/view_model/profile_viewmodel.dart';

class MockUploadPhotoUsecase extends Mock implements UploadPhotoUsecase {}

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  late ProviderContainer container;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;
  late MockProfileRepository mockProfileRepository;
  late MockUserSessionService mockUserSessionService;

  setUp(() {
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
    mockProfileRepository = MockProfileRepository();
    mockUserSessionService = MockUserSessionService();

    container = ProviderContainer(
      overrides: [
        uploadPhotoUsecaseProvider.overrideWithValue(mockUploadPhotoUsecase),
        profileRepositoryProvider.overrideWithValue(mockProfileRepository),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
      ],
    );
    addTearDown(container.dispose);
  });

  test('uploadProfileImage sets state to loaded on success', () async {
    final file = File('test.png');

    when(() => mockUploadPhotoUsecase(file))
        .thenAnswer((_) async => const Right('image-url'));

    final viewModel = container.read(profileViewModelProvider.notifier);

    await viewModel.uploadProfileImage(file);

    final state = container.read(profileViewModelProvider);
    expect(state.status, ProfileStatus.loaded);
    expect(state.imageUrl, 'image-url');
    expect(state.errorMessage, isNull);
  });

  test('uploadProfileImage sets state to error on failure', () async {
    final file = File('test.png');

    const failure = ApiFailure(message: 'Upload failed');
    when(() => mockUploadPhotoUsecase(file))
        .thenAnswer((_) async => const Left(failure));

    final viewModel = container.read(profileViewModelProvider.notifier);

    await viewModel.uploadProfileImage(file);

    final state = container.read(profileViewModelProvider);
    expect(state.status, ProfileStatus.error);
    expect(state.errorMessage, failure.message);
  });

  test('updateProfile updates session and sets state to loaded on success',
      () async {
    when(() => mockProfileRepository.updateProfile('New Name', 'new@example.com'))
        .thenAnswer((_) async => const Right(true));

    when(
      () => mockUserSessionService.updateUserDetails(
        fullName: 'New Name',
        email: 'new@example.com',
      ),
    ).thenAnswer((_) async {});

    final viewModel = container.read(profileViewModelProvider.notifier);

    await viewModel.updateProfile('New Name', 'new@example.com');

    final state = container.read(profileViewModelProvider);
    expect(state.status, ProfileStatus.loaded);
    verify(
      () => mockUserSessionService.updateUserDetails(
        fullName: 'New Name',
        email: 'new@example.com',
      ),
    ).called(1);
  });

  test('updateProfile sets state to error when repository returns failure',
      () async {
    const failure = ApiFailure(message: 'Update failed');
    when(() => mockProfileRepository.updateProfile('New Name', 'new@example.com'))
        .thenAnswer((_) async => const Left(failure));

    final viewModel = container.read(profileViewModelProvider.notifier);

    await viewModel.updateProfile('New Name', 'new@example.com');

    final state = container.read(profileViewModelProvider);
    expect(state.status, ProfileStatus.error);
    expect(state.errorMessage, failure.message);
  });
}