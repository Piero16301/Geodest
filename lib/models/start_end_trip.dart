class StartEndTrip {
  StartEndTrip({this.state, this.bikerLat, this.bikerLng});

  final int state;
  final double bikerLat;
  final double bikerLng;

  StartEndTrip.fromJson(Map<String, dynamic> json):
      state = json['state'],
      bikerLat = json['biker_lat'],
      bikerLng = json['biker_lng'];

  Map<String, dynamic> toJson() {
    return {
      "state": state,
      "biker_lat": bikerLat,
      "biker_lng": bikerLng,
    };
  }
}