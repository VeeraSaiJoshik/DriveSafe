import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:permission_handler/permission_handler.dart';
import 'DriveSafeHomePage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:random_string_generator/random_string_generator.dart';

class SignUpLoadScreenWithImage extends StatefulWidget {
  User appUser;
  SignUpLoadScreenWithImage(this.appUser);
  @override
  SignUpLoadScreenWithImageState createState() =>
      SignUpLoadScreenWithImageState();
}

String createRandomPhoneNumber() {
  String phoneNumber = "+1";
  for (int i = 0; i < 10; i++) {
    phoneNumber = phoneNumber + Random().nextInt(9).toString();
  }
  return phoneNumber;
}

class SignUpLoadScreenWithImageState extends State<SignUpLoadScreenWithImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  void upload() async {
    await FirebaseDatabase.instance.ref("User").update({
      widget.appUser.phoneNumber: {
        "age": widget.appUser.age,
        "firstName": widget.appUser.firstName,
        "lastName": widget.appUser.lastName,
        "friendReqeusts": [],
        "friendRequestsPending": [],
        "image": "",
        "password": widget.appUser.password,
        "friends": widget.appUser.friends,
        "location": widget.appUser.location,
        "phoneNumber": widget.appUser.phoneNumber,
        "locationSharingPeople": [],
        "numberApproved": false,
        "locationTrackingOn": false,
        "phoneNumbersChosen": [],
        "userName": widget.appUser.userName
      }
    });
  }

  void uploaduploadTestData() async {
    List firsNames = [
      "Kevin",
      "Cristiano",
      "Lionel",
      "Rubin",
      "John",
      "Ronaldo",
      "Paulo",
      "David",
      "Alphonso",
      "Jack"
    ];
    List lastNames = [
      "De Bruyne",
      "Ronaldo",
      "Messi",
      "Dias",
      "Stones",
      "Nazario",
      "Dybala",
      "Beckham",
      "Davies",
      "Grealish"
    ];
    String RandomPhoneNumber = "";

    for (int i = 0; i < 100; i++) {
      RandomPhoneNumber = createRandomPhoneNumber();
      await FirebaseDatabase.instance.ref("User").update({
        RandomPhoneNumber: {
          "age": 20,
          "firstName": firsNames[(i / 10).toInt()],
          "lastName": lastNames[(i % 10).toInt()],
          "friendReqeusts": [],
          "friendRequestsPending": [],
          "image": "",
          "password": widget.appUser.password,
          "friends": widget.appUser.friends,
          "location": widget.appUser.location,
          "phoneNumber": RandomPhoneNumber,
          "locationSharingPeople": [],
          "numberApproved": false,
          "locationTrackingOn": false,
          "phoneNumbersChosen": [],
          "userName": firsNames[(i / 10).toInt()] +
              getRandomString(5) +
              lastNames[(i % 10).toInt()] +
              getRandomString(5)
        }
      });
    }
  }

  void checkPermission() async {
    if (await Permission.sms.isGranted == false) {
      await Permission.sms.request();
    }
  }

  void initState() {
    checkPermission();
    upload();

    uploaduploadTestData();
    controller = AnimationController(vsync: this);
    super.initState();
  }

  void dispose() {
    this.dispose();
    controller.dispose();
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
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: ((context) =>
                                DriveSafeHomePage(widget.appUser, context))),
                        (route) => false);
                    controller.animateTo(2);
                  },
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
