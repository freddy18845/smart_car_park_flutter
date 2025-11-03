import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

import '../../Service/api_services.dart';
import '../../utils/constant.dart';
import '../../utils/storage_manage.dart';
import '../admin_home_section.dart';
import '../dailog/status_dailog.dart';
import 'car_park_space.dart';
import '../empty_list.dart';
import '../footer.dart';
import '../loader.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<HomeScreen> {
  bool isLoading = true;
  final apiService = ApiService();
  bool isLogin = StorageManager().getLoginToken().isNotEmpty;
  final TextEditingController filterTextController = TextEditingController();

  List allResults = [];
  List filteredResults = [];

  @override
  void initState() {
    super.initState();

    filterTextController.addListener(_filterList);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      final data = await apiService.get('parking-spaces');

      if (data is List) {
        allResults = data; // ✅ direct assignment
      } else if (data is Map && data.containsKey("data")) {
        allResults = data["data"] as List; // fallback if wrapped
      } else {
        allResults = [];
      }
      filteredResults = List.from(allResults);

      setState(() {
        isLoading = false;
      });
    });
  }


  void _filterList() {
    final query = filterTextController.text.toLowerCase();
    setState(() {
      filteredResults = allResults.where((item) {
        final name = item["name"]?.toString().toLowerCase() ?? '';
        final location = item["location"]?.toString().toLowerCase() ?? '';
        return name.contains(query) || location.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    filterTextController.removeListener(_filterList);
    filterTextController.dispose();
    super.dispose();
  }

  Future<void> logoutFunction() async {
    if (isLogin) {
      final token = StorageManager().getLoginToken();

      final logOutResult = await apiService.logout(token);
      if (logOutResult['statusCode'] == 200) {
        routeNavigation(context: context, pageName: 'login');

      } else {
        routeNavigation(context: context, pageName: 'login');
      }
      StorageManager().clearUserData();
    } else {
      routeNavigation(context: context, pageName: 'login');
      StorageManager().clearUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName =StorageManager().getUserFirstName() ;
    final size = MediaQuery.of(context).size;
    final role= StorageManager().getUserStatus();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading:role == 'operator'&& isLogin?  IconButton(
          onPressed: (){
            routeNavigation(context: context, pageName: 'admin_setup');
          },
          icon: Icon(Icons.account_circle_outlined, color: Colors.white),
        ):SizedBox(),
        actions: [
          IconButton(
            onPressed: logoutFunction,
            icon: Icon(Icons.login_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Black Header
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.only(left: size.height * 0.03, bottom: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: size.width * 0.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName.isNotEmpty ? "Welcome $userName," : 'Hello!',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            Text(
                              role == 'operator' && isLogin ?"Operator Dashboard Screen" :"Select Your Preferred Car Park",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.4,
                        child: SvgPicture.asset(
                          'assets/images/login_image.svg',
                          height: 150,
                          fit: BoxFit.fitHeight,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // White Body
            Align(
              alignment: Alignment.topCenter,
              child:
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 150),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child:role  == 'operator'&& isLogin?AdminHomeSection():
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Field
                    TextField(
                      controller: filterTextController,
                      decoration: InputDecoration(
                        hintText: "Search Car Park",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    // Section Header
                    Center(
                      child: Text(
                        "Car Park List".toUpperCase(),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Car Park List
                    isLoading
                        ? Expanded(child: Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.09),
                      child: Center(
                          child: ListLoader(
                            size: size,
                          ))))

                    :   filteredResults.isNotEmpty?  Expanded(
                      child:  ListView.builder(
                        itemCount: filteredResults.length,
                        itemBuilder: (context, index) {
                          final carPark = filteredResults[index];
                          return InkWell(
                            onTap: () {
                              if (isLogin) {
                                StorageManager().setSelectedCarPark(carPark["name"], carPark["id"].toString());
                                routeNavigation(
                                  context: context,
                                  pageName: 'space',
                                  args: {
                                    'carParkName':  carPark["name"],
                                    'carParkID': carPark["id"],
                                  },
                                );

                              } else {
                                routeNavigation(
                                  context: context,
                                  pageName: 'login',
                                );
                              }
                            },
                            child: Container(
                              height: 90,
                              margin: EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/park_image.jpg',
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          carPark["name"] ?? '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.pin_drop, size: 13, color: Colors.blue),
                                            SizedBox(width: 2),
                                            Text(
                                              carPark["location"] ?? '',
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Available Space: ${carPark["available_sub_spaces"]}',
                                          style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.5)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .scale(duration: 400.ms, curve: Curves.easeOutBack, delay: (index * 80).ms)
                                .slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut),
                          );
                        },
                      )
                    ):EmptyList(size: size,
                  ),
                    if(isLogin) Footer(activeNavIndex: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
