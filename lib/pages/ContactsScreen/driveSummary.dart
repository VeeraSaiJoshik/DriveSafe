import 'package:drivesafev2/models/DrivingHistoryModel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';

import '../../models/User.dart';
import '../driveStateScreen.dart';

class DriveSummary extends StatefulWidget {
  String phoneNumber;
  User user;
  String currentUserNumber;
  DriveSummary(this.phoneNumber, this.user, this.currentUserNumber);

  @override
  State<DriveSummary> createState() => _DriveSummaryState();
}

class _DriveSummaryState extends State<DriveSummary> {
  @override
  List<List> drivingLogs = [];
  int day = 0;
  int month = 0;
  int year = 0;

  void initStateFunctino() async {
    List DriveLogdata = [];
    DataSnapshot data = await FirebaseDatabase.instance
        .ref("User")
        .child(widget.currentUserNumber)
        .child("friendsRecentDrives")
        .child(widget.phoneNumber)
        .get();
    print(widget.phoneNumber);
    print(widget.currentUserNumber);
    print((data.value as List).length);

    if (data.exists) {
      DriveLogdata.addAll(data.value as List);
    }
    for (int i = DriveLogdata.length - 1; i >= 0; i--) {
      DrivingHistory iData = DrivingHistory();
      iData.jsonToDriving(DriveLogdata[i]);
      drivingLogs
          .add([DriveDataScreen(iData, widget.user, true), iData, widget.user]);
    }
    setState(() {
      drivingLogs;
    });
    print(drivingLogs);
  }

  void initState() {
    initStateFunctino();
    super.initState();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Container(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.05,
            ),
            Neumorphic(
              style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: -15,
                  color: Colors.grey.shade300,
                  lightSource: LightSource.topLeft,
                  border: NeumorphicBorder(color: Colors.blue, width: 5),
                  shape: NeumorphicShape.concave),
              child: widget.user.image == ""
                  ? CircleAvatar(
                      radius: height * 0.1,
                      backgroundColor: Colors.grey.shade300,
                      child: NeumorphicIcon(
                        Icons.tag_faces,
                        size: MediaQuery.of(context).textScaleFactor * 150,
                        style: NeumorphicStyle(color: Colors.blue),
                      ),
                    )
                  : CircleAvatar(
                      radius: height * 0.1,
                      backgroundImage: NetworkImage(widget.user.image),
                    ),
            ),
            Text(widget.user.firstName + ' ' + widget.user.lastName,
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: MediaQuery.of(context).textScaleFactor * 35,
                    fontWeight: FontWeight.w700)),
            Text(widget.user.phoneNumber,
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: MediaQuery.of(context).textScaleFactor * 25,
                    fontWeight: FontWeight.w700)),
            Container(
              height: height * 0.1,
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.network(
                      "https://assets5.lottiefiles.com/packages/lf20_z4cshyhf.json"),
                  Text(
                    "Drive History",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                      fontSize: MediaQuery.of(context).textScaleFactor * 30,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: width * 0.95,
                child: drivingLogs.length == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: height * 0.3,
                            child: Lottie.network(
                                "https://assets9.lottiefiles.com/datafiles/vhvOcuUkH41HdrL/data.json"),
                          ),
                          Text(
                            "0 Drive Logs\nShared",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w800,
                                fontSize: textSize * 40),
                          ),
                          Expanded(
                            child: Container(),
                          )
                        ],
                      )
                    : MediaQuery.removePadding(
                        removeTop: true,
                        removeBottom: true,
                        context: context,
                        child: ListView(
                          children: [
                            SizedBox(
                              height: height * 0.01,
                            ),
                            ...drivingLogs.map((e) {
                              String duration = "";
                              Duration totalDuration = DateTime.parse(
                                      (e[1] as DrivingHistory).endingTime)
                                  .difference(DateTime.parse(
                                      (e[1] as DrivingHistory).startingTime));
                              if (totalDuration.inHours > 0) {
                                duration = duration +
                                    totalDuration.inHours.toString() +
                                    " H ";
                              }
                              if (totalDuration.inMinutes > 0) {
                                duration = duration +
                                    totalDuration.inMinutes.toString() +
                                    " M ";
                              }
                              if (totalDuration.inSeconds < 60) {
                                duration = duration +
                                    totalDuration.inSeconds.toString() +
                                    " S ";
                              }
                              DateTime propTime = DateTime.parse(
                                  (e[1] as DrivingHistory).startingTime);
                              String text = "";
                              text = propTime.hour.toString();
                              if (propTime.minute <= 9) {
                                text = text + ":0" + propTime.minute.toString();
                              } else {
                                text = text + ":" + propTime.minute.toString();
                              }
                              if (propTime.day == day &&
                                  propTime.month == month &&
                                  propTime.year == year) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (builder) {
                                      return e[0];
                                    }));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: width * 0.025,
                                        vertical: height * 0.01),
                                    height: height * 0.2,
                                    child: Stack(
                                      children: [
                                        Neumorphic(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: height * 0.015,
                                              ),
                                              Container(
                                                width: width * 0.95,
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                          width: width * 0.1),
                                                      SizedBox(width: 5),
                                                      Container(
                                                        width: width * 0.65,
                                                        child: Center(
                                                          child: Text(
                                                            (e[1] as DrivingHistory)
                                                                .starting,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    textSize *
                                                                        12),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(),
                                                      ),
                                                      Container(
                                                          height: height * 0.04,
                                                          child: Image.asset(
                                                              "assets/images/start.png")),
                                                      SizedBox(
                                                          width: width * 0.05),
                                                    ]),
                                              ),
                                              SizedBox(
                                                height: height * 0.005,
                                              ),
                                              Container(
                                                width: width * 0.95,
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                          width: width * 0.1),
                                                      SizedBox(width: 5),
                                                      Container(
                                                        width: width * 0.65,
                                                        child: Center(
                                                          child: Text(
                                                            (e[1] as DrivingHistory)
                                                                .ending,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    textSize *
                                                                        12),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(),
                                                      ),
                                                      Container(
                                                          height: height * 0.04,
                                                          child: Image.asset(
                                                              "assets/images/finish.png")),
                                                      SizedBox(
                                                          width: width * 0.05),
                                                    ]),
                                              ),
                                              SizedBox(
                                                height: height * 0.01,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: width * 0.95,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Container(
                                                        height: height * 0.065,
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: height *
                                                                  0.002,
                                                            ),
                                                            Text(
                                                              "Start Time",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  fontSize:
                                                                      textSize *
                                                                          15),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                child:
                                                                    FittedBox(
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        child:
                                                                            RichText(
                                                                          text:
                                                                              TextSpan(
                                                                            children: <TextSpan>[
                                                                              TextSpan(
                                                                                text: text.toString(),
                                                                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.065,
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: height *
                                                                  0.002,
                                                            ),
                                                            Text(
                                                              "Duration",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  fontSize:
                                                                      textSize *
                                                                          15),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                child:
                                                                    FittedBox(
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        child:
                                                                            RichText(
                                                                          text:
                                                                              TextSpan(
                                                                            children: <TextSpan>[
                                                                              TextSpan(
                                                                                text: duration.toString(),
                                                                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.065,
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height: height *
                                                                  0.002,
                                                            ),
                                                            Text(
                                                              "Distance",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  fontSize:
                                                                      textSize *
                                                                          15),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  child: FittedBox(
                                                                      fit: BoxFit.contain,
                                                                      child: RichText(
                                                                        text:
                                                                            TextSpan(
                                                                          children: <
                                                                              TextSpan>[
                                                                            TextSpan(
                                                                              text: (e[1] as DrivingHistory).distanceTraveled.toString() == "" ? "--" : (e[1] as DrivingHistory).distanceTraveled.toString(),
                                                                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ))),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: height * 0.02,
                                              ),
                                            ],
                                          ),
                                          style: NeumorphicStyle(
                                              color: Colors.grey.shade300,
                                              depth: 2,
                                              boxShape:
                                                  NeumorphicBoxShape.roundRect(
                                                BorderRadius.all(
                                                    Radius.circular(25)),
                                              )),
                                        ),
                                        Positioned(
                                          top: height * 0.022,
                                          left: width * 0.025,
                                          child: Container(
                                            width: width * 0.06,
                                            height: width * 0.06,
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(100))),
                                          ),
                                        ),
                                        Positioned(
                                          top: height * 0.07,
                                          left: width * 0.025,
                                          child: Container(
                                            width: width * 0.06,
                                            height: width * 0.06,
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(100))),
                                          ),
                                        ),
                                        Positioned(
                                          top: height * 0.022,
                                          left: width * 0.045,
                                          child: Container(
                                            width: width * 0.02,
                                            height: height * 0.058,
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(100))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                day = propTime.day;
                                month = propTime.month;
                                year = propTime.year;
                                return Column(
                                  
                                  children: [
                                    Container(
                                      height: height * 0.08,
                                      margin: EdgeInsets.only(
                                          left: width * 0.025,
                                          right: width * 0.025),
                                      child: Neumorphic(
                                        style: NeumorphicStyle(
                                            color: Colors.blue,
                                            depth: 2,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.all(
                                                        Radius.circular(25)))),
                                        child: Center(
                                          child: Text(
                                            day.toString() +
                                                "/" +
                                                month.toString() +
                                                "/" +
                                                year.toString(),
                                            style: TextStyle(
                                                color: Colors.grey.shade300,
                                                fontSize: textSize * 25,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (builder) {
                                          return e[0];
                                        }));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: width * 0.025,
                                            vertical: height * 0.01),
                                        height: height * 0.2,
                                        child: Stack(
                                          children: [
                                            Neumorphic(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: height * 0.015,
                                                  ),
                                                  Container(
                                                    width: width * 0.95,
                                                    child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                              width:
                                                                  width * 0.1),
                                                          SizedBox(width: 5),
                                                          Container(
                                                            width: width * 0.65,
                                                            child: Center(
                                                              child: Text(
                                                                (e[1] as DrivingHistory)
                                                                    .starting,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        textSize *
                                                                            12),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(),
                                                          ),
                                                          Container(
                                                              height:
                                                                  height * 0.04,
                                                              child: Image.asset(
                                                                  "assets/images/start.png")),
                                                          SizedBox(
                                                              width:
                                                                  width * 0.05),
                                                        ]),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.005,
                                                  ),
                                                  Container(
                                                    width: width * 0.95,
                                                    child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                              width:
                                                                  width * 0.1),
                                                          SizedBox(width: 5),
                                                          Container(
                                                            width: width * 0.65,
                                                            child: Center(
                                                              child: Text(
                                                                (e[1] as DrivingHistory)
                                                                    .ending,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        textSize *
                                                                            12),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(),
                                                          ),
                                                          Container(
                                                              height:
                                                                  height * 0.04,
                                                              child: Image.asset(
                                                                  "assets/images/finish.png")),
                                                          SizedBox(
                                                              width:
                                                                  width * 0.05),
                                                        ]),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.01,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      width: width * 0.95,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Container(
                                                            height:
                                                                height * 0.065,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.002,
                                                                ),
                                                                Text(
                                                                  "Start Time",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      fontSize:
                                                                          textSize *
                                                                              15),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    child: FittedBox(
                                                                        fit: BoxFit.contain,
                                                                        child: RichText(
                                                                          text:
                                                                              TextSpan(
                                                                            children: <TextSpan>[
                                                                              TextSpan(
                                                                                text: text.toString(),
                                                                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            height:
                                                                height * 0.065,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.002,
                                                                ),
                                                                Text(
                                                                  "Duration",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      fontSize:
                                                                          textSize *
                                                                              15),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    child: FittedBox(
                                                                        fit: BoxFit.contain,
                                                                        child: RichText(
                                                                          text:
                                                                              TextSpan(
                                                                            children: <TextSpan>[
                                                                              TextSpan(
                                                                                text: duration.toString(),
                                                                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            height:
                                                                height * 0.065,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.002,
                                                                ),
                                                                Text(
                                                                  "Distance",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                      fontSize:
                                                                          textSize *
                                                                              15),
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                      child: FittedBox(
                                                                          fit: BoxFit.contain,
                                                                          child: RichText(
                                                                            text:
                                                                                TextSpan(
                                                                              children: <TextSpan>[
                                                                                TextSpan(
                                                                                  text: (e[1] as DrivingHistory).distanceTraveled.toString() == "" ? "--": (e[1] as DrivingHistory).distanceTraveled.toString(),
                                                                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ))),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.02,
                                                  ),
                                                ],
                                              ),
                                              style: NeumorphicStyle(
                                                  color: Colors.grey.shade300,
                                                  depth: 2,
                                                  boxShape: NeumorphicBoxShape
                                                      .roundRect(
                                                    BorderRadius.all(
                                                        Radius.circular(25)),
                                                  )),
                                            ),
                                            Positioned(
                                              top: height * 0.022,
                                              left: width * 0.025,
                                              child: Container(
                                                width: width * 0.06,
                                                height: width * 0.06,
                                                decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                100))),
                                              ),
                                            ),
                                            Positioned(
                                              top: height * 0.07,
                                              left: width * 0.025,
                                              child: Container(
                                                width: width * 0.06,
                                                height: width * 0.06,
                                                decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                100))),
                                              ),
                                            ),
                                            Positioned(
                                              top: height * 0.022,
                                              left: width * 0.045,
                                              child: Container(
                                                width: width * 0.02,
                                                height: height * 0.058,
                                                decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                100))),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }).toList()
                          ],
                        ),
                      ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            )
          ],
        ),
      ),
    );
  }
}
