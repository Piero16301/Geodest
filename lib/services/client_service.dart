import 'package:geodest/services/storage_service.dart';
import 'package:http_interceptor/http_client_with_interceptor.dart';
import 'package:http/http.dart' as http show Response;

import '../interceptor/http_interceptor.dart';
import '../services/common_service.dart';
import 'dart:convert';

class ClientService {

  static final _client = HttpClientWithInterceptor.build(
      interceptors: [
        GeodestInterceptor(),
      ]
  );

  /// login

  static Future<http.Response> login(Map<String, dynamic> body) async {
    return await _client.post(
        Uri.parse(CommonService.loginUrl),
        body: jsonEncode(body),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  /// deliveries

  static Future<http.Response> postDelivery(Map<String, dynamic> body) async {
    return await _client.post(
        Uri.parse(CommonService.deliveryUrl),
        body: jsonEncode(body),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  static Future<http.Response> getDeliveries() async {
    return await _client.get(
        Uri.parse(CommonService.deliveryUrl),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  static Future<http.Response> completeDelivery(int id) async {
    return await _client.put(
        Uri.parse("${CommonService.deliveryUrl}/$id"),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

  /// token

  static Future<http.Response> refreshToken() async {
    String refreshToken = await StorageService.getRefreshToken();
    return await _client.post(
        Uri.parse(CommonService.refreshTokenUrl),
        headers: <String, String> {
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'refresh': '$refreshToken'
        })
    );
  }



  /// username
  static Future<http.Response> getUsername() async {
    return await _client.get(
        Uri.parse(CommonService.usernameUrl),
        headers: <String, String> {
          'Content-Type': 'application/json'
        }
    );
  }

}