import 'dart:async';
import 'package:doctor_app/push_notifications/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../assistants/assistant_methods.dart';
import '../global/global.dart';



class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  _HomeTabPageState createState()=> _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {

  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap =
  Completer();


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  String statusText = "Now offline";
  Color buttonColor = Colors.grey;
  bool isDoctorActive = false;



  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
    {
      _locationPermission = await Geolocator.requestPermission();
    }
  }


  locateDoctorPosition( )async{
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    doctorCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(doctorCurrentPosition!.latitude, doctorCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    // ignore: use_build_context_synchronously
    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(doctorCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);

  }

  readCurrentDoctorInformation () async{
    currentFirebaseUser = fAuth.currentUser;

    await FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((DatabaseEvent snap)
    {
      if(snap.snapshot.value != null)
      {
        onlineDoctorData.id = (snap.snapshot.value as Map)["id"];
        onlineDoctorData.name = (snap.snapshot.value as Map)["name"];
        onlineDoctorData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDoctorData.email = (snap.snapshot.value as Map)["email"];
        onlineDoctorData.base_price = (snap.snapshot.value as Map)["service_details"]["base_price"];
        onlineDoctorData.institution_name = (snap.snapshot.value as Map)["service_details"]["institution_name"];
        onlineDoctorData.registeredId = (snap.snapshot.value as Map)["service_details"]["registeredId"];
        onlineDoctorData.service_type = (snap.snapshot.value as Map)["service_details"]["service_type"];
        onlineDoctorData.specialty = (snap.snapshot.value as Map)["service_details"]["specialty"];

        print("Service Details :: ");

        print(onlineDoctorData.institution_name);
        print(onlineDoctorData.registeredId);
      }
    });
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();


  }

  @override
  void initState(){
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDoctorInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller)
          {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            //black theme google map
            //blackThemeGoogleMap();
            locateDoctorPosition();
          },
        ),

        // ui for online offline doctor

        statusText != "Now Online"
            ? Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: Colors.black87,
        )
            : Container(),

        //button for online offline doctor
        Positioned(
          top: statusText != "Now Online"
              ? MediaQuery.of(context).size.height * 0.46
              : 25,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: ()
                {
                  if(isDoctorActive != true) //offline
                      {
                    doctorIsOnlineNow();
                    updateDoctorsLocationAtRealTime();

                    setState(() {
                      statusText = "Now Online";
                      isDoctorActive = true;
                      buttonColor = Colors.transparent;
                    });

                    //display Toast
                    Fluttertoast.showToast(msg: "you are Online Now");
                  }
                  else //online
                      {
                    doctorIsOfflineNow();

                    setState(() {
                      statusText = "Now Offline";
                      isDoctorActive = false;
                      buttonColor = Colors.grey;
                    });

                    //display Toast
                    Fluttertoast.showToast(msg: "you are Offline Now, Restart app");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: statusText != "Now Online"
                    ? Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.phonelink_ring,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  doctorIsOnlineNow() async
  {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    doctorCurrentPosition = pos;

    Geofire.initialize("activeDoctors");

    Geofire.setLocation(
        currentFirebaseUser!.uid,
        doctorCurrentPosition!.latitude,
        doctorCurrentPosition!.longitude,
    );

    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(currentFirebaseUser!.uid)
        .child("newVisitStatus");

    ref.set("idle"); //searching for visit request
    ref.onValue.listen((event) { });
  }

  updateDoctorsLocationAtRealTime()
  {
    streamSubscriptionPosition = Geolocator.getPositionStream()
        .listen((Position position)
    {
      doctorCurrentPosition = position;

      if(isDoctorActive == true)
      {
        Geofire.setLocation(
            currentFirebaseUser!.uid,
            doctorCurrentPosition!.latitude,
            doctorCurrentPosition!.longitude
        );
      }

      LatLng latLng = LatLng(
        doctorCurrentPosition!.latitude,
        doctorCurrentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  doctorIsOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(currentFirebaseUser!.uid)
        .child("newVisitStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), ()
    {
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop();
    });
  }
}
