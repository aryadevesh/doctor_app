import 'package:google_maps_flutter/google_maps_flutter.dart';

class userVisitRequestInformation{
  LatLng? originLatLng;
  String? originAddress;
  String? visitRequestId;
  String? userName;
  String? userPhone;

  userVisitRequestInformation({
    this.originLatLng,
    this.originAddress,
    this.visitRequestId,
    this.userName,
    this.userPhone,
  });
}