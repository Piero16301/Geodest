import 'package:flutter/material.dart';

import 'package:geodest/utils/colors.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  String _selected = 'Vendedor';
  List <String> _roles = ['Vendedor', 'Motorizado'];

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
                    _textInput(hint: "Confirmar Contraseña", icon: Icons.vpn_key),
                    _textInput(hint: "Nombres", icon: Icons.person),
                    _textInput(hint: "Apellidos", icon: Icons.person),
                    Container(height: 10),
                    _createDropdown(),
                    _textInput(hint: "Usuario del Motorizado", icon: Icons.motorcycle),

                    Container(height: 50),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
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
                            Navigator.pushNamed(context, 'deliveries');
                          },
                        ),
                      ),
                    ),
                    Container(height: 50),
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
      margin: EdgeInsets.only(top: 15),
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

  List<DropdownMenuItem<String>> getOptionsDropdown() {
    List <DropdownMenuItem<String>> lista = [];
    _roles.forEach((role) {
      lista.add(DropdownMenuItem(
        child: Text(role),
        value: role,
      ));
    });
    return lista;
  }

  Widget _createDropdown() {
    return Row(
      children: <Widget>[
        SizedBox(width: 20),
        Icon(Icons.work, color: Colors.grey),
        SizedBox(width: 30),
        Expanded(
          child: DropdownButton(
            value: _selected,
            items: getOptionsDropdown(),
            onChanged: (opt) {
              setState(() {
                _selected = opt;
              });
            },
          ),
        ),
      ],
    );
  }
  
}

