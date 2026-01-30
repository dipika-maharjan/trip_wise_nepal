import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/core/services/storage/token_service.dart';
import 'package:trip_wise_nepal/features/profile/data/datasources/remote/profile_remote_datasource.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, String>> uploadProfileImage(File imageFile);
}

// Provider
final profileRemoteDataSourceProvider = Provider<IProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(
    dio: ref.read(apiClientProvider).dio,
    tokenService: ref.read(tokenServiceProvider),
  );
});

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final remoteDataSource = ref.read(profileRemoteDataSourceProvider);
  return ProfileRepository(profileRemoteDataSource: remoteDataSource);
});

// Implementation
class ProfileRepository implements IProfileRepository {
  final IProfileRemoteDataSource _profileRemoteDataSource;

  ProfileRepository({required IProfileRemoteDataSource profileRemoteDataSource})
      : _profileRemoteDataSource = profileRemoteDataSource;

  @override
  Future<Either<Failure, String>> uploadProfileImage(File imageFile) async {
    try {
      // Validate file exists
      if (!imageFile.existsSync()) {
        return const Left(ApiFailure(message: 'Image file does not exist'));
      }

      // Validate file size (max 5MB)
      final fileSizeInBytes = await imageFile.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 5) {
        return const Left(ApiFailure(message: 'Image size must be less than 5MB'));
      }

      // Validate file extension
      final fileName = imageFile.path.toLowerCase();
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
      final hasValidExtension = allowedExtensions.any((ext) => fileName.endsWith('.$ext'));

      if (!hasValidExtension) {
        return const Left(ApiFailure(message: 'Invalid image format. Allowed: jpg, jpeg, png, gif'));
      }

      final imageUrl = await _profileRemoteDataSource.uploadProfileImage(imageFile);
      return Right(imageUrl);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to upload image: ${e.toString()}'));
    }
  }
}
