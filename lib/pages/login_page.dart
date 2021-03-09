import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:geodest/models/user.dart';
import 'package:geodest/services/storage_service.dart';
import 'package:geodest/utils/colors.dart';
import '../services/client_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //TODO: validación del form

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  end: Alignment.topCenter,
                  begin: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
              ),
              child: Center(
                child: Image.asset("assets/logo_white.png", height: 150),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: ListView(
                  //mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _textInput(hint: "Correo Electrónico", icon: Icons.email, controller: emailController),
                    _textInput(hint: "Contraseña", icon: Icons.vpn_key, controller: passwordController),
                    Container(height: 50),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          child: Text(
                            "INICIAR SESIÓN",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: primaryColor,
                            onPrimary: Colors.white,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                          ),
                          onPressed: () {

                            setIsLoading(waiting: true, context: context);

                            ///lo de abajo es para debuggear
                            // Future.delayed(Duration(seconds: 5)).then((_) {
                            //   setIsLoading(waiting: false, context: context);
                            // });

                            User user = User(email: emailController.text, password: passwordController.text);

                            ClientService.login(
                              user.toJson()
                            ).then((res) {
                              if (res.statusCode == 200) {
                                final body = jsonDecode(res.body);
                                print("body del login: $body");
                                //TODO: save Access and Refresh token
                                StorageService.saveAccessToken(body['access']).then((_) {
                                  StorageService.saveRefreshToken(body['refresh']).then((_) {
                                    setIsLoading(waiting: false, context: context);
                                    Navigator.pushNamed(context, 'deliveries');
                                  });
                                });
                              } else {
                                //TODO: dialog diciendo que las credenciales son incorrectas
                              }
                            });

                          },
                        ),
                      ),
                    ),
                    Container(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "¿Aún no tienes cuenta?",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          //width: MediaQuery.of(context).size.width,
                          height: 40,
                          child: ElevatedButton(
                            child: Text(
                              "REGISTRARSE",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: primaryColor,
                              onPrimary: Colors.white,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                            ),
                            onPressed: () {
                              //Navigator.pushNamed(context, 'register');
                              openRegisterTab();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  openRegisterTab() async {
    await FlutterWebBrowser.openWebPage(
      url: "https://geosend.herokuapp.com/accounts/signup/",
      customTabsOptions: CustomTabsOptions(
        toolbarColor: primaryColor,
        showTitle: true,
      ),
    );
  }

  void setIsLoading({bool waiting, BuildContext context}) {
    if (waiting) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Iniciando sesión...'),
              content: const CircularProgressIndicator(),
              elevation: 30.0,
            );
          },
          barrierDismissible: true, //FIXME: cambiar a false
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _textInput({controller, hint, icon}) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

}

