import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:system_settings/system_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

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

  static complainContactsPermissionDenied(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("¡Necesitamos tu permiso!"),
          content: const Text("Para que puedas elegir el número del cliente más fácilmente. Por favor, anda a Ajustes y cambia los permisos."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  SystemSettings.app();
                },
                child: const Text("OK")
            )
          ],
          elevation: 30.0,
        );
      },
      barrierDismissible: false,
    );
  }

  static void showCreditInfoDialog({@required BuildContext context, @required int remainingCredits}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: const Center(
              child: Text("Mis Créditos"),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Créditos disponibles: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '$remainingCredits\n',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ]
                    ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Si quieres aumentar tus créditos, escríbenos por ",
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "whatsapp.",
                        style: const TextStyle(
                          color: Colors.green
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            //TODO: llevar a whatsapp con mensaje predeterminado
                            String number = "+51981344873";
                            String message = "¡Hola!\nQuisiera conseguir más créditos en la plataforma de Caudal.";
                            final whatsAppLink = WhatsAppUnilink(
                              phoneNumber: number,
                              text: message,
                            );
                            await launch('$whatsAppLink');
                          }
                      ),
                    ]
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

}