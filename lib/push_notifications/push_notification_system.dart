
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:doctor_app/models/user_visit_request_information.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global.dart';
import 'notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    //1 terminated
    FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //display visit request information
        readVisitRequestInformation(remoteMessage.data["visitRequestId"],context);
      }
    });
    //2 foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readVisitRequestInformation(remoteMessage!.data["visitRequestId"],context);

    });
    //3 background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readVisitRequestInformation(remoteMessage!.data["visitRequestId"],context);

    });
  }

  readVisitRequestInformation(String userVisitRequestId, context){
    FirebaseDatabase.instance.ref()
        .child("All visit Requests")
        .child(userVisitRequestId)
        .once().then((snapData)
    {
      if(snapData.snapshot.value != null){

        audioPlayer.open(Audio("music/music_notification.mp3"));
        audioPlayer.play();

        double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
        double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
        String originAddress = (snapData.snapshot.value! as Map)["originAddress"];
        // double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
        // double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
        // String destinationAddress = (snapData.snapshot.value! as Map)["destinationAddress"];


        String userName = (snapData.snapshot.value! as Map)["userName"];
        String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

        String? visitRequestId = snapData.snapshot.key;

        userVisitRequestInformation userVisitRequestDetails = userVisitRequestInformation();
        userVisitRequestDetails.originLatLng = LatLng(originLat, originLng);
        //userVisitRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
        userVisitRequestDetails.originAddress = originAddress;
        //userVisitRequestDetails.destinationAddress = destinationAddress;


        userVisitRequestDetails.userName = userName;
        userVisitRequestDetails.userPhone = userPhone;

        userVisitRequestDetails.visitRequestId = visitRequestId;

        showDialog(
            context: context,
            builder: (BuildContext context) => NotificationDialogBox(
              userVisitRequestDetails: userVisitRequestDetails,
            ),
        );

      }
      else{
        Fluttertoast.showToast(msg: "This Visit Request Id do not exist.");
      }
    });
  }

  Future generateAndGetToken() async{
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: ");
    print(registrationToken);

    FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDoctors");
    messaging.subscribeToTopic("allUsers");
  }
}