
import 'package:trip_wise_nepal/features/accommodation/domain/entities/room_type_entity.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/features/accommodation/data/models/room_type_api_model.dart';



class RoomTypeRemoteDataSource {
  final ApiClient apiClient;
  RoomTypeRemoteDataSource({required this.apiClient});

  Future<List<RoomTypeEntity>> getRoomTypesByAccommodationId(String accommodationId) async {
    final response = await apiClient.get('/room-types?accommodationId=$accommodationId');
    final data = response.data;
    if (response.statusCode == 200 && data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .map((json) => RoomTypeApiModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    }
    return [];
  }
}
