import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_carpark_app/utils/geoloctor_manager.dart';
import 'package:smart_carpark_app/utils/storage_manage.dart';
import '../Service/api_services.dart';
import '../presentation/Models/reservation_modal.dart';
import 'package:intl/intl.dart';

import '../presentation/Models/user_data.dart';
import 'constant.dart';

class ReservationManager {
  // ───────────────────────────
  // ❶ Singleton boilerplate
  // ───────────────────────────
  ReservationManager._internal(); // private constructor
  static final ReservationManager _singleton = ReservationManager._internal();
  static ReservationManager get instance => _singleton; // global access point
  final apiService = ApiService();
  // ───────────────────────────
  // ❷ Mutable reservation data
  // ───────────────────────────
  ReservationData _reservationData = ReservationData();

  // ───────────────────────────
  // ❸ Setters
  // ───────────────────────────
  void setCoreData({
    required int parkingSpotId,
    required int parkingSpaceId,
    required int subSpaceId,
    required String type,
  }) {
    final userId = StorageManager().getUserID();
    _reservationData = _reservationData.copyWith(
      userId: userId,
      parkingSpotId: parkingSpotId,
      parkingSpaceId: parkingSpaceId,
      subSpaceId: subSpaceId,
      type: type,
    );
  }

  Future<void> setReservationTime({
    required bool isWithinRange,
    required int timeDuration,
    required BuildContext context,
    required String selectedSpotLatitude,
    required String vehicleNumPlate,
    required String selectedSpotLongitude
  }) async {
    // Push start time 1 minute into the future to satisfy "after:now"
    final actualStartTime = DateTime.now().add(const Duration(minutes: 1));

    final endTime = !isWithinRange
        ? actualStartTime.add(Duration(minutes: timeDuration))
        : actualStartTime.add(Duration(hours: timeDuration));
    final User userData = StorageManager().userItem.user;
    final Position currentPosition = (await GeolocatorManager().getCurrentPosition());
    _reservationData = _reservationData.copyWith(
      startTime: actualStartTime,
      endTime: endTime,
      userName: "${userData.firstName} ${"${userData.lastName}"}",
      type: !isWithinRange ? 'booking' : 'walk-in',
      vehicleNumber: vehicleNumPlate,
      userId:userData.id ,
      latitude: currentPosition.latitude.toString(),
      longitude: currentPosition.longitude.toString()

    );

    final formattedStartTime =
    DateFormat("yyyy-MM-dd HH:mm:ss").format(actualStartTime);
    final formattedEndTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(endTime);

    final payload = _reservationData.toJson()
      ..['reservation_time'] = formattedStartTime
      ..['start_time'] = formattedStartTime
      ..['end_time'] = formattedEndTime;


    try {
      final response = await apiService.post('reservations', payload);

      // At this point, response is already a Map<String, dynamic>
      print('Reservation Created: ${response['data']['id']}');

      if (!isWithinRange) {
        final String token = StorageManager().userItem.token;
        // Optionally start background location updates here
      }

      showCustomSnackBar(
        context: context,
        message: 'Reservation created successfully',
      );

      if (!isWithinRange) {
        await StorageManager().saveReservationData(
          reservationId: response['data']['id'],
          endDate: endTime.toString(),
          latitude: selectedSpotLatitude,
          longitude: selectedSpotLongitude,
        );
      }
      StorageManager().setBookingStatus(false);
    } catch (e) {
      // If the post() throws an Exception, it’ll already contain the API message
      showCustomSnackBar(
        context: context,
        message: 'Reservation Creation Failed: $e',
        backgroundColor: Colors.redAccent,
      );
      print("Reservation Creation Failed: $e");
    }
  }

  Future<void> updateReservationTime({
    required int timeDuration,
    required BuildContext context,
  }) async {
    // Push start time 1 minute into the future to satisfy "after:now"
    final actualStartTime = DateTime.now().add(const Duration(minutes: 1));
    final endTime = actualStartTime.add(Duration(hours: timeDuration));
    final formattedEndTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(endTime);
    int? reservationId = StorageManager().getCurrentReservationId();
    if (reservationId != null) {
      try {
        // Update the reservation - FIXED: Use formattedEndTime string
        final response = await apiService.put('reservations/$reservationId', {
          "end_time": formattedEndTime,  // ← FIXED: Was endTime.formattedEndTime
          "status": "occupied"
        });

        if (response.statusCode == 200) {
          showCustomSnackBar(context: context, message: 'Reservation updated successfully');
          StorageManager().setBookingStatus(false);
        } else {
          showCustomSnackBar(context: context,backgroundColor: Colors.redAccent, message: 'Reservation updated Failed');
          print('Failed to update reservation: ${response.body}');
        }
      } catch (e) {
        showCustomSnackBar(context: context,backgroundColor: Colors.redAccent, message: 'Error updating reservation: $e');
      }
    } else {
      showCustomSnackBar(context: context,backgroundColor: Colors.redAccent, message: 'No active reservation found');

    }
  }
  void setVehicleNumber(String vehicleNumber) => _reservationData =
      _reservationData.copyWith(vehicleNumber: vehicleNumber);

  // ───────────────────────────
  // ❹ Getters / helpers
  // ───────────────────────────
  ReservationData get data => _reservationData;

  String toJson() => reservationDataToJson(_reservationData);

  void reset() => _reservationData = ReservationData();
}
