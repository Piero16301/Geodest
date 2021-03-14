import 'package:flutter/material.dart';

import 'package:geodest/models/delivery_response.dart';
import 'package:geodest/utils/colors.dart';

class DeliveryDetailsPage extends StatefulWidget {
  @override
  _DeliveryDetailsPageState createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  @override
  Widget build(BuildContext context) {

    final DeliveryResponse deliveryResponse = ModalRoute.of(context).settings.arguments;

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
                Center(
                  child: FadeInImage(
                    image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&markers=color:red%7C$lat,$lng&zoom=16&size=1000x1000&key=AIzaSyCw0h5QGQWJSHiY4L289Og34FRlWdltZlo'),
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
      onPressed: () {},
    );
  }

}

