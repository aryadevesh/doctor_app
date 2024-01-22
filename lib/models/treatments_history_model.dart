import 'package:firebase_database/firebase_database.dart';

class TreatmentsHistoryModel
{
  String? time;
  String? originAddress;
  String? status;
  String? base_price;
  String? userPhone;
  String? userName;

  TreatmentsHistoryModel({
    this.time,
    this.originAddress,
    this.status,
    this.userPhone,
    this.userName,
    this.base_price,
  });

  TreatmentsHistoryModel.fromSnapshot(DataSnapshot dataSnapshot)
  {
    time = (dataSnapshot.value as Map)["time"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    //destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
    status = (dataSnapshot.value as Map)["status"];
    base_price = (dataSnapshot.value as Map)["base_price"];
    userPhone = (dataSnapshot.value as Map)["userPhone"];
    userName = (dataSnapshot.value as Map)["userName"];
  }
}