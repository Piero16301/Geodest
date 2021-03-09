import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geodest/models/delivery.dart';
import 'package:geodest/services/client_service.dart';
import 'package:geodest/utils/colors.dart';
import 'package:geodest/widgets/speed_dial_button.dart';

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
        setState(() {
          deliveries = parsedDeliveries;
          print("deliveries: $deliveries");
        });
      } else {
        print(res.statusCode);
        print("[ERROR]: fetching deliveries");
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Deliveries"),
        backgroundColor: primaryColor,
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
              },
            ),
          );
        },
      ),
      floatingActionButton: SpeedDialButton(),
    );
  }
}