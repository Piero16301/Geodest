import 'dart:convert';

import '../interceptor/http_interceptor.dart';
import './storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'common_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

var client;
var originalClient = http.Client();

class ClientService {

  /// login

  static Future<http.Response> login(Map<String, dynamic> body) async {
    //FIXME: si da un error de 'Tried calling: getString("accessToken")' entonces no se instancio el authenticatedclient
    client = AuthenticatedHttpClient(sharedPref: await SharedPreferences.getInstance());
    return await client.post(
        Uri.parse(CommonService.loginUrl),
        body: jsonEncode(body),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  /// deliveries

  static Future<http.Response> postDelivery(Map<String, dynamic> body) async {
    client = AuthenticatedHttpClient(sharedPref: await SharedPreferences.getInstance());
    return await client.post(
        Uri.parse(CommonService.deliveryUrl),
        body: jsonEncode(body),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  static Future<http.Response> getDeliveries() async {
    print("getting deliveries");
    client = AuthenticatedHttpClient(sharedPref: await SharedPreferences.getInstance());
    print("got client instance");
    return await client.get(
        Uri.parse(CommonService.deliveryUrl),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  static Future<http.Response> completeDelivery(int id) async {
    client = AuthenticatedHttpClient(sharedPref: await SharedPreferences.getInstance());
    return await client.put(
        Uri.parse("${CommonService.deliveryUrl}/$id"),
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
        Uri.parse(CommonService.refreshTokenUrl),
        headers: <String, String> {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'token': '$refreshToken'
        })
    );
    //TODO: despues de esto, se debe guardar el nuevo access token (refresh se mantiene)
    //TODO: si el response da 401, logout al user sí o sí, decirle q la sesión ha expirado
  }

  /// username
  static Future<http.Response> getUsername() async {
    client = AuthenticatedHttpClient(sharedPref: await SharedPreferences.getInstance());
    return await client.get(
      Uri.parse(CommonService.usernameUrl),
      headers: <String, String> {
        'Content-Type': 'application/json'
      }
    );
  }

}