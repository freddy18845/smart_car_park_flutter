import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../utils/constant.dart';
import '../utils/storage_manage.dart';

class ApiService {
  final String baseUrl = BASE_URL;

  Map<String, String> get headers => {
        'Accept': 'application/json',
    'Content-Type': 'application/json'
      };

  /// Generic GET
  Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    final uri =
        Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);
    final token = await StorageManager().getLoginToken();

    final requestHeaders = Map<String, String>.from(headers);
    if (token.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    final response = await http
        .get(uri, headers: requestHeaders)
        .timeout(Duration(seconds: 15), onTimeout: () {
      throw Exception('Request timed out');
    });


    return _handleResponse(response);
  }

  /// Generic POST
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final token = await StorageManager().getLoginToken();

    final requestHeaders = Map<String, String>.from(headers);
    if (token.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );
    print(jsonEncode(body));
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return decoded; // ✅ return decoded map
    } else {
      throw Exception(decoded['message'] ?? 'API Error: ${response.statusCode}');
    }

  }


  /// Generic PUT
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final token = await StorageManager().getLoginToken();

    // Clone base headers
    final requestHeaders = Map<String, String>.from(headers);

    // Add Authorization header if token exists
    if (token.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }


    final response = await http.put(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'API Error: ${response.statusCode}');
    }
  }

  /// Generic DELETE
  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final response = await http.delete(uri, headers: headers);
    return _handleResponse(response);
  }

  /// Specific: Get filtered reservations
  Future<List<dynamic>> getFilteredReservations({
    int? userId,
    int? parkingSpaceId,
    String? vehicleNumber,
  }) async {
    final queryParams = {
      if (userId != null) 'user_id': userId.toString(),
      if (parkingSpaceId != null) 'parking_space_id': parkingSpaceId.toString(),
      if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
    };

    final result = await get('reservations/filter', queryParams: queryParams);
    return result['data'] ?? [];
  }

  //Specific: Login
  Future<Map<String, dynamic>> login(String number, String password) async {
    final uri = Uri.parse('$baseUrl/login');
    //print("${number} ${password}");

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'phone': number,
        'password': password,
      }),
    );

    final responseData = json.decode(response.body);
    final responseUser = responseData["user"];
    final String authToken = "${responseData["token"]}";
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Login${responseData}");
      StorageManager().setUserData(
          responseUser["first_name"],
          responseUser["last_name"],
          responseUser["phone"],
          responseUser["id"], responseUser["role"], authToken);


    }
    return {
      'statusCode': response.statusCode,
      'body': responseData,
    };
  }

  Future<Map<String, dynamic>> logout(String token) async {
    print(token);
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }

  // User Registration
  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String role,
    required  BuildContext context
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final body = jsonEncode({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'password': password,
      'role': role.toLowerCase(),
    });

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      showCustomSnackBar(context: context, message: 'Registration Successful!');
      return jsonDecode(response.body);

      // contains token, user_id, role, etc.
    } else {
      final error = jsonDecode(response.body);
      throw Exception(
          error['message'] ?? 'Registration failed${response.statusCode}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    print("working");
    print("$body");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'API Error: ${response.statusCode}');
    }
  }
}
// -------------------------------------------------------------------------
// | API Endpoints Documentation
// |--------------------------------------------------------------------------
// |
// | 1. Update Sub-Space Status
// |    PUT /api/sub-spaces/{id}/status
// |    Body: {
// |        "parking_spot_id": 3,
// |        "parking_space_id": 1,
// |        "operator_id": 1,
// |        "status": "occupied"
// |    }
// |
// | 2. Bulk Update Sub-Spaces Status
// |    POST /api/sub-spaces/bulk-update-status
// |    Body: {
// |        "sub_space_ids": [9, 10, 11],
// |        "parking_spot_id": 3,
// |        "parking_space_id": 1,
// |        "operator_id": 1,
// |        "status": "available"
// |    }
// |
// | 3. Toggle Sub-Space Status
// |    POST /api/sub-spaces/{id}/toggle-status
// |    Body: {
// |        "parking_spot_id": 3,
// |        "parking_space_id": 1,
// |        "operator_id": 1
// |    }
// |
// | 4. Get Sub-Space Details
// |    GET /api/sub-spaces/{id}
// |
// | 5. Get Sub-Spaces by Parking Spot
// |    GET /api/parking-spots/{parkingSpotId}/sub-spaces
// |