import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery.g.dart';

@JsonSerializable()
class Delivery {
  Delivery({this.address, this.latitude, this.longitude, this.receiver, this.phone, this.token, this.pk});

  final String address;
  final double latitude;
  final double longitude;
  final String receiver;
  final int phone;
  final String token;
  final int pk;

  factory Delivery.fromJson(Map<String, dynamic> json) => _$DeliveryFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryToJson(this);
}