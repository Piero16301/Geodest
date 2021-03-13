class DeliveryResponse {
  DeliveryResponse({this.address, this.latitude, this.longitude, this.receiver, this.phone, this.token, this.pk});

  final String address;
  final String latitude;
  final String longitude;
  final String receiver;
  final String phone;
  final String token;
  final int pk;

  DeliveryResponse.fromJson(Map<String, dynamic> json):
      address = json['address'],
      latitude = json['latitude'],
      longitude = json['longitude'],
      receiver = json['receiver'],
      phone = json['phone'],
      token = json['token'],
      pk = json['pk'];

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "receiver": receiver,
      "phone": phone,
      "token": token,
      "pk": pk,
    };
  }
}