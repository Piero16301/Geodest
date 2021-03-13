import 'dart:ffi';

class DeliveryRequest {
  DeliveryRequest({this.address, this.latitude, this.longitude, this.receiver, this.phone});

  final String address;
  final double latitude;
  final double longitude;
  final String receiver;
  final int phone;

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "receiver": receiver,
      "phone": phone,
    };
  }
}