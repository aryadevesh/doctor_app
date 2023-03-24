import 'package:google_maps_flutter/google_maps_flutter.dart';

class userVisitRequestInformation{
  LatLng? originLatLng;
  LatLng? destinationLatLng;

  String? originAddress;
  String? visitRequestId;
  String? userName;
  String? userPhone;

  userVisitRequestInformation({
    this.originLatLng,
    this.destinationLatLng,

    this.originAddress,
    this.visitRequestId,
    this.userName,
    this.userPhone,
  });
}