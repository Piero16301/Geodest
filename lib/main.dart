import 'package:flutter/material.dart';

import './pages/deliveries_page.dart';
import './pages/login_page.dart';
import './pages/register_page.dart';
import './pages/splash_page.dart';

void main() {
  runApp(MyApp());
}

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
