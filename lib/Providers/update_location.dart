import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class ReservationCheckService {
  Timer? _timer;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  DateTime? _lastNotificationTime;

  /// Initialize notifications
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(settings);
  }

  /// Show local notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reservation_channel',
      'Reservation Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notifications.show(0, title, body, details);
  }

  /// Starts periodic reservation checks
  Future<void> startReservationCheck(String token, int userId, {int intervalMinutes = 5}) async {
    await _initNotifications();

    // Cancel existing timer if any
    _timer?.cancel();

    _timer = Timer.periodic(Duration(minutes: intervalMinutes), (timer) async {
      try {
        final response = await http.get(
          Uri.parse('https://your-domain.com/api/reservations/check/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final status = data['status'];
          final minutesLeft = data['minutes_left'];

          if (status == 'reserved' && minutesLeft != null && minutesLeft <= 10 && minutesLeft > 0) {
            // prevent duplicate notifications within 9 minutes
            if (_lastNotificationTime == null ||
                DateTime.now().difference(_lastNotificationTime!).inMinutes > 9) {
              await _showNotification(
                'Reservation Reminder',
                'Your reservation expires in $minutesLeft minutes. Please take action soon.',
              );
              _lastNotificationTime = DateTime.now();
            }
          }
        } else {
          print('⚠️ Reservation check failed: ${response.body}');
        }
      } catch (e) {
        print('⚠️ Error during reservation check: $e');
      }
    });

    print('✅ Started reservation check every $intervalMinutes minutes.');
  }

  /// Stop periodic checks
  void stopReservationCheck() {
    _timer?.cancel();
    _timer = null;
    print('🛑 Stopped reservation checks.');
  }
}
