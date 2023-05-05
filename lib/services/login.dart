import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/token.dart';

Future<Token> fetchToken(String email, String password) async {
  final response = await http.post(
    Uri.parse('$host/paseto_auth/token/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );

  if ([200, 400, 401].contains(response.statusCode)) {
    return Token.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load token');
  }
}
