import 'dart:async';

import 'package:doctor_app/authentication/login_screen.dart';
import 'package:doctor_app/authentication/signup_screen.dart';
import 'package:doctor_app/mainScreens/main_screen.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
{
  startTimer(){
    Timer(const Duration(seconds: 1), () async
    {
      if(fAuth.currentUser != null)
      {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
      }
      else
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=>  LoginScreen()));
      }
      // send user to home screen
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

