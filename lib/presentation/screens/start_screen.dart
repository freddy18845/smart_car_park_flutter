import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/constant.dart';
import '../../utils/storage_manage.dart';


class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final List<String> _svgImages = [
    'assets/images/start_screen1.svg',
    'assets/images/start_screen2.svg',
    'assets/images/start_screen3.svg',
    'assets/images/start_screen4.svg',
    'assets/images/start_screen5.svg',
  ];

  int _currentIndex = 0;
  late Timer _timer;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startFadeCarousel();
  }

  void _startFadeCarousel() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _opacity = 0.0;
      });
      StorageManager().clearUserData();
      // Wait for fade out to complete before changing image
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _svgImages.length;
          _opacity = 1.0;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child:Column(children: [
                  SizedBox(height: size.height * 0.05,),
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
                 ),),
                  SizedBox(height:size.height * 0.005 ,),
                  Text("Smart Car Park",
                    style: TextStyle(fontSize: size.height * 0.02,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF407BFF)),)
                ],)
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.1),
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.linear,
                    child: SvgPicture.asset(
                      _svgImages[_currentIndex],
                      height: size.height * 0.4,
                      width: size.height * 0.1,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:  EdgeInsets.only(bottom:  size.height * 0.25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _svgImages.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 12 : 8,
                        height: _currentIndex == index ? 12 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? Color(0xFF407BFF)
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:  EdgeInsets.only(bottom:  size.height * 0.1),
                  child: InkWell(
                    onTap: () {
                      routeNavigation(context: context, pageName: 'home');

                    },
                    child: btnNavigator(
                      btnColor: const Color(0xFF407BFF),
                      text: 'Get Started'.toUpperCase(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget btnNavigator({required Color btnColor, required String text}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
