import 'package:flutter/material.dart';

import 'views/login_screen/login_page.dart';
import 'views/home_screen/home_page.dart';

import 'package:telephony/telephony.dart';
import 'package:siac_sms_gateway/services/send_sms.dart';

void onBackgroundMessage(SmsMessage message) {
  sendSmsData(message, null);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromRGBO(243, 122, 9, 1),
          // secondary: const Color(0xFFFFC107),
        ),
        fontFamily: 'Nunito',
      ),
      home: const LoginForm(),
      routes: <String, WidgetBuilder>{
        LoginForm.tag: (context) => const LoginForm(),
        HomePage.tag: (context) => const HomePage(onBackgroundMessage: onBackgroundMessage),
      },
    );
  }
}
