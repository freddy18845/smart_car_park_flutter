
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_carpark_app/presentation/Models/user_data.dart';
import '../../Service/api_services.dart';
import '../../utils/constant.dart';
import '../../utils/storage_manage.dart';
import '../footer.dart';


class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    // Safely build the full name
    final UserData userData =  StorageManager().userItem;
    final firstName = userData.user.firstName ?? '';
    final lastName = userData.user.lastName ?? '';

// Get the first character (if not empty)
    final firstChar = (firstName.isNotEmpty ? firstName[0] : '') +
        (lastName.isNotEmpty ? lastName[0] : '');
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            routeNavigation(context: context, pageName: 'home');
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final token = StorageManager()
                  .getLoginToken();
              await apiService.logout(token);
              routeNavigation(context: context, pageName: 'login');
              StorageManager().clearUserData();

            },
            icon: const Icon(Icons.logout, color: Colors.white),
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
                        children: [
                          Text(
                            'HELLO ${userData.user.role}!'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                           Text(
                            "${userData.user.role=="driver"? "Driver":'Admin' } Account",
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
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // White body section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 150),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header inside white body
                  Row(
                    children: [
                       CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage("assets/images/avatar.png"),
                        child: Center(child: Text(firstChar , style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        ),),// Replace with network image if available
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          Text("${userData.user.firstName} ${userData.user.lastName}",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("${userData.user.firstName}${userData.user.lastName}@gmail.com",
                              style: TextStyle(color: Colors.grey)),

                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Settings options
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.black),
                          title:  Text("${userData.user.phone}"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navigate to edit profile
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading:
                          const Icon(Icons.lock, color: Colors.black),
                          title: const Text("Change Password"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navigate to change password
                          },
                        ),
                        const Divider(),
                        userData.user.role!="driver"?ListTile(
                          leading: const Icon(Icons.notifications,
                              color: Colors.black),
                          title: const Text("Update Car Park"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            routeNavigation(context: context, pageName: 'admin_home');
                          },
                        ):SizedBox(),
                        userData.user.role!="driver"? const Divider(): SizedBox(),
                        ListTile(
                          leading:
                          const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            final token = StorageManager()
                                .getLoginToken();
                            await apiService.logout(token);
                            routeNavigation(context: context, pageName: 'login');
                              StorageManager().clearUserData();


                          }
                        )],
                    ),

                  ),
                  Footer(activeNavIndex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
