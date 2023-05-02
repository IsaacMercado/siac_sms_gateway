import 'package:flutter/material.dart';
import 'package:siac_sms_gateway/models/token.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:telephony/telephony.dart';

import '../../utils/constants.dart';
import '../../services/login.dart';
import '../home_screen/home_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  static String tag = 'login-page';

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  Token _token = Token();
  final Telephony telephony = Telephony.instance;

  void _submitForm() async {
    final email = _token.email;
    final password = _token.password;

    if (email != null &&
        email.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      try {
        final token = await fetchToken(email, password);
        if (token.accessToken != null) {
          await Future.delayed(const Duration(seconds: 1));
          if (!context.mounted) return;
          Navigator.of(context).pushNamed(HomePage.tag);
        } else {
          setState(() {
            _token = token;
          });
        }
      } catch (error) {
        debugPrint(error.toString());
      }
    }
  }

  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      debugPrint("Granted");
      String? networkOperator = await telephony.networkOperator;
      String? operatorName = await telephony.networkOperatorName;
      String? simOperator = await telephony.simOperator;
      String? simOperatorName = await telephony.simOperatorName;
      debugPrint(
          "Operator name: $operatorName, $simOperator, $simOperatorName, $networkOperator");
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              Hero(
                tag: 'hero',
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 100.0,
                  child: Image.asset('assets/logo.png'),
                ),
              ),
              const Text(
                'SIAC SMS Gateway',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28.0),
              ),
              const SizedBox(height: 48.0),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El email es obligatorio';
                  }
                  return null;
                },
                onSaved: (newValue) => _token.email = newValue,
                decoration: InputDecoration(
                  hintText: 'Email',
                  labelText: 'Email',
                  errorText: _token.emailErrors.join('/n'),
                  contentPadding:
                      const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                autofocus: false,
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  return null;
                },
                onSaved: (newValue) => _token.password = newValue,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  labelText: 'Contraseña',
                  errorText: _token.passwordErrors.join('/n'),
                  contentPadding:
                      const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
              const SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).pushNamed(HomePage.tag);
                    // fetchToken();
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                      _submitForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    // backgroundColor: const Color.fromRGBO(243, 122, 9, 1.0),
                  ),
                  child: const Text('Log In',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              TextButton(
                child: const Text(
                  'Ir a la página de principal',
                  style: TextStyle(color: Colors.black54),
                ),
                onPressed: () {
                  // _launchUrl();
                  debugPrint("Hola mundo");
                  initPlatformState();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(host);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
