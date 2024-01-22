
import 'package:doctor_app/assistants/request_assistant.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import '../models/treatments_history_model.dart';




class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async
  {

    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress="";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred, Failed. No Response.")
    {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress ;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);

    }

    return humanReadableAddress;
  }
  // static void readCurrentOnlineUserInfo() async
  // {
  //   currentFirebaseUser = fAuth.currentUser;
  //
  //   DatabaseReference userRef = FirebaseDatabase.instance
  //       .ref()
  //       .child("users").child(currentFirebaseUser!.uid);
  //
  //   userRef.once().then((snap)
  //   {
  //     if(snap.snapshot.value != null)
  //     {
  //       userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
  //     }
  //   }
  //   );
  // }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async
  {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Error Occurred, Failed. No Response.")
    {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static resumeLiveLocationUpdates(){
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid,
        doctorCurrentPosition!.latitude,
        doctorCurrentPosition!.longitude
    );
  }

  static void readTreatmentsKeysForOnlineDoctor(context)
  {
    FirebaseDatabase.instance.ref()
        .child("All visit Requests")
        .orderByChild("doctorId")
        .equalTo(fAuth.currentUser!.uid)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        Map keysTreatmentsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTreatmentsCounter = keysTreatmentsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTreatmentsCounter(overAllTreatmentsCounter);

        //share trips keys with Provider
        List<String> treatmentsKeysList = [];
        keysTreatmentsId.forEach((key, value)
        {
          treatmentsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTreatmentsKeys(treatmentsKeysList);
        print(treatmentsKeysList);
        //get treatments keys data - read treatments complete information
        readTreatmentsHistoryInformation(context);
      }
    });
  }

  static void readTreatmentsHistoryInformation(context)
  {
    var treatmentsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTreatmentsKeysList;

    for(String eachKey in treatmentsAllKeys)
    {
      FirebaseDatabase.instance.ref()
          .child("All visit Requests")
          .child(eachKey)
          .once()
          .then((snap)
      {
        var eachTreatmentHistory = TreatmentsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"] == "ended")
        {
          //update-add each history to OverAllTreatments History Data List
          Provider.of<AppInfo>(context, listen: false).updateOverAllTreatmentsHistoryInformation(eachTreatmentHistory);
          print(eachTreatmentHistory);
        }
      });
    }
  }

  //readDriverEarnings
  static void readDoctorEarnings(context)
  {
    FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(fAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        String doctorEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDoctorTotalEarnings(doctorEarnings);
        print(doctorEarnings);
      }
    });

    readTreatmentsKeysForOnlineDoctor(context);
  }

  static void readDoctorRatings(context){
    FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(fAuth.currentUser!.uid)
        .child("ratings")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        String doctorRatings= snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDoctorRatings(doctorRatings);
        print(doctorRatings);
      }
    });
  }

  // static void checkConnectivity(BuildContext context) async{
  //   var connectionResult = await Connectivity().checkConnectivity();
  //
  //   if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi){
  //     if(!context.mounted) return;
  //     displaySnackBar("Internet is on Holiday :/", context);
  //
  //   }
  // }
  // static void displaySnackBar(String messageText, BuildContext context){
  //   var snackBar = SnackBar(content: Text(messageText));
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

}