import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geodest/services/common_service.dart';
import 'package:geodest/services/user_preferences.dart';

import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:http/http.dart' as http;

import 'package:geodest/enums/delivery_state.dart';
import 'package:geodest/models/delivery_response.dart';
import 'package:geodest/models/start_end_trip.dart';
import 'package:geodest/services/client_service.dart';
import 'package:geodest/services/dialog_service.dart';
import 'package:geodest/utils/colors.dart';
import 'package:geodest/models/update_eta.dart';
import 'package:geodest/services/storage_service.dart';

class DeliveryDetailsPage extends StatefulWidget {
  @override
  _DeliveryDetailsPageState createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {

  DeliveryResponse deliveryResponse;

  String buttonText;
  IconData buttonIcon;
  Color buttonColor;

  final preferences = new PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {

    deliveryResponse = ModalRoute.of(context).settings.arguments;
    // print("Pedido: ${deliveryResponse.toJson()}");
    if (preferences.getDeliveryStarted() == deliveryResponse.pk) {
      buttonText = 'Finalizar viaje';
      buttonIcon = Icons.check;
      buttonColor = primaryColor;
    } else {
      buttonText = 'Iniciar viaje';
      buttonIcon = Icons.flag;
      buttonColor = ternaryColor;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Detalles del pedido"),
        backgroundColor: primaryColor,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: ListView(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          children: [
            Column(
              children: [
                _cardDetail(data: deliveryResponse.address, field: "Dirección del comprador", icon: Icons.home),
                _cardDetail(data: deliveryResponse.receiver, field: "Nombre del comprador", icon: Icons.person),
                _cardDetail(data: deliveryResponse.phone, field: "Celular del comprador", icon: Icons.phone_android),
                _mapView(delivery: deliveryResponse),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: _finishDelivery(),
    );
  }

  Widget _cardDetail({data, field, icon}) {
    return Column(
      children: [
        Container(height: 10),
        Container(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(icon),
                  title: SelectableText(data),
                  subtitle: Text(field),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapView({delivery}) {
    final lat = delivery.latitude;
    final lng = delivery.longitude;
    return Column(
      children: [
        Container(height: 10),
        Container(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                Container(height: 10),
                const Center(
                  child: Text(
                    "Ubicación del destino",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'map_view', arguments: delivery);
                  },
                  child: FadeInImage(
                    image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&markers=color:red%7C$lat,$lng&zoom=16&size=2000x2000&key=AIzaSyDszjoQPzSF_ddL2pXODJy2nwZoT2IfYGI'),
                    placeholder: AssetImage('assets/google-maps-loading.gif'),
                    fadeInDuration: Duration(milliseconds: 500),
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _finishDelivery() {
    return FloatingActionButton.extended(
      label: Text(buttonText),
      icon: Icon(buttonIcon),
      backgroundColor: buttonColor,
      onPressed: () {
        // print("Finalizar delivery");
        if (buttonText == 'Iniciar viaje') {
          _confirmStartDelivery(context);
        } else {
          _confirmFinishDelivery(context);
        }
      },
    );
  }

  void _confirmStartDelivery(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: const Text("¿Seguro que quieres iniciar el viaje?"),
            actions: [
              TextButton(
                child: const Text('Sí'),
                onPressed: () async {
                  //if (preferences.getDeliveryStarted() != 0) {
                    int pk = deliveryResponse.pk;
                    LocationPermission permission;
                    permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied ||
                          permission == LocationPermission.deniedForever) {
                        Navigator.of(ctx).pop();
                        DialogService.mostrarAlert(context: context,
                            title: 'No se puede acceder a tu ubicación',
                            subtitle: 'Es necesario habilitar los permisos de ubicación para la aplicación.');
                        return;
                      }
                    }

                    ///Se obtiene la posición actual de morotizado
                    Position currentPosition = await Geolocator
                        .getCurrentPosition();
                    // print("Posición actual: Lat ${currentPosition
                    //    .latitude} Lng ${currentPosition.longitude}");
                    StartEndTrip startEndTrip = StartEndTrip(
                        state: DeliveryState.Begin,
                        bikerLat: currentPosition.latitude,
                        bikerLng: currentPosition.longitude);
                    // print("Pk: $pk JSON: ${startEndTrip.toJson()}");
                    ClientService.changeDeliveryState(
                        deliveryId: pk, body: startEndTrip.toJson()).then((
                        res) async {
                      if (res.statusCode == 200) {
                        final body = jsonDecode(res.body);
                        if (body['success'] == false) {
                          Navigator.of(ctx).pop();
                          DialogService.mostrarAlert(context: context,
                              title: 'No se pudo iniciar el viaje',
                              subtitle: 'Compruebe los permisos de ubicación en inténtelo nuevamente.');
                          return;
                        }
                        Navigator.of(ctx).pop();

                        ///reenvio de ETA al websocket
                        final tiempoLlegada = body['ETA'];
                        // print("Start trip response: ${res.body}");
                        UpdateEta updateEta = UpdateEta(updateEta: true,
                            pk: pk,
                            eta: tiempoLlegada,
                            lat: currentPosition.latitude,
                            lng: currentPosition.longitude);
                        String username = await StorageService.getUsername();
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
                        // print("Username: $username");
                        // print("Envío ETA al websocket");
                        // print(updateEta.toJson());
                        ClientService.sendEtaToWebsocket(
                            username: username, body: updateEta.toJson());
                        DialogService.mostrarAlert(context: context,
                            title: "Éxito",
                            subtitle: "El viaje se ha iniciado.");
                        preferences.saveDeliveryStarted(pk);
                        setState(() {
                          buttonText = 'Finalizar viaje';
                          buttonIcon = Icons.check;
                          buttonColor = primaryColor;
                        });

                        ///Enviar mensaje por WhatsApp
                        String number = "+51${deliveryResponse.phone}";
                        String message = "¡Hola! ✋\nRastrea tu pedido aquí 👇\n${CommonService.baseUrl}/deliveries/${deliveryResponse.token}\n¡Gracias!";
                        final whatsAppLink = WhatsAppUnilink(
                          phoneNumber: number,
                          text: message,
                        );
                        await launch('$whatsAppLink');

                      } else {
                        Navigator.of(context).pop();
                        DialogService.mostrarAlert(context: context,
                            title: 'Error de conexión con el servidor',
                            subtitle: 'Compruebe su conexión e inténtelo nuevamente.');
                      }
                    });
                  /*} else {
                    Navigator.of(ctx).pop();
                    DialogService.mostrarAlert(context: context,
                        title: 'Ya existe un viaje en curso',
                        subtitle: 'No puede iniciar dos viajes en simultáneo.');
                  }*/
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        }
    );
  }

  void _confirmFinishDelivery(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: Text("¿Seguro que quieres finalizar el viaje?"),
            actions: [
              TextButton(
                child: Text("Sí"),
                onPressed: () {
                  int pk = deliveryResponse.pk;
                  StartEndTrip startEndTrip = StartEndTrip(state: DeliveryState.End);
                  ClientService.completeDelivery(id: pk, body: startEndTrip.toJson()).then((res) async {
                    //TODO: feedback cuando
                    if (res.statusCode == 200) {
                      // print("Pedido marcado como completado");
                      ///funciona pero da exception por alguna razon
                      Navigator.of(context).pop();
                      String number = "+51${deliveryResponse.phone}";
                      String message = "¡Hola de nuevo! ✋\nTu pedido ha llegado a su destino.";
                      final whatsAppLink = WhatsAppUnilink(
                        phoneNumber: number,
                        text: message,
                      );
                      await launch('$whatsAppLink');
                      DialogService.mostrarAlert(context: context, title: "Éxito", subtitle: "El pedido se ha finalizado.", popUntilDeliveriesPage: true);
                      preferences.removeDeliveryStarted();
                    } else {
                      // print("Error en marcar pedido como completado, intentar de nuevo");
                      //TODO: se tiene que meterle dismiss a este dialog
                      Navigator.of(context).pop();
                      DialogService.mostrarAlert(context: context, title: "Ups", subtitle: "Ocurrió un error. Por favor, inténtalo más tarde.");
                      // Navigator.of(ctx).pop();
                    }
                  });
                },
              ),
              TextButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        }
    );
  }



}

