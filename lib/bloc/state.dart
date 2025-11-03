import 'package:geolocator/geolocator.dart';

class CarParkingSpaceState {
  final bool isTracking;
  final bool isWithinRange;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final LocationPermission? permission;
  final String? errorMessage;
  final bool shouldShowDialog;

  CarParkingSpaceState({
    this.isTracking = false,
    this.isWithinRange = false,
    this.latitude,
    this.longitude,
    this.distance,
    this.permission,
    this.errorMessage,
    this.shouldShowDialog = false,
  });

  CarParkingSpaceState copyWith({
    bool? isTracking,
    bool? isWithinRange,
    double? latitude,
    double? longitude,
    double? distance,
    LocationPermission? permission,
    String? errorMessage,
    bool? shouldShowDialog,
  }) {
    return CarParkingSpaceState(
      isTracking: isTracking ?? this.isTracking,
      isWithinRange: isWithinRange ?? this.isWithinRange,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      permission: permission ?? this.permission,
      errorMessage: errorMessage ?? this.errorMessage,
      shouldShowDialog: shouldShowDialog ?? this.shouldShowDialog,
    );
  }

  @override
  String toString() {
    return 'CarParkingSpaceState(isTracking: $isTracking, isWithinRange: $isWithinRange, distance: $distance, shouldShowDialog: $shouldShowDialog)';
  }
}