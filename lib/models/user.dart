import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  final String username;
  final String firstName;
  final String lastName;
  final String personId;
  final String birthday;
  final String affiliatedPhoneNumber;
  final String alternativePhoneNumber;

  User({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.personId,
    required this.birthday,
    required this.affiliatedPhoneNumber,
    required this.alternativePhoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      personId: json['person_id'] as String,
      birthday: json['birthday'] as String,
      affiliatedPhoneNumber: json['affiliated_phone_number'] as String,
      alternativePhoneNumber: json['alternative_phone_number'] as String,
    );
  }

  static Future<User> fromStorage(FlutterSecureStorage storage) async {
    String? username = await storage.read(key: 'username');
    String? firstName = await storage.read(key: 'firstName');
    String? lastName = await storage.read(key: 'lastName');
    String? personId = await storage.read(key: 'personId');
    String? birthday = await storage.read(key: 'birthday');
    String? affiliatedPhoneNumber =
        await storage.read(key: 'affiliatedPhoneNumber');
    String? alternativePhoneNumber =
        await storage.read(key: 'alternativePhoneNumber');

    if (username == null ||
        firstName == null ||
        lastName == null ||
        personId == null ||
        birthday == null ||
        affiliatedPhoneNumber == null ||
        alternativePhoneNumber == null) {
      throw Exception('Failed to load user from storage');
    }

    return User(
      username: username,
      firstName: firstName,
      lastName: lastName,
      personId: personId,
      birthday: birthday,
      affiliatedPhoneNumber: affiliatedPhoneNumber,
      alternativePhoneNumber: alternativePhoneNumber,
    );
  }
}
