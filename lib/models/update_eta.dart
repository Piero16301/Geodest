class UpdateEta {
  UpdateEta({this.updateEta, this.pk, this.eta, this.lat, this.lng});

  final bool updateEta;
  final int pk;
  final String eta;
  final double lat;
  final double lng;

  UpdateEta.fromJson(Map<String, dynamic> json):
      updateEta = json['update_eta'],
      pk = json['pk'],
      eta = json['eta'],
      lat = json['lat'],
      lng = json['lng'];

  Map<String, dynamic> toJson() {
    return {
      "update_eta": updateEta,
      "pk": pk,
      "eta": eta,
      "lat": lat,
      "lng": lng,
    };
  }
}