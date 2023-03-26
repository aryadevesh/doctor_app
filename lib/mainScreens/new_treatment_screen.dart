import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:doctor_app/models/user_visit_request_information.dart';
import 'package:flutter/material.dart';

import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';



class NewTreatmentScreen extends StatefulWidget {

  userVisitRequestInformation? userVisitRequestDetails;
  NewTreatmentScreen({super.key,
    this.userVisitRequestDetails,
});

  @override
  State<NewTreatmentScreen> createState() => _NewTreatmentScreenState();
}

class _NewTreatmentScreenState extends State<NewTreatmentScreen> {

  GoogleMapController? newTreatmentGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;
  String statusBtn = "accepted";

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;

  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();

  Position? onlineDoctorCurrentPosition;
  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  //Step 1:: when driver accepts the user ride request
  // originLatLng = doctor Current Location
  // destinationLatLng = user PickUp Location

  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng) async
  {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    polyLinePositionCoordinates.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty)
    {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng)
      {
        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.black,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTreatmentGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.black,
      radius: 5,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.black,
      radius: 5,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  @override
  void initState(){
    super.initState();
    saveAssignedDoctorDetailsToUserVisitRequest();
  }

  createDoctorIconMarker()
  {
    if(iconAnimatedMarker == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/red_plus.png").then((value)
      {
        iconAnimatedMarker = value;
      });
    }
  }

  getDoctorsLocationUpdatesAtRealTime()
  {
    LatLng oldLatLng = LatLng(0,0);
    streamSubscriptionDoctorLivePosition = Geolocator.getPositionStream()
        .listen((Position position)
    {
      doctorCurrentPosition = position;
      onlineDoctorCurrentPosition = position;


      LatLng latLngLiveDoctorPosition = LatLng(
        onlineDoctorCurrentPosition!.latitude,
        onlineDoctorCurrentPosition!.longitude,
      );

      Marker animatingMarker = Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latLngLiveDoctorPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(title: "This is your Position"),
      );
      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDoctorPosition, zoom : 16);
        newTreatmentGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });
      oldLatLng = latLngLiveDoctorPosition;

      updateDurationTimeAtRealTime();

      Map doctorLatLngDataMap = {
        "latitude":onlineDoctorCurrentPosition!.latitude.toString(),
        "longitude":onlineDoctorCurrentPosition!.longitude.toString(),

      };
      FirebaseDatabase.instance.ref().child("All visit Requests")
          .child(widget.userVisitRequestDetails!.visitRequestId!)
          .child("doctorLocation")
          .set(doctorLatLngDataMap);
    });
  }
  updateDurationTimeAtRealTime()async{
    if(isRequestDirectionDetails == false){
      isRequestDirectionDetails = true;
      if(onlineDoctorCurrentPosition == null){
        return;
      }
      var originLatLng = LatLng(
          onlineDoctorCurrentPosition!.latitude,
          onlineDoctorCurrentPosition!.longitude);

      var destinationLatLng = widget.userVisitRequestDetails!.originLatLng;
      // if(rideRequestStatus == "accepted") {
      //   var destinationLatLng = widget.userVisitRequestDetails!.originLatLng;
      // }
      //else{
      //   destinationLatLng = widget.userVisitRequestDetails!.destinationLatLng;
      // }
      var directionInformation = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng!);

      if(directionInformation!=null){
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }
      isRequestDirectionDetails = false;
    }

  }
  @override
  Widget build(BuildContext context) {

    createDoctorIconMarker();

    return Scaffold(
      body: Stack(
        children: [
          //google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType:MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: _kGooglePlex,

            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,


            onMapCreated: (GoogleMapController controller){
            _controllerGoogleMap.complete(controller);
            newTreatmentGoogleMapController = controller;
              //for black theme of google maps
              //blackThemeGoogleMap()

            setState(() {
              mapPadding = 350;
            });
            var doctorCurrentLatLng = LatLng(
                doctorCurrentPosition!.latitude,
                doctorCurrentPosition!.longitude
            );
            var userPickUpLatLng = widget.userVisitRequestDetails!.originLatLng;

            drawPolyLineFromOriginToDestination(doctorCurrentLatLng, userPickUpLatLng!);

            getDoctorsLocationUpdatesAtRealTime();

            },
          ),
          Positioned(
            bottom: 0,
            left:0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 18,
                    spreadRadius: 5,
                    offset: Offset(0.6, 0.6),
                  ),

                ]
              ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20,),
                  child: Column(
                    children:[
                       //Time to reach the patient
                      Text(
                        "Arriving in "+durationFromOriginToDestination,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:  Colors.black,
                        ),
                      ),

                     const Divider(
                        thickness: 2,
                        height: 2,
                        color: Colors.black,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Text(
                            widget.userVisitRequestDetails!.userName!,
                            style: const TextStyle(
                              fontSize: 20,
                              color:  Colors.black,
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.phone_android,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      ElevatedButton.icon(onPressed: ()
                      {

                      },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        icon: const Icon(
                          Icons.call,
                          color: Colors.blue,
                          size: 25,
                        ),
                        label: Text(
                          widget.userVisitRequestDetails!.userPhone!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,

                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

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

                      const SizedBox(height: 20),

                      const Divider(
                        thickness: 2,
                        height: 2,
                        color: Colors.black,
                      ),

                      const SizedBox(height: 26),

                      ElevatedButton.icon(onPressed: ()
                      {
                        if(statusBtn == "accepted"){ //doctor has arrived at user PickUp Location
                          statusBtn = "arrived";
                          FirebaseDatabase.instance.ref().child("All visit Requests").
                        }
                      },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                          icon: const Icon(
                          Icons.medical_information,
                          color: Colors.blue,
                          size: 25,
                        ),
                        label: Text(
                          buttonTitle!,
                          style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
          )
        ],
      )
    );
  }

  saveAssignedDoctorDetailsToUserVisitRequest()
  {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref()
        .child("All visit Requests")
        .child(widget.userVisitRequestDetails!.visitRequestId!);

    Map doctorLocationDataMap =
    {
      "latitude": doctorCurrentPosition!.latitude.toString(),
      "longitude": doctorCurrentPosition!.longitude.toString(),
    };
    databaseReference.child("doctorLocation").set(doctorLocationDataMap);

    databaseReference.child("status").set("accepted");
    databaseReference.child("doctorId").set(onlineDoctorData.id);
    databaseReference.child("doctorName").set(onlineDoctorData.name);
    databaseReference.child("doctorPhone").set(onlineDoctorData.phone);
    databaseReference.child("service_details").set(onlineDoctorData.service_type.toString() + onlineDoctorData.base_price.toString());

    saveVisitRequestIdToDoctorHistory();
  }

  saveVisitRequestIdToDoctorHistory()
  {
    DatabaseReference treatmentsHistoryRef = FirebaseDatabase.instance.ref()
        .child("doctors")
        .child(currentFirebaseUser!.uid)
        .child("treatmentsHistory");

    treatmentsHistoryRef.child(widget.userVisitRequestDetails!.visitRequestId!).set(true);
  }
}
