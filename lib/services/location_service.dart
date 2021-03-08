import 'dart:convert';

import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:web_socket_channel/io.dart';
import 'common_service.dart';
import 'client_service.dart';
import 'storage_service.dart';
import 'package:http/http.dart' as http;

//TODO: PROBAR EL PERMISSIONN DENIED, LUEGO EL COMPARTIR SIN WEBSOCKET Y FINALMENTE CON SOCKET

class LocationService {

  static IOWebSocketChannel channel;

  static start() async {
    print("Compartiendo ubicación...");
    await StorageService.saveIsSharingLocation(true);
    String username = await StorageService.getUsername();

    // solo hacer el request cuando no tenemos username en disco
    if (username.isEmpty) {
      http.Response res = await ClientService.getUsername();

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        username = body['username'];
        await StorageService.saveUsername(username);
      } else {
        print("[ERROR]: when fetching username");
        return;
      }
    }

    print("${CommonService.wsBaseUrl}/$username/");

    channel = IOWebSocketChannel.connect(Uri.parse("${CommonService.wsBaseUrl}/$username/"));



    /// lo de abajo es para debugging
    // channel = IOWebSocketChannel.connect(Uri.parse("wss://echo.websocket.org"));
    channel.stream.listen((event) {
      print("WS response: $event");
    });

    BackgroundLocation.setAndroidNotification(
      title: "Compartiendo tu ubicación...",
      message: "El cliente puede ver tu viaje desde el mapa.",
      icon: "@mipmap/ic_launcher",
    );
    BackgroundLocation.setAndroidConfiguration(10000);
    //TODO: descomentar lo de abajo antes del deploy
    // BackgroundLocation.startLocationService(distanceFilter : 50);
    BackgroundLocation.startLocationService();
  }

  static toggleLocationSharing() async {
    bool isSharingLocation = await StorageService.getIsSharingLocation();

    if (!isSharingLocation) {
      await LocationService.start();

      BackgroundLocation.getLocationUpdates((Location location) {
        print("Location update at ${DateTime.now()}: (lat: ${location.latitude}, long: ${location.longitude})");
        sendLocation(location);
      });

    } else {
      await LocationService.stop();
    }
  }

  /*
    Location class:
    double latitude;
    double longitude;
    double altitude;
    double bearing;
    double accuracy;
    double speed;
    double time;
    bool isMock;
  */
  static sendLocation(Location location) {
    // channel.sink.add(
    //   "${location.longitude}, ${location.latitude}"
    // );
    channel.sink.add(jsonEncode({
      'message': "{\"lat\": ${location.latitude}, \"lng\": ${location.longitude}"
    }));
  }

  static stop() async {
    print("Dejando de compartir ubicación...");
    // channel.sink.close();
    BackgroundLocation.stopLocationService();
    // await StorageService.removeUsername();
    await StorageService.saveIsSharingLocation(false);
  }

  static complainPermissionDenied(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("¡Necesitamos tu permiso!"),
          content: const Text("Para que el usuario pueda verte en el mapa, necesitamos que nos permitas acceso a tu ubicación. Por favor, anda a Ajustes y cambia los permisos."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  //FIXME: lo de abajo no funca
                  AppSettings.openLocationSettings();
                },
                child: const Text("OK")
            )
          ],
          elevation: 30.0,
        );
      },
      barrierDismissible: false,
    );
  }

}
