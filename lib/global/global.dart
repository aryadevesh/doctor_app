import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:doctor_app/models/doctor_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/user_model.dart';



final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
StreamSubscription<Position>? streamSubscriptionPosition;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
Position? doctorCurrentPosition;
DoctorData onlineDoctorData = DoctorData();
StreamSubscription<Position>? streamSubscriptionDoctorLivePosition;