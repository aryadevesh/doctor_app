import 'dart:async';
import 'package:doctor_app/authentication/login_screen.dart';
import 'package:doctor_app/authentication/service_type.dart';
import 'package:doctor_app/mainScreens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
{
  //Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
  startTimer(){
    Timer(const Duration(seconds: 1), () async
    {
      final currentUser = fAuth.currentUser;
      if (currentUser != null) {
        DatabaseReference doctorsRef = FirebaseDatabase.instance.ref().child(
            "doctors").child(currentUser.uid);
        doctorsRef.once().then((snap) {
          if (snap.snapshot.value != null) {
            if ((snap.snapshot.value as Map)["service_details"] == null) {
              // AssistantMethods.displaySnackBar(
              //     "Please fill all the necessary details first!", context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ServiceType()));
            }
            else if((snap.snapshot.value as Map)["blockStatus"] == "no") {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const MainScreen()));
            }
            else {
              FirebaseAuth.instance.signOut();
              Fluttertoast.showToast(
                msg: "Either wait for your verification or Please contact admin: aryadevesh78@gmail.com",
                toastLength: Toast.LENGTH_LONG,
              );
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => const LoginScreen()));
            }
          }
          else {
            FirebaseAuth.instance.signOut();
            Fluttertoast.showToast(
              msg: "Either wait for your verification or Please contact admin: aryadevesh78@gmail.com",
            );
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => const LoginScreen()));
          }
        });
      }
      else {
        FirebaseAuth.instance.signOut();
        //AssistantMethods.displaySnackBar(
        //   "your records does not exist as a Doctor.", context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/logo1.jpg"),

            const SizedBox(height: 10,),

            const Text(
              "All-in-1 Medical Service",
              style: TextStyle(
                fontSize: 24,
                color: Colors.pink,
                fontWeight: FontWeight.bold,
              )
            )
          ],
        ),
      ),
    );
  }
}

