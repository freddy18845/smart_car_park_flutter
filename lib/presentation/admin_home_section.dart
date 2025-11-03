
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_carpark_app/presentation/status_row.dart';

import '../Service/api_services.dart';
import '../utils/constant.dart';
import '../utils/storage_manage.dart';
import 'car_space_listview.dart';
import 'footer.dart';
import 'loader.dart';

class AdminHomeSection extends StatefulWidget {
  const AdminHomeSection({super.key});

  @override
  State<AdminHomeSection> createState() => _AdminHomeSectionState();
}

class _AdminHomeSectionState extends State<AdminHomeSection> {
  final apiService = ApiService();
  bool isLoading = false;

  List result = [];
  double latitude = 0.0;
  double longitude = 0.0;
  String? selectedLot;
  String? selectedCarSpace;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      try {
        int? parkingSpaceId = StorageManager().getUserID();
        final dynamic parkingSpaceData =
        await apiService.get('parking-spaces/operator/$parkingSpaceId');
        final List dataList = parkingSpaceData['data'] ?? [];

        setState(() {
          result = dataList[0]["parking_spots"];
          isLoading = false;
        });
        StorageManager().setSelectedCarPark(dataList[0]?["name"],
            dataList[0]!["id"].toString());



      } catch (e) {
        setState(() {
          isLoading = false;
        });
        // Handle error appropriately
        print('Error loading parking spaces: $e');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,

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
          const SizedBox(height: 15),
          StatusRow(),
         const SizedBox(height: 15),
          Expanded(
            child: isLoading
                ? Center(
              child: ListLoader(
                size: size,
              ),
            )
                : result.isEmpty
                ? const Center(
              child: Text('No parking spaces available'),
            )

                : CarParkList(
                isAdminDashboard: true,
              carParks: result,
              selectedCarLot: selectedLot,
              selectedCarSpaceName: selectedCarSpace,
              latitude: latitude,
              longitude: longitude,
              onSlotTap: (slot) {
                setState(() {
                  selectedLot = slot['id']?.toString();
                  selectedCarSpace = slot['name'] ?? slot['label'];
                });
              },
              onCancel: () {
                setState(() {
                  selectedLot = null;
                  selectedCarSpace = null;
                });
              },
              onConfirm: (lotId) {
                if (lotId != null) {
                  // Handle confirmation logic here
                  showCustomSnackBar(
                    context: context,
                    message: 'Parking spot confirmed!',
                  );
                }
              },
            )
          ),
          Footer(activeNavIndex: 0),
        ],
      ),
    );
  }
}