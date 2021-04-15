import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:geodest/pages/delivery_details_page.dart';
import 'package:geodest/pages/map_view_page.dart';
import 'package:geodest/services/navigation_service.dart';
import 'package:geodest/services/user_preferences.dart';

import './pages/deliveries_page.dart';
import './pages/login_page.dart';
import './pages/splash_page.dart';
import './pages/new_delivery_page.dart';

void isolate1(String arg) async  {
  Timer.periodic(Duration(seconds:5),(timer)=>print("Timer Running From Isolate 1 every 5 seconds: ${timer.tick}"));
}

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // final preferences = new PreferenciasUsuario();
  // await preferences.initPreferences();
  //
  // final isolate = await FlutterIsolate.spawn(isolate1, "hello");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caudal Service',
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: 'splash',
      routes: {
        'splash'           : (BuildContext context) => SplashPage(),
        'login'            : (BuildContext context) => LoginPage(),
        'deliveries'       : (BuildContext context) => DeliveriesPage(),
        'new_delivery'     : (BuildContext context) => NewDeliveryPage(),
        'delivery_details' : (BuildContext context) => DeliveryDetailsPage(),
        'map_view'         : (BuildContext context) => MapViewPage(),
      },
    );
  }
}
