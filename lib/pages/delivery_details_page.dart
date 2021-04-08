import 'dart:convert';

import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:geodest/enums/delivery_state.dart';

import 'package:geodest/models/delivery_response.dart';
import 'package:geodest/models/start_end_trip.dart';
import 'package:geodest/services/client_service.dart';
import 'package:geodest/services/dialog_service.dart';
import 'package:geodest/services/location_service.dart';
import 'package:geodest/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class DeliveryDetailsPage extends StatefulWidget {
  @override
  _DeliveryDetailsPageState createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {

  DeliveryResponse deliveryResponse;
  String buttonText = 'Iniciar viaje';
  IconData buttonIcon = Icons.flag;
  Color buttonColor = ternaryColor;

  @override
  Widget build(BuildContext context) {

    deliveryResponse = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Detalles del pedido"),
        backgroundColor: primaryColor,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: ListView(
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
                  title: Text(data),
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
                Center(
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
        print("Finalizar delivery");
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
            title: Text("¿Seguro que quieres iniciar el viaje?"),
            actions: [
              TextButton(
                child: Text('Sí'),
                onPressed: () {
                  int pk = deliveryResponse.pk;
                  //TODO: Obtener la ubicación del repartidor para armar el JSON
                  StartEndTrip startEndTrip = StartEndTrip(state: DeliveryState.Begin, bikerLat: -12.130817, bikerLng: -77.029850);
                  print("Pk: $pk JSON: ${startEndTrip.toJson()}");
                  ClientService.changeDeliveryState(deliveryId: pk, body: startEndTrip.toJson()).then((res) async {
                    if (res.statusCode == 200) {
                      final body = jsonDecode(res.body);
                      if (body['success'] == false) {
                        Navigator.of(ctx).pop();
                        DialogService.mostrarAlert(context: context, title: 'No se pudo iniciar el viaje', subtitle: 'Compruebe los permisos de ubicación en inténtelo nuevamente.');
                        return;
                      }
                      Navigator.of(ctx).pop();
                      //TODO: esto reenviar al websocket
                      final tiempoLlegada = body['ETA'];
                      print("Start trip response: ${res.body}");
                    } else {
                      Navigator.of(context).pop();
                      DialogService.mostrarAlert(context: context, title: 'No se pudo iniciar el viaje', subtitle: 'Compruebe los permisos de ubicación en inténtelo nuevamente.');
                    }
                  });
                  setState(() {
                    buttonText = 'Finalizar viaje';
                    buttonIcon = Icons.check;
                    buttonColor = primaryColor;
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
                  ClientService.completeDelivery(pk).then((res) async {
                    //TODO: feedback cuando
                    if (res.statusCode == 200) {
                      print("Pedido marcado como completado");
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
                    } else {
                      print("Error en marcar pedido como completado, intentar de nuevo");
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

