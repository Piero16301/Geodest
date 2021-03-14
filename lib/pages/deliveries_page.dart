import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:geodest/models/delivery_response.dart';
import 'package:geodest/services/client_service.dart';
import 'package:geodest/utils/colors.dart';
import 'package:geodest/widgets/speed_dial_button.dart';

import '../services/events_service.dart';

class DeliveriesPage extends StatefulWidget {
  DeliveriesPage();

  @override
  _DeliveriesPageState createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {

  Future<List<DeliveryResponse>> obtainDeliveries() async {
    var res = await ClientService.getDeliveries();

    if (res.statusCode == 200) {
      List<dynamic> buff = jsonDecode(res.body) as List<dynamic>;
      List<DeliveryResponse> parsedDeliveries = [];
      buff.forEach((post) {
        parsedDeliveries.add(DeliveryResponse.fromJson(post as Map<String, dynamic>));
      });
      print("Deliveries: $parsedDeliveries");
      return parsedDeliveries;
    } else {
      throw "[ERROR] (status code ${res.statusCode}): fetching deliveries";
    }
  }

  @override
  void initState() {
    EventsService.emitter.on("refreshDeliveries", context, (ev, context) {
      print("refresco de deliveries");
      if (this.mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Pedidos"),
        backgroundColor: primaryColor,
        ///Para ocultar el botón atrás del AppBar
        automaticallyImplyLeading: false,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: FutureBuilder(
          future: obtainDeliveries(),
          builder: (BuildContext ctx, AsyncSnapshot<List<DeliveryResponse>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext ctx, int idx) {
                  return _deliveryCard(snapshot: snapshot, idx: idx);
                },
              );
            } else if (snapshot.hasError) {
              //TODO: retry request
              return const Padding(
                padding: EdgeInsets.only(top: 25.0, left: 30.0, right: 30.0),
                child: Text(
                    "Ocurrió un error. Actualiza nuevamente los pedidos.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                child: LinearProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: SpeedDialButton(),
    );
  }

  Widget _deliveryCard({snapshot, idx}) {
    // print("Snapshot: ${snapshot.data[idx].toJson()} Idx: $idx");
    return Column(
      children: [
        Container(height: 10),
        Container(
          //margin: EdgeInsets.symmetric(horizontal: 10),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.motorcycle),
                  title: Text("${snapshot.data[idx].receiver}"),
                  subtitle: Text("${snapshot.data[idx].address}"),
                  // trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    //TODO: show pedido details
                    Navigator.pushNamed(context, 'delivery_details', arguments: snapshot.data[idx]).then((_) {
                      setState(() {
                        print("refreshing deliveries");
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    EventsService.emitter.removeListener("refreshDeliveries", (a, b) {
      print("unsubscribing from event emitter");
    });
  }

}