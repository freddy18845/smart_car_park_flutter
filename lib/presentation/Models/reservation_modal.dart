// To parse this JSON data, do
//
//     final reservationData = reservationDataFromJson(jsonString);

import 'dart:convert';

ReservationData reservationDataFromJson(String str) => ReservationData.fromJson(json.decode(str));

String reservationDataToJson(ReservationData data) => json.encode(data.toJson());

class ReservationData {
  final int? userId;
  final int? parkingSpotId;
  final int? parkingSpaceId;
  final int? subSpaceId;
  final int? id;
  final String? userName;
  final String? type;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? vehicleNumber;
  final String? latitude;
  final String? longitude;

  ReservationData({
    this.userId,
    this.parkingSpotId,
    this.parkingSpaceId,
    this.subSpaceId,
    this.id,
    this.userName,
    this.type,
    this.startTime,
    this.endTime,
    this.vehicleNumber,
    this.latitude,
    this.longitude
  });

  ReservationData copyWith({
    int? userId,
    int? parkingSpotId,
    int? parkingSpaceId,
    int? subSpaceId,
    int? id,
    String? type,
    String? userName,
    DateTime? startTime,
    DateTime? endTime,
    String? vehicleNumber,
    String? latitude,
    String? longitude,

  }) =>
      ReservationData(
        userId: userId ?? this.userId,
        parkingSpotId: parkingSpotId ?? this.parkingSpotId,
        parkingSpaceId: parkingSpaceId ?? this.parkingSpaceId,
        subSpaceId: subSpaceId ?? this.subSpaceId,
        id: id ?? this.id,
        type: type ?? this.type,
        userName: userName ?? this.userName,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  factory ReservationData.fromJson(Map<String, dynamic> json) => ReservationData(
    userId: json["user_id"],
    parkingSpotId: json["parking_spot_id"],
    parkingSpaceId: json["parking_space_id"],
    subSpaceId: json["sub_space_id"],
    id: json["id"],
    type: json["type"],
    userName: json["userName"],
    startTime: json["start_time"] == null ? null : DateTime.parse(json["start_time"]),
    endTime: json["end_time"] == null ? null : DateTime.parse(json["end_time"]),
    vehicleNumber: json["vehicle_number"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "parking_spot_id": parkingSpotId,
    "parking_space_id": parkingSpaceId,
    "sub_space_id": subSpaceId,
    "id": id,
    "type": type,
    "userName": userName,
    "start_time": startTime?.toIso8601String(),
    "end_time": endTime?.toIso8601String(),
    "vehicle_number": vehicleNumber,
    "latitude": latitude,
    "longitude": longitude,
  };
}
