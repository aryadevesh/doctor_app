

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:doctor_app/assistants/assistant_methods.dart';
import 'package:doctor_app/mainScreens/new_treatment_screen.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../models/user_visit_request_information.dart';



class NotificationDialogBox extends StatefulWidget
{
  userVisitRequestInformation? userVisitRequestDetails;

  NotificationDialogBox({this.userVisitRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}




class _NotificationDialogBoxState extends State<NotificationDialogBox>
{
  @override
  Widget build(BuildContext context) 
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.lightBlueAccent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 14,),

            Image.asset(
              "images/logo1.jpg",
              width: 160,
            ),

            const SizedBox(height: 10,),

            //title
            const Text(
              "New Visit Request",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black
              ),
            ),

            const SizedBox(height: 14.0),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //addresses origin destination
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //origin location with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 14,),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userVisitRequestDetails!.originAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  //destination location with icon
                  /*Row(
                    children: [
                      Image.asset(
                        "images/destination.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 14,),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userVisitRequestDetails!.destinationAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),*/
                ],
              ),
            ),


            const Divider(
              height: 3,
              thickness: 3,
            ),

            //buttons cancel accept
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //cancel the rideRequest
                      FirebaseDatabase.instance.ref()
                          .child("All visit Requests")
                          .child(widget.userVisitRequestDetails!.visitRequestId!)
                          .remove().then((value){
                            FirebaseDatabase.instance.ref()
                                .child("doctors")
                                .child(currentFirebaseUser!.uid)
                                .child("newVisitStatus").set("idle");
                      }).then((value){
                        FirebaseDatabase.instance.ref()
                            .child("doctors")
                            .child(currentFirebaseUser!.uid)
                            .child("treatmentsHistory")
                            .child(widget.userVisitRequestDetails!.visitRequestId!).remove();
                      }).then((value){
                        Fluttertoast.showToast(msg: "Visit Request has be cancelled, Successfully. Restart App Now.");
                      });
                      

                      Future.delayed(const Duration(milliseconds: 3000),(){
                        SystemNavigator.pop();
                      });
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 25.0),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //accept the rideRequest

                      acceptVisitRequest(context);
                    },
                    child: Text(
                      "Accept".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  acceptVisitRequest(BuildContext context){
    String getVisitRequestId = "";
    FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(currentFirebaseUser!.uid)
        .child("newVisitStatus")
        .once().then((snap)
    {
      if(snap.snapshot.value!= null){
            getVisitRequestId = snap.snapshot.value.toString();
      }else{
            Fluttertoast.showToast(msg: "This visit request don't exist.");
      }

//***** change this id to getVisitRequestId later *****
      if(getVisitRequestId == widget.userVisitRequestDetails!.visitRequestId){
            FirebaseDatabase.instance.ref()
                .child("doctors")
                .child(currentFirebaseUser!.uid)
                .child("newVisitStatus")
                .set("Accepted");
            AssistantMethods.pauseLiveLocationUpdates();

            //send doctor to treatmentScreen
            Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTreatmentScreen(
                userVisitRequestDetails: widget.userVisitRequestDetails)));
      }
      else
      {
            Fluttertoast.showToast(msg: "This visit request don't exist.");
      }
    });
  }
}
