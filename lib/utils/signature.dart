import 'dart:convert';
import 'package:crypto/crypto.dart';

String gererateSignature(String input) {
  final bytes = utf8.encode(input);
  final digest = sha1.convert(bytes);
  return base64Encode(digest.bytes);
}