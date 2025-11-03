import 'package:flutter/material.dart';
import 'package:smart_carpark_app/presentation/slot_gridview.dart';
import '../utils/constant.dart';
import '../utils/geoloctor_manager.dart';
import '../utils/storage_manage.dart';
import 'Models/user_data.dart';

typedef OnSlotTap = void Function(Map<String, dynamic> slot);
typedef OnCancel = void Function();
typedef OnConfirm = void Function(String? lotName);

class CarParkList extends StatefulWidget {
  final List<dynamic> carParks;
  final String? selectedCarLot;
  final String? selectedCarSpaceName;
  final OnSlotTap? onSlotTap;
  final OnCancel? onCancel;
  final OnConfirm? onConfirm;
  final double latitude;
  final double longitude;
  final bool isAdminDashboard;

  const CarParkList({
    Key? key,
    required this.carParks,
    this.selectedCarLot,
    this.selectedCarSpaceName,
    this.onSlotTap,
    this.onCancel,
    this.onConfirm,
    this.isAdminDashboard = false,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<CarParkList> createState() => _CarParkListState();
}

class _CarParkListState extends State<CarParkList> {
  int? selectedCarParkIndex;
  String? selectedCarParkName;
  String? selectedSlotID;
  String? selectedSlotName;
  bool _isWithinRange = false; // local state to prevent flickering

  @override
  void initState() {
    super.initState();

    // Initialize selection if provided
    if (widget.selectedCarLot != null) {
      selectedSlotID = widget.selectedCarLot;
    }
    if (widget.selectedCarSpaceName != null) {
      selectedSlotName = widget.selectedCarSpaceName;
    }

    // Get initial range status (static check)
    _isWithinRange = GeolocatorManager().getRange();

  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.carParks.length,
      itemBuilder: (context, index) {
        final carPark = widget.carParks[index];

        // Skip unavailable parks
        if (carPark["status"] != "available") {
          return const SizedBox();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: 1,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${carPark["name"]}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () {
                      if (carPark["directions"] != null &&
                          carPark["directions"].toString() != "null") {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Navigation To ${carPark["name"]}'),
                            content: Text('${carPark["directions"]}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        showCustomSnackBar(
                          context: context,
                          message: 'Sorry, No Navigation To Lot',
                          backgroundColor: Colors.redAccent,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.info,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),

              // Car spaces grid
              CarSpaceGrid(
                isAdminDashboard: widget.isAdminDashboard,
                subSpaces: (carPark["sub_spaces"] as List<dynamic>)
                    .map((e) => e as Map<String, dynamic>)
                    .toList(),
                carParkName: carPark["name"],
                selectedCarSpaceID: selectedSlotID,
                selectedCarSpace: selectedSlotName,
                onSlotTap: (slot) {
                  setState(() {
                    selectedCarParkIndex = index;
                    selectedCarParkName = carPark["name"];
                    selectedSlotID = slot['id']?.toString();
                    selectedSlotName = slot['name'];

                    // Update local range state
                    _isWithinRange = GeolocatorManager().getRange();
                  });
                  if (widget.onSlotTap != null) widget.onSlotTap!(slot);
                },
              ),

              // Buttons Row
              if (!widget.isAdminDashboard)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedCarParkIndex = null;
                            selectedCarParkName = null;
                            selectedSlotID = null;
                            selectedSlotName = null;
                          });
                          if (widget.onCancel != null) widget.onCancel!();
                        },
                        child: modalBtn(
                          btnColor: Colors.white,
                          text: 'Cancel',
                          textColor: selectedCarParkName == carPark["name"]
                              ? Colors.black
                              : Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Confirm / Reserve button
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          if (widget.onConfirm != null &&
                              selectedSlotID != null) {

                            final bool reservationStatus = StorageManager().isBookingReadyForUpdated;
                            if(reservationStatus){
                              if( !_isWithinRange){
                                showCustomSnackBar(
                                  context: context,
                                  message: 'Sorry, Your  Still  Not  Within Range',
                                  backgroundColor: Colors.redAccent,
                                );
                                return;
                              }

                            }
                            widget.onConfirm!(selectedSlotID);
                          }
                        },
                        child: modalBtn(
                          btnColor: selectedCarParkName == carPark["name"]
                              ? Colors.black
                              : Colors.black.withOpacity(0.3),
                          text: _isWithinRange
                              ? 'Confirm'
                              : 'Reserve Spot',
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
