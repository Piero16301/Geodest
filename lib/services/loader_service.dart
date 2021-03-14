import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoaderService {

  static BuildContext _buildContext;

  static void setIsLoading({bool waiting, BuildContext context, String message = ''}) {
    if (waiting) {
      _buildContext = context;
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(message),
            content: const LinearProgressIndicator(),
            elevation: 30.0,
          );
        },
        barrierDismissible: false,
      );
    } else {
      //TODO: va a dar error si se llaman dos veces seguidas a
      // setIsLoading(false)
      Navigator.of(_buildContext).pop();
    }
  }

}