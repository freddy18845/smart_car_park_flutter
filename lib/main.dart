import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_carpark_app/presentation/screens/splashscreen.dart';
import 'dart:async';
import 'package:smart_carpark_app/presentation/screens/start_screen.dart';
import 'package:smart_carpark_app/utils/storage_manage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_carpark_app/presentation/screens/splashscreen.dart';
import 'package:smart_carpark_app/presentation/screens/start_screen.dart';
import 'package:smart_carpark_app/utils/storage_manage.dart';

// 🔹 Import your BLoC files
import 'package:smart_carpark_app/bloc/bloc.dart'; // contains CarParkingSpaceBloc

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  await StorageManager().init();

  runApp(const MyApp());
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ Global Bloc provider for CarParkingSpace
        BlocProvider<CarParkingSpaceBloc>(
          create: (_) => CarParkingSpaceBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Car Park',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(
          nextScreen: const StartScreen(),
        ),
      ),
    );
  }
}
