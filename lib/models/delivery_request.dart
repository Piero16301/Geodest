class DeliveryRequest {
  DeliveryRequest(
      {this.address,
      this.link,
      this.latitude,
      this.longitude,
      this.receiver,
      this.brand,
      this.phone});

  final String address;
  final String link;
  final double latitude;
  final double longitude;
  final String receiver;
  final String brand;
  final int phone;

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "link": link,
      "latitude": latitude,
      "longitude": longitude,
      "receiver": receiver,
      "brand": brand,
      "phone": phone,
    };
  }
}
