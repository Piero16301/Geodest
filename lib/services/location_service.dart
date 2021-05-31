import 'dart:convert';

import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:system_settings/system_settings.dart';
import 'package:web_socket_channel/io.dart';
import 'common_service.dart';
import 'storage_service.dart';
import 'package:http/http.dart' as http;

import './client_service.dart';

class LocationService {

  static IOWebSocketChannel _channel;
  static int _counter = 0;

  static bool isSharingLocation;

  static start() async {
    // print("Compartiendo ubicación...");
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
        // print("[ERROR]: when fetching username");
        return;
      }
    }

    // print("WEBSOCKET: ${CommonService.wsBaseUrl}/$username/");

    _channel = IOWebSocketChannel.connect(Uri.parse("${CommonService.wsBaseUrl}/$username/"));

    /// lo de abajo es para debugging
    //TODO: comentar antes del deploy
    // _channel.stream.listen((event) {
      // print("WS response: $event");
    // });

    BackgroundLocation.setAndroidNotification(
      title: "Compartiendo tu ubicación...",
      message: "El cliente puede ver tu viaje desde el mapa.",
      icon: "@mipmap/ic_launcher",
    );
    BackgroundLocation.startLocationService(distanceFilter: 50);
    BackgroundLocation.startLocationService();
  }

  static Future<bool> toggleLocationSharing({bool start = false}) async {
    bool isSharingLocation = await StorageService.getIsSharingLocation();

    if (!isSharingLocation || start) {
      await LocationService.start();

      BackgroundLocation.getLocationUpdates((Location location) {
        _counter++;
        // si se movió 50m*30=1500m, mandar el PUT
        if (_counter % 30 == 0) {
          // print("================MANDAR PUT===================");
          http.put(
            Uri.parse(CommonService.locationUpdateUrl),
            headers: <String, String> {
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'lat': location.latitude,
              'lng': location.longitude,
            })
          );
        }
        isSharingLocation = true;
        // print("channel: $_channel");
        // print("Location update at ${DateTime.now()}: (lat: ${location.latitude}, long: ${location.longitude})");
        sendLocation(location);
        isSharingLocation = false;
      });
      return true;
    } else {
      await LocationService.stop();
      return false;
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
    _channel.sink.add(
      jsonEncode({
        'message': jsonEncode({
          'lat': location.latitude,
          'lng': location.longitude
        })
      })
    );
  }

  static stop() async {
    _counter = 0;
    // print("Dejando de compartir ubicación...");
    if (_channel != null) {
      _channel.sink.close();
      BackgroundLocation.stopLocationService();
    }
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
                  SystemSettings.app();
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
