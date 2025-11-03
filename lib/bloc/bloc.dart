import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_carpark_app/bloc/state.dart';
import '../../presentation/dailog/time_duration.dart';
import '../../utils/storage_manage.dart';
import 'event.dart';

class CarParkingSpaceBloc extends Bloc<CarParkingSpaceEvent, CarParkingSpaceState> {
  StreamSubscription<Position>? _positionStreamSubscription;
  DateTime? _lastAlertTime;
  DateTime? _lastDistanceCheck;
  double thresholdDistance = 200; // meters
  double? _targetLatitude;
  double? _targetLongitude;

  CarParkingSpaceBloc() : super(CarParkingSpaceState()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<UpdatePosition>(_onUpdatePosition);
    on<UpdateDistance>(_onUpdateDistance);
    on<DismissDialog>(_onDismissDialog);
  }

  Future<void> _onStartTracking(StartTracking event, Emitter<CarParkingSpaceState> emit) async {
    print("🟩 StartTracking event received");

    // ✅ If already tracking, stop first then restart
    if (state.isTracking || _positionStreamSubscription != null) {
      print("⚠️ Already tracking, stopping previous session first...");
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("🟥 Permission denied");
        emit(state.copyWith(
          permission: permission,
          errorMessage: "Location permission denied",
          isTracking: false,
        ));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("🟥 Permission denied forever");
      emit(state.copyWith(
        permission: permission,
        errorMessage: "Location permission permanently denied. Please enable in settings.",
        isTracking: false,
      ));
      await Geolocator.openAppSettings();
      return;
    }

    print("✅ Starting location tracking...");

    // ✅ Store target coordinates
    _targetLatitude = event.targetLatitude;
    _targetLongitude = event.targetLongitude;

    // ✅ Set isTracking to true BEFORE starting stream
    emit(CarParkingSpaceState(
      isTracking: true,
      isWithinRange: false,
      permission: permission,
      errorMessage: null,
      distance: null,
      shouldShowDialog: false,
    ));

    try {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(
            (Position position) {
          print("📍 Position update: ${position.latitude}, ${position.longitude}");
          // ✅ Use add() instead of directly calling emit
          add(UpdatePosition(position.latitude, position.longitude));
          add(UpdateDistance(position));
        },
        onError: (error) {
          print("🟥 GPS Error: $error");
          emit(state.copyWith(
            isTracking: false,
            errorMessage: "GPS error: ${error.toString()}",
          ));
        },
        onDone: () {
          print("🟦 Position stream completed");
          emit(state.copyWith(isTracking: false));
        },
        cancelOnError: false,
      );

      print("✅ Location tracking started successfully");
    } catch (e) {
      print("🟥 Error starting tracking: $e");
      emit(state.copyWith(
        isTracking: false,
        errorMessage: "Failed to start tracking: ${e.toString()}",
      ));
    }
  }

  Future<void> _onStopTracking(StopTracking event, Emitter<CarParkingSpaceState> emit) async {
    print("🟥 Stopping tracking...");

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _lastAlertTime = null;
    _lastDistanceCheck = null;
    _targetLatitude = null;
    _targetLongitude = null;

    emit(CarParkingSpaceState(
      isTracking: false,
      isWithinRange: false,
      distance: null,
      shouldShowDialog: false,
    ));

    print("✅ Tracking stopped successfully");
  }

  void _onUpdatePosition(UpdatePosition event, Emitter<CarParkingSpaceState> emit) {
    // Only update if still tracking
    if (state.isTracking) {
      emit(state.copyWith(latitude: event.latitude, longitude: event.longitude));
    }
  }

  void _onDismissDialog(DismissDialog event, Emitter<CarParkingSpaceState> emit) {
    emit(state.copyWith(shouldShowDialog: false));
  }

  void _onUpdateDistance(UpdateDistance event, Emitter<CarParkingSpaceState> emit) {
    if (_targetLatitude == null || _targetLongitude == null) return;

    final now = DateTime.now();

    // ✅ Throttle calculations (only check every 5 seconds)
    if (_lastDistanceCheck != null && now.difference(_lastDistanceCheck!).inSeconds < 5) {
      return;
    }
    _lastDistanceCheck = now;

    final distance = Geolocator.distanceBetween(
      event.position.latitude,
      event.position.longitude,
      _targetLatitude!,
      _targetLongitude!,
    );

    final bool isWithinRange = distance <= thresholdDistance;

    // ✅ Log only when range status changes
    if (isWithinRange != state.isWithinRange) {
      print("📏 Range status changed: ${distance.toStringAsFixed(2)}m (within range: $isWithinRange)");
    }

    // ✅ Check if tracking is still active
    final bool stillTracking = _positionStreamSubscription != null && !_positionStreamSubscription!.isPaused;

    if (!stillTracking) {
      print("⚠️ Tracking stopped, setting isTracking to false");
    }

    // ✅ Update distance and range status
    emit(state.copyWith(
      isWithinRange: isWithinRange,
      isTracking: stillTracking,
      distance: distance,
    ));

    // ✅ Trigger dialog via state (let UI handle the actual dialog display)
    if (isWithinRange && stillTracking) {
      if (_lastAlertTime == null || now.difference(_lastAlertTime!).inMinutes >= 1) {
        _lastAlertTime = now;
        int? reservationId = StorageManager().getCurrentReservationId();
        if (reservationId != null) {
          print("🔔 Triggering dialog for reservation: $reservationId");
          emit(state.copyWith(shouldShowDialog: true));
        }
      }
    }
  }

  @override
  Future<void> close() {
    print("🔴 Closing CarParkingSpaceBloc");
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}