import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';

import 'package:geodest/utils/colors.dart';

class NewDeliveryPage extends StatefulWidget {
  @override
  _NewDeliveryPageState createState() => _NewDeliveryPageState();
}

class _NewDeliveryPageState extends State<NewDeliveryPage> {
  final addressController = TextEditingController();
  final clientController = TextEditingController();
  final phoneController = TextEditingController();

  Address finalAddress = Address();

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
                  _textInput(controller: clientController, label: "Nombre del comprador", icon: Icons.person),
                  _textInput(controller: phoneController, label: "Celular del comprador", icon: Icons.phone_android),
                  _newDeliveryButton(),
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
          suffix: InkWell(
            onTap: () async {
              Address result = await searchAddress();
              if (result != null) {
                setState(() {
                  addressController.text = result.addressLine;
                  finalAddress = result;
                });
              } else {
                //TODO: mostrar alert que no existe la dirección

              }
            },
            child: Icon(Icons.search),
          ),
        ),
      ),
    );
  }

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

  Widget _newDeliveryButton() {
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

          },
        ),
      ),
    );
  }

}

