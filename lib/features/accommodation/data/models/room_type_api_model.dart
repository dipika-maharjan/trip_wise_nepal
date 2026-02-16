import 'package:trip_wise_nepal/features/accommodation/domain/entities/room_type_entity.dart';

class RoomTypeApiModel {
  final String id;
  final String name;
  final String description;
  final double pricePerNight;
  final bool isActive;
  final int maxGuests;
  final int totalRooms;

  RoomTypeApiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.isActive,
    required this.maxGuests,
    required this.totalRooms,
  });

  factory RoomTypeApiModel.fromJson(Map<String, dynamic> json) {
    return RoomTypeApiModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pricePerNight: (json['pricePerNight'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      maxGuests: json['maxGuests'] ?? 1,
      totalRooms: json['totalRooms'] ?? 1,
    );
  }

  RoomTypeEntity toEntity() {
    return RoomTypeEntity(
      id: id,
      name: name,
      description: description,
      pricePerNight: pricePerNight,
      isActive: isActive,
      maxGuests: maxGuests,
      totalRooms: totalRooms,
    );
  }
}
