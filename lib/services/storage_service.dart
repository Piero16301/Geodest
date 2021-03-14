import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  /// refresh token

  static Future<void> saveRefreshToken(String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('refreshToken', refreshToken);
  }

  static Future<String> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken') ?? "";
  }

  static Future<void> removeRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('refreshToken');
  }

  /// access token

  static Future<void> saveAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('accessToken', accessToken);
  }

  static Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? "";
  }

  static Future<void> removeAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }

  /// email

  static Future<void> saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('email', email);
  }

  static Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? "";
  }

  static Future<void> removeEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
  }

  /// username

  static Future<void> saveUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('username', username);
  }

  static Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? "";
  }

  static Future<void> removeUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  /// is sharing location

  static Future<void> saveIsSharingLocation(bool isOrNot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('isSharingLocation', isOrNot);
  }

  static Future<bool> getIsSharingLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSharingLocation') ?? false;
  }

  static Future<void> removeIsSharingLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  /// logout
  static Future<void> logout() async {
    await removeAccessToken();
    await removeRefreshToken();
    await removeIsSharingLocation();
    await removeIsSharingLocation();
    /// FIXME: asumo que no esta compartiendo ubicacion cuando hace logout
  }

}