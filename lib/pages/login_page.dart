import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geodest/utils/colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                    _textInput(hint: "Correo Electrónico", icon: Icons.email),
                    _textInput(hint: "Contraseña", icon: Icons.vpn_key),
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
                            Navigator.pushNamed(context, 'deliveries');
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
                              Navigator.pushNamed(context, 'register');
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

