import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {

  static final PreferenciasUsuario _instancia = new PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  SharedPreferences _preferences;

  initPreferences() async {
    this._preferences = await SharedPreferences.getInstance();
  }

  int getDeliveryStarted() {
    return _preferences.getInt('deliveryStarted') ?? 0;
  }

  void saveDeliveryStarted(int deliveryId) {
    _preferences.setInt('deliveryStarted', deliveryId);
  }

  void removeDeliveryStarted() {
    _preferences.remove('deliveryStarted');
  }

}