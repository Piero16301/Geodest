import 'package:flutter/material.dart';
import 'package:geodest/pages/deliveries_page.dart';
import 'package:geodest/pages/login_page.dart';
import 'package:geodest/pages/register_page.dart';
import 'package:geodest/pages/splash_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geodest',
      initialRoute: 'splash',
      routes: {
        'splash'     : (BuildContext context) => SplashPage(),
        'login'      : (BuildContext context) => LoginPage(),
        'register'   : (BuildContext context) => RegisterPage(),
        'deliveries' : (BuildContext context) => DeliveriesPage(),
      },
    );
  }
}
