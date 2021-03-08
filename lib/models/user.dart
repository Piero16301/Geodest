class User {
  User({this.email, this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
    };
  }
}