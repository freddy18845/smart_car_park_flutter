import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_carpark_app/utils/storage_manage.dart';
import '../presentation/dailog/time_duration.dart';

class GeolocatorManager {
  static final GeolocatorManager _instance = GeolocatorManager._internal();
  factory GeolocatorManager() => _instance;
  GeolocatorManager._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  bool isTracking = false;
  bool isWithinRange = false;
  DateTime? _lastAlertTime;
  double thresholdDistance = 200; // meters (example threshold)

  /// Callback for notifying UI about range changes
  void Function(bool)? _onRangeChanged;

  Future<void> startTracking(
      BuildContext context, {
        required double targetLatitude,
        required double targetLongitude,
        void Function(bool)? onRangeChanged, // ✅ new
      }) async {
    print(isWithinRange.toString());
    isWithinRange = false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // If already tracking, no need to restart
    if (isTracking) return;

    _onRangeChanged = onRangeChanged;
    isTracking = true;

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      print("current position: ${position.longitude}  ${position.latitude}");
      _calculateDistance(
        context,
        targetLatitude: targetLatitude,
        targetLongitude: targetLongitude,
      );
      print(isWithinRange.toString());
    });
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    isTracking = false;
    print(isWithinRange.toString());
  }

  bool getRange() => isWithinRange;

  void _calculateDistance(
      BuildContext context, {
        required double targetLatitude,
        required double targetLongitude,
      }) {
    if (_currentPosition == null) return;

    if (_currentPosition == null) return;

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetLatitude,
      targetLongitude,
    );

     final bool newRangeStatus = distance <= thresholdDistance;
    final now = DateTime.now();

    // 🔁 Notify UI only when range status changes
    if (newRangeStatus != isWithinRange) {
      isWithinRange = newRangeStatus;
      _onRangeChanged?.call(isWithinRange);
    }

    // ✅ Show alert only if newly in range and enough time passed
    if (isWithinRange) {
      if (_lastAlertTime == null || now.difference(_lastAlertTime!).inMinutes >= 1) {
        _lastAlertTime = now;
        // int? reservationId = StorageManager().getCurrentReservationId();
        // if (reservationId != null) {
        //   TimeDurationDialog.show(
        //     context: context,
        //     isWithinRange: isWithinRange,
        //   );
        // }
      }
    }

  }
  Future<Position> getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }
}



