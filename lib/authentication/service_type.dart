import 'package:flutter/material.dart';
import 'package:doctor_app/global/global.dart';
import 'package:doctor_app/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ServiceType extends StatefulWidget
{
  const ServiceType({super.key});
  @override
  State<ServiceType> createState() => _ServiceTypeState();
}



class _ServiceTypeState extends State<ServiceType>
{
  TextEditingController institutionNameTextEditingController = TextEditingController();
  TextEditingController specialtyTextEditingController = TextEditingController();
  TextEditingController registeredIdTextEditingController = TextEditingController();
  TextEditingController visitingPriceTextEditingController =  TextEditingController();

  List<String> serviceTypesList = ["Hospital","Doctor","Pathology","Pharmacy"];
  String? selectedServiceType;

  saveServiceInfo()
  {
    Map doctorServiceInfoMap =
    {
      "institution_name": institutionNameTextEditingController.text.trim(),
      "specialty": specialtyTextEditingController.text.trim(),
      "registeredId": registeredIdTextEditingController.text.trim(),
      "service_type": selectedServiceType,
      "base_price": visitingPriceTextEditingController.text.trim(),
    };
    final currentFirebaseUser = fAuth.currentUser;

    DatabaseReference doctorsRef = FirebaseDatabase.instance.ref().child("doctors");
    doctorsRef.child(currentFirebaseUser!.uid).child("service_details").set(doctorServiceInfoMap);

    Fluttertoast.showToast(msg: "Medical Service Details has been saved, Congratulations.");
    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              const SizedBox(height: 24,),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo1.jpg"),
              ),

              const SizedBox(height: 10,),

              const Text(
                "Select the service you want to provide: ",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextField(
                controller: institutionNameTextEditingController,
                keyboardType: TextInputType.text,
                style:const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Institution/Self",
                  hintText: "Institution Name/Self",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14                ),
                ),

              ),
              TextField(
                controller: specialtyTextEditingController,
                keyboardType: TextInputType.text,
                style:const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Specialization in /All",
                  hintText: "Specialty/All",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14),
                ),

              ),

              TextField(
                controller: registeredIdTextEditingController,
                keyboardType: TextInputType.text,
                style:const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Registered Id/None",
                  hintText: "Registered Id/None",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14                ),
                ),
              ),
              TextField(
                controller: visitingPriceTextEditingController,
                keyboardType: TextInputType.number,
                style:const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Base Visit Fee",
                  hintText: "Amount you would charge for a visit",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14                ),
                ),

              ),

              DropdownButton(
                iconSize: 20,
                dropdownColor: Colors.lightBlueAccent,
                hint:const Text(
                  "Please choose the service type",
                  style: TextStyle(
                    fontSize: 14.0,
                    color:Colors.black,
                  ),
                ),
                  value: selectedServiceType,
                  onChanged: (newValue)
                {
                  setState((){
                    selectedServiceType = newValue.toString();
                  });
                },
                items: serviceTypesList.map((service){
                  return DropdownMenuItem(
                    value: service,
                    child: Text(
                    service,
                    style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20,),

              ElevatedButton(onPressed:()
              {
                if(institutionNameTextEditingController.text.isNotEmpty
                    && specialtyTextEditingController.text.isNotEmpty
                    && registeredIdTextEditingController.text.isNotEmpty && selectedServiceType != null)
                {
                  saveServiceInfo();
                }
                else{
                  Fluttertoast.showToast(msg: "Fill complete details then save.");
                }
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: const Text(
                  "Save Now",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
