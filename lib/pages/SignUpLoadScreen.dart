import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:drivesafev2/models/User.dart';
import 'DriveSafeHomePage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string_generator/random_string_generator.dart';

class SignUpLoadScreen extends StatefulWidget {
  User appUser;
  SignUpLoadScreen(this.appUser);
  @override
  SignUpLoadScreenState createState() => SignUpLoadScreenState();
}

class SignUpLoadScreenState extends State<SignUpLoadScreen> {
  void UploadData() async {
    File image = File(widget.appUser.image);
    final firstUrl = await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('user images')
        .child(widget.appUser.phoneNumber.toString() + '.jpg');
    firebase_storage.UploadTask uploadTask = firstUrl.putFile(image);
    uploadTask.whenComplete(() async {
      final finalUrl = await firstUrl.getDownloadURL();
      await FirebaseDatabase.instance.ref("User").update({
        widget.appUser.phoneNumber: {
          "age": widget.appUser.age,
          "firstName": widget.appUser.firstName,
          "lastName": widget.appUser.lastName,
          "friendReqeusts": [],
          "friendRequestsPending": [],
          "image": finalUrl,
          "password": widget.appUser.password,
          "friends": widget.appUser.friends,
          "location": widget.appUser.location,
          "phoneNumber": widget.appUser.phoneNumber,
          "locationSharingPeople": [],
          "numberApproved": false,
          "locationTrackingOn": false,
          "phoneNumbersChosen": []
        }
      });
    });
  }

  void initState() {
    UploadData();
    if (Permission.sms.isGranted == false) {
      Permission.sms.request();
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String fullName;
    double textSize = MediaQuery.of(context).textScaleFactor;
    Color mainColor = Colors.grey.shade300;
    int animatedSize = 0;

    return Scaffold(
      backgroundColor: mainColor,
      body: Stack(children: [
        Container(
          height: height,
          width: width,
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                InkWell(
                  onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: ((context) =>
                              DriveSafeHomePage(widget.appUser, context))),
                      (route) => false),
                  child: NeumorphicIcon(
                    CupertinoIcons.car_detailed,
                    style: NeumorphicStyle(
                      color: Colors.blue,
                    ),
                    size: textSize * (180 + animatedSize),
                  ),
                ),
                Text(
                  "Thank You",
                  style: TextStyle(
                    fontSize: textSize * 50,
                    fontFamily: "Nunito",
                    fontWeight: FontWeight.w700,
                    shadows: [
                      const Shadow(
                          offset: Offset(1.5, 1.5),
                          color: Colors.black38,
                          blurRadius: 10),
                      Shadow(
                          offset: Offset(-1.5, -1.5),
                          color: Colors.white.withOpacity(0.85),
                          blurRadius: 10)
                    ],
                    color: Colors.blue,
                  ),
                ),
                Container(
                  width: width,
                  padding: EdgeInsets.symmetric(
                      vertical: 0, horizontal: width * 0.15),
                  child: Text(
                    "Thankyou for downloading the app and playing your part in making the roads a tad safer",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: textSize * 20,
                      fontFamily: "Nunito",
                      fontWeight: FontWeight.w700,
                      shadows: [
                        const Shadow(
                            offset: Offset(1.5, 1.5),
                            color: Colors.black38,
                            blurRadius: 10),
                        Shadow(
                            offset: Offset(-1.5, -1.5),
                            color: Colors.white.withOpacity(0.85),
                            blurRadius: 10)
                      ],
                      color: Colors.blue,
                    ),
                  ),
                ),
              ])),
        ),
        Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(bottom: height * 0.03),
            width: width,
            padding:
                EdgeInsets.symmetric(vertical: 0, horizontal: width * 0.15),
            child: Text(
              "click the car to begin",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize * 15,
                fontFamily: "Nunito",
                fontWeight: FontWeight.w700,
                shadows: [
                  const Shadow(
                      offset: Offset(1.5, 1.5),
                      color: Colors.black38,
                      blurRadius: 10),
                  Shadow(
                      offset: Offset(-1.5, -1.5),
                      color: Colors.white.withOpacity(0.85),
                      blurRadius: 10)
                ],
                color: Colors.blue,
              ),
            ))
      ]),
    );
  }
}
