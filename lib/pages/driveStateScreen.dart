import 'package:drivesafev2/models/DrivingHistoryModel.dart';
import 'package:drivesafev2/pages/DriveSafeHomePage.dart';
import 'package:drivesafev2/pages/drivingScreen.dart';
import 'package:drivesafev2/pages/sendNotification.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import '../models/User.dart';
import 'package:map_launcher/map_launcher.dart';

class Blinking extends StatefulWidget {
  List<blinkSession> data;
  Function onTap;
  Blinking(this.data, this.onTap);
  @override
  State<Blinking> createState() => _BlinkingState();
}

class _BlinkingState extends State<Blinking> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: width * 0.1,
            ),
            Container(
                height: height * 0.08,
                child: Lottie.network(
                    "https://lottie.host/f8ad0aa7-957b-4620-a8da-d0ddd2733640/53F2UCvC3D.json")),
            Text(
              "Blinking Data",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: textSize * 30),
            ),
          ],
        ),
        Expanded(
            child: Container(
          child: widget.data.length == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.3,
                      child: Lottie.network(
                          "https://assets9.lottiefiles.com/datafiles/vhvOcuUkH41HdrL/data.json"),
                    ),
                    Text(
                      "No Blinking\nInstances",
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
                  context: context,
                  removeTop: true,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: height * 0.005,
                      ),
                      ...widget.data.map((e) {
                        String text = "";
                        text = e.timeStarted.hour.toString();
                        if (e.timeStarted.minute <= 9) {
                          text = text + ":0" + e.timeStarted.minute.toString();
                        } else {
                          text = text + ":" + e.timeStarted.minute.toString();
                        }
                        String text2 = "";
                        text2 = e.timeEnded.hour.toString();
                        if (e.timeEnded.minute <= 9) {
                          text2 = text2 + ":0" + e.timeEnded.minute.toString();
                        } else {
                          text2 = text2 + ":" + e.timeEnded.minute.toString();
                        }
                        String duration = "";
                        Duration totalDuration =
                            e.timeEnded.difference(e.timeStarted);
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
                        if (totalDuration.inSeconds > 0) {
                          duration = duration +
                              totalDuration.inSeconds.toString() +
                              " S ";
                        }
                        if (duration == "") {
                          duration = "1 M";
                        }
                        print(duration);
                        return Container(
                          height: height * 0.16,
                          margin:
                              EdgeInsets.symmetric(horizontal: width * 0.025),
                          child: Neumorphic(
                            child: Column(
                              children: [
                                Container(
                                  width: width * 0.95,
                                  height: height * 0.085,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 10),
                                        Container(
                                            height: height * 0.06,
                                            child: Image.asset(
                                                "assets/images/eye.png")),
                                        SizedBox(width: 5),
                                        Container(
                                          height: height * 0.065,
                                          width: width * 0.65,
                                          child: Center(
                                            child: Text(
                                              e.address,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: textSize * 15),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                            child: InkWell(
                                          onTap: () {
                                            widget.onTap(e.latitude,
                                                e.longitude, "Drowsy Alert");
                                          },
                                          child: SizedBox(
                                            height: height * 0.06,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Icon(
                                                Icons.map_rounded,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                      ]),
                                ),
                                Expanded(
                                  child: Container(
                                    width: width * 0.95,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          height: height * 0.065,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "Start",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Text(
                                                        text.toString(),
                                                        style: TextStyle(
                                                            color: Colors.blue,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
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
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "End",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: text2
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
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
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "Duration",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Text(
                                                      duration,
                                                      style: TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ),
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
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "BPM",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: e
                                                                  .avgBlinksPerMinute
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
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
                                boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.all(Radius.circular(25)),
                                )),
                          ),
                        );
                      }).toList()
                    ],
                  ),
                ),
        ))
      ],
    );
  }
}

class Speeding extends StatefulWidget {
  List<speedingHistoryVal> data;
  Function onTap;
  Speeding(this.data, this.onTap);

  @override
  State<Speeding> createState() => _SpeedingState();
}

class _SpeedingState extends State<Speeding> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: width * 0.1,
            ),
            Container(
                height: height * 0.08,
                child: Lottie.network(
                    "https://assets3.lottiefiles.com/packages/lf20_kqfglvmb.json")),
            Text(
              "Speeding Data",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: textSize * 30),
            ),
          ],
        ),
        Expanded(
            child: Container(
          child: widget.data.length == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.3,
                      child: Lottie.network(
                          "https://assets9.lottiefiles.com/datafiles/vhvOcuUkH41HdrL/data.json"),
                    ),
                    Text(
                      "No Speeding\nInstances",
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
                  context: context,
                  removeTop: true,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: height * 0.005,
                      ),
                      ...widget.data.map((e) {
                        String text = "";
                        text = e.time.hour.toString();
                        if (e.time.minute <= 9) {
                          text = text + ":0" + e.time.minute.toString();
                        } else {
                          text = text + ":" + e.time.minute.toString();
                        }
                        return Container(
                          height: height * 0.16,
                          margin:
                              EdgeInsets.symmetric(horizontal: width * 0.025),
                          child: Neumorphic(
                            child: Column(
                              children: [
                                Container(
                                  width: width * 0.95,
                                  height: height * 0.085,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 10),
                                        Container(
                                            height: height * 0.06,
                                            child: Image.asset(
                                                "assets/images/speeding.png")),
                                        SizedBox(width: 5),
                                        Container(
                                          height: height * 0.065,
                                          width: width * 0.65,
                                          child: Center(
                                            child: Text(
                                              e.address,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: textSize * 15),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                            child: InkWell(
                                          onTap: () {
                                            widget.onTap(e.latitude,
                                                e.longitude, "Drowsy Alert");
                                          },
                                          child: SizedBox(
                                            height: height * 0.06,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Icon(
                                                Icons.map_rounded,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                      ]),
                                ),
                                Expanded(
                                  child: Container(
                                    width: width * 0.95,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          height: height * 0.065,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "Speed",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: e.speed
                                                                  .toInt()
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                            TextSpan(
                                                              text: "M/H",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      textSize *
                                                                          4),
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
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "Limit",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: e.speedLimit
                                                                  .toInt()
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                            TextSpan(
                                                              text: "M/H",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      textSize *
                                                                          4),
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
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "Time",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: text,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
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
                                boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.all(Radius.circular(25)),
                                )),
                          ),
                        );
                      }).toList()
                    ],
                  ),
                ),
        ))
      ],
    );
  }
}

class Drowsy extends StatefulWidget {
  List<blinkSession> data;
  Function onTap;
  Drowsy(this.data, this.onTap);
  @override
  State<Drowsy> createState() => _DrowsyState();
}

class _DrowsyState extends State<Drowsy> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: width * 0.1,
            ),
            Container(
                height: height * 0.08,
                child: Lottie.network(
                    "https://assets2.lottiefiles.com/packages/lf20_zbyipz72.json")),
            Text(
              "Drowsy Data",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: textSize * 30),
            ),
          ],
        ),
        Expanded(
            child: Container(
          child: widget.data.length == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.3,
                      child: Lottie.network(
                          "https://assets9.lottiefiles.com/datafiles/vhvOcuUkH41HdrL/data.json"),
                    ),
                    Text(
                      "No Drowsy\nInstances",
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
                  context: context,
                  removeTop: true,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: height * 0.005,
                      ),
                      ...widget.data.map((e) {
                        String text = "";
                        text = e.timeStarted.hour.toString();
                        if (e.timeStarted.minute <= 9) {
                          text = text + ":0" + e.timeStarted.minute.toString();
                        } else {
                          text = text + ":" + e.timeStarted.minute.toString();
                        }
                        String text2 = "";
                        text2 = e.timeEnded.hour.toString();
                        if (e.timeEnded.minute <= 9) {
                          text2 = text2 + ":0" + e.timeEnded.minute.toString();
                        } else {
                          text2 = text2 + ":" + e.timeEnded.minute.toString();
                        }
                        String duration = "";
                        Duration totalDuration =
                            e.timeEnded.difference(e.timeStarted);
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
                        if (totalDuration.inSeconds > 0) {
                          duration = duration +
                              totalDuration.inSeconds.toString() +
                              " S ";
                        }
                        return Container(
                          height: height * 0.16,
                          margin: EdgeInsets.symmetric(
                              horizontal: width * 0.025,
                              vertical: height * 0.01),
                          child: Neumorphic(
                            child: Column(
                              children: [
                                Container(
                                  width: width * 0.95,
                                  height: height * 0.085,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 10),
                                        Container(
                                            height: height * 0.06,
                                            child: Image.asset(
                                                "assets/images/sleepWarning.png")),
                                        SizedBox(width: 5),
                                        Container(
                                          height: height * 0.065,
                                          width: width * 0.65,
                                          child: Center(
                                            child: Text(
                                              e.address,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: textSize * 15),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                            child: InkWell(
                                          onTap: () {
                                            widget.onTap(e.latitude,
                                                e.longitude, "Sleepy Alert");
                                          },
                                          child: SizedBox(
                                            height: height * 0.06,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Icon(
                                                Icons.map_rounded,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                      ]),
                                ),
                                Expanded(
                                  child: Container(
                                    width: width * 0.95,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          height: height * 0.065,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "Start",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: text
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
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
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "End",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: text2
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
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
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "Duration",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: duration,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
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
                                boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.all(Radius.circular(25)),
                                )),
                          ),
                        );
                      }).toList()
                    ],
                  ),
                ),
        ))
      ],
    );
  }
}

class Breaks extends StatefulWidget {
  List data;
  Function onTap;
  Breaks(this.data, this.onTap);

  @override
  State<Breaks> createState() => _BreaksState();
}

class _BreaksState extends State<Breaks> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: width * 0.05,
            ),
            Container(
                height: height * 0.08,
                child: Image.asset("assets/images/breaks.png")),
            Text(
              "Deceleration Data",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: textSize * 30),
            ),
          ],
        ),
        Expanded(
            child: Container(
          child: widget.data.length == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: height * 0.3,
                      child: Lottie.network(
                          "https://assets9.lottiefiles.com/datafiles/vhvOcuUkH41HdrL/data.json"),
                    ),
                    Text(
                      "No Deceleration\nInstances",
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
                  context: context,
                  removeTop: true,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: height * 0.012,
                      ),
                      ...widget.data.map((e) {
                        DateTime propTime = DateTime.parse(e["time"]);
                        String text = "";
                        text = propTime.hour.toString();
                        if (propTime.minute <= 9) {
                          text = text + ":0" + propTime.minute.toString();
                        } else {
                          text = text + ":" + propTime.minute.toString();
                        }
                        return Container(
                          height: height * 0.16,
                          margin: EdgeInsets.only(
                              left: width * 0.025,
                              right: width * 0.025,
                              bottom: height * 0.01),
                          child: Neumorphic(
                            child: Column(
                              children: [
                                Container(
                                  width: width * 0.95,
                                  height: height * 0.085,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 10),
                                        Container(
                                            height: height * 0.06,
                                            child: Image.asset(
                                                "assets/images/breaks.png")),
                                        SizedBox(width: 5),
                                        Container(
                                          height: height * 0.065,
                                          width: width * 0.65,
                                          child: Center(
                                            child: Text(
                                              e["location"],
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: textSize * 15),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                            child: InkWell(
                                          onTap: () {
                                            widget.onTap(e["lat"], e["lon"],
                                                "Deceleration Alert");
                                          },
                                          child: SizedBox(
                                            height: height * 0.06,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Icon(
                                                Icons.map_rounded,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        )),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                      ]),
                                ),
                                Expanded(
                                  child: Container(
                                    width: width * 0.95,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          height: height * 0.065,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "From",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: e["from"]
                                                                  .toInt()
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                            TextSpan(
                                                              text: "mph"
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      textSize *
                                                                          10),
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
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "To",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: e["to"]
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                            TextSpan(
                                                              text: "mph"
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      textSize *
                                                                          10),
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
                                                height: height * 0.002,
                                              ),
                                              Text(
                                                "Time",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: textSize * 15),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: text,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
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
                                boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.all(Radius.circular(25)),
                                )),
                          ),
                        );
                      }).toList()
                    ],
                  ),
                ),
        ))
      ],
    );
  }
}

class DriveDataScreen extends StatefulWidget {
  DrivingHistory history;
  User user;
  bool viewOnly;
  DriveDataScreen(this.history, this.user, this.viewOnly);
  @override
  State<DriveDataScreen> createState() => _DriveDataScreenState();
}

class _DriveDataScreenState extends State<DriveDataScreen> {
  @override
  String timeTaken = "";
  int chosenIndex = -1;
  bool useGoogleMaps = false;
  bool useGoogleMapsGo = false;
  bool useAppleMaps = false;
  List<AvailableMap> availableMaps = [];
  List<Widget> possibleOptions = [
    Container(),
    Container(),
    Container(),
    Container()
  ];
  void initStateFunction() async {
    availableMaps = await MapLauncher.installedMaps;
    for (int i = 0; i < availableMaps.length; i++) {
      if (availableMaps[i].mapType == MapType.google) {
        useGoogleMaps = true;
      } else if (availableMaps[i].mapType == MapType.googleGo) {
        useGoogleMapsGo = true;
      } else if (availableMaps[i].mapType == MapType.apple) {
        useAppleMaps = true;
      }
    }
    Map appendData = widget.history.drivingToJson();
    List<String> sendTokens = [];
    DataSnapshot data = await FirebaseDatabase.instance.ref("User").get();
    Map allUsersData = data.value as Map;
    for (int i = 0; i < widget.user.LocationSharingPeople.length; i++) {
      Map curUserData = allUsersData[widget.user.LocationSharingPeople[i]];
      List updateDataList = [];
      if (curUserData.containsKey("friendsRecentDrives")) {
        print(curUserData["friendsRecentDrives"]);
        if (curUserData["friendsRecentDrives"]
            .containsKey(widget.user.phoneNumber)) {
          updateDataList.addAll(
              curUserData["friendsRecentDrives"][widget.user.phoneNumber]);
        }
      }

      updateDataList.add(appendData);
      FirebaseDatabase.instance
          .ref("User")
          .child(widget.user.LocationSharingPeople[i])
          .child("friendsRecentDrives")
          .child(widget.user.phoneNumber)
          .set(updateDataList);
      if (curUserData.containsKey("FCM")) {
        sendTokens.add(curUserData["FCM"]);
      }
    }
    sendNotification(
        "Drive Report",
        sendTokens,
        widget.user.firstName +
            " " +
            widget.user.lastName +
            " just completed a drive. Information about his trip has been shared with you, please go to the friends screen to view.");
  }

  void pushMap(double lat, double lon, String title) async {
    if (useGoogleMaps) {
      await MapLauncher.showMarker(
        mapType: MapType.google,
        coords: Coords(lat, lon),
        title: title,
      );
    } else if (useAppleMaps) {
      await MapLauncher.showMarker(
        mapType: MapType.apple,
        coords: Coords(lat, lon),
        title: title,
      );
    } else if (useGoogleMapsGo) {
      await MapLauncher.showMarker(
        mapType: MapType.googleGo,
        coords: Coords(lat, lon),
        title: title,
      );
    } else {
      availableMaps.first.showMarker(
        coords: Coords(lat, lon),
        title: title,
      );
    }
  }

  void initState() {
    initStateFunction();
    possibleOptions[3] = Blinking(widget.history.blinking, pushMap);
    possibleOptions[2] = Speeding(widget.history.speeding, pushMap);
    possibleOptions[1] = Breaks(widget.history.hardBreak, pushMap);
    possibleOptions[0] = Drowsy(widget.history.drowsy, pushMap);
    setState(() {
      possibleOptions;
    });
    Duration totalTime = DateTime.parse(widget.history.endingTime)
        .difference(DateTime.parse(widget.history.startingTime));
    if (totalTime.inDays > 0) {
      timeTaken = timeTaken + totalTime.inDays.toString() + " D ";
    }
    if (totalTime.inHours > 0) {
      if (totalTime.inHours > 24) {
        timeTaken = timeTaken + (totalTime.inHours % 24).toString() + " H ";
      } else {
        timeTaken = timeTaken + totalTime.inHours.toString() + " H ";
      }
    }
    if (totalTime.inMinutes > 0) {
      if (totalTime.inMinutes > 60) {
        timeTaken = timeTaken + (totalTime.inMinutes % 60).toString() + " M ";
      } else {
        timeTaken = timeTaken + totalTime.inMinutes.toString() + " M ";
      }
    } else {
      timeTaken = timeTaken + totalTime.inSeconds.toString() + " S ";
    }
    setState(() {
      timeTaken;
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.04,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(width * 0.04, 0, width * 0.04, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: width * 0.1,
                  ),
                  Container(
                    height: height * 0.05,
                    child: Lottie.network(
                        "https://assets10.lottiefiles.com/packages/lf20_gvofx8ha.json"),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: textSize * 35,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(child: Container()),
                  Container(
                    height: height * 0.07,
                    width: height * 0.07,
                    child: widget.viewOnly
                        ? chosenIndex != -1
                            ? NeumorphicButton(
                                onPressed: () async {
                                  // Map jsonData = jsonDecode(response.body);
                                  setState(() {
                                    chosenIndex = -1;
                                  });
                                },
                                padding: EdgeInsets.fromLTRB(width * 0,
                                    height * 0, width * 0, height * 0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: textSize * 30,
                                        color: Colors.red,
                                      ),
                                    ]),
                                style: NeumorphicStyle(
                                    border: const NeumorphicBorder(
                                        color: Colors.red, width: 3),
                                    boxShape: NeumorphicBoxShape.circle(),
                                    depth: 0,
                                    color: Colors.grey.shade300,
                                    lightSource: LightSource.topLeft,
                                    shape: NeumorphicShape.concave))
                            : NeumorphicButton(
                                onPressed: () async {
                                  Map appendData =
                                      widget.history.drivingToJson();

                                  Navigator.of(context).pop();
                                },
                                padding: EdgeInsets.fromLTRB(width * 0,
                                    height * 0, width * 0, height * 0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: textSize * 30,
                                        color: Colors.blue,
                                      ),
                                    ]),
                                style: NeumorphicStyle(
                                    border: const NeumorphicBorder(
                                        color: Colors.blue, width: 3),
                                    boxShape: NeumorphicBoxShape.circle(),
                                    depth: 0,
                                    color: Colors.grey.shade300,
                                    lightSource: LightSource.topLeft,
                                    shape: NeumorphicShape.concave))
                        : chosenIndex != -1
                            ? NeumorphicButton(
                                onPressed: () async {
                                  // Map jsonData = jsonDecode(response.body);
                                  setState(() {
                                    chosenIndex = -1;
                                  });
                                },
                                padding: EdgeInsets.fromLTRB(width * 0,
                                    height * 0, width * 0, height * 0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: textSize * 30,
                                        color: Colors.red,
                                      ),
                                    ]),
                                style: NeumorphicStyle(
                                    border: const NeumorphicBorder(
                                        color: Colors.red, width: 3),
                                    boxShape: NeumorphicBoxShape.circle(),
                                    depth: 0,
                                    color: Colors.grey.shade300,
                                    lightSource: LightSource.topLeft,
                                    shape: NeumorphicShape.concave))
                            : NeumorphicButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                padding: EdgeInsets.fromLTRB(width * 0,
                                    height * 0, width * 0, height * 0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.done,
                                        size: textSize * 30,
                                        color: Colors.blue,
                                      ),
                                    ]),
                                style: NeumorphicStyle(
                                    border: const NeumorphicBorder(
                                        color: Colors.blue, width: 3),
                                    boxShape: NeumorphicBoxShape.circle(),
                                    depth: 0,
                                    color: Colors.grey.shade300,
                                    lightSource: LightSource.topLeft,
                                    shape: NeumorphicShape.concave)),
                  ),
                  SizedBox(
                    width: width * 0.01,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Container(
                height: height * 0.135,
                width: width * 0.95,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    color: Colors.grey.shade300,
                    depth: 2,
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.all(Radius.circular(25))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: height * 0.06,
                            child: Lottie.network(
                                "https://lottie.host/878b8487-9cab-4a1b-a4fa-b595f6f94234/gm8y6i3kWc.json"),
                          ),
                          Text(" From",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: textSize * 25))
                        ],
                      ),
                      Expanded(
                          child: Container(
                        alignment: Alignment.center,
                        width: width * 0.9,
                        child: Text(
                          widget.history.starting,
                          maxLines: 2,
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: textSize * 15),
                        ),
                      )),
                      SizedBox(height: height * 0.02)
                    ],
                  ),
                )),
            SizedBox(
              height: height * 0.02,
            ),
            Container(
              height: height * 0.135,
              width: width * 0.95,
              child: Neumorphic(
                style: NeumorphicStyle(
                  color: Colors.grey.shade300,
                  depth: 2,
                  boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.all(Radius.circular(25))),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: height * 0.06,
                          child: Lottie.network(
                              "https://assets7.lottiefiles.com/packages/lf20_hrwp5nsb.json"),
                        ),
                        Text(" To",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                                fontSize: textSize * 25))
                      ],
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      width: width * 0.9,
                      child: Text(
                        widget.history.ending,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: textSize * 15),
                      ),
                    )),
                    SizedBox(height: height * 0.02)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Expanded(
              child: Container(
                  child: chosenIndex != -1
                      ? possibleOptions[chosenIndex]
                      : ListView(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * 0.03, vertical: 0),
                              height: height * 0.15,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      print(DateTime.parse(
                                              widget.history.endingTime)
                                          .difference(DateTime.parse(
                                              widget.history.startingTime))
                                          .inSeconds);
                                    },
                                    child: Container(
                                      width: width * 0.43,
                                      height: height * 0.15,
                                      child: Neumorphic(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: height * 0.03,
                                                  child: Lottie.network(
                                                      "https://assets4.lottiefiles.com/private_files/lf30_nhg4au0e.json"),
                                                ),
                                                Text(" Distance",
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize:
                                                            textSize * 20)),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: width * 0.38,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: height * 0.005),
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    (widget.history
                                                                .distanceTraveled)
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        style: NeumorphicStyle(
                                            color: Colors.grey.shade300,
                                            depth: 2,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.all(
                                                        Radius.circular(25)))),
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  InkWell(
                                    onTap: () {
                                      print(DateTime.parse(
                                              widget.history.endingTime)
                                          .difference(DateTime.parse(
                                              widget.history.startingTime))
                                          .inSeconds);
                                    },
                                    child: Container(
                                      width: width * 0.43,
                                      height: height * 0.15,
                                      child: Neumorphic(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: height * 0.03,
                                                  child: Lottie.network(
                                                      "https://lottie.host/f9b93798-0da2-47eb-938c-ce0aa2542bcd/WjoUTsWktm.json"),
                                                ),
                                                Text(" Time",
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize:
                                                            textSize * 20)),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: width * 0.38,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: height * 0.005),
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    timeTaken,
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        style: NeumorphicStyle(
                                            color: Colors.grey.shade300,
                                            depth: 2,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.all(
                                                        Radius.circular(25)))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * 0.03),
                              height: height * 0.15,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        chosenIndex = 3;
                                      });
                                    },
                                    child: Container(
                                      width: width * 0.43,
                                      height: height * 0.15,
                                      child: Neumorphic(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: height * 0.03,
                                                  child: Lottie.network(
                                                      "https://lottie.host/f8ad0aa7-957b-4620-a8da-d0ddd2733640/53F2UCvC3D.json"),
                                                ),
                                                Text(" Blinking",
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize:
                                                            textSize * 20)),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: width * 0.38,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: height * 0.005),
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    widget
                                                        .history.blinking.length
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        style: NeumorphicStyle(
                                            color: Colors.grey.shade300,
                                            depth: 2,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.all(
                                                        Radius.circular(25)))),
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        chosenIndex = 0;
                                      });
                                    },
                                    child: Container(
                                      width: width * 0.43,
                                      height: height * 0.15,
                                      child: Neumorphic(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: height * 0.03,
                                                  child: Lottie.network(
                                                      "https://assets2.lottiefiles.com/packages/lf20_zbyipz72.json"),
                                                ),
                                                Text("Drowsy",
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize:
                                                            textSize * 20)),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: width * 0.38,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: height * 0.005),
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    widget.history.drowsy.length
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        style: NeumorphicStyle(
                                            color: Colors.grey.shade300,
                                            depth: 2,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.all(
                                                        Radius.circular(25)))),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * 0.03),
                              height: height * 0.15,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        chosenIndex = 2;
                                      });
                                    },
                                    child: Container(
                                      width: width * 0.43,
                                      height: height * 0.15,
                                      child: Neumorphic(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: height * 0.03,
                                                  child: Lottie.network(
                                                      "https://assets3.lottiefiles.com/packages/lf20_o4C0VO.json"),
                                                ),
                                                Text(" Speeding",
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize:
                                                            textSize * 20)),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: width * 0.38,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: height * 0.005),
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    widget
                                                        .history.speeding.length
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        style: NeumorphicStyle(
                                            color: Colors.grey.shade300,
                                            depth: 2,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.all(
                                                        Radius.circular(25)))),
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        chosenIndex = 1;
                                      });
                                    },
                                    child: Container(
                                      width: width * 0.43,
                                      height: height * 0.15,
                                      child: Neumorphic(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    height: height * 0.03,
                                                    child: Image.asset(
                                                        "assets/images/delay.png")),
                                                Text(" Breaks",
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize:
                                                            textSize * 20)),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: width * 0.38,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: height * 0.005),
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    widget.history.hardBreak
                                                        .length
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        style: NeumorphicStyle(
                                            color: Colors.grey.shade300,
                                            depth: 2,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.all(
                                                        Radius.circular(25)))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * 0.04),
                              height: height * 0.2,
                              child: Neumorphic(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: width * 0.03,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: height * 0.15,
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: height * 0.08,
                                                  child: Lottie.asset(
                                                      "assets/animations/texting.json",
                                                      repeat: true),
                                                )
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    widget
                                                        .history.messagesBlocked
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width * 0.03,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: height * 0.15,
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: height * 0.08,
                                                  child: Lottie.asset(
                                                      "assets/animations/phoneCall.json",
                                                      repeat: true),
                                                )
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    widget.history.callsBlocked
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width * 0.03,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: height * 0.15,
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: height * 0.08,
                                                  child: Lottie.asset(
                                                      "assets/animations/warning.json",
                                                      repeat: true),
                                                )
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    widget.history.warningsGiven
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width * 0.03,
                                    ),
                                  ],
                                ),
                                style: NeumorphicStyle(
                                    color: Colors.grey.shade300,
                                    depth: 2,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.all(Radius.circular(25)))),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            )
                          ],
                        )),
            )
          ],
        ),
      ),
    );
  }
}
