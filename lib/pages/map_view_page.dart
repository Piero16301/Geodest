import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:geodest/models/delivery_response.dart';
import 'package:geodest/utils/colors.dart';

class MapViewPage extends StatefulWidget {
  @override
  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  @override
  Widget build(BuildContext context) {

    DeliveryResponse deliveryResponse = ModalRoute.of(context).settings.arguments;
    final lat = deliveryResponse.latitude;
    final lng = deliveryResponse.longitude;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Ubicación del destino"),
        backgroundColor: primaryColor,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&markers=color:red%7C$lat,$lng&zoom=16&size=2000x2000&key=AIzaSyDszjoQPzSF_ddL2pXODJy2nwZoT2IfYGI'),
        ),
      ),
      floatingActionButton: _viewOnMaps(lat: lat, lng: lng),
    );
  }

  Widget _viewOnMaps({lat, lng}) {
    return FloatingActionButton.extended(
      label: Text('Ver en Maps'),
      icon: Icon(Icons.map),
      backgroundColor: primaryColor,
      onPressed: () async {
        print("Abriendo Google Maps");
        openMaps(latitude: lat, longitude: lng);
      },
    );
  }

  Future<void> openMaps({latitude, longitude}) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      _mostrarAlert(context: context, title: "No se ha encontrado Google Maps", content: "Instala Google Maps en tu teléfono y vuelve a intentarlo");
    }
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

