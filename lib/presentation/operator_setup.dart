import 'package:flutter/material.dart';
import '../Service/api_services.dart';
import '../utils/constant.dart';
import '../utils/storage_manage.dart';
import 'screens/home.dart';

class SetUpScreen extends StatefulWidget {
  const SetUpScreen({super.key});

  @override
  State<SetUpScreen> createState() => _SetUpScreenState();
}

class _SetUpScreenState extends State<SetUpScreen> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();
  final otherContactController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  late bool isLoading = false;
  int? parkingSpaceId = StorageManager().getUserID();
  bool isEditMode = true;
  final apiService = ApiService();
  List<SpotData> spots = [SpotData()];
  late Map<String, dynamic>? existingParkingData;

  Map<String, dynamic> buildPayload() {
    return {
      "operator_id": parkingSpaceId, // now guaranteed non-null
      "name": nameController.text.trim(),
      "location": locationController.text.trim(),
      "phone": phoneController.text.trim(),
      "other_contact": otherContactController.text.trim(),
      "latitude": double.tryParse(latitudeController.text) ?? 0,
      "longitude": double.tryParse(longitudeController.text) ?? 0,
      "spots": spots.map((spot) {
        final validSubSpaces = spot.subSpaces
            .where((s) => s.labelController.text.trim().isNotEmpty)
            .toList();

        return {
          "name": spot.nameController.text.trim(),
          "status": spot.statusController.text.isEmpty ? "available" : spot.statusController.text,
          "latitude": double.tryParse(spot.latitudeController.text) ?? 0,
          "longitude": double.tryParse(spot.longitudeController.text) ?? 0,
          "directions": spot.directionsController.text.trim(),
          "distance": double.tryParse(spot.distanceController.text) ?? 0,
          "sub_spaces": validSubSpaces.map((s) => s.toJson()).toList(),
        };
      }).toList(),
    };
  }

  @override
  void initState() {
    super.initState();
    initSetup();
  }

  Future<void> initSetup() async {
    parkingSpaceId = await StorageManager().getUserID();
    await getData();

    if (existingParkingData?["data"] != null && existingParkingData?["data"].isNotEmpty) {
      setState(() {
        isEditMode = true;
        loadData(existingParkingData!["data"]);
      });
    }
  }

  Future<void> getData() async {
    try {
      existingParkingData = await apiService.get('parking-spaces/operator/$parkingSpaceId');
    } catch (e) {
      print("Error fetching data: $e");
      existingParkingData = null;
    }
  }
  void loadData(Map<String, dynamic> data) {
    parkingSpaceId = data['id'];
    nameController.text = data['name'];
    locationController.text = data['location'];
    phoneController.text = data['phone'] ?? '';
    otherContactController.text = data['other_contact'] ?? '';
    latitudeController.text = data['latitude'].toString();
    longitudeController.text = data['longitude'].toString();

    spots = (data['spots'] as List).map((spot) {
      final s = SpotData();
      s.nameController.text = spot['name'];
      s.statusController.text = spot['status'];
      s.latitudeController.text = spot['latitude'].toString();
      s.longitudeController.text = spot['longitude'].toString();
      s.directionsController.text = spot['directions'] ?? '';
      s.distanceController.text = spot['distance']?.toString() ?? '';

      s.subSpaces = (spot['sub_spaces'] as List).map((sub) {
        final subS = SubSpaceData();
        subS.labelController.text = sub['label'];
        subS.statusController.text = sub['status'];
        subS.latitudeController.text = sub['latitude'].toString();
        subS.longitudeController.text = sub['longitude'].toString();
        return subS;
      }).toList();

      return s;
    }).toList();
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        title: Padding(
            padding: EdgeInsets.only(top: 0, left: size.width * 0.26),
            child: Text("Forms",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white))),
        actions: [
          IconButton(
            onPressed: () {
    routeNavigation(context: context, pageName: 'home');
    },
            icon: const Icon(Icons.home_outlined, color: Colors.white),
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
              child: Padding(
                padding: EdgeInsets.only(left: size.height * 0.03, bottom: 60),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const []),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06, vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text("Add A New Parking Center ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      CustomTextField(
                          controller: nameController, hint: "Car Park Name", limit: 100),
                      CustomTextField(
                          controller: locationController, hint: "Location", limit: 100),
                      Row(children: [
                        Expanded(
                            child: CustomTextField(
                                controller: phoneController, hint: "Phone", limit: 10)),
                        SizedBox(width: 5),
                        Expanded(
                            child: CustomTextField(
                                controller: otherContactController,
                                hint: "Other Contact", limit: 10)),
                      ]),
                      Row(children: [
                        Expanded(
                            child: CustomTextField(
                                controller: latitudeController,
                                hint: "Latitude", limit: 15)),
                        SizedBox(width: 5),
                        Expanded(
                            child: CustomTextField(
                                controller: longitudeController,
                                hint: "Longitude", limit: 15)),
                      ]),
                      const SizedBox(height: 10),
                      const Text("Spaces List",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      ...spots.map((spot) {
                        int index = spots.indexOf(spot);
                        spot.statusController.text = "available";
                        return ExpansionTile(
                          title: Text(
                              "Spot ${index + 1}: ${spot.nameController.text.isEmpty ? "Unnamed" : spot.nameController.text}"),
                          children: [
                            CustomTextField(
                                controller: spot.nameController,
                                hint: "Spot Name", limit: 100),
                            Row(
                              children: [
                                Expanded(
                                    child: CustomTextField(
                                        controller: spot.latitudeController,
                                        hint: "Latitude", limit: 15)),
                                SizedBox(width: 5),
                                Expanded(
                                    child: CustomTextField(
                                        controller: spot.longitudeController,
                                        hint: "Longitude", limit: 15)),
                              ],
                            ),
                            CustomTextField(
                                controller: spot.directionsController,
                                hint: "Directions", limit: 500),
                            CustomTextField(
                                controller: spot.distanceController,
                                hint: "Distance", limit: 500),
                            ExpansionTile(
                              title: const Text("Sub-Spaces"),
                              children: [
                                ...spot.subSpaces.map((subSpace) {
                                  subSpace.statusController.text = "available";
                                  return Card(
                                    margin:
                                    const EdgeInsets.symmetric(vertical: 4),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          CustomTextField(
                                              controller:
                                              subSpace.labelController,
                                              hint: "Label", limit: 100),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: CustomTextField(
                                                      controller: subSpace
                                                          .latitudeController,
                                                      hint: "Latitude", limit: 15)),
                                              SizedBox(width: 5),
                                              Expanded(
                                                  child: CustomTextField(
                                                      controller: subSpace
                                                          .longitudeController,
                                                      hint: "Longitude", limit: 15)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      spot.subSpaces.add(SubSpaceData());
                                    });
                                  },
                                  child: const Text("Add Sub-space",style: TextStyle(color: Color(0xFF407BFF))),
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            spots.add(SpotData());
                          });
                        },
                        child: const Text("Add Space" ,style: TextStyle(color: Color(0xFF407BFF)),),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });

                      try {

                        final payload = buildPayload();
                        final response =! isEditMode
                            ? await apiService.put('update-parking-spaces/$parkingSpaceId', payload)
                            : await apiService.post('parking-spaces', payload);

                        print("✅ Response: ${response["message"]}");

                        // Optionally show success
                        showCustomSnackBar(
                            context: context,
                            message:
                            response["message"] ?? "Created successfully");

                        _resetForm(); // Clear fields
                      } catch (e) {
                        print("❌ Error: $e");
                        showCustomSnackBar(
                            context: context,
                            message: "Submission failed. Please try again.",
                            backgroundColor: Colors.redAccent);
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: btnNavigator(
                      isActive: isLoading,
                      btnColor: Color(0xFF407BFF),
                      text: !isEditMode?'Submit' :'Edit',
                    ),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      if (!isLoading) {
                        _resetForm();
                      } else {
                        showCustomSnackBar(
                            context: context,
                            message: 'Server Busy, please wait...');
                      }
                    },
                    child: btnNavigator(
                      btnColor: Colors.black,
                      text: 'Cancel',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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


