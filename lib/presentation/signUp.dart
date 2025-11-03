import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../Service/api_services.dart';
import '../utils/constant.dart';


class SignUpScreen extends StatefulWidget {
  final Size size;
  const SignUpScreen({super.key, required this.size});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNmeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _psdController = TextEditingController();
  final TextEditingController _cpsdController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  final apiService = ApiService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNmeController.dispose();
    _phoneNumberController.dispose();
    _psdController.dispose();
    _cpsdController.dispose();
    _roleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 🔹 location permission check
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showCustomSnackBar(context: context, message: 'Location services are disabled',backgroundColor: Colors.red);

      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showCustomSnackBar(context: context, message: 'Location permissions are denied',backgroundColor: Colors.red);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      showCustomSnackBar(context: context, message: 'Location permissions are permanently denied',backgroundColor: Colors.red);
    }
  }



  // 🔹 registration
  void attemptRegister() async {
    try {
      setState(() => isLoading = true);
      final result = await apiService.registerUser(
        context: context,
        firstName: _firstNameController.text,
        lastName: _lastNmeController.text,
        phone: _phoneNumberController.text,
        password: _psdController.text,
        role: _roleController.text,
      );
      setState(() => isLoading = false);
      showCustomSnackBar(context: context, message: 'Registration Successfully. Login To proceed');
      _clearFields();

    } catch (e) {
      print('Registration error: $e');
      setState(() => isLoading = false);
      _clearFields();
      showCustomSnackBar(context: context, message: 'Registration failed. Try again.',backgroundColor: Colors.red);

    }
  }

  void _clearFields() {
    _firstNameController.clear();
    _lastNmeController.clear();
    _phoneNumberController.clear();
    _psdController.clear();
    _cpsdController.clear();
    _roleController.clear();
    routeNavigation(
      context: context,
      pageName: 'login',
    );
  }

  // 🔹 next / previous
  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Register'.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Create A New  Account',
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.grey
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: size.height * 0.15,
          width: double.infinity,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              // Step 1: Name
              Column(
                  children: [
                    CustomTextField(
                    controller: _firstNameController,
                    hint: 'FirstName',
                    icon: Icons.person, limit: 100),
                    CustomTextField(
                    controller: _lastNmeController,
                    hint: 'LastName',
                    icon: Icons.person_2, limit: 100),
              ]),

              // Step 2: Role + Phone
              Column(children: [
                customDropdownField(
                  context: context,
                  hint: "Select Role",
                  items: ["Operator", "Driver"],
                  controller: _roleController,
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
                CustomTextField(
                    controller: _phoneNumberController,
                    hint: 'Phone Number',
                    icon: Icons.phone, limit: 10),
              ]),

              // Step 3: Password
              Column(children: [
                CustomTextField(
                    controller: _psdController,
                    hint: 'Password',
                    icon: Icons.lock, limit: 100),
                const SizedBox(width: 5),
                CustomTextField(
                    controller: _cpsdController,
                    hint: 'Confirm Password',
                    icon: Icons.lock, limit: 100),
              ]),
            ],
          ),
        ),
        //const SizedBox(height: 20),
        SizedBox(
          height: size.height * 0.08,
          child:  Row(
            children: [
              // Back or Cancel button (depending on step)

              Expanded(child:  InkWell(
                onTap: () {
                  if (_currentPage > 1) {
                    _previousPage(); // go back
                  } else {
                    _clearFields(); // reset everything if on first page
                  }
                },
                child: btnNavigator(
                  isOutline: true,
                  btnColor: Colors.black,
                  text: _currentPage > 1 ? 'Back' : 'Cancel',
                ),
              ),),
              const SizedBox(width: 10),
              // Next or Submit button
             Expanded(child:  InkWell(
               onTap: () {
                 if (_currentPage < 2) {
                   _nextPage();
                 } else {
                   if (_firstNameController.text.isNotEmpty &&
                       _lastNmeController.text.isNotEmpty &&
                       _phoneNumberController.text.isNotEmpty &&
                       _psdController.text.isNotEmpty) {
                     attemptRegister();
                   } else {
                     showCustomSnackBar(context: context, message: 'All Fields Are Required.',backgroundColor: Colors.red);
                   }
                 }
               },
               child: btnNavigator(
                 isActive: isLoading,
                 btnColor: const Color(0xFF407BFF),
                 text: _currentPage == 2 ? 'Submit' : 'Next',
               ),
             ),),

            ],
          ),
        )
        // Wizard Buttons


      ],
    );
  }
}
