import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siac_sms_gateway/services/refresh_token.dart';

import '../../utils/constants.dart';
import '../models/user.dart';
import '../models/token.dart';

Future<User> fetchUser(FlutterSecureStorage? storage) async {
  storage ??= const FlutterSecureStorage();
  String? refreshToken = await storage.read(key: 'refreshToken');

  if (refreshToken == null) {
    throw Exception('Failed to load user');
  }

  Token token = await fetchRefreshToken(refreshToken);

  final response = await http.get(
    Uri.parse('$host/api/v1/users/me/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${token.accessToken}',
    },
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load user');
  }
}
