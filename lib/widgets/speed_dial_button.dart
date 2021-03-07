import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geodest/utils/colors.dart';

class SpeedDialButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      marginEnd: 20,
      marginBottom: 20,
      icon: Icons.add,
      activeIcon: Icons.remove,
      buttonSize: 60,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 5,
      shape: CircleBorder(),
      children: [
        _dialChild(context: context, icon: Icons.location_on, color: Colors.red, label: "Compartir Ubicación", route: 'login'),
        _dialChild(context: context, icon: Icons.update, color: Colors.blue, label: "Actualizar pedidos", route: 'splash'),
        _dialChild(context: context, icon: Icons.add, color: Colors.green, label: "Añadir Envío", route: 'login'),
      ],
    );
  }

  SpeedDialChild _dialChild({context, icon, color, label, route}) {
    return SpeedDialChild(
      child: Icon(icon),
      backgroundColor: color,
      foregroundColor: Colors.white,
      //labelBackgroundColor: Color(0xffF9D342),
      labelBackgroundColor: color,
      label: label,
      labelStyle: TextStyle(
        fontSize: 15,
        //color: Color(0xff292826),
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

}

