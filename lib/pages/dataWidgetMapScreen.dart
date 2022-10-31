// ignore_for_file: unnecessary_const

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import 'MapPageScreen.dart';

class weatherDataWidget1 extends StatefulWidget {
  String description;
  weather data;
  String assetAddress;
  DateTime currentTime;
  weatherDataWidget1(
      this.description, this.data, this.assetAddress, this.currentTime);
  @override
  State<weatherDataWidget1> createState() => _weatherDataWidgetState1();
}

class _weatherDataWidgetState1 extends State<weatherDataWidget1> {
  double backSplashHeight = 0;
  double iconHeight = 0;

  void initStateFunction() async {
    await Duration(milliseconds: 500);
    setState(() {
      backSplashHeight = 0.45;
    });
  }

  void initState() {
    print("here");
    initStateFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: Container(
            height: height,
            width: width,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  height: height * backSplashHeight,
                  width: width,
                  curve: Curves.easeIn,
                  child: Container(
                    height: height * backSplashHeight,
                    width: width,
                    child: iconHeight == 0
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: width,
                                height: height * 0.12,
                              ),
                              Container(
                                  width: 0.17 * height,
                                  height: 0.17 * height,
                                  child: Image.asset(widget.assetAddress)),
                              Text(
                                widget.data.type +
                                    "(" +
                                    widget.data.temp
                                        .toInt()
                                        .toString() +
                                    ")°",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            40,
                                    color: Colors.grey.shade300,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                  ),
                  onEnd: () {
                    setState(() {
                      iconHeight = 0.1;
                    });
                    print(iconHeight);
                  },
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50))),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: height * 0.01, vertical: height * 0.04),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: height * 0.08,
                          width: height * 0.08,
                          child: NeumorphicButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              padding: EdgeInsets.fromLTRB(
                                  width * 0, height * 0, width * 0, height * 0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back,
                                      size: MediaQuery.of(context)
                                              .textScaleFactor *
                                          25,
                                      color: Colors.red,
                                    ),
                                  ]),
                              style: NeumorphicStyle(
                                  boxShape: NeumorphicBoxShape.circle(),
                                  border: const NeumorphicBorder(
                                      color: Colors.red, width: 2),
                                  shadowLightColor: Colors.transparent,
                                  depth: 50,
                                  color: Colors.grey.shade300,
                                  lightSource: LightSource.topLeft,
                                  shape: NeumorphicShape.concave)),
                        ),
                      ]),
                ),
                Container(
                  width: width,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: height * 0.4),
                        Text(
                          widget.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 20,
                            color: Colors.grey.shade300,
                          ),
                        )
                      ]),
                ),
                Container(
                  width: width,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: height * 0.35),
                        Text(
                          widget.data.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).textScaleFactor * 30,
                              color: Colors.grey.shade300,
                              fontWeight: FontWeight.w700),
                        )
                      ]),
                ),
                Container(
                  width: width,
                  height: height,
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.45,
                        width: width,
                      ),
                      iconHeight == 0
                          ? Container()
                          : Expanded(
                              child: Container(
                              color: Colors.grey.shade300,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          height: height * 0.05,
                                          //color : Colors.blue,
                                          child: const FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              "Temp.",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          )),
                                      Container(
                                        height: height * 0.09,
                                        width: height * 0.09,
                                        child: Lottie.network(
                                            "https://assets3.lottiefiles.com/temp/lf20_rpC1Rd.json"),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            height: height * 0.03,
                                            child: const FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text("Temp",
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ))),
                                          ),
                                          Container(
                                              height: height * 0.05,
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                      widget.data.temp
                                                              .toInt()
                                                              .toString() +
                                                          "° F",
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ))))
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            height: height * 0.03,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text("Feels Like",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                  )),
                                            ),
                                          ),
                                          Container(
                                              height: height * 0.05,
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                      widget.data.feel_like
                                                              .toInt()
                                                              .toString() +
                                                          "° F",
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ))))
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            height: height * 0.03,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text("Time",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                  )),
                                            ),
                                          ),
                                          Container(
                                              height: height * 0.05,
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                      widget.currentTime.hour
                                                              .toString() +
                                                          ":" +
                                                          "0" +
                                                          widget.currentTime
                                                              .minute
                                                              .toString(),
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ))))
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          height: height * 0.05,
                                          //color : Colors.blue,
                                          margin: EdgeInsets.only(
                                              left: width * 0.02),
                                          child: const FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              "Wind",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          )),
                                      Container(
                                        height: height * 0.09,
                                        width: height * 0.09,
                                        child: Lottie.network(
                                            "https://assets5.lottiefiles.com/packages/lf20_vcg89p.json"),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            height: height * 0.03,
                                            child: const FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text("Directions",
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ))),
                                          ),
                                          Container(
                                            height: height * 0.05,
                                            width: height * 0.05,
                                            child: RotationTransition(
                                              turns: AlwaysStoppedAnimation(
                                                  ((180 + widget.data.windDeg) %
                                                          360) /
                                                      360),
                                              child: Container(
                                                height: height * 0.04,
                                                width: height * 0.04,
                                                child: const FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Icon(
                                                      Icons.arrow_back,
                                                      color: Colors.blue,
                                                    )),
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(100)),
                                                ),
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(100)),
                                                color: Colors.grey.shade300,
                                                border: Border.all(
                                                    color: Colors.blue,
                                                    width: 4)),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            height: height * 0.03,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text("Speed(M/S)",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                  )),
                                            ),
                                          ),
                                          Container(
                                              height: height * 0.05,
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                      widget.data.windSpeed
                                                          .toString(),
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ))))
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            height: height * 0.03,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text("Gust(M/S)",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                  )),
                                            ),
                                          ),
                                          Container(
                                              height: height * 0.05,
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                      widget.data.gust
                                                          .toString(),
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ))))
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          height: height * 0.05,
                                          margin: EdgeInsets.only(
                                              left: width * 0.02, bottom: 0),
                                          child: const FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              "Land",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          )),
                                      Container(
                                        height: height * 0.09,
                                        width: height * 0.09,
                                        child: Lottie.network(
                                            "https://assets8.lottiefiles.com/packages/lf20_umBOmV.json"),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            height: height * 0.03,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text("Visibility",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                  )),
                                            ),
                                          ),
                                          Container(
                                              height: height * 0.05,
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                      (widget.data.visibility /
                                                                  1000)
                                                              .toInt()
                                                              .toString() +
                                                          "KM",
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ))))
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            height: height * 0.03,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text("Humidity",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                  )),
                                            ),
                                          ),
                                          Container(
                                              height: height * 0.05,
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                      widget.data.humidity
                                                              .toInt()
                                                              .toString() +
                                                          "%",
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ))))
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            height: height * 0.03,
                                            child: const FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text("Grnd Lvl(hPa)",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w800,
                                                  )),
                                            ),
                                          ),
                                          Container(
                                              height: height * 0.05,
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                      widget.data.groundLevel
                                                          .toString(),
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ))))
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ))
                    ],
                  ),
                )
              ],
            )));
  }
}
