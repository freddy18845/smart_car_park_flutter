// To parse this JSON data, do
//
//     final parkingSpaceData = parkingSpaceDataFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ParkingSpaceData parkingSpaceDataFromJson(String str) => ParkingSpaceData.fromJson(json.decode(str));

String parkingSpaceDataToJson(ParkingSpaceData data) => json.encode(data.toJson());

class ParkingSpaceData {
  final String label;
  final String parkingSpaceId;
  final String spaceId;
  final String subSpaceId;

  ParkingSpaceData({
    required this.label,
    required this.parkingSpaceId,
    required this.spaceId,
    required this.subSpaceId,
  });

  ParkingSpaceData copyWith({
    String? label,
    String? parkingSpaceId,
    String? spaceId,
    String? subSpaceId,
  }) =>
      ParkingSpaceData(
        label: label ?? this.label,
        parkingSpaceId: parkingSpaceId ?? this.parkingSpaceId,
        spaceId: spaceId ?? this.spaceId,
        subSpaceId: subSpaceId ?? this.subSpaceId,
      );

  factory ParkingSpaceData.fromJson(Map<String, dynamic> json) => ParkingSpaceData(
    label: json["label"],
    parkingSpaceId: json["parkingSpaceID"],
    spaceId: json["spaceID"],
    subSpaceId: json["subSpaceID"],
  );

  Map<String, dynamic> toJson() => {
    "label": label,
    "parkingSpaceID": parkingSpaceId,
    "spaceID": spaceId,
    "subSpaceID": subSpaceId,
  };
}
