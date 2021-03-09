import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  SharedPreferences sharedPref;
  AuthenticatedHttpClient({this.sharedPref});

  String cachedAccessToken = '';

  String get userAccessToken {
    if (cachedAccessToken.isNotEmpty)
      return cachedAccessToken;
    else
      cachedAccessToken = loadAccessToken();
    return cachedAccessToken;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // si es un request para refrescar el token, no necesita header alguno
    if (request.url.toString().contains('refresh')) {
      return request.send();
    }

    String token = userAccessToken;

    if (token.isNotEmpty) {
      request.headers.putIfAbsent('Authorization', () => 'Bearer $userAccessToken');
      print("haha 401");
    }
    return request.send();
  }

  //TODO: interceptar responses si es necesario

  String loadAccessToken() {
    final accessToken = sharedPref.getString('accessToken');
    return accessToken ?? '';
  }

  /// LLAMAR ESTA FUNCION CUANDO EL USUARIO HAGA LOGOUT
  void reset() {
    cachedAccessToken = '';
  }
}