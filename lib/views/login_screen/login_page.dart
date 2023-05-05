import 'package:flutter/material.dart';
import 'package:siac_sms_gateway/models/token.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:telephony/telephony.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:siac_sms_gateway/utils/constants.dart';
import 'package:siac_sms_gateway/services/login.dart';
import 'package:siac_sms_gateway/services/user.dart';
import '../home_screen/home_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  static String tag = 'login-page';

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final Telephony telephony = Telephony.instance;
  final storage = const FlutterSecureStorage();

  Token _token = Token();

  Future<void> _submitForm() async {
    final email = _token.email;
    final password = _token.password;

    if (email != null &&
        email.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      try {
        final token = await fetchToken(email, password);

        if (token.accessToken != null) {
          await storage.write(key: 'accessToken', value: token.accessToken);
          await storage.write(key: 'refreshToken', value: token.refreshToken);

          try {
            final user = await fetchUser(storage);

            await storage.write(key: 'username', value: user.username);
            await storage.write(key: 'firstName', value: user.firstName);
            await storage.write(key: 'lastName', value: user.lastName);
            await storage.write(key: 'personId', value: user.personId);
            await storage.write(key: 'birthday', value: user.birthday);
            await storage.write(
                key: 'affiliatedPhoneNumber',
                value: user.affiliatedPhoneNumber);
            await storage.write(
                key: 'alternativePhoneNumber',
                value: user.alternativePhoneNumber);
          } catch (error) {
            debugPrint(error.toString());
          }

          await Future.delayed(const Duration(seconds: 1));
          if (!context.mounted) return null;
          Navigator.of(context).pushNamed(HomePage.tag);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(token.nonFieldErrors.join('/n'))),
          );
          setState(() {
            _token = token;
          });
        }
      } catch (error) {
        debugPrint(error.toString());
      }
      return null;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
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
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isLoading = true;
                        });
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
                    _launchUrl();
                  },
                )
              ],
            ),
          ),
        ),
      ),
      if (_isLoading)
        const Opacity(
          opacity: 0.8,
          child: ModalBarrier(dismissible: false, color: Colors.black),
        ),
      if (_isLoading)
        const Center(
          child: CircularProgressIndicator(),
        ),
    ]);
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(host);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
