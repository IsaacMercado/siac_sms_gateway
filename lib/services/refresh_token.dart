import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:siac_sms_gateway/utils/constants.dart';
import 'package:siac_sms_gateway/models/token.dart';

Future<Token> fetchRefreshToken(String refreshToken) async {
  final response = await http.post(
    Uri.parse('$host/paseto_auth/token/refresh/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'refresh_token': refreshToken,
    }),
  );

  if (response.statusCode == 200) {
    dynamic body = jsonDecode(response.body);
    body['refresh_token'] = refreshToken;
    return Token.fromJson(body);
  } else {
    throw Exception('Failed to load token');
  }
}
