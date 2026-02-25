import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trip_wise_nepal/core/services/location_service.dart';

class MapViewModel extends ChangeNotifier {
  final LocationService _locationService;
  LatLng? userLocation;
  double? distanceKm;

  MapViewModel(this._locationService);

  Future<void> fetchUserLocationAndDistance(LatLng accommodationLocation) async {
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      userLocation = LatLng(position.latitude, position.longitude);
      distanceKm = _locationService.distanceInKm(
        userLocation!.latitude,
        userLocation!.longitude,
        accommodationLocation.latitude,
        accommodationLocation.longitude,
      );
      notifyListeners();
    }
  }
}
