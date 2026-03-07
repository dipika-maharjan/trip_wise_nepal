import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/core/services/connectivity/network_info.dart';
import 'package:trip_wise_nepal/core/services/hive/hive_service.dart';
import 'package:trip_wise_nepal/features/accommodation/data/datasources/accommodation_datasource.dart';
import 'package:trip_wise_nepal/features/accommodation/data/datasources/remote/accommodation_remote_datasource.dart';
import 'package:trip_wise_nepal/features/accommodation/data/models/accommodation_api_model.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/repositories/accommodation_repository.dart';

final accommodationRepositoryProvider = Provider<IAccommodationRepository>((ref) {
  final remoteDatasource = ref.read(accommodationRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final hiveService = ref.read(hiveServiceProvider);

  return AccommodationRepository(
    datasource: remoteDatasource,
    networkInfo: networkInfo,
    hiveService: hiveService,
  );
});

class AccommodationRepository implements IAccommodationRepository {
  final IAccommodationDataSource _datasource;
  final NetworkInfo _networkInfo;
  final HiveService _hiveService;

  AccommodationRepository({
    required IAccommodationDataSource datasource,
    required NetworkInfo networkInfo,
    required HiveService hiveService,
  })  : _datasource = datasource,
        _networkInfo = networkInfo,
        _hiveService = hiveService;

  @override
  Future<Either<Failure, List<AccommodationEntity>>> getAccommodations({
    int page = 1,
    int limit = 12,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _datasource.getAccommodations(
          page: page,
          limit: limit,
        );

        if (apiModels != null && apiModels.isNotEmpty) {
          final activeModels = apiModels.where((m) => m.isActive).toList();
          // Cache latest accommodations for offline use
          await _hiveService.cacheAccommodations(
            activeModels.map((m) => m.toJson()).toList(),
          );
          final entities = AccommodationApiModel.toEntityList(activeModels);
          return Right(entities);
        }
        return const Left(
          ApiFailure(message: "No accommodations available"),
        );
      } on DioException catch (e) {
        // If network/API fails while we appear online, try cached data
        final cached = _hiveService.getCachedAccommodations();
        if (cached.isNotEmpty) {
          final models = cached
              .map((m) => AccommodationApiModel.fromJson(m))
              .where((m) => m.isActive)
              .toList();
          final entities = AccommodationApiModel.toEntityList(models);
          return Right(entities);
        }

        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? 'Failed to fetch accommodations',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline: attempt to load from cache
      final cached = _hiveService.getCachedAccommodations();
      if (cached.isNotEmpty) {
        final models = cached
            .map((m) => AccommodationApiModel.fromJson(m))
            .where((m) => m.isActive)
            .toList();
        final entities = AccommodationApiModel.toEntityList(models);
        return Right(entities);
      }

      return const Left(
        ApiFailure(message: "No internet connection"),
      );
    }
  }

  @override
  Future<Either<Failure, AccommodationEntity>> getAccommodationById(
    String id,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _datasource.getAccommodationById(id);

        if (apiModel != null) {
          return Right(apiModel.toEntity());
        }
        return const Left(
          ApiFailure(message: "Accommodation not found"),
        );
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch accommodation',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        ApiFailure(message: "No internet connection"),
      );
    }
  }

  @override
  Future<Either<Failure, List<AccommodationEntity>>> searchAccommodations({
    required String query,
    int page = 1,
    int limit = 12,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _datasource.searchAccommodations(
          query: query,
          page: page,
          limit: limit,
        );

        if (apiModels != null && apiModels.isNotEmpty) {
          final entities = AccommodationApiModel.toEntityList(apiModels);
          return Right(entities);
        }
        return const Left(
          ApiFailure(message: "No accommodations found"),
        );
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Search failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        ApiFailure(message: "No internet connection"),
      );
    }
  }

  @override
  Future<Either<Failure, List<AccommodationEntity>>>
      getAccommodationsByPriceRange({
    required double minPrice,
    required double maxPrice,
    int page = 1,
    int limit = 12,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _datasource.getAccommodationsByPriceRange(
          minPrice: minPrice,
          maxPrice: maxPrice,
          page: page,
          limit: limit,
        );

        if (apiModels != null && apiModels.isNotEmpty) {
          final entities = AccommodationApiModel.toEntityList(apiModels);
          return Right(entities);
        }
        return const Left(
          ApiFailure(message: "No accommodations found in this price range"),
        );
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Price filter failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        ApiFailure(message: "No internet connection"),
      );
    }
  }
}
