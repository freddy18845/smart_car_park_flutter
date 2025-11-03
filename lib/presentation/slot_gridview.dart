import 'package:flutter/material.dart';
import '../utils/constant.dart';
import '../utils/storage_manage.dart';
import 'Models/user_data.dart';
import 'dailog/status_dailog.dart';

typedef OnSlotTap = void Function(Map<String, dynamic> slot);

class CarSpaceGrid extends StatefulWidget {
  final List<Map<String, dynamic>> subSpaces;
  final String carParkName;
  final String? selectedCarSpace;
  final String? selectedCarSpaceID;
  final bool isAdminDashboard;
  final OnSlotTap? onSlotTap;

  const CarSpaceGrid({
    Key? key,
    required this.subSpaces,
    required this.carParkName,
    this.selectedCarSpace,
    this.selectedCarSpaceID,
    this.isAdminDashboard = false,
    this.onSlotTap,
  }) : super(key: key);

  @override
  State<CarSpaceGrid> createState() => _CarSpaceGridState();
}

class _CarSpaceGridState extends State<CarSpaceGrid> {
  String? _selectedSpaceId;
  String? _selectedSpaceName;

  @override
  void initState() {
    super.initState();
    _selectedSpaceId = widget.selectedCarSpaceID;
    _selectedSpaceName = widget.selectedCarSpace;
  }

  void _handleTap(Map<String, dynamic> carSpace) {
    final User userData = StorageManager().userItem.user;
    if (widget.isAdminDashboard) {
      final Map selectedCarPark = StorageManager().getSelectCarParkData();
      StatusDialog.show(
        context,
        parkingSpotId: carSpace["parking_spot_id"],
        parkingSpaceId: int.parse(selectedCarPark["id"]),
        subSpaceId: carSpace['id'],
        currentStatus: carSpace['status'],
        subSpaceLabel: carSpace['label'],
      );
      return;
    }
    if(carSpace['status']=="booked"
        && carSpace['current_user_id']== userData.id ) {
      StorageManager().setBookingStatus(true);
      setState(() {
        _selectedSpaceId = carSpace['id'].toString();
        _selectedSpaceName = carSpace['name'];
      });
    }else if(carSpace['status'] == 'available'){
      StorageManager().setBookingStatus(false);
      setState(() {
        _selectedSpaceId = carSpace['id'].toString();
        _selectedSpaceName = carSpace['name'];
      });
    }

  else  {
      showCustomSnackBar(
        context: context,
        message: 'Sorry, this slot is not available',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    widget.onSlotTap?.call(carSpace);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: widget.subSpaces.length,
      itemBuilder: (context, index) {
        final carSpace = widget.subSpaces[index];

        final bool isSelected = _selectedSpaceId == carSpace['id'].toString();
        final Color statusColor = getSubSpaceColor(carSpace['status']);
        final bool isAvailable = carSpace['status'] == 'available';

        return InkWell(
          onTap: () => _handleTap(carSpace),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.9,
                color: isAvailable ? Colors.grey : statusColor,
              ),
              color: isSelected
                  ? Colors.green.withOpacity(0.9)
                  : statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car_filled_outlined,
                  size: 30,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                const SizedBox(height: 1),
                Text(
                  '${carSpace["label"]}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
