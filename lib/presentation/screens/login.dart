import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_carpark_app/presentation/signUp.dart';
import 'package:smart_carpark_app/utils/storage_manage.dart';
import '../../Service/api_services.dart';
import '../../utils/constant.dart';


class LoginScreen extends StatefulWidget {


  const LoginScreen({super.key,});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final PageController _pageController = PageController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    StorageManager().clearUserData();

    // Jump to Register page if needed

  }

  void attemptLogin() async {
    if (numberController.text.isEmpty || passwordController.text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final result = await apiService.login(
        numberController.text,
        passwordController.text,
      );


      final statusCode = result['statusCode'];
      final data = result['body'];

      if (statusCode == 200 && data != null && data['user'] != null) {
        final user = data['user'];
        final token = data['token'];

        await StorageManager().setUserData(
          user["first_name"],
          user["last_name"],
          user["phone"],
          user["id"],
          user["role"],
          token,
        );
        if (user["role"] == 'operator') {
          final result = await apiService.get('parking-spaces/operator/${user["id"]}');

          final dataList = result?["data"] as List<dynamic>?;

          if (dataList == null || dataList.isEmpty) {
            routeNavigation(context: context, pageName: 'admin_setup');
          } else {
            routeNavigation(context: context, pageName: 'home');
          }
        } else {
          routeNavigation(context: context, pageName: 'home');
        }

        numberController.clear();
        passwordController.clear();
      } else {
        showCustomSnackBar(
          context: context,
          message: 'Sorry, login failed',
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: 'An error occurred. Check your connection.',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    numberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                StorageManager().clearUserData();
                routeNavigation(context: context, pageName: 'home');
              },
              icon: const Icon(Icons.home_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Black header
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black,
              child: Padding(
                padding: EdgeInsets.only(
                  left: size.height * 0.03,
                  bottom: 60,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: size.width * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'WELCOME!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Selected Account Type",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.4,
                      child: SvgPicture.asset(
                        'assets/images/login_image.svg',
                        height: 150,
                        width: size.width * 0.4,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // White body with paginator
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 150),
              padding: EdgeInsets.only(
                left: size.width * 0.06,
                right: size.width * 0.06,
                top:  size.height * 0.04,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Page 0: Login
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Login'.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                         fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Log in to your Account',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.grey
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: numberController,
                        hint: 'Mobile Number',
                        icon: Icons.phone, limit: 10,
                      ),
                      CustomTextField(
                        controller: passwordController,
                        hint: 'Password',
                        icon: Icons.lock, limit: 100,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: attemptLogin,
                        child: btnNavigator(
                          isActive: isLoading,
                          btnColor: const Color(0xFF407BFF),
                          text: 'Login',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Sign Up text
                          InkWell(
                            onTap: () {
                              _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Text(
                              "Don't have an account? Sign Up",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          // Forgotten Password text
                          InkWell(
                            onTap: () {
                              // TODO: Add forgotten password navigation
                              showCustomSnackBar(
                                context: context,
                                message: 'Forgotten password tapped',
                              );
                            },
                            child: const Text(
                              "Forgotten Password?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,

                              ),
                            ),
                          ),
                        ],
                      ),



                    ],
                  ),

                  // Page 1: Register
                  SignUpScreen(size: size),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
