import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geodest/models/delivery.dart';
import 'package:geodest/providers/ui_provider.dart';
import 'package:geodest/services/client_service.dart';
import 'package:geodest/utils/colors.dart';
import 'package:geodest/widgets/speed_dial_button.dart';
import 'package:provider/provider.dart';

import '../services/events_service.dart';

class DeliveriesPage extends StatefulWidget {

  DeliveriesPage();

  @override
  _DeliveriesPageState createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {

  Future<List<Delivery>> obtainDeliveries() async {
    //FIXME: aveces da 401 (porq expira el accessToken creo)
    var res = await ClientService.getDeliveries();

    if (res.statusCode == 200) {
      List<dynamic> buff = jsonDecode(res.body) as List<dynamic>;
      List<Delivery> parsedDeliveries = [];
      buff.forEach((post) {
        parsedDeliveries.add(Delivery.fromJson(post as Map<String, dynamic>));
      });
      print("Deliveries: $parsedDeliveries");
      return parsedDeliveries;
    } else {
      throw "[ERROR] (status code ${res.statusCode}): fetching deliveries";
      //TODO: mostrar dialog indicando el error
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

    // final uiProvider = Provider.of<UiProvider>(context);
    // final currentIndex = uiProvider.selectedMenuOpt;

    //TODO: sale error en cuando se hace un setState dentro de la función build()
    // if (currentIndex == 1) {
    //   print("Current index: $currentIndex");
    //   // obtainDeliveries();
    //   // uiProvider.selectedMenuOpt = 0;
    //   print("Current index: $currentIndex");
    // }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Deliveries"),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: obtainDeliveries(),
        builder: (BuildContext ctx, AsyncSnapshot<List<Delivery>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext ctx, int idx) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.motorcycle),
                    title: Text("${snapshot.data[idx].address}"),
                    // subtitle: Text("${snapshot.data[idx].receiver}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      //TODO: show pedido details
                      print("Show delivery details");
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.only(top: 25.0, left: 30.0, right: 30.0),
              child: Text("Ocurrió un error. Refresca los deliveries."),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              child: LinearProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: SpeedDialButton(),
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