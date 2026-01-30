import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/profile/data/repositories/profile_repository.dart';
import 'package:trip_wise_nepal/features/profile/domain/usecases/upload_image_usecase.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late UploadPhotoUsecase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UploadPhotoUsecase(profileRepository: mockRepository);
  });

  final tFile = File('test.jpg');
  const tImageUrl = 'http://example.com/image.jpg';

  group('UploadPhotoUsecase', () {
    test('should return imageUrl when upload is successful', () async {
      when(() => mockRepository.uploadProfileImage(tFile))
          .thenAnswer((_) async => const Right(tImageUrl));

      final result = await usecase(tFile);

      expect(result, const Right(tImageUrl));
      verify(() => mockRepository.uploadProfileImage(tFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when upload fails', () async {
      const failure = ApiFailure(message: 'Upload failed');
      when(() => mockRepository.uploadProfileImage(tFile))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tFile);

      expect(result, const Left(failure));
      verify(() => mockRepository.uploadProfileImage(tFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}