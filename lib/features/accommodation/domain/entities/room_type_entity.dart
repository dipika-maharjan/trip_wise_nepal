import 'package:equatable/equatable.dart';

class RoomTypeEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double pricePerNight;
  final bool isActive;
  final int maxGuests;
  final int totalRooms;

  const RoomTypeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.isActive,
    required this.maxGuests,
    required this.totalRooms,
  });

  @override
  List<Object?> get props => [id, name, description, pricePerNight, isActive, maxGuests, totalRooms];
}
