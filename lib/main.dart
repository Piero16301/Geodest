import 'package:flutter/material.dart';
import 'package:geodest/pages/delivery_details_page.dart';
import 'package:geodest/pages/map_view_page.dart';
import 'package:geodest/services/navigation_service.dart';

import './pages/deliveries_page.dart';
import './pages/login_page.dart';
import './pages/splash_page.dart';
import './pages/new_delivery_page.dart';

void main() {
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
