import 'dart:convert';

import 'package:http_interceptor/http_client_with_interceptor.dart';
import 'package:http/http.dart' as http show Response;

import 'package:geodest/services/storage_service.dart';
import 'package:web_socket_channel/io.dart';

import '../interceptor/http_interceptor.dart';
import './common_service.dart';

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
        Uri.parse("${CommonService.deliveryUrl}/"),
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

  static Future<http.Response> completeDelivery({int id, Map<String, dynamic> body}) async {
    return await _client.put(
      Uri.parse("${CommonService.deliveryUrl}/$id/"),
      headers: <String, String> {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body),
    );
  }

  /// iniciar/terminar viaje
  static Future<http.Response> changeDeliveryState({int deliveryId, Map<String, dynamic> body}) async {
    return await _client.put(
      Uri.parse(CommonService.deliveryUrl + '/$deliveryId/'),
      headers: <String, String> {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body),
    );
  }

  /// enviar ETA al websocket
  static void sendEtaToWebsocket({String username, Map<String, dynamic> body}) {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(Uri.parse("${CommonService.wsBaseUrl}/$username/"));
    // print("${CommonService.wsBaseUrl}/$username/");

    channel.stream.listen((event) {
      // print("WS response: $event");
    });

    channel.sink.add(jsonEncode(body));

    channel.sink.close();
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
  
  /// credits
  static Future<http.Response> getCreditInfo() async {
    return await _client.get(
      Uri.parse(CommonService.creditsUrl),
      headers: <String, String> {
        'Content-Type': 'application/json'
      }
    );
  }

  /// location update
  static Future<http.Response> updateLocation(Map<String, dynamic> body) async {
    return await _client.put(
      Uri.parse('${CommonService.locationUpdateUrl}/'),
      headers: <String, String> {
        'Content-Type': 'application/json'
      },
      body: body,
    );
  }

  /// general
  static Future<http.Response> sendRequest({String url, String method, String body, Map<String, String> headers}) async {
    switch (method) {
      case "GET": {
        return await _client.get(
          Uri.parse(url),
          headers: headers
        );
      }
      case "POST": {
        return await _client.post(
            Uri.parse(url),
            headers: headers,
            body: body
        );
      }
      case "PUT": {
        return await _client.put(
            Uri.parse(url),
            headers: headers
        );
      }
      default: {
        // print("add the request method");
        return null;
      }
    }
  }

}