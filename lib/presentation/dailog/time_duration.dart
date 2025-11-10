import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/constant.dart';
import '../../utils/reservation_manager.dart';
import '../../utils/storage_manage.dart';


class TimeDurationDialog {
  static void show({
    required BuildContext context,
    String? lotName,
    required bool isWithinRange,
    String? selectedSpotLatitude,
    String? selectedSpotLongitude,
  }) {
    String selectedTime = '';
    int duration = (!isWithinRange && lotName != null) ? 30 : 1;
    final TextEditingController numberPlate = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Keep a stable copy of the initial state
              bool localIsWithinRange = isWithinRange;

              void increaseDuration() {
                setState(() {
                  if (!localIsWithinRange && lotName != null) {
                    if (duration < 40) duration++;
                    selectedTime = '$duration mins';
                  } else {
                    duration++;
                    selectedTime = '$duration hrs';
                  }
                });
              }

              void decreaseDuration() {
                if (duration > 1) {
                  setState(() {
                    duration--;
                    selectedTime = !localIsWithinRange && lotName != null
                        ? '$duration mins'
                        : '$duration hrs';
                  });
                }
              }

              Future<void> handleConfirm() async {
                if (selectedTime.isEmpty) {
                  selectedTime =
                  '$duration ${!localIsWithinRange && lotName != null ? "mins" : "hrs"}';
                }

                if (selectedTime.isEmpty) {
                  showCustomSnackBar(
                    context: context,
                    message: 'Please select a time duration',
                  );
                  return;
                }

                // Show loading spinner
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CupertinoActivityIndicator(
                      radius: 20,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                );

                try {
                  if (lotName != null) {
                    await ReservationManager.instance.setReservationTime(
                      timeDuration: duration,
                      isWithinRange: localIsWithinRange,
                      context: context,
                      selectedSpotLatitude: selectedSpotLatitude ?? '',
                      selectedSpotLongitude: selectedSpotLongitude ?? '',
                      vehicleNumPlate: numberPlate.text,
                    );
                  } else {
                    await ReservationManager.instance.updateReservationTime(
                      timeDuration: duration,
                      context: context,
                      status: "occupied"
                    );
                  }

                  // Close loading
                  Navigator.pop(context);

                  // Go to space screen
                  final Map selectedCarPark =
                  StorageManager().getSelectCarParkData();

                  routeNavigation(
                    context: context,
                    pageName: 'space',
                    args: {
                      'carParkName': selectedCarPark["name"],
                      'carParkID': int.parse(selectedCarPark["id"]),
                    },
                  );
                } catch (e) {
                  Navigator.pop(context); // close loading

                  String errorMessage = 'Failed to set reservation time';
                  final errorStr = e.toString().toLowerCase();

                  if (errorStr.contains('already reserved')) {
                    errorMessage =
                    'This parking space is already reserved during the selected time';
                  } else if (errorStr.contains('not available')) {
                    errorMessage =
                    'This parking space is currently not available';
                  } else if (errorStr.contains('connection') ||
                      errorStr.contains('network')) {
                    errorMessage = 'Please check your internet connection';
                  }

                  debugPrint("Reservation error: $e");
                  showCustomSnackBar(
                    context: context,
                    message: errorMessage,
                    backgroundColor: Colors.red,
                  );
                }
              }

              return Container(
                height: 260,
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Center(
                      child: Text(
                        'Select Time Duration',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lot: ${lotName ?? "N/A"}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: increaseDuration,
                          child: timeCardBtn(
                            icon: Icons.add_circle_outline,
                            iconColor: Colors.black,
                          ),
                        ),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              "$duration ${!localIsWithinRange && lotName != null ? "mins" : "hrs"}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: decreaseDuration,
                          child: timeCardBtn(
                            icon: Icons.remove_circle_outline,
                            iconColor: duration <= 1
                                ? Colors.black38
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: numberPlate,
                      hint: "Vehicle No. Plate",
                      limit: 20,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: modalBtn(
                              btnColor: Colors.white,
                              text: 'Cancel',
                              textColor: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: handleConfirm,
                            child: modalBtn(
                              btnColor: Colors.black,
                              text:
                              !localIsWithinRange ? 'Book Now' : 'Confirm',
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
          ),
        );
      },
    );
  }
}
