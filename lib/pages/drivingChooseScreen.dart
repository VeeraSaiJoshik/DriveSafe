import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:drivesafev2/models/settings.dart';
import 'package:drivesafev2/pages/blockSMSCall.dart';
import 'package:drivesafev2/pages/chooseCurrentLocation.dart';
import 'package:drivesafev2/pages/drivingScreen.dart';
import 'package:drivesafev2/pages/testing/chooseTypeOfTestScreen.dart';
import 'package:drivesafev2/pages/viewSavedLocations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:drivesafev2/models/User.dart';
//import 'package:location/location.dart';

class drivingChooseScreen extends StatefulWidget {
  User user;

  drivingChooseScreen(this.user);
  @override
  drivingChooseScreenState createState() => drivingChooseScreenState();
}

class drivingChooseScreenState extends State<drivingChooseScreen> {
  @override
  Location location = new Location();
  bool haveClicked = false;
  bool hasPermission = false;
  bool? hasPermissionSMS = false;
  double chooseWidth = 0;
  double chooseHeight = 0;
  double status = 0;
  Color chooseColor = Colors.transparent;
  late LocationData locationData;
  LatLng currentLocation = LatLng(0, 0);
  Future<bool> getLocationAccess(location) async {
    bool serviceEnabled = false;
    PermissionStatus permissionGranted;
    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == false) {
      serviceEnabled = await location.requestService();
      if (serviceEnabled == false) {
        return false;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void checkThings() async {
    hasPermission = await getLocationAccess(location);
    if (hasPermission == true) {
      locationData = await location.getLocation();
      setState(() {
        currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });
    }
  }

  void initState() {
    checkThings();
    super.initState();
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            child: Stack(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: width * 0.85,
                        height: height * 0.32,
                        child: NeumorphicButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (ctx) {
                              return testChooseScreen(widget.user);
                            }));
                          },
                          child: Stack(
                            children: [
                              Lottie.asset(
                                  //"https://assets5.lottiefiles.com/packages/lf20_tyi61jpp.json",
                                  "assets/animations/test.json",
                                  frameRate: FrameRate.max),
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  margin:
                                      EdgeInsets.only(bottom: height * 0.015),
                                  padding: EdgeInsets.only(
                                      left: width * 0.045,
                                      right: width * 0.045,
                                      top: width * 0.015,
                                      bottom: width * 0.015),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  ),
                                  child: Text(
                                    "Pre-Drive Check",
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            30,
                                        color: Colors.grey.shade300,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              )
                            ],
                          ),
                          style: NeumorphicStyle(
                            depth: 20,
                            border: const NeumorphicBorder(
                                color: Colors.blueAccent, width: 5),
                            color: Colors.grey.shade300,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.all(Radius.circular(45))),
                          ),
                        ),
                      ),
                      Container(
                        width: width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: width * 0.33,
                              height: 10,
                              decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100))),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * 0.02,
                                  vertical: height * 0.03),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            25,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            Container(
                              width: width * 0.33,
                              height: 10,
                              decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100))),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: width * 0.85,
                        height: height * 0.32,
                        margin: EdgeInsets.only(bottom: height * 0.02),
                        child: NeumorphicButton(
                          onPressed: () {
                            print("here");
                            setState(() {
                              status = 1;
                              haveClicked = true;
                              chooseWidth = width * 0.73;
                              chooseHeight = height * 0.21;
                              chooseColor = Color.fromARGB(165, 0, 0, 0);
                            });
                          },
                          child: Stack(
                            children: [
                              Lottie.asset(
                                  "assets/animations/driveOptionChooseScreen.json",
                                  frameRate: FrameRate.max),
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  margin:
                                      EdgeInsets.only(bottom: height * 0.015),
                                  padding: EdgeInsets.only(
                                      left: width * 0.045,
                                      right: width * 0.045,
                                      top: width * 0.015,
                                      bottom: width * 0.015),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  ),
                                  child: Text(
                                    "Start Drive",
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            35,
                                        color: Colors.grey.shade300,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              )
                            ],
                          ),
                          style: NeumorphicStyle(
                            depth: 20,
                            border: const NeumorphicBorder(
                                color: Colors.blueAccent, width: 5),
                            color: Colors.grey.shade300,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.all(Radius.circular(45))),
                          ),
                        ),
                      ),
                    ]),
                Container(
                  height: height,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(bottom: height * 0.03),
                      width: height * 0.1,
                      height: height * 0.1,
                      child: NeumorphicButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: const NeumorphicStyle(
                          color: Color(0xFFDF4758),
                          boxShape: NeumorphicBoxShape.circle(),
                        ),
                        child: Lottie.network(
                            "https://assets10.lottiefiles.com/packages/lf20_i0zh5psb.json",
                            repeat: false,
                            fit: BoxFit.fill),
                      )),
                )
              ],
            ),
          ),
          InkWell(
            onDoubleTap: () {
              setState(() {
                status = 0;
                chooseColor = Colors.transparent;
                chooseWidth = 0;
                chooseHeight = 0;
              });
            },
            child: AnimatedContainer(
                duration: Duration(seconds: 0),
                width: 0 + width * status,
                height: 0 + height * status,
                color: chooseColor,
                child: Center(
                    child: AnimatedContainer(
                        curve: Curves.bounceInOut,
                        duration: const Duration(milliseconds: 700),
                        width: chooseWidth,
                        height: chooseHeight,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          border: Border.all(color: Colors.blue, width: 5),
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (builder) {
                                  return viewSavedLocations(
                                      widget.user.phoneNumber, true, [
                                    location,
                                    widget.user,
                                    currentLocation,
                                    false
                                  ]);
                                }));
                              },
                              child: Container(
                                child: Stack(children: [
                                  Column(
                                    children: [
                                      Lottie.network(
                                          "https://assets6.lottiefiles.com/private_files/lf30_x8aowqs9.json"),
                                      //"https://assets2.lottiefiles.com/packages/lf20_2scSKA.json"),
                                      SizedBox(height: height * 0.01)
                                    ],
                                  ),
                                  Positioned(
                                    bottom: height * 0.02,
                                    right: width * 0.05,
                                    child: Text(
                                      "Select",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: textSize * 25,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  )
                                ]),
                              ),
                            )),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: chooseHeight * 0.025),
                              width: 5,
                              height: chooseHeight * 0.95,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                            ),
                            Expanded(
                                child: InkWell(
                              onTap: () async {
                                if (hasPermission == false) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.ERROR,
                                    animType: AnimType.SCALE,
                                    headerAnimationLoop: false,
                                    title: "ERROR",
                                    desc:
                                        "We do not have permission to access your location",
                                    titleTextStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Nunito",
                                      fontSize: textSize * 25,
                                      color: Colors.red,
                                    ),
                                    descTextStyle: TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: textSize * 20,
                                        color: Colors.red),
                                    btnOkOnPress: () {},
                                    btnOkText: "Ok",
                                    btnOkColor: Colors.red,
                                  ).show();
                                } else {
                                  var ting = await FirebaseDatabase.instance
                                      .ref("User")
                                      .child(widget.user.phoneNumber)
                                      .child("Settings")
                                      .get();
                                  Map datA = ting.value as Map;
                                  print(datA);
                                  Settings currentUserSettings = Settings();
                                  currentUserSettings.jsonToSettings(datA);
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return chooseCurrentLocationScreen(
                                        location,
                                        widget.user,
                                        currentLocation,
                                        false,
                                        currentUserSettings);
                                    //return Example();
                                  }));
                                }
                              },
                              child: Container(
                                child: Stack(children: [
                                  Column(
                                    children: [
                                      Lottie.network(
                                          "https://assets7.lottiefiles.com/packages/lf20_1jihwhfi.json"),
                                      //"https://assets2.lottiefiles.com/packages/lf20_2scSKA.json"),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: height * 0.02,
                                    right: width * 0.05,
                                    child: Text(
                                      "Search",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: textSize * 25,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  )
                                ]),
                              ),
                            ))
                          ],
                        )))),
          )
        ],
      ),
    );
  }
}


/*if (hasPermission == false) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.ERROR,
                                animType: AnimType.SCALE,
                                headerAnimationLoop: false,
                                title: "ERROR",
                                desc:
                                    "We do not have permission to access your location",
                                titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Nunito",
                                  fontSize: textSize * 25,
                                  color: Colors.red,
                                ),
                                descTextStyle: TextStyle(
                                    fontFamily: "Nunito",
                                    fontSize: textSize * 20,
                                    color: Colors.red),
                                btnOkOnPress: () {},
                                btnOkText: "Ok",
                                btnOkColor: Colors.red,
                              ).show();
                            } else {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return chooseCurrentLocationScreen(
                                    location, widget.user, currentLocation);
                              }));
                            } */