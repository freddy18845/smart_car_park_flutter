import 'package:geolocator/geolocator.dart';

abstract class CarParkingSpaceEvent {}

class StartTracking extends CarParkingSpaceEvent {
  final double targetLatitude;
  final double targetLongitude;

  StartTracking({
    required this.targetLatitude,
    required this.targetLongitude,
  });
}

class StopTracking extends CarParkingSpaceEvent {}

class UpdatePosition extends CarParkingSpaceEvent {
  final double latitude;
  final double longitude;

  UpdatePosition(this.latitude, this.longitude);
}

class UpdateDistance extends CarParkingSpaceEvent {
  final Position position;

  UpdateDistance(this.position);
}

class DismissDialog extends CarParkingSpaceEvent {}