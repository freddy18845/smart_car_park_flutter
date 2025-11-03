// To parse this JSON data, do
//
//     final userData = userDataFromJson(jsonString);

import 'dart:convert';

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  User user;
  String token;

  UserData({
    required this.user,
  required  this.token,
  });

  UserData copyWith({
    User? user,
    String? token,
  }) =>
      UserData(
        user: user ?? this.user,
        token: token ?? this.token,
      );

  factory UserData.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("user")) {
      // Case 1: { user: {...}, token: ... }
      return UserData(
        user:  User.fromJson(json["user"]),
        token: json["token"],
      );
    } else {
      // Case 2: { id: ..., first_name: ..., token: ... }
      return UserData(
        user: User.fromJson(json),
        token: json["token"],
      );
    }
  }



  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
    "token": token,
  };
}

class User {
  int? id;
  String? firstName;
  String? lastName;
  String? phone;
  String? role;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      User(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    phone: json["phone"],
    role: json["role"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "phone": phone,
    "role": role,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
