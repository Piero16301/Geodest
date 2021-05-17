import 'dart:async';

import 'package:flutter/material.dart';

import 'package:geodest/services/storage_service.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 3000), () async {
      ///Se verifica si se tiene un Access Token guardado
      ///Si es así, redirige a deliveries, si no al login
      if (await StorageService.getAccessToken() != "") {
        //TODO: Hay un error cuando se entra de frente a deliveries, porque no hay headers para hacer el GET
        Navigator.pushNamedAndRemoveUntil(context, 'deliveries', (_) => false);
      } else {
        showProminentDisclosure(context);
        // Navigator.pushNamedAndRemoveUntil(context, 'login', (_) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          /*gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
          ),*/
          color: Colors.white,
        ),
        child: Center(
          child: Image.asset("assets/logo_green.png", height: 200),
        ),
      ),
    );
  }

  static void showProminentDisclosure(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text("Política de uso de ubicación"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Esta aplicación recopila datos de ubicación para que el cliente pueda visualizar la ubicación de su pedido en tiempo real y poder calcular el tiempo estimado de llegada del pedido, incluso cuando la aplicación esté cerrada o no está en uso."),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, 'login', (_) => false);
              },
            ),
          ],
        );
      }
    );
  }
}

