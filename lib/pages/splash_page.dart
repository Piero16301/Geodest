import 'package:flutter/material.dart';
import 'dart:async';

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
        Navigator.pushNamedAndRemoveUntil(context, 'login', (_) => false);
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
}

