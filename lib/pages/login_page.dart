import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:geodest/models/user.dart';
import 'package:geodest/services/common_service.dart';
import 'package:geodest/services/dialog_service.dart';
import 'package:geodest/services/storage_service.dart';
import 'package:geodest/utils/colors.dart';

import '../services/client_service.dart';
import '../services/loader_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  ///Validación del form
  final _formKey = GlobalKey<FormState>();

  bool _isHidden = true;

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
                margin: EdgeInsets.only(left: 20, right: 20),
                child: ListView(
                  //mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _textEmailInput(hint: "Ingrese su correo electrónico", label: "Correo electrónico", icon: Icons.email, controller: emailController),
                          _textPasswordInput(hint: "Ingrese su contraseña", label: "Contraseña", icon: Icons.vpn_key, controller: passwordController),
                          Container(height: 50),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                child: Text(
                                  "INICIAR SESIÓN",
                                  style: TextStyle(
                                    fontSize: 15,
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
                                  if (_formKey.currentState.validate()) {
                                    LoaderService.setIsLoading(message: "Iniciando sesión...", waiting: true, context: context);

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
                                        // print("Body del login: $body");
                                        ///save Access and Refresh token
                                        StorageService.saveAccessToken(body['access']).then((_) {
                                          StorageService.saveRefreshToken(body['refresh']).then((_) {
                                            LoaderService.setIsLoading(waiting: false);
                                            ///pushNamedAndRemoveUntil para borrar el navigator stack y no poder volver
                                            ///a la vista del login
                                            Navigator.pushNamedAndRemoveUntil(context, 'deliveries', (_) => false);
                                          });
                                        });
                                      } else {
                                        ///dialog diciendo que las credenciales son incorrectas
                                        Navigator.of(context).pop();
                                        DialogService.mostrarAlert(context: context, title: "Credenciales incorrectas", subtitle: "Verifica tu correo y/o contraseña e inténtalo de nuevo");
                                      }
                                    });
                                  }
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
                                      fontSize: 15,
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
                          Container(height: 50),
                        ],
                      ),
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
      url: "${CommonService.baseUrl}/accounts/signup/",
      customTabsOptions: CustomTabsOptions(
        toolbarColor: primaryColor,
        showTitle: true,
      ),
    );
  }

  Widget _textEmailInput({controller, hint, label, icon}) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 70,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value.isEmpty) {
            String tempLabel = label.toString().toLowerCase();
            return 'Por favor, ingrese su $tempLabel';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          labelText: label,
          icon: Icon(icon),
        ),
      ),
    );
  }


  Widget _textPasswordInput({controller, hint, label, icon}) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: 70,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value.isEmpty) {
            String tempLabel = label.toString().toLowerCase();
            return 'Por favor, ingrese su $tempLabel';
          }
          return null;
        },
        obscureText: _isHidden,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          labelText: label,
          icon: Icon(icon),
          suffix: InkWell(
            onTap: _togglePasswordView,
            child: Icon(
              _isHidden ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
      ),
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}

