// import 'dart:async';

import 'package:flutter/material.dart';
/*import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';*/

import 'package:geodest/utils/colors.dart';

class NewDeliveryPage extends StatefulWidget {
  @override
  _NewDeliveryPageState createState() => _NewDeliveryPageState();
}

class _NewDeliveryPageState extends State<NewDeliveryPage> {
  final addressController = TextEditingController();
  final clientController = TextEditingController();
  final phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //final _apiKey = "AIzaSyBVwLl1VyKZ5G5gnZOpk78JX2udK8VpvXE";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Nuevo pedido"),
        backgroundColor: primaryColor,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _addressInput(controller: addressController, label: "Dirección del comprador", icon: Icons.home),
                  _textInput(controller: clientController, label: "Nombre del comprador", icon: Icons.person),
                  _textInput(controller: phoneController, label: "Celular del comprador", icon: Icons.phone_android),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressInput({controller, label, icon}) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 60,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value.isEmpty) {
            String tempLabel = label.toString().toLowerCase();
            return 'Por favor, ingrese su $tempLabel';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          labelText: label,
          icon: Icon(icon),
        ),
        onTap: () /*async*/ {
          /*Prediction prediction = await PlacesAutocomplete.show(
            context: context,
            apiKey: _apiKey,
            onError: onError,
            language: "es",
            components: [Component(Component.country, "pe")],
          );
          displayPrediction(prediction, _scaffoldKey.currentState);*/
        },
      ),
    );
  }

  /*void onError(PlacesAutocompleteResponse response) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<Null> displayPrediction(Prediction prediction, ScaffoldState scaffoldState) async {
    if (prediction != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: _apiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse _detail = await _places.getDetailsByPlaceId(prediction.placeId);
      final address = _detail.result.formattedAddress;
      final lat = _detail.result.geometry.location.lat;
      final lng = _detail.result.geometry.location.lng;
      print("Address: $address Latitud: $lat Longitud: $lng");
      setState(() {
        addressController.text = address;
      });
    }
  }*/

  Widget _textInput({controller, label, icon}) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 60,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value.isEmpty) {
            String tempLabel = label.toString().toLowerCase();
            return 'Por favor, ingrese su $tempLabel';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          labelText: label,
          icon: Icon(icon),
        ),
      ),
    );
  }

}

