import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:doctor_app/models/doctor_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';




final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;

StreamSubscription<Position>? streamSubscriptionPosition;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
Position? doctorCurrentPosition;
DoctorData onlineDoctorData = DoctorData();
StreamSubscription<Position>? streamSubscriptionDoctorLivePosition;
String titleStarsRating = "not rated";
bool isDoctorActive = false;
String statusText = "Now offline";
Color buttonColor = Colors.grey;