import 'package:doctor_app/authentication/login_screen.dart';
import 'package:doctor_app/authentication/service_type.dart';
import 'package:doctor_app/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import 'package:firebase_database/firebase_database.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm(){
    if(nameTextEditingController.text.length < 3)
    {
      Fluttertoast.showToast(msg: "name must be at least 3 characters");
    }
    else if(!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "Please check the email address!");
    }
    else if(phoneTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Please check the Phone number");
    }
    else if(passwordTextEditingController.text.length< 6){
      Fluttertoast.showToast(msg: "Password must be at least of 6 characters.");
    }
    else{
      saveDoctorInfoNow();
    }
  }

  saveDoctorInfoNow() async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext c){
          return ProgressDialog(message: "Registering Please wait...",);
        }
    );
    final User? firebaseUser = (
        await fAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error: " + msg.toString());
        })
    ).user;

    if(firebaseUser != null)
    {
      Map doctorMap =
      {
        "id": firebaseUser.uid,
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      DatabaseReference doctorsRef = FirebaseDatabase.instance.ref().child("doctors");
      doctorsRef.child(firebaseUser.uid).set(doctorMap);

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Account has been Created.");
      Navigator.push(context, MaterialPageRoute(builder: (c)=> ServiceType()));
    }
    else
    {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been Created.");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              const SizedBox(height: 10,),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo1.jpg"),
              ),

              const SizedBox(height: 10,),

              const Text(
                "Register as Medical Service Provider",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
              ),

              TextField(
                controller: nameTextEditingController,
                keyboardType: TextInputType.text,
                style:const TextStyle(
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Name",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
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
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style:const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14),
                ),

              ),

              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style:const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
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
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style:const TextStyle(
                    color: Colors.black
                ),
                decoration: const InputDecoration(
                  labelText: "Mobile/Cell",
                  hintText: "Mobile Phone No",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
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

              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed:()
              {
                validateForm();
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: const Text(
                  "Create Account",
                   style: TextStyle(
                    color: Colors.black87,
                     fontSize: 18
                 ),
                ),
              ),

              const SizedBox(height: 20,),

              TextButton(
                child:const Text(
                    "Already have an Account, Login Here"
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder:(c)=>LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
