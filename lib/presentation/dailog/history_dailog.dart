import 'package:flutter/material.dart';
import 'package:http/http.dart' as apiService;
import 'package:intl/intl.dart';

import '../../utils/constant.dart';
import '../../utils/reservation_manager.dart'; // for formatting
void showReservationDialog(BuildContext context, String userRole, Map<String, dynamic> reservationData) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  "Reservation Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Corrected: pull user info
              if(userRole.toLowerCase()=="operator")
              _detailRow("Customer Name", reservationData["user"]?["fullname"]),
              _detailRow("Phone", reservationData["user"]?["phone"]),

              const Divider(),
              _detailRow("Reservation Type", reservationData["type"]),
              _detailRow("Status", reservationData["status"]),
              _detailRow("Start Time", formatDateTime(reservationData["start_time"])),
              _detailRow("End Time", formatDateTime(reservationData["end_time"])),
              _detailRow("Vehicle Number", reservationData["vehicle_number"]),
              const Divider(),

              _detailRow("Car Park Name", reservationData["parking_space"]?["name"]),
              _detailRow("Location", reservationData["parking_space"]?["location"]),
              _detailRow("Phone", reservationData["parking_space"]?["phone"]),
              const Divider(),

              _detailRow("Spot", reservationData["parking_spot"]?["name"]),
              _detailRow("Sub-space", reservationData["sub_space"]?["label"]),

              const SizedBox(height: 20),


              userRole.toLowerCase()!="operator" &&  reservationData["status"]=="booked"?   Align(

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  ElevatedButton(
                    onPressed: () async {

                      await ReservationManager.instance.updateReservationTime(
                          timeDuration: 0,
                          context: context,
                          status: "cancelled"
                      );
                      Navigator.of(context).pop();},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF407BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cancel Booking", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Close", style: TextStyle(color: Colors.white)),
                  ),
                  // InkWell(
                  //   onTap: (){},
                  //   child: btnNavigator(
                  //     isActive: false,
                  //     btnColor: const Color(0xFF407BFF),
                  //     text: 'Cancel Booking',
                  //
                  //   ),
                  // ),



                ],),
              ):Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Helper widget for detail rows
Widget _detailRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            (value?.toString().isNotEmpty ?? false) ? value.toString() : "-",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

/// Date formatter
String formatDateTime(String? dateTimeString) {
  if (dateTimeString == null || dateTimeString.isEmpty) return "-";
  try {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat("dd MMM yyyy, hh:mm a").format(dateTime);
  } catch (e) {
    return dateTimeString; // fallback raw string
  }
}
