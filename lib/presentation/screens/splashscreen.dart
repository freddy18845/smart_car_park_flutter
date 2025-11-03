import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/gps_permission.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({
    Key? key,
    required this.nextScreen,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _permissionGranted = false;
  final GpsPermissionManager _gpsManager = GpsPermissionManager();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // First, check if we already have permission
    if (_gpsManager.getPermissionStatus()) {
      _navigateToNext();
      return;
    }

    // Wait for the first frame to be built before showing dialog
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final granted = await _gpsManager.requestPermission(context);
      setState(() {
        _permissionGranted = granted;
        _isLoading = false;
      });

      if (granted) {
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() {
    // Navigate to next screen with replacement
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => widget.nextScreen)
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 8,
              shadowColor:Color(0xFF407BFF) ,
              child:  Container(
                width: size.height * 0.08,
                height: size.height * 0.08,
                decoration: BoxDecoration(
                  color: Color(0xFF407BFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color:  Colors.grey, width: 0.60),
                ),
                child: Icon(Icons.car_crash_outlined, color: Colors.white, size: size.height * 0.06,),
              ),).animate()
            .fadeIn(duration: 300.ms)
            .scale(duration: 400.ms, curve: Curves.easeOutBack, delay: (1 * 80).ms)
            .slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut),
            SizedBox(height:size.height * 0.005 ,),
            Text("Smart Car Park",
              style: TextStyle(fontSize: size.height * 0.02,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF407BFF)),),
            SizedBox(height: 24),
            if (_isLoading)
              Container(
                padding: EdgeInsets.symmetric(vertical:size.height * 0.03 ),
                height: size.height * 0.1,
                width: size.height * 0.1,
                child:  CupertinoActivityIndicator(
                  radius: 20,
                  color: Color(0xFF407BFF),
                ),
              ),
            if (!_isLoading && !_permissionGranted)
              Column(
                children: [
                  Text(
                    'Location Permission Required',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This app needs location permission to function properly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      final granted = await _gpsManager.requestPermission(context);
                      setState(() {
                        _permissionGranted = granted;
                        _isLoading = false;
                      });

                      if (granted) {
                        _navigateToNext();
                      }
                    },
                    child: Text('Grant Permission'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}