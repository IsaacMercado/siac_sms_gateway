import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:siac_sms_gateway/models/user.dart';
import 'package:siac_sms_gateway/services/send_sms.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onBackgroundMessage});
  static String tag = 'home-page';
  final MessageHandler onBackgroundMessage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final telephony = Telephony.instance;
  final storage = const FlutterSecureStorage();
  User? _user;

  onMessage(SmsMessage message) async {
    await sendSmsData(message, storage);
  }

  @override
  void initState() {
    super.initState();
    _getUser();

    if (Platform.isAndroid) {
      initPlatformState();
    }
  }

  Future<void> _getUser() async {
    final user = await User.fromStorage(storage);
    setState(() {
      _user = user;
    });
  }

  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? smsPermission = await telephony.requestPhoneAndSmsPermissions;

    if (smsPermission != null && smsPermission) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage,
          onBackgroundMessage: widget.onBackgroundMessage);
    }

    if (!mounted) return;
  }

  Future<void> _cleanData() async {
    await storage.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Bienvenido';

    if (_user != null) {
      title = 'Bienvenido\n${_user!.firstName} ${_user!.lastName}';
    }

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: <Widget>[
            const Hero(
              tag: 'hero',
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircleAvatar(
                  radius: 72.0,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28.0),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Esta aplicación permite enviar mensajes de texto a través de la plataforma SIAC SMS Gateway.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  _cleanData().then((value) => Navigator.pop(context));
                },
                child: const Text('Salir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
