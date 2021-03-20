import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geodest/models/delivery_request.dart';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import 'package:geodest/services/client_service.dart';
import 'package:geodest/services/events_service.dart';
import 'package:geodest/services/loader_service.dart';
import 'package:geodest/utils/colors.dart';

class NewDeliveryPage extends StatefulWidget {
  @override
  _NewDeliveryPageState createState() => _NewDeliveryPageState();
}

class _NewDeliveryPageState extends State<NewDeliveryPage> {
  final addressController = TextEditingController();
  final clientController = TextEditingController();
  final phoneController = TextEditingController();

  PlacesDetailsResponse finalAddress;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
                  _clientInput(controller: clientController, label: "Nombre del comprador", icon: Icons.person),
                  _phoneInput(controller: phoneController, label: "Celular del comprador", icon: Icons.phone_android),
                  _createNewDelivery(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Address> searchAddress() async {
    try {
      List<Address> results = await Geocoder.local.findAddressesFromQuery(addressController.text);
      Address bestResult = results.first;
      print("Result: ${bestResult.toMap()}");
      return bestResult;
    } catch(e) {
      print("Error occured: $e");
      return null;
    }
  }

  Widget _addressInput({controller, label, icon}) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 80,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value.isEmpty) {
            String tempLabel = label.toString().toLowerCase();
            return 'Por favor, ingrese la $tempLabel';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          labelText: label,
          icon: Icon(icon),
          /*suffix: InkWell(
            onTap: () async {
              Address result = await searchAddress();
              if (result != null) {
                setState(() {
                  addressController.text = result.addressLine;
                  finalAddress = result;
                });
              } else {
                ///mostrar alert que no existe la dirección
                _mostrarAlert(context: context, title: 'Dirección incorrecta', content: 'La dirección ingresada no ha sido encontrada, verifica los datos');
              }
            },
            child: Icon(Icons.search),
          ),*/
        ),
        onTap: _displaySuggestions,
      ),
    );
  }

  Future<void> _displaySuggestions() async {
    Prediction prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: 'AIzaSyDszjoQPzSF_ddL2pXODJy2nwZoT2IfYGI',
      mode: Mode.overlay,
      language: "es",
      components: [Component(Component.country, "pe")],
    );
    if (prediction != null) {
      _setNewAddress(prediction);
    }
  }

  Future<Null> _setNewAddress(Prediction prediction) async {
    GoogleMapsPlaces googleMapsPlaces = GoogleMapsPlaces(
      apiKey: 'AIzaSyDszjoQPzSF_ddL2pXODJy2nwZoT2IfYGI',
      apiHeaders: await GoogleApiHeaders().getHeaders(),
    );

    PlacesDetailsResponse placesDetailsResponse = await googleMapsPlaces.getDetailsByPlaceId(prediction.placeId);
    setState(() {
      addressController.text = placesDetailsResponse.result.formattedAddress;
      finalAddress = placesDetailsResponse;
    });
  }

  bool _isNumeric(String s) {
    try{
      var value = double.parse(s);
      print(value);
    } on FormatException {
      return false;
    }
    return true;
  }

  bool _checkString(String input) {
    bool result = true;
    input.runes.forEach((int rune) {
      var character = new String.fromCharCode(rune);
      if (_isNumeric(character)) {
        result = false;
      }
    });
    return result;
  }

  Widget _clientInput({controller, label, icon}) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 80,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value.isEmpty) {
            String tempLabel = label.toString().toLowerCase();
            return 'Por favor, ingrese el $tempLabel';
          }
          else if (!_checkString(value)) {
            String tempLabel = label.toString().toLowerCase();
            return 'El $tempLabel solo debe contener letras';
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

  Widget _phoneInput({controller, label, icon}) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 80,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value.isEmpty) {
            String tempLabel = label.toString().toLowerCase();
            return 'Por favor, ingrese el $tempLabel';
          }
          else if (value.length != 9) {
            String tempLabel = label.toString().toLowerCase();
            return 'El $tempLabel debe tener 9 dígitos';
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
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly
        ],
      ),
    );
  }

  Widget _createNewDelivery() {
    return Container(
      margin: EdgeInsets.only(top: 50),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          child: Text(
            "REGISTRAR PEDIDO",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: primaryColor,
            onPrimary: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
          ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              LoaderService.setIsLoading(message: "Guardando pedido...", waiting: true, context: context);
              DeliveryRequest delivery = DeliveryRequest(address: addressController.text, latitude: finalAddress.result.geometry.location.lat, longitude: finalAddress.result.geometry.location.lng, receiver: clientController.text, phone: int.parse(phoneController.text));
              print("Delivery: ${delivery.toJson()}");
              ClientService.postDelivery(
                delivery.toJson()
              ).then((res) {
                print('Code: ${res.statusCode} Body: ${res.body}');
                if (res.statusCode == 200) {
                  final body = jsonDecode(res.body);
                  print("Body del nuevo pedido: $body");
                  EventsService.emitter.emit("refreshDeliveries");
                  Navigator.popUntil(context, (route) => route.settings.name == "deliveries");
                } else {
                  Navigator.of(context).pop();
                  _mostrarAlert(context: context, title: 'No se pudo guardar el pedido', content: 'Verifica todos los campos e inténtalo nuevamente');
                }
              });
            }
          },
        ),
      ),
    );
  }

  void _mostrarAlert({context, title, content}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(content),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        }
    );
  }

}

