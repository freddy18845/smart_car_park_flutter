import 'dart:math';

import 'package:flutter/material.dart' hide AlertDialog;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_carpark_app/presentation/Models/user_data.dart';
import 'package:smart_carpark_app/utils/reservation_manager.dart';
import 'package:smart_carpark_app/utils/storage_manage.dart';
import '../../Service/api_services.dart';
import '../../bloc/bloc.dart';
import '../../bloc/event.dart';
import '../../bloc/state.dart';
import '../../utils/constant.dart';
import '../car_space_listview.dart';
import '../dailog/time_duration.dart';
import '../loader.dart';
import '../status_row.dart';

class CarParkSpaceScreen extends StatefulWidget {
  final String carParkName;
  final int carParkID;
  const CarParkSpaceScreen({
    super.key,
    required this.carParkName,
    required this.carParkID,
  });

  @override
  State<CarParkSpaceScreen> createState() => _CarParkSpaceScreenState();
}

class _CarParkSpaceScreenState extends State<CarParkSpaceScreen> {
  int selectedCarLot = 0;
  String selectedCarSpace = '';
  String selectedLot = '';
  bool isLoading = false;
  User user = User();

  final apiService = ApiService();

  List result = [];
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initParkingData();
    });
  }

  Future<void> _initParkingData() async {
    user = StorageManager().userItem.user;
    setState(() => isLoading = true);

    try {
      final data = await apiService.get('parking-space/${widget.carParkID}');
      final parkingData = data['data'];

      if (parkingData == null) {
        showCustomSnackBar(
          context: context,
          message: data['message'] ?? 'Parking space not found',
          backgroundColor: Colors.redAccent,
        );
        setState(() => isLoading = false);
        return;
      }

      latitude = double.tryParse(parkingData['latitude'].toString()) ?? 0.0;
      longitude = double.tryParse(parkingData['longitude'].toString()) ?? 0.0;
      result = parkingData['parking_spots'] ?? [];

      // ✅ Stop any existing tracking first, then start fresh
      if (mounted) {
        context.read<CarParkingSpaceBloc>().add(StopTracking());

        // Small delay to ensure cleanup
        await Future.delayed(const Duration(milliseconds: 100));

        // Start fresh tracking
        context.read<CarParkingSpaceBloc>().add(StartTracking(
          targetLatitude: latitude,
          targetLongitude: longitude,
        ));
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print("Error $e");
      showCustomSnackBar(
        context: context,
        message: 'Error loading parking space',
        backgroundColor: Colors.redAccent,
      );
    }
  }

  @override
  void dispose() {
    // ✅ Stop tracking when leaving screen
    context.read<CarParkingSpaceBloc>().add(StopTracking());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () {
            // Stop tracking before navigation
            context.read<CarParkingSpaceBloc>().add(StopTracking());
            routeNavigation(context: context, pageName: 'home');
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Stop tracking before navigation
              context.read<CarParkingSpaceBloc>().add(StopTracking());
              routeNavigation(context: context, pageName: 'home');
            },
            icon: const Icon(Icons.home_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Black Section
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.black,
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
                            widget.carParkName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "Select Your Preferred Car Park",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user.role?.toUpperCase() ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.41,
                      child: SvgPicture.asset(
                        'assets/images/start_screen4.svg',
                        height: 200,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content Section with BLoC
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
                    StatusRow(),
                    const SizedBox(height: 25),

                    // ✅ BLoC Integration - Listen for state changes
                    Expanded(
                      child: BlocConsumer<CarParkingSpaceBloc, CarParkingSpaceState>(
                        // ✅ Listen for side effects (dialog, errors)
                        listener: (context, state) {
                          // Show dialog when triggered by state
                          if (state.shouldShowDialog) {
                            TimeDurationDialog.show(
                              lotName: selectedLot,
                              context: context,
                              selectedSpotLatitude: latitude.toString(),
                              selectedSpotLongitude: longitude.toString(),
                              isWithinRange: state.isWithinRange,
                            );
                            // Dismiss the dialog flag immediately after showing
                            context.read<CarParkingSpaceBloc>().add(DismissDialog());
                          }

                          // Show error messages
                          if (state.errorMessage != null) {
                            showCustomSnackBar(
                              context: context,
                              message: state.errorMessage!,
                              backgroundColor: Colors.redAccent,
                            );
                          }
                        },
                        // ✅ Build UI based on state
                        builder: (context, state) {
                          // Show loader while loading or initializing tracking
                          if (isLoading) {
                            return Center(child: ListLoader(size: size));
                          }

                          // Show parking list with current state
                          return Column(
                            children: [
                              // ✅ Show tracking status indicator
                              if (state.isTracking || state.distance != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: state.isWithinRange
                                        ? Colors.green.shade50
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: state.isWithinRange
                                          ? Colors.green.shade200
                                          : Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        state.isWithinRange
                                            ? Icons.check_circle_outline
                                            : Icons.location_on_outlined,
                                        color: state.isWithinRange
                                            ? Colors.green.shade700
                                            : Colors.blue.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _getTrackingStatusText(state),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: state.isWithinRange
                                                ? Colors.green.shade700
                                                : Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      // ✅ Show loading indicator when tracking
                                      if (state.isTracking && state.distance == null)
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                              // Parking list
                              Expanded(
                                child: CarParkList(
                                  isTracking: state.isTracking,
                                  carParks: result,
                                  selectedCarLot: selectedLot,
                                  selectedCarSpaceName: selectedCarSpace,
                                  latitude: latitude,
                                  longitude: longitude,
                                  onSlotTap: (slot) {
                                    ReservationManager.instance.setCoreData(
                                      parkingSpotId: slot['parking_spot_id'] ?? 0,
                                      parkingSpaceId: widget.carParkID,
                                      subSpaceId: slot["id"],
                                      type: state.isWithinRange ? 'walk-in' : 'booking',
                                    );
                                    setState(() {
                                      selectedLot = slot['parking_spot_id'].toString();
                                      selectedCarSpace = slot['label'];
                                    });
                                  },
                                  onCancel: () {
                                    setState(() {
                                      selectedLot = '';
                                    });
                                  },
                                  onConfirm: (lotName) {
                                    // Show dialog with current range state
                                    TimeDurationDialog.show(
                                      lotName: selectedLot,
                                      context: context,
                                      selectedSpotLatitude: latitude.toString(),
                                      selectedSpotLongitude: longitude.toString(),
                                      isWithinRange: state.isWithinRange,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper method to get appropriate tracking status text
  String _getTrackingStatusText(CarParkingSpaceState state) {
    if (state.distance == null) {
      return 'Tracking location...';
    }

    if (state.isWithinRange) {
      return 'Within Parking Range • ${state.distance!.toStringAsFixed(0)}meters Away';
    } else {
      return 'Out of Range • ${state.distance!.toStringAsFixed(0)}meters Away';
    }
  }
}