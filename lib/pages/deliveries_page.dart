import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geodest/models/delivery.dart';
import 'package:geodest/providers/ui_provider.dart';
import 'package:geodest/services/client_service.dart';
import 'package:geodest/utils/colors.dart';
import 'package:geodest/widgets/speed_dial_button.dart';
import 'package:provider/provider.dart';

class DeliveriesPage extends StatefulWidget {

  DeliveriesPage();

  @override
  _DeliveriesPageState createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {

  List<Delivery> deliveries = [];

  void obtainDeliveries() {
    //FIXME: aveces da 401 (porq expira el accessToken creo)
    ClientService.getDeliveries().then((res) {
      if (res.statusCode == 200) {
        List<dynamic> buff = jsonDecode(res.body) as List<dynamic>;
        List<Delivery> parsedDeliveries = [];
        buff.forEach((post) {
          parsedDeliveries.add(Delivery.fromJson(post as Map<String, dynamic>));
        });
        /*print("Deliveries: $parsedDeliveries");
        return parsedDeliveries;*/
        setState(() {
          deliveries = parsedDeliveries;
          print("Deliveries: $deliveries");
        });
      } else {
        print(res.statusCode);
        print("[ERROR]: fetching deliveries");
        //TODO: mostrar dialog indicando el error
      }
    });
  }

  @override
  void initState() {

    //TODO: call this method when refreshing
    obtainDeliveries();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final uiProvider = Provider.of<UiProvider>(context);
    final currentIndex = uiProvider.selectedMenuOpt;

    //TODO: sale error en cuando se hace un setState dentro de la función build()
    if (currentIndex == 1) {
      print("Current index: $currentIndex");
      obtainDeliveries();
      uiProvider.selectedMenuOpt = 0;
      print("Current index: $currentIndex");
      print("Updating deliveries: $deliveries");
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Deliveries"),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: deliveries.length,
        itemBuilder: (BuildContext ctx, int idx) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.motorcycle),
              title: Text("${deliveries[idx].address}"),
              subtitle: Text("${deliveries[idx].receiver} - ${deliveries[idx].phone}"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                //TODO: show pedido details
                print("Show delivery details");
              },
            ),
          );
        },
      ),
      floatingActionButton: SpeedDialButton(),
    );
  }
}