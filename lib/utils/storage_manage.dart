import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/Models/user_data.dart';
import 'constant.dart';
import 'geoloctor_manager.dart';

class StorageManager {
  static final StorageManager _instance = StorageManager._internal();

  factory StorageManager() => _instance;

  StorageManager._internal();

  // Keys for SharedPreferences
  static const String _keyUserStatus = 'user_status';
  static const String _keyFirstName = 'first_name';
  static const String _keyLoginToken = 'login_token';
  static const String _keyUserID = 'user_id';
  static const String _keyCarParkName = 'car_park_name';
  static const String _keyCarParkID = 'car_park_id';
  static const String _keySelectedSpace = 'selected_space';
  static const String _keyReservationData = 'current_reservation_data';

  // In-memory variables
  String loginToken = '';
  bool isBookingReadyForUpdated = false;
  Map<String, dynamic> selectCarParkData = {};
  UserData userItem = UserData(
    user: User(role: 'viewer', firstName: '', id: 0),
    token: '',
  );

  Map<String, dynamic> currentReservationData = {};

  // Initialize SharedPreferences and load data
  Future<void> init() async {
    await _loadUserData();
  }

  getUserData(UserData data){
    userItem = data;
  }
  setBookingStatus(bool status){
    isBookingReadyForUpdated = status;
  }
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    userItem.user.role = prefs.getString(_keyUserStatus) ?? 'viewer';
    userItem.user.firstName = prefs.getString(_keyFirstName) ?? '';
    loginToken = prefs.getString(_keyLoginToken) ?? '';
    userItem.user.id = prefs.getInt(_keyUserID) ?? 0;


    // Load reservation data as Map
    final reservationJson = prefs.getString(_keyReservationData);
    if (reservationJson != null) {
      try {
        currentReservationData = Map<String, dynamic>.from(json.decode(reservationJson));
      } catch (e) {
        print('Error parsing reservation data: $e');
        currentReservationData = {};
      }
    }

    // Load car park data
    selectCarParkData = {
      'name': prefs.getString(_keyCarParkName) ?? '',
      'id': prefs.getString(_keyCarParkID) ?? '',
      "spaceSelected":prefs.getString(_keySelectedSpace) ?? '',
    };
  }

  Future<void> saveReservationData({
    required int reservationId,
    required String endDate,
    required String latitude,
    required String longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();


    await prefs.setString(_keyReservationData, json.encode(currentReservationData));
  }

  int? getCurrentReservationId() => currentReservationData['reservationId'] as int?;
  Map<String, dynamic> getCurrentReservationData() => Map<String, dynamic>.from(currentReservationData);

  Future<void> setCurrentReservationId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currentReservationData['reservationId'], id);
  }


  Future<void> clearReservationData() async {
    final prefs = await SharedPreferences.getInstance();
    currentReservationData = {};
    await prefs.remove(_keyReservationData);
  }

  bool hasActiveReservation() => getCurrentReservationId() != null;



  Future<void> updateReservationEndDate(String newEndDate) async {
    if (hasActiveReservation()) {
      currentReservationData['endDate'] = newEndDate;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyReservationData, json.encode(currentReservationData));
    }
  }

  // ✅ Null-safe getters
  String getUserStatus() => (userItem.user.role ?? 'viewer').toLowerCase();
  String getUserFirstName() => userItem.user.firstName ?? '';
  int getUserID() => userItem.user.id ?? 0;
  String getLoginToken() => loginToken;
  Map<String, dynamic> getSelectCarParkData() => selectCarParkData;

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userItem = UserData(user: User(role: 'viewer', firstName: '', id: 0), token: '');
    loginToken = '';
    currentReservationData = {};
    selectCarParkData = {};
    await prefs.clear();
  }

  Future<void> setUserStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    userItem.user.role = status;
    await prefs.setString(_keyUserStatus, status);
  }

  Future<void> setSelectedCarPark(String name, String ID) async {
    final prefs = await SharedPreferences.getInstance();
    selectCarParkData["name"] = name;
    selectCarParkData["id"] = ID;
    await prefs.setString(_keyCarParkName, name);
    await prefs.setString(_keyCarParkID, ID);
  }

  Future<void> setUserData(String fName,String lName,String phone, int id, String status, String token) async {
    final prefs = await SharedPreferences.getInstance();
    userItem.user.firstName = fName;
    userItem.user.id = id;
    userItem.user.lastName = lName;
    userItem.user.phone = phone;
    userItem.user.role = status;
    userItem.token = token;
    loginToken = token;

    await prefs.setString(_keyFirstName, fName);
    await prefs.setInt(_keyUserID, id);
    await prefs.setString(_keyUserStatus, status);
    await prefs.setString(_keyLoginToken, token);
  }

  Map<String, dynamic> getReservationInfo() {
    return {
      'hasActiveReservation': hasActiveReservation(),
      'reservationId': getCurrentReservationId(),
    };
  }
}
