import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_carpark_app/presentation/loader.dart';
import 'package:smart_carpark_app/utils/geoloctor_manager.dart';
import 'package:smart_carpark_app/utils/storage_manage.dart';
import '../../Service/api_services.dart';
import '../../utils/constant.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();
  final otherContactController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  bool isLoading = false;
  int? parkingSpaceId = StorageManager().getUserID();
  bool isEditMode = false;
  bool isNewUser = false;
  final apiService = ApiService();
  List<SpotData> spots = [SpotData()];

  Map<String, dynamic>? existingParkingData;

  Map<String, dynamic> buildPayload() {
    return {
      "operator_id": parkingSpaceId,
      "name": nameController.text,
      "location": locationController.text,
      "phone": phoneController.text,
      "other_contact": otherContactController.text,
      "latitude": double.tryParse(latitudeController.text) ?? 0,
      "longitude": double.tryParse(longitudeController.text) ?? 0,
      "spots": spots.map((spot) => spot.toJson()).toList(),
    };
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    getData();
    //  });
  }

  Future<void> getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final dynamic parkingSpaceData =
          await apiService.get('parking-spaces/operator/$parkingSpaceId');
      final List dataList = parkingSpaceData['data'] ?? [];
      if (dataList.isNotEmpty) {
        existingParkingData = dataList[0] as Map<String, dynamic>;
        StorageManager().setSelectedCarPark(existingParkingData?["name"],
            existingParkingData!["id"].toString());
        setState(() {
          isEditMode = true;
          loadData(existingParkingData!);
        });
      } else {
        setState(() {
          isNewUser = true;
          isEditMode = false;
          existingParkingData = null;
          _resetForm();
        });
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // print("Error fetching data: $e");
      setState(() {
        existingParkingData = null;
        isEditMode = false;
      });
    }
  }

  void loadData(Map<String, dynamic> data) {
    parkingSpaceId = data['id'];
    nameController.text = data['name'] ?? '';
    locationController.text = data['location'] ?? '';
    phoneController.text = data['phone'] ?? '';
    otherContactController.text = data['other_contact'] ?? '';
    latitudeController.text = data['latitude']?.toString() ?? '';
    longitudeController.text = data['longitude']?.toString() ?? '';

    spots = (data['parking_spots'] as List? ?? []).map((spot) {
      final s = SpotData();
      s.nameController.text = spot['name'] ?? '';
      s.statusController.text = spot['status'] ?? '';
      s.latitudeController.text = spot['latitude']?.toString() ?? '';
      s.longitudeController.text = spot['longitude']?.toString() ?? '';
      s.directionsController.text = spot['directions'] ?? '';
      s.distanceController.text = spot['distance']?.toString() ?? '';

      s.subSpaces = (spot['sub_spaces'] as List).map((sub) {
        final subS = SubSpaceData();
        subS.labelController.text = sub['label'] ?? '';
        subS.statusController.text = sub['status'] ?? '';
        subS.latitudeController.text = sub['latitude']?.toString() ?? '';
        subS.longitudeController.text = sub['longitude']?.toString() ?? '';
        return subS;
      }).toList();

      return s;
    }).toList();
  }

  void _showParkingCenterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            backgroundColor: Colors.white,
            title: Align(
              alignment: Alignment.center,
              child: Text(
                isEditMode ? "Edit Parking Center" : "Add Parking Center",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                      controller: nameController,
                      hint: "Car Park Name*",
                      limit: 100),
                  const SizedBox(height: 12),
                  CustomTextField(
                      controller: locationController,
                      hint: "Location*",
                      limit: 100),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: CustomTextField(
                              controller: phoneController,
                              hint: "Phone*",
                              limit: 10)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: CustomTextField(
                              controller: otherContactController,
                              hint: "Other Contact",
                              limit: 10)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ✅ FIXED BUTTON
                  InkWell(
                    onTap: () async {
                      showCustomSnackBar(
                          context: context,
                          message: "Starting location fetch...");
                      try {
                        final pos =
                            await GeolocatorManager().getCurrentPosition();
                        setStateDialog(() {
                          // 👈 use dialog’s setState here
                          latitudeController.text = pos.latitude.toString();
                          longitudeController.text = pos.longitude.toString();
                        });
                        showCustomSnackBar(
                            context: context,
                            message: "Location set successfully!");
                      } catch (e) {
                        showCustomSnackBar(
                          context: context,
                          message: "Error getting location",
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                    child: modalBtn(
                      btnColor: latitudeController.text.isNotEmpty &&
                              longitudeController.text.isNotEmpty
                          ? const Color(0xFF407BFF)
                          : Colors.grey,
                      text: 'Get GPS Coordinate',
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
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
                      onTap: () {
                        if (latitudeController.text.isNotEmpty) {
                          Navigator.pop(context);
                          setState(() {
                            isNewUser = false;
                          });
                        } else {
                          showCustomSnackBar(
                              context: context,
                              message:
                                  "Please Make Sure to Get The GPS Coordinate.");
                        }
                      },
                      child: modalBtn(
                        btnColor: Colors.black,
                        text: 'Save',
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Padding(
          padding: const EdgeInsets.only(top: 0, left: 10),
          child: IconButton(
            onPressed: () =>
                routeNavigation(context: context, pageName: 'transactions'),
            icon: const Icon(Icons.list_alt_sharp, color: Colors.white),
          ),
        ),
        title: Padding(
            padding: EdgeInsets.only(top: 0, left: size.width * 0.26),
            child: const Text("Setting Up",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white))),
        actions: [
          IconButton(
            onPressed: () async {
              final token = StorageManager().getLoginToken();
              final logOutResult = await apiService.logout(token);
              if (logOutResult['statusCode'] == 200) {
                routeNavigation(context: context, pageName: 'login');
              }
              StorageManager().clearUserData();
            },
            icon: const Icon(Icons.login_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              color: Colors.black,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(30)),
                ),
                child: isLoading
                    ? Center(
                        child: ListLoader(size: size),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Text("Parking Center Info ".toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: size.height * 0.01),

                            // Parking Center Info Section
                            !isNewUser
                                ? Column(
                                    children: [
                                      Card(
                                        elevation: 4,
                                        color: Colors.white,
                                        shadowColor: Colors.black,
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                          padding: EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      nameController.text
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16)),
                                                  _iconbtn(
                                                      icon: Icons.edit,
                                                      action: () {
                                                        _showParkingCenterDialog();
                                                      },
                                                      text: 'Edit'),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 1.0,
                                              ),
                                              _buildInfoDisplay(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Spaces List".toUpperCase(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          if (_isParkingCenterInfoComplete())
                                            _iconbtn(
                                                icon: Icons.add,
                                                action: () {
                                                  setState(() {
                                                    spots.add(SpotData());
                                                  });
                                                },
                                                text: 'space'),
                                        ],
                                      ),
                                      Column(
                                        children: spots.map((spot) {
                                          int index = spots.indexOf(spot);
                                          spot.statusController.text =
                                              "available";

                                          return Card(
                                              elevation: 4,
                                              color: Colors.white,
                                              shadowColor: Colors.black,
                                              clipBehavior: Clip.antiAlias,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: ExpansionTile(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    side: BorderSide.none,
                                                  ),
                                                  collapsedShape:
                                                      const RoundedRectangleBorder(
                                                    side: BorderSide.none,
                                                  ),
                                                  title: Text(
                                                    "Space ${index + 1}: ${spot.nameController.text.isEmpty ? "Unnamed" : spot.nameController.text}"
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.edit,
                                                            size: 20,
                                                            color: Colors.grey),
                                                        onPressed: () =>
                                                            _showSpotDialog(
                                                                spot, index),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            size: 20,
                                                            color: Colors
                                                                .redAccent),
                                                        onPressed: () =>
                                                            _deleteSpot(index),
                                                      ),
                                                    ],
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          //_buildSpotInfo(spot),
                                                          Divider(
                                                            thickness: 1,
                                                          ),
                                                          const SizedBox(
                                                              height: 2),
                                                          // Sub-spaces section
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                "SUB-SPACES",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              if (spot
                                                                  .nameController
                                                                  .text
                                                                  .isNotEmpty)
                                                                _iconbtn(
                                                                    icon: Icons
                                                                        .add,
                                                                    action: () {
                                                                      _showSubSpaceDialog(
                                                                          spot,
                                                                          null,
                                                                          -1);
                                                                    },
                                                                    text:
                                                                        'Sub-Spaces'),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 8),

                                                          // Sub-space grid
                                                          GridView.builder(
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            gridDelegate:
                                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 3,
                                                              mainAxisSpacing:
                                                                  10,
                                                              crossAxisSpacing:
                                                                  10,
                                                              childAspectRatio:
                                                                  1,
                                                            ),
                                                            itemCount: spot
                                                                .subSpaces
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    subIndex) {
                                                              final subSpace =
                                                                  spot.subSpaces[
                                                                      subIndex];
                                                              subSpace.statusController
                                                                      .text =
                                                                  "available";

                                                              return Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                  color: getSubSpaceColor(
                                                                      subSpace
                                                                          .statusController
                                                                          .text),
                                                                  border: Border
                                                                      .all(
                                                                    width: 2,
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .directions_car_filled_outlined,
                                                                      size: 28,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    Text(
                                                                      subSpace
                                                                              .labelController
                                                                              .text
                                                                              .isEmpty
                                                                          ? "Sub-space ${subIndex + 1}"
                                                                          : subSpace
                                                                              .labelController
                                                                              .text,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () => _showSubSpaceDialog(
                                                                          spot,
                                                                          subSpace,
                                                                          subIndex),
                                                                      child:
                                                                          btnNavigator(
                                                                        btnColor:
                                                                            Colors.black,
                                                                        text:
                                                                            "Edit",
                                                                        height:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () => _deleteSubSpace(
                                                                          spot,
                                                                          subIndex),
                                                                      child:
                                                                          btnNavigator(
                                                                        btnColor:
                                                                            Colors.black,
                                                                        isOutline:
                                                                            true,
                                                                        text:
                                                                            "Delete",
                                                                        height:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                        }).toList(),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    height: size.height * 0.5,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                            "assets/images/no_files.png"),
                                        Text(
                                          "No Parking Space info, tap create to begin",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _showParkingCenterDialog(),
                                          icon: Icon(Icons.add),
                                          label: Text("Create New"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8), // 👈 slight curve
                                            ),
                                            elevation: 2, //
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                            // Spaces List Section
                          ],
                        ),
                      ),
              ),
            ),
            if (nameController.text.isNotEmpty)
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (isLoading) {
                            showCustomSnackBar(
                              context: context,
                              message: 'Server Busy, please wait...',
                            );
                            return;
                          }

                          if (isEditMode) {
                            routeNavigation(context: context, pageName: 'home');
                          } else {
                            _resetForm();
                          }
                        },
                        child: btnNavigator(
                          isOutline: true,
                          btnColor: Colors.black,
                          text: isEditMode ? "Done" : 'Cancel',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          setState(() => isLoading = true);

                          try {
                            final payload = buildPayload();
                            final response = isEditMode
                                ? await apiService.put(
                                    'parking-spaces/$parkingSpaceId', payload)
                                : await apiService.post(
                                    'parking-spaces', payload);

                            print("✅ Response: ${response["message"]}");

                            showCustomSnackBar(
                              context: context,
                              message:
                                  response["message"] ?? "Created successfully",
                            );
                            routeNavigation(context: context, pageName: 'home');
                          } catch (e) {
                            print("❌ Error: $e");
                            showCustomSnackBar(
                              context: context,
                              message: "Error: $e",
                              backgroundColor: Colors.redAccent,
                            );
                          } finally {
                            if (mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                        child: btnNavigator(
                          isActive: isLoading,
                          btnColor: const Color(0xFF407BFF),
                          text: isEditMode ? 'Update' : 'Create',
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  void _showSpotDialog(SpotData spot, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: Colors.white,
            title: Align(
              alignment: Alignment.center,
              child: Text(
                "Space ${index + 1}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                      controller: spot.nameController,
                      hint: "Spot Name*",
                      limit: 100),
                  const SizedBox(height: 12),
                  customTextArea(
                      controller: spot.directionsController,
                      hint: "${spot.nameController.text} Directions*",
                      limit: 100),
                  const SizedBox(height: 12),
                  CustomTextField(
                      controller: spot.distanceController,
                      hint: "Distance",
                      limit: 200),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      showCustomSnackBar(
                          context: context,
                          message: "Starting location fetch...");

                      try {
                        final Position pos =
                            await GeolocatorManager().getCurrentPosition();
                        setState(() {
                          spot.latitudeController.text =
                              pos.latitude.toString();
                          spot.longitudeController.text =
                              pos.longitude.toString();
                        });
                        showCustomSnackBar(
                            context: context,
                            message: "Location set successfully!");
                      } catch (e) {
                        showCustomSnackBar(
                            context: context,
                            message: "Error getting location",
                            backgroundColor: Colors.red);
                      }
                    },
                    child: modalBtn(
                      btnColor: spot.latitudeController.text.isNotEmpty &&
                              spot.longitudeController.text.isNotEmpty
                          ? Color(0xFF407BFF)
                          : Colors.grey,
                      text: 'Get Spaces GPS Co.',
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
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
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: modalBtn(
                        btnColor: Colors.black,
                        text: 'Save',
                        textColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showSubSpaceDialog(SpotData spot, SubSpaceData? subSpace, int index) {
    final isEditing = subSpace != null;
    final labelController =
        isEditing ? subSpace.labelController : TextEditingController();
    final latController =
        isEditing ? subSpace.latitudeController : TextEditingController();
    final lngController =
        isEditing ? subSpace.longitudeController : TextEditingController();
    final statusController = isEditing
        ? subSpace.statusController
        : TextEditingController(text: "available");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            "Sub-space",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Colors.white,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                  controller: labelController, hint: "Label*", limit: 100),
              const SizedBox(height: 12),
              customDropdownField(
                hint: isEditing
                    ? statusController.text.toString()
                    : "Select Role",
                items: ["available", "occupied", "cancelled", "reserved"],
                controller: statusController,
                context: context,
                onChanged: (val) {
                  setState(() {
                    statusController.text = val!;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: CustomTextField(
                          controller: latController,
                          hint: "Latitude",
                          limit: 15)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: CustomTextField(
                          controller: lngController,
                          hint: "Longitude",
                          limit: 15)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: modalBtn(
                    btnColor: Colors.white,
                    text: 'Cancel',
                    textColor: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (!isEditing) {
                      final newSubSpace = SubSpaceData();
                      newSubSpace.labelController.text = labelController.text;
                      newSubSpace.latitudeController.text = latController.text;
                      newSubSpace.longitudeController.text = lngController.text;
                      newSubSpace.statusController.text = statusController.text;
                      spot.subSpaces.add(newSubSpace);
                    }
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: modalBtn(
                    btnColor: Colors.black,
                    text: 'Save',
                    textColor: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _deleteSpot(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Spot"),
        content: const Text("Are you sure you want to delete this spot?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              setState(() {
                spots.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteSubSpace(SpotData spot, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Sub-space"),
        content: const Text("Are you sure you want to delete this sub-space?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              setState(() {
                spot.subSpaces.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDisplay() {
    if (!_isParkingCenterInfoComplete()) {
      return const Text("No parking center information added yet.",
          style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Location:", locationController.text),
        _buildInfoRow("Phone:", phoneController.text),
        if (otherContactController.text.isNotEmpty)
          _buildInfoRow("Other Contact:", otherContactController.text),
        _buildInfoRow(
          "Coordinates:",
          "${latitudeController.text}, ${longitudeController.text}",
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110, // ensures all titles align equally
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotInfo(SpotData spot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          thickness: 1.0,
        ),
        // if (spot.nameController.text.isNotEmpty)
        //   _buildInfoRow("Name:", spot.nameController.text),
        // if (spot.latitudeController.text.isNotEmpty &&
        //     spot.longitudeController.text.isNotEmpty)
        _buildInfoRow(
          "Coordinates:",
          "${spot.latitudeController.text}, ${spot.longitudeController.text}",
        ),
        if (spot.distanceController.text.isNotEmpty)
          _buildInfoRow("Distance:", spot.distanceController.text),
        if (spot.directionsController.text.isNotEmpty)
          _buildInfoRow("Directions:", spot.directionsController.text),
      ],
    );
  }

  Widget _iconbtn(
      {required IconData icon,
      required String text,
      required Function action}) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10), // slight curve
      ),
      child: IconButton(
        onPressed: () => action(),
        icon: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            SizedBox(
              width: 1,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 10), // keeps icon centered
        constraints: const BoxConstraints(), // removes extra padding
      ),
    );
  }

  Widget _buildSubSpaceInfo(SubSpaceData subSpace) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subSpace.latitudeController.text.isNotEmpty &&
            subSpace.longitudeController.text.isNotEmpty)
          Text(
              "Coordinates: ${subSpace.latitudeController.text}, ${subSpace.longitudeController.text}"),
      ],
    );
  }

  bool _isParkingCenterInfoComplete() {
    return nameController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        latitudeController.text.isNotEmpty &&
        longitudeController.text.isNotEmpty;
  }

  void _resetForm() {
    nameController.clear();
    locationController.clear();
    phoneController.clear();
    otherContactController.clear();
    latitudeController.clear();
    longitudeController.clear();

    for (final spot in spots) {
      spot.nameController.clear();
      spot.statusController.clear();
      spot.latitudeController.clear();
      spot.longitudeController.clear();
      spot.directionsController.clear();
      spot.distanceController.clear();

      for (final subSpace in spot.subSpaces) {
        subSpace.labelController.clear();
        subSpace.statusController.clear();
        subSpace.latitudeController.clear();
        subSpace.longitudeController.clear();
      }
    }

    setState(() {
      spots = [SpotData()];
    });
  }
}

class SpotData {
  final nameController = TextEditingController();
  final statusController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final directionsController = TextEditingController();
  final distanceController = TextEditingController();

  List<SubSpaceData> subSpaces = [SubSpaceData()];

  Map<String, dynamic> toJson() => {
        "name": nameController.text,
        "status": statusController.text,
        "latitude": double.tryParse(latitudeController.text) ?? 0,
        "longitude": double.tryParse(longitudeController.text) ?? 0,
        "directions": directionsController.text,
        "distance": double.tryParse(distanceController.text) ?? 0,
        "sub_spaces": subSpaces.map((s) => s.toJson()).toList(),
      };
}

class SubSpaceData {
  final labelController = TextEditingController();
  final statusController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  Map<String, dynamic> toJson() => {
        "label": labelController.text,
        "status": statusController.text,
        "latitude": double.tryParse(latitudeController.text) ?? 0,
        "longitude": double.tryParse(longitudeController.text) ?? 0,
      };
}
