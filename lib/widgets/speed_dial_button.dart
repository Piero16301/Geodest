import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:background_location/background_location.dart';
import 'package:geodest/services/client_service.dart';

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

//TODO: convertir a un staeful widget
//TODO: darle un feedback al usuario para que se note que está compartiendo ubicación
class _SpeedDialButtonState extends State<SpeedDialButton> {

  Icon shareLocationIcon;
  Color shareLocationColor;
  String shareLocationText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    StorageService.getIsSharingLocation().then((isSharing) {
      if (isSharing) {
        shareLocationIcon = Icon(Icons.location_off);
        shareLocationColor = Colors.red;
        shareLocationText = "Dejar de compartir";
        setState(() {});
      } else {
        shareLocationIcon = Icon(Icons.location_on);
        shareLocationColor = Colors.amber;
        shareLocationText = "Compartir ubicación";
        setState(() {});
      }
    });

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
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 5,
      shape: CircleBorder(),
      children: [
        //TODO: cada _dialChild debería ser un widget, ya sea stateless o stateful, hay un switch enorme que no debería estar ahí (por legibilidad)
        _dialChild(action: SpeedDialAction.Logout, context: context, icon: Icon(Icons.logout), color: Colors.deepPurpleAccent, label: "Logout", route: 'login'),
        _dialChild(action: SpeedDialAction.ShowCreditInfo, context: context, icon: Icon(Icons.attach_money), color: Colors.purpleAccent, label: "Mis Créditos"),
        _dialChild(action: SpeedDialAction.ShareLocation, context: context, icon: shareLocationIcon, color: shareLocationColor, label: shareLocationText, route: 'login'),
        _dialChild(action: SpeedDialAction.RefreshDeliveries, context: context, icon: Icon(Icons.update), color: Colors.blue, label: "Actualizar pedidos", route: 'splash'),
        _dialChild(action: SpeedDialAction.AddDelivery, context: context, icon: Icon(Icons.add), color: Colors.green, label: "Añadir Envío", route: 'login'),
      ],
    );
  }

  SpeedDialChild _dialChild({action, context, icon, color, label, route}) {

    // final uiProvider = Provider.of<UiProvider>(context);
    // final currentIndex = uiProvider.selectedMenuOpt;

    return SpeedDialChild(
      child: icon,
      backgroundColor: color,
      foregroundColor: Colors.white,
      //labelBackgroundColor: Color(0xffF9D342),
      labelBackgroundColor: color,
      label: label,
      labelStyle: TextStyle(
        fontSize: 15,
        //color: Color(0xff292826),
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      onTap: () {
        switch (action) {
          case SpeedDialAction.RefreshDeliveries: {
            //TODO: mandarle un evento a DeliveriesPage para q refresque
            print("Refresh deliveries");

            // uiProvider.selectedMenuOpt = 1;
            EventsService.emitter.emit("refreshDeliveries");

            break;
          }
          case SpeedDialAction.ShowCreditInfo: {
            //TODO: hacer request
            //TODO: mandarle la data del responde al dialog
            ClientService.getCreditInfo().then(
              (res) {
                final body = jsonDecode(res.body);
                print("credit info data: $body");
                DialogService.showCreditInfoDialog(context: context, remainingCredits: body['credits']);
              }
            );
            break;
          }
          case SpeedDialAction.ShareLocation: {
            BackgroundLocation.getPermissions(
              onGranted: () {
                LocationService.toggleLocationSharing().then((result) {
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
            //TODO: pushear la vista de añadir delivery
            Navigator.pushNamed(context, 'new_delivery');
            break;
          }
          case SpeedDialAction.Logout: {
            StorageService.logout().then((_) {
              Navigator.pushNamedAndRemoveUntil(context, 'login', (_) => false);
            });
            print("logout");
            break;
          }
          default: {
            // nica llega acá
          }
        }
      },
    );
  }

}

