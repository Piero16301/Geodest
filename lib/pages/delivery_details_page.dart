import 'package:flutter/material.dart';

import 'package:geodest/models/delivery_response.dart';
import 'package:geodest/services/client_service.dart';
import 'package:geodest/services/dialog_service.dart';
import 'package:geodest/utils/colors.dart';

class DeliveryDetailsPage extends StatefulWidget {
  @override
  _DeliveryDetailsPageState createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {

  DeliveryResponse deliveryResponse;

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
                    image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&markers=color:red%7C$lat,$lng&zoom=16&size=2000x2000&key=AIzaSyCw0h5QGQWJSHiY4L289Og34FRlWdltZlo'),
                    placeholder: AssetImage('assets/google-maps-loading.gif'),
                    fadeInDuration: Duration(milliseconds: 1000),
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
      label: Text('Finalizar'),
      icon: Icon(Icons.check),
      backgroundColor: primaryColor,
      onPressed: () {
        print("Finalizar delivery");
        _confirmFinishDelivery(context);
      },
    );
  }

  void _confirmFinishDelivery(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: Text("Marcar pedido como finalizado?"),
            actions: [
              TextButton(
                child: Text("Sí"),
                onPressed: () {
                  int pk = deliveryResponse.pk;
                  ClientService.completeDelivery(pk).then((res) {
                    //TODO: feedback cuando
                    if (res.statusCode == 200) {
                      print("Pedido marcado como completado");
                      ///funciona pero da exception por alguna razon
                      DialogService.mostrarAlert(context: context, title: "Éxito", subtitle: "Pedido marcado como completado", popUntilDeliveriesPage: true);
                    } else {
                      print("Error en marcar pedido como completado, intentar de nuevo");
                      //TODO: se tiene que meterle dismiss a este dialog
                      DialogService.mostrarAlert(context: context, title: "Oops", subtitle: "Ocurrió un error. Inténtalo de nuevo");
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

