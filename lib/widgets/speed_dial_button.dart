import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:background_location/background_location.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:geodest/services/client_service.dart';
import 'package:geodest/services/common_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geodest/utils/colors.dart';

import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/events_service.dart';
import '../services/dialog_service.dart';
import '../enums/speed_dial_action.dart';

class SpeedDialButton extends StatefulWidget {
  SpeedDialButton();

  @override
  _SpeedDialButtonState createState() => _SpeedDialButtonState();

}

class _SpeedDialButtonState extends State<SpeedDialButton> {

  Icon shareLocationIcon;
  Color shareLocationColor;
  String shareLocationText;

  @override
  void initState() {
    super.initState();

    _checkIsSharingLocation().then((isSharing) {
      if (isSharing) {
        shareLocationIcon = Icon(Icons.location_off);
        shareLocationColor = Colors.red;
        shareLocationText = "Dejar de compartir";
      } else {
        shareLocationIcon = Icon(Icons.location_on);
        shareLocationColor = Colors.amber;
        shareLocationText = "Compartir ubicación";
      }
      setState(() {});
    });
  }

  Future<bool> _checkIsSharingLocation() async {
    bool isSharingLocation = await StorageService.getIsSharingLocation();
    // print("isSharingLocation: $isSharingLocation");
    // print("LocationService.isSharingLocation: ${LocationService.isSharingLocation}");
    if (isSharingLocation) { /// deberia estar compartiendo ubicacion
      if (LocationService.isSharingLocation == null) { /// cerró la app, mientras compartia
        await LocationService.toggleLocationSharing(start: true);
      }
      return true;
    } else { /// no esta compartiendo ubicacion
      return false;
    }

  }

  @override
  Widget build(BuildContext context) {

    return SpeedDial(
      marginEnd: 20,
      marginBottom: 20,
      icon: Icons.add,
      activeIcon: Icons.remove,
      buttonSize: 60,
      overlayOpacity: 0.5,
      onOpen: () => {},// print('OPENING DIAL'),
      onClose: () => {}, // print('DIAL CLOSED'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 5,
      shape: CircleBorder(),
      children: [
        //TODO: cada _dialChild debería ser un widget, ya sea stateless o stateful, hay un switch enorme que no debería estar ahí (por legibilidad)
        _dialChild(action: SpeedDialAction.Logout, context: context, icon: Icon(Icons.logout), color: Colors.deepPurpleAccent, label: "Logout", route: 'login'),
        _dialChild(action: SpeedDialAction.EditProfile, context: context, icon: Icon(Icons.person), color: Colors.deepOrange, label: "Editar perfil", route: 'login'),
        _dialChild(action: SpeedDialAction.ShowCreditInfo, context: context, icon: Icon(Icons.attach_money), color: Colors.purpleAccent, label: "Mis Créditos"),
        _dialChild(action: SpeedDialAction.ShareLocation, context: context, icon: shareLocationIcon, color: shareLocationColor, label: shareLocationText, route: 'login'),
        _dialChild(action: SpeedDialAction.RefreshDeliveries, context: context, icon: Icon(Icons.update), color: Colors.blue, label: "Actualizar pedidos", route: 'splash'),
        _dialChild(action: SpeedDialAction.AddDelivery, context: context, icon: Icon(Icons.add), color: Colors.green, label: "Añadir Envío", route: 'login'),
      ],
    );
  }

  void sendPutLocation(String arg) async {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      ///Hacer el put al server
      Position currentPosition = await Geolocator.getCurrentPosition();
      final body = {
        "lat": currentPosition.latitude,
        "lng": currentPosition.longitude
      };
      // print('Haciendo el PUT de la ubicación');
      ClientService.updateLocation(body).then((response) {
        // print('Update response: ${json.decode(response.body)}');
      });
    });
  }

  SpeedDialChild _dialChild({action, context, icon, color, label, route}) {

    return SpeedDialChild(
      child: icon,
      backgroundColor: color,
      foregroundColor: Colors.white,
      labelBackgroundColor: color,
      label: label,
      labelStyle: TextStyle(
        fontSize: 15,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      onTap: () {
        switch (action) {
          case SpeedDialAction.RefreshDeliveries: {
            // print("Refresh deliveries");
            EventsService.emitter.emit("refreshDeliveries");
            break;
          }
          case SpeedDialAction.ShowCreditInfo: {
            ClientService.getCreditInfo().then(
              (res) {
                final body = jsonDecode(res.body);
                // print("credit info data: $body");
                DialogService.showCreditInfoDialog(context: context, remainingCredits: body['credits']);
              }
            );
            break;
          }
          case SpeedDialAction.ShareLocation: {
            BackgroundLocation.getPermissions(
              onGranted: () {
                LocationService.toggleLocationSharing().then((result) async {
                  if (result) {
                    /// empezó a compartir ubicación
                    setState(() {
                      shareLocationIcon = Icon(Icons.location_off);
                      shareLocationColor = Colors.red;
                      shareLocationText = "Dejar de compartir";
                    });
                  } else {
                    /// dejó de compartir ubicación
                    setState(() {
                      shareLocationIcon = Icon(Icons.location_on);
                      shareLocationColor = Colors.amber;
                      shareLocationText = "Compartir ubicación";
                    });
                  }
                });
              },
              onDenied: () {
                LocationService.complainPermissionDenied(context);
              },
            );
            break;
          }
          case SpeedDialAction.AddDelivery: {
            Navigator.pushNamed(context, 'new_delivery');
            break;
          }
          case SpeedDialAction.EditProfile: {
            openEditProfileTab();
            break;
          }
          case SpeedDialAction.Logout: {
            StorageService.logout().then((_) {
              Navigator.pushNamedAndRemoveUntil(context, 'login', (_) => false);
            });
            // print("logout");
            break;
          }
        }
      },
    );
  }

  openEditProfileTab() async {
    await FlutterWebBrowser.openWebPage(
      url: "${CommonService.baseUrl}/accounts/profile/",
      customTabsOptions: CustomTabsOptions(
        toolbarColor: primaryColor,
        showTitle: true,
      ),
    );
  }

}

