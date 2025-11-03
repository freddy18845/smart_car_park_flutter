import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../Service/api_services.dart';
import '../../utils/constant.dart';
import '../../utils/storage_manage.dart';
import '../empty_list.dart';
import '../footer.dart';
import '../dailog/history_dailog.dart';
import '../loader.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  final TextEditingController filterTextController = TextEditingController();
  Map<String, dynamic>? result;
  List<dynamic> allResults = [];
  bool isLoading = false;
  final apiService = ApiService();
  final int userID = StorageManager().getUserID();
  final Map selectedCarPark =
  StorageManager()
      .getSelectCarParkData();
  final String userRole = StorageManager().getUserStatus();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      late Map selectedCarPark ={};
      if(userRole.toLowerCase()=="operator"){
          selectedCarPark =
        StorageManager()
            .getSelectCarParkData();
      }
      final response =
      await apiService.get('reservations/filter?${userRole.toLowerCase()=="operator"?"parking_space_id":"user_id"}= ${userRole.toLowerCase()=="operator"? selectedCarPark["id"]:userID}');
      setState(() {
        result = response;
        allResults = response["data"] ?? [];
        isLoading = false;
      });
    });
  }

  void _filterList() {
    final query = filterTextController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        result?["data"] = allResults;
      } else {
        if(userRole.toLowerCase()=="driver"){
          result?["data"] = allResults.where((item) {
            final name = item["parking_space"]?["name"]?.toString().toLowerCase() ?? '';
            final spot = item["parking_spot"]?["name"]?.toString().toLowerCase() ?? '';
            return name.contains(query) || spot.contains(query);
          }).toList();
        }else{
          result?["data"] = allResults.where((item) {
            final name = item['user']["first_name"]?.toString().toLowerCase() ?? '';
            final spot = item['user']["first_name"]?.toString().toLowerCase() ?? '';
            return name.contains(query) || spot.contains(query);
          }).toList();
        }

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            if(userRole.toLowerCase()=="driver"){
              routeNavigation(context: context, pageName: 'home');
            }else{
              routeNavigation(context: context, pageName: 'admin_home');
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if(userRole.toLowerCase()=="driver"){
                routeNavigation(context: context, pageName: 'home');
              }else{
                routeNavigation(context: context, pageName: 'admin_home');
              }

            },
            icon: const Icon(Icons.home_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            // Header
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.black,
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
                        children:  [
                          Text(
                            userRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            userRole.toLowerCase()=="driver"?"Your History,":"Reservation History",
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

            // Body
            Align(
              alignment: Alignment.topCenter,
              child: Container(
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
                    CustomTextField(
                      controller: filterTextController,
                      hint: 'Search By Car Park',
                      icon: Icons.search,
                      onChanged: (_) => _filterList(), limit: 100,
                    ),
                    SizedBox(height: 15),

                    // Section Header
                    Center(
                      child: Text(
                        userRole.toLowerCase()=="driver"? "History List".toUpperCase():"Reservations".toUpperCase(),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Table header
                    isLoading
                        ? Expanded(child: Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.09),
                        child: Center(
                            child: ListLoader(
                              size: size,
                            ))))

                        :  result?["data"].isNotEmpty?   Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Type',
                              textAlign: TextAlign.center,
                              style: tableHeader(size),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              userRole.toLowerCase()=="driver"?"Car Park": 'Driver',
                              textAlign: TextAlign.center,
                              style: tableHeader(size),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Spot',
                              textAlign: TextAlign.center,
                              style: tableHeader(size),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'EndTime',
                              textAlign: TextAlign.center,
                              style: tableHeader(size),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Status',
                              textAlign: TextAlign.center,
                              style: tableHeader(size),
                            ),
                          ),
                        ],
                      ),
                    ):SizedBox(),

                    // List
                    result?["data"].isNotEmpty?
                  Expanded(child:   ListView.builder(
                    itemCount:  result?["data"].length,
                    itemBuilder: (context, index) {
                      final reservationData =  result?["data"][index]; // <-- each row's data
                      return InkWell(
                        onTap: () => showReservationDialog(context,userRole.toString(), reservationData,), // 👈 here
                        child: Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reservationData["type"] ?? '',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userRole.toLowerCase()=="driver"? (reservationData["parking_space"]?["name"] ?? '') :  (reservationData['user']["first_name"] ?? ''),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  reservationData["parking_spot"]?["name"] ?? '',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  reservationData["end_time"] ?? '',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  reservationData["status"] ?? '',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: (reservationData["status"] == "completed")
                                        ? Colors.green
                                        : Colors.black.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ))

                        :EmptyList(size: size,
                    ),
                    // if(userRole.toLowerCase()=="driver")
                    Footer(activeNavIndex: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle tableHeader(Size size) {
    return TextStyle(
      fontSize: size.width * 0.028,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
  }
}
