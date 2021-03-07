import 'package:flutter/material.dart';
import 'package:geodest/utils/colors.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 3000), () {
      Navigator.pushNamed(context, 'login');
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

