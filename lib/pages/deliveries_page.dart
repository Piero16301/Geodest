import 'package:flutter/material.dart';
import 'package:geodest/widgets/speed_dial_button.dart';

class DeliveriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Deliveries"),
      ),
      floatingActionButton: SpeedDialButton(),
    );
  }
}

