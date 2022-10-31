import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:drivesafev2/pages/blockSMSCall.dart';
import 'package:drivesafev2/pages/chooseCurrentLocation.dart';
import 'package:drivesafev2/pages/drivingScreen.dart';
import 'package:drivesafev2/pages/testing/visualTestGuidanceScreen.dart';
import 'package:drivesafev2/pages/testing/visualTestScreen.dart';
import 'package:drivesafev2/pages/viewSavedLocations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:drivesafev2/models/User.dart';
//import 'package:location/location.dart';

class testChooseScreen extends StatefulWidget {
  User user;

  testChooseScreen(this.user);
  @override
  testChooseScreenState createState() => testChooseScreenState();
}

class testChooseScreenState extends State<testChooseScreen> {
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
                          onPressed: () {},
                          child: Stack(
                            children: [
                              Container(
                                width: width * 0.85,
                                height: height * 0.32,
                                margin: EdgeInsets.only(bottom: height * 0.08),
                                child: Lottie.network(
                                    //"https://assets5.lottiefiles.com/packages/lf20_tyi61jpp.json",
                                    "https://assets8.lottiefiles.com/private_files/lf30_ji43sg7w.json",
                                    frameRate: FrameRate.max),
                              ),
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
                                    "Audio Test",
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            30,
                                        color: Colors.grey.shade300,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: height * 0.01,
                                left : width * (0.25/2),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent, 
                                    borderRadius: BorderRadius.all(Radius.circular(100))
                                  ),
                                  width: width * 0.5,
                                  height: height * 0.04,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.network("https://assets10.lottiefiles.com/packages/lf20_w51pcehl.json"), 
                                      Text("Coming Soon!!", style : TextStyle(
                                        color: Colors.grey.shade300, 
                                        fontWeight: FontWeight.w700, 
                                        fontSize: textSize * 15
                                      ))
                                    ],
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
                            Navigator.of(context).pushNamed("VisualTest",
                                arguments: widget.user.phoneNumber);
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: width * 0.85,
                                height: height * 0.32,
                                margin: EdgeInsets.only(bottom: height * 0.08),
                                child: Lottie.network(
                                    //"https://assets5.lottiefiles.com/packages/lf20_tyi61jpp.json",
                                    "https://assets6.lottiefiles.com/packages/lf20_nq20lr0r.json",
                                    frameRate: FrameRate.max),
                              ),
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
                                    "Visual Test",
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            35,
                                        color: Colors.grey.shade300,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                              Positioned(
                                  right: width * 0.005,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (d) {
                                        return VtGuidanceScreen(widget.user);
                                      }));
                                    },
                                    child: Container(
                                        child: Icon(
                                      Icons.more_horiz_outlined,
                                      color: Colors.blue,
                                      size: textSize * 50,
                                    )),
                                  ))
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
                          Navigator.pop(context);
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
                ),
              ],
            ),
          ),
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