import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:telephony/telephony.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:siac_sms_gateway/utils/constants.dart';
import 'package:siac_sms_gateway/models/token.dart';
import './refresh_token.dart';

RegExp regExp = RegExp(
    r'^BDV:[^#]+#(?<number>\d+)[^B]+Bs.\s*(?<amount>\d+,\d+)[^0-9]+(?<phoneNumber>\d{4}-\d{7}).+Fecha:(?<datetime>\d+-\d+-\d+ \d+:\d+).+$');

Future<http.Response?> sendSmsData(
    SmsMessage message, FlutterSecureStorage? storage) async {
  final messageBody = message.body;
  final messageAddress = message.address;

  if (messageAddress != null && messageBody != null) {
    final match = regExp.firstMatch(messageBody);

    if (match != null) {
      final phoneNumber = match.namedGroup("phoneNumber");
      final amount = match.namedGroup("amount");
      final datetime = match.namedGroup("datetime");
      final number = match.namedGroup("number");

      if (phoneNumber != null &&
          amount != null &&
          datetime != null &&
          number != null) {
        storage ??= const FlutterSecureStorage();
        String? refreshToken = await storage.read(key: 'refreshToken');

        if (refreshToken == null) {
          return null;
        }

        Token token = await fetchRefreshToken(refreshToken);
        final response = await http.post(
          Uri.parse("$host/api/v1/deposits/mobile_payment/from_sms/"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${token.accessToken}'
          },
          body: jsonEncode(<String, dynamic>{
            'address': message.address,
            'timestamp': message.date,
            'datetime': datetime,
            'amount': amount,
            'phone_number': phoneNumber,
            'number': number,
            'subject': message.subject,
            'subscriptionId': message.subscriptionId,
            'serviceCenterAddress': message.serviceCenterAddress,
          }),
        );

        return response;
      }
    }
  }

  return null;
}
