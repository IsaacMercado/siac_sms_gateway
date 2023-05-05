class Token {
  String? accessToken;
  String? refreshToken;

  String? email;
  String? password;

  List<String> nonFieldErrors = [];
  List<String> emailErrors = [];
  List<String> passwordErrors = [];

  Token({this.accessToken, this.refreshToken});

  factory Token.fromJson(Map<String, dynamic> json) {
    final token = Token(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );

    if (json.containsKey('non_field_errors')) {
      token.nonFieldErrors = json['non_field_errors'];
    } else if (json.containsKey('detail')) {
      token.nonFieldErrors = [json['detail']];
    }

    if (json.containsKey('email')) {
      token.emailErrors = json['email'];
    }

    if (json.containsKey('password')) {
      token.passwordErrors = json['password'];
    }

    return token;
  }

}
