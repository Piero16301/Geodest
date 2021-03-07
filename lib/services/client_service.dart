import 'package:geodest/interceptor/http_interceptor.dart';
import 'package:geodest/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'common_service.dart';

var client = AuthenticatedHttpClient();
var originalClient = http.Client();

class ClientService {

  /// login

  static Future<http.Response> login(Map<String, dynamic> body) async {
    return await client.post(
        Uri.https(CommonService.loginUrl, ''),
        body: body,
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  /// deliveries

  static Future<http.Response> postDelivery(Map<String, dynamic> body) async {
    return await client.post(
        Uri.https(CommonService.deliveryUrl, ''),
        body: body,
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  static Future<http.Response> getDeliveries() async {
    return await client.get(
        Uri.https(CommonService.deliveryUrl, ''),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  static Future<http.Response> completeDelivery(int id) async {
    return await client.put(
        Uri.https(CommonService.deliveryUrl, '/$id'),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  /// token

  //TODO: llamar esta función cuando nos llegue un 401 Unauthorized
  static Future<http.Response> refreshToken() async {
    String refreshToken = await StorageService.getRefreshToken();
    return await originalClient.post(
        Uri.https(CommonService.refreshTokenUrl, ''),
        headers: <String, String> {
          'Content-Type': 'application/json'
        },
        body: {
          'token': '$refreshToken'
        }
    );
    //TODO: despues de esto, se debe guardar el nuevo access token (refresh se mantiene)
    //TODO: si el response da 401, logout al user sí o sí, decirle q la sesión ha expirado
  }
}