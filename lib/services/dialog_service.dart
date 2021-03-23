import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogService {

  static void mostrarAlert({@required BuildContext context, @required String title, String subtitle = "", bool popUntilDeliveriesPage = false}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(subtitle),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  if (popUntilDeliveriesPage) {
                    Navigator.popUntil(context, (route) => route.settings.name == "deliveries");
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        }
    );
  }

}