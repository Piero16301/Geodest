import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:http/http.dart' as http show Response, Request, StreamedResponse;

import '../services/storage_service.dart';
import '../services/client_service.dart';

class GeodestInterceptor implements InterceptorContract {

  RequestData lastRequest;
  ResponseData lastRequestResponseData;
  bool tokenExpired = false;

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
    print("Authorization: ${data.headers["Authorization"]}");

    lastRequest = data;

    return data;
  }

  /// RESPONSE
  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {

    /// sin este if, se hace un loop recursivo, Lmao
    if (data.url.toString().contains("refresh") || tokenExpired) {
      print("SAVING LAST RESPONSE DATA: req url: ${data.url}");
      tokenExpired = false;
      return data;
    }

    lastRequestResponseData = data;

    print("Response intercepted, data:\n ${data.toString()}");

    if (data.statusCode == 401) {
      tokenExpired = true;

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

      //FIXME: tengo q retornar la data de este request
      print("A PUNTO DE REPETIR EL REQUEST");
      await ClientService.sendRequest(
          url: lastRequest.url,
          method: methodToString(lastRequest.method),
          body: lastRequest.body
      );

      print("Retrying request: ${data.url}");
      print("Retried request data: ${lastRequestResponseData.body}");

      return lastRequestResponseData;

    } else {
      print("Normal response");
    }

    return data;
  }

}