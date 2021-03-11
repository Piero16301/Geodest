import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';

import 'package:http/http.dart' as http show Response;

import '../services/storage_service.dart';
import '../services/client_service.dart';

class GeodestInterceptor implements InterceptorContract {

  /// REQUEST
  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    print("Request intercepted, data: ${data.toString()}");

    if (data.url.toString().contains("refresh")) {
      data.headers["Content-Type"] = "application/json";
      return data;
    }

    String accessToken = await StorageService.getAccessToken();

    data.headers["Content-Type"] = "application/json";
    data.headers["Authorization"] = "Bearer $accessToken";

    return data;
  }

  /// RESPONSE
  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {

    /// sin este if, se hace un loop recursivo, Lmao
    if (data.url.toString().contains("refresh")) {
      return data;
    }

    print("Response intercepted, data: ${data.toString()}");

    if (data.statusCode == 401) {
      print("Refreshing token...");

      http.Response res = await ClientService.refreshToken();

      print(res.body);

      Map body = jsonDecode(res.body);

      if (body["access"] != null) {
        await StorageService.saveAccessToken(body["access"]);
      } else {
        print("REFRESHED TOKEN BUT GOT NO NEW ACCESS TOKEN");
        /// creo q en este caso, tenemos que desloguear al usuario
      }

      //TODO: retornar un statusCode especial para reintentar el request

    } else {
      print("Normal response");
    }

    return data;
  }

}