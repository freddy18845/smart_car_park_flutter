
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsPermissionManager {
  // Singleton instance
  static final GpsPermissionManager _instance = GpsPermissionManager._internal();
  factory GpsPermissionManager() => _instance;
  GpsPermissionManager._internal();

  bool locationServiceEnabled = false;
  late LocationPermission permission;

  bool getPermissionStatus() {
    return locationServiceEnabled &&
        (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
  }

  Future<bool> requestPermission(BuildContext context) async {
    // Check if location services are enabled
    locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationServiceEnabled) {
      // Show dialog to enable location services
      await _showLocationServiceDialog(context);
      // Check again after user interaction
      locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationServiceEnabled) {
        return false;
      }
    }

    // Check current permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // If still denied after request, show explanation dialog
      if (permission == LocationPermission.denied) {
        await _showPermissionDeniedDialog(context);
        permission = await Geolocator.requestPermission();
      }
    }

    // If permission is permanently denied, direct user to settings
    if (permission == LocationPermission.deniedForever) {
      await _showAppSettingsDialog(context);
      return false;
    }

    // Update status again
    locationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    return getPermissionStatus(); // true if granted and service enabled
  }

  // Get current coordinates only if permission is granted
  Future<String> getGpsCoordinate(BuildContext context) async {
    bool granted = await requestPermission(context);
    if (!granted) {
      return "Permission";
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String latitude = position.latitude.toString();
      String longitude = position.longitude.toString();

      return "$longitude,$latitude";
    } catch (e) {
      return "";
    }
  }

  // Helper method to show dialog for enabling location services
  Future<void> _showLocationServiceDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to use this app.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method to show dialog when permission is denied
  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
            'This app needs location permission to function properly. '
                'Please grant permission when prompted.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method to direct user to app settings
  Future<void> _showAppSettingsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Permanently Denied'),
          content: Text(
            'Location permission is permanently denied. '
                'Please enable it in app settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}