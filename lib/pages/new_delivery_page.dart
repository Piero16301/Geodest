import 'dart:convert';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geodest/models/delivery_request.dart';
import 'package:geodest/services/dialog_service.dart';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import 'package:geodest/services/client_service.dart';
import 'package:geodest/services/events_service.dart';
import 'package:geodest/services/loader_service.dart';
import 'package:geodest/utils/colors.dart';

import 'package:clipboard/clipboard.dart';
import 'package:permission_handler/permission_handler.dart';

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

  List<bool> _isSelected = [true, false];
  List<bool> _isSelectedPhonePill = [true, false];
  int link = 1;
  int address = 0;
  int contacts = 1;

  FocusNode phoneFocus = new FocusNode();
  FocusNode addressFocus = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Nuevo pedido"),
        backgroundColor: primaryColor,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // FIXME: _addressInput y _pillToggle deberían ser un solo stateful widget, esto hace que sea más rápida la aplicación
                  if (_isSelected[address]) _addressInput(link: false, controller: addressController, label: "Dirección del comprador", icon: Icons.home),
                  if (_isSelected[link]) _addressInput(link: true, controller: addressController, label: "Link de Google Maps", icon: Icons.home),
                  _pillAddressToggle(),
                  _clientInput(controller: clientController, label: "Nombre del comprador", icon: Icons.person),
                  // FIXME: _phoneInput y _pillPhoneToggle deberían ser un solo stateful widget, esto hace que sea más rápida la aplicación
                  _phoneInput(controller: phoneController, label: "Celular del comprador", icon: Icons.phone_android, context: context),
                  _pillPhoneToggle(),
                  _createNewDelivery(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillPhoneToggle() {
    return ToggleButtons(
        selectedColor: Colors.green,
        color: Colors.grey,
        fillColor: Colors.lightGreen[100],
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text("Teclado"),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text("Contactos"),
          ),
        ],
        onPressed: (idx) {
          setState(() {
            phoneController.text = '';
            _isSelectedPhonePill[idx] = true;
            _isSelectedPhonePill[1-idx] = false;
            phoneFocus.unfocus();
            if (_isSelectedPhonePill[contacts]) {
              _pickContact();
            }
          });
        },
        isSelected: _isSelectedPhonePill
    );
  }

  Widget _pillAddressToggle() {
    return ToggleButtons(
        selectedColor: Colors.green,
        color: Colors.grey,
        fillColor: Colors.lightGreen[100],
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text("Dirección"),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text("Link"),
          ),
        ],
        onPressed: (idx) {
          setState(() {
            addressController.text = '';
            _isSelected[idx] = true;
            _isSelected[1-idx] = false;
            addressFocus.unfocus();
          });
        },
        isSelected: _isSelected
    );
  }

  Widget _addressInput({bool link, controller, label, icon}) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      height: 80,
      child: TextFormField(
        controller: controller,
        focusNode: addressFocus,
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
          suffixIcon: link ? IconButton(
            icon: Icon(Icons.paste),
            onPressed: _pasteLinkFromClipboard,
          ) : null,
        ),
        onTap: !link ? _displaySuggestions : null,
      ),
    );
  }

  void _pasteLinkFromClipboard() {
    addressFocus.unfocus();
    FlutterClipboard.paste().then(
      (clipboardValue) {
        setState(() {
          addressController.text = clipboardValue;
          print("clipboardValue: $clipboardValue");
        });
      }
    );
  }

  Future<void> _displaySuggestions() async {
    Prediction prediction = await PlacesAutocomplete.show(
      context: context,
      //TODO: mover el apiKey a un lugar seguro
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
      margin: const EdgeInsets.only(top: 30),
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

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    print("permission status: $permission");
    if (permission != PermissionStatus.granted) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  String removeAllSpaces({String fromString, String replaceSpaceBy}) {
    if (fromString == null) {
      return null;
    }

    // This pattern means "at least one space, or more"
    // \\s : space
    // +   : one or more
    final pattern = RegExp('\\s+');
    return fromString.replaceAll(pattern, replaceSpaceBy);
  }

  Future<void> _pickContact() async {
    try {
      final Contact contact = await ContactsService.openDeviceContactPicker(
          iOSLocalizedLabels: true
      );
      setState(() {
        //FIXME: acá hay un problema, un contacto puede tener varios números celulares
        /// por ahora, elegimos el primero pero deberíamos mostrar un dropdown con todas las
        /// opciones
        String phoneNumber = contact.phones.elementAt(0).value;
        if (phoneNumber.substring(0, 3) == "+51") {
          phoneNumber = phoneNumber.substring(3);
        }
        //FIXME: probar
        phoneNumber = removeAllSpaces(fromString: phoneNumber, replaceSpaceBy: '');
        phoneController.text = phoneNumber;
        print("contact: ${contact.phones.elementAt(0).value}");
      });
    } catch (e) {
      print("Error al elegir conatcto: ${e.toString()}");
    }
  }

  Widget _phoneInput({controller, label, icon, @required context}) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      height: 80,
      child: TextFormField(
        controller: controller,
        focusNode: phoneFocus,
        validator: (String value) {
          String tempLabel = label.toString().toLowerCase();
          if (value.isEmpty) {
            return 'Por favor, ingrese el $tempLabel';
          }
          else if (value.length != 9) {
            return 'El $tempLabel debe tener 9 dígitos';
          }
          else if (value[0] != '9') {
            return 'El $tempLabel debe ser un número válido';
          }
          return null;
        },
        onTap: () async {
          if (_isSelectedPhonePill[contacts]) {
            phoneFocus.unfocus();
            PermissionStatus permissionStatus = await _getContactPermission();
            if (permissionStatus == PermissionStatus.granted) {
              _pickContact();
            } else {
              DialogService.complainContactsPermissionDenied(context);
            }
          }
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
      margin: const EdgeInsets.only(top: 50),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          child: const Text(
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
              DeliveryRequest delivery;
              if (_isSelected[link]) {
                delivery = DeliveryRequest(address: '', link: addressController.text, receiver: clientController.text, phone: int.parse(phoneController.text));
              } else {
                delivery = DeliveryRequest(address: addressController.text, link: '', latitude: finalAddress.result.geometry.location.lat, longitude: finalAddress.result.geometry.location.lng, receiver: clientController.text, phone: int.parse(phoneController.text));
              }
              print("Delivery: ${delivery.toJson()}");
              ClientService.postDelivery(
                delivery.toJson()
              ).then((res) {
                print('Code: ${res.statusCode} Body: ${res.body}');
                if (res.statusCode == 200) {
                  final body = jsonDecode(res.body);

                  if (body['success'] == false) {
                    Navigator.of(context).pop();
                    DialogService.mostrarAlert(context: context, title: 'No se pudo guardar el pedido', subtitle: body['message']);
                    addressController.text = '';
                    return;
                  }

                  print("Body del nuevo pedido: $body");
                  EventsService.emitter.emit("refreshDeliveries");
                  Navigator.popUntil(context, (route) => route.settings.name == "deliveries");
                } else {
                  Navigator.of(context).pop();
                  DialogService.mostrarAlert(context: context, title: 'No se pudo guardar el pedido', subtitle: 'Verifica todos los campos e inténtalo nuevamente.');
                }
              });
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    print("disposed NewDeliveryPage");
  }

}

