import 'dart:convert';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
        'email': email,
        'role': role,
      };

  // ✅ Encode properly
  String toJsonString() => jsonEncode(toJson());

  // ✅ Decode properly
 
  static UserModel fromJsonString(String jsonString) {
  final jsonMap = jsonDecode(jsonString);
  return UserModel.fromJson(jsonMap);
}

}
