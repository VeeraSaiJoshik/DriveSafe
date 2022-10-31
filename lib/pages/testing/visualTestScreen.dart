// ignore_for_file: avoid_print, sized_box_for_whitespace, sort_child_properties_last
// ignore_for_file: avoid_print, prefer_const_constructors, sort_child_properties_last
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisualTest extends StatefulWidget {
  const VisualTest({Key? key}) : super(key: key);

  @override
  State<VisualTest> createState() => _VisualTestState();
}

enum BuzzerActive { active, init, deactive }

class _VisualTestState extends State<VisualTest>
    with SingleTickerProviderStateMixin {
  void pushEndScreen() {
    finalTestResult();
    if (index == 5) {
      setState(() {
        showEndScreen = true;
      });
    }
  }

  void finalTestResult() {
    int total = 0;
    for (int i = 0; i < 5; i++) {
      total = total + test1Result[i];
      if (test1Result[i] == 0) {
        total = total + 700;
      }
    }
    test1AverageScor = total ~/ 5;
    total = 0;
    for (int i = 0; i < 5; i++) {
      total = total + test1Result[i];
      if (test2Result[i] == 0) {
        total = total + 700;
      }else if(test2Result[i] == -2){
        total = total + 600;
      }
    }
    test2AverageScor = total ~/ 5;
  }

  @override
  late SharedPreferences prefs;
  BuzzerActive active = BuzzerActive.deactive;
  BuzzerActive active1 = BuzzerActive.deactive;
  bool ind = true;
  int quizBowlResults = 0;
  int test1AverageScor = 0;
  int test2AverageScor = 0;
  bool showEndScreen = false;
  @override
  int testingScreen = 0;
  int queryCounter = 0;
  List<int> test1Result = [-1, -1, -1, -1, -1];
  List test2Result = [-1, -1, -1, -1, -1];
  Color buzzerColor = Colors.red;
  List<Color> possibleColors = const [
    Color.fromARGB(255, 6, 186, 99),
    Color.fromARGB(255, 231, 29, 54),
    Color.fromARGB(255, 234, 122, 244)
  ];
  List allColorTest = [];
  DateTime colorShowTime = DateTime.now();
  double? buzzerDepth = 0;
  DateTime estimatedTime = DateTime.now();
  DateTime hitTime = DateTime.now();
  late TabController tabBarController;
  int i = 0;
  int index = 0;
  bool quickClick = false;
  Color hitBuzzerColor = Colors.grey;
  double colorButtonDepth = 0;
  int testingScreenIndex = 0;
  void reset() {
    i++;
    buzzerDepth = 0;
    hitBuzzerColor = Colors.grey;
    active = BuzzerActive.deactive;
    setState(() {
      buzzerDepth;
      hitBuzzerColor;
      active;
    });
  }

  @override
  void initState() {
    tabBarController = new TabController(length: 2, vsync: this);
    tabBarController.addListener(() {
      setState(() {
        testingScreenIndex = tabBarController.index;
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    String phoneNumber = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Container(
        width: width,
        height: height,
        child: Column(
          children: [
            SizedBox(
              height: width * 0.08,
            ),
            Container(
              child: Row(
                children: [
                  SizedBox(
                    width: width * 0.06,
                  ),
                  Container(
                    width: width * 0.15,
                    height: width * 0.15,
                    child: NeumorphicButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      style: NeumorphicStyle(
                          color: Colors.red,
                          depth: 5,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(100))),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.02,
                  ),
                  Text(
                    "",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                      fontSize: textSize * 40,
                      shadows: [
                        const Shadow(
                            offset: Offset(1, 1),
                            color: Colors.black38,
                            blurRadius: 10),
                        Shadow(
                            // ignore: prefer_const_constructors
                            offset: Offset(-1, -1),
                            color: Colors.white.withOpacity(0.85),
                            blurRadius: 10)
                      ],
                    ),
                  ),
                ],
              ),
              width: width,
            ),
            Expanded(
                child: Container(
              width: width,
              child: Column(
                children: testingScreen == 0
                    ? [
                        Container(
                          height: height * 0.2,
                          child: Lottie.network(
                              "https://assets1.lottiefiles.com/private_files/lf30_dflaa25e.json"),
                        ),
                        Text(
                          "Reaction Test",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: textSize * 40),
                        ),
                        Container(
                            width: width,
                            height: height * 0.06,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(width * 0.01),
                                    decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(72, 255, 255, 255),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100))),
                                    child: Row(children: [
                                      ...test1Result.map((e) {
                                        if (e == -1) {
                                          return Container(
                                            height: height * 0.06,
                                            width: height * 0.06,
                                            child: Center(
                                              child: CircleAvatar(
                                                radius: height * 0.018,
                                                backgroundColor: Colors.grey,
                                              ),
                                            ),
                                          );
                                        } else if (e == 0) {
                                          return Container(
                                            height: height * 0.06,
                                            child: Center(
                                              child: Lottie.network(
                                                  "https://assets6.lottiefiles.com/private_files/lf30_jtkhrafm.json",
                                                  repeat: false),
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            height: height * 0.06,
                                            child: Center(
                                              child: Lottie.network(
                                                  "https://assets3.lottiefiles.com/packages/lf20_afs4kbqm.json",
                                                  repeat: false),
                                            ),
                                          );
                                        }
                                      }).toList()
                                    ])),
                              ],
                            )),
                        Text(
                          "Reaction Time :",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: textSize * 30),
                        ),
                        Text(
                          (active == BuzzerActive.init ||
                                      active == BuzzerActive.active) ||
                                  i == 0
                              ? "Unkown"
                              : test1Result[i - 1].toString() + " Milli-Sec",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: textSize * 28),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: height * 0.01,
                          ),
                        ),
                        Container(
                          height: height * 0.4,
                          width: width * 0.95,
                          // ignore: sort_child_properties_last
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: width * 0.6,
                                height: height * 0.13,
                                child: NeumorphicButton(
                                  onPressed: () {
                                    if (active == BuzzerActive.init) {
                                      print(i);
                                      print("thisis");
                                      test1Result[i] = 0;
                                      setState(() {
                                        test1Result;
                                      });
                                      if (i < 4) {
                                        reset();
                                      } else {
                                        AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.SUCCES,
                                            title: "Reaction Test Complete",
                                            desc:
                                                "Click on the continue button to move on to the next test",
                                            titleTextStyle: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w800,
                                              fontSize: textSize * 25,
                                            ),
                                            descTextStyle: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w700,
                                              fontSize: textSize * 20,
                                            ),
                                            btnOkColor: Colors.green,
                                            btnOkText: "Continue",
                                            btnOkOnPress: () {
                                              setState(() {
                                                for (int fi = 0; fi < 5; fi++) {
                                                  allColorTest
                                                      .add(Random().nextInt(3));
                                                }
                                                print(allColorTest);
                                                print("this is the colorTest");
                                                i = 0;
                                                testingScreen = 1;
                                                print(active);
                                              });
                                            }).show();
                                      }
                                      quickClick = true;
                                      print(quickClick);
                                    } else {
                                      int diff = DateTime.now()
                                          .difference(estimatedTime)
                                          .inMilliseconds;
                                      if (diff > 500) {
                                        test1Result[i] = diff - 400;
                                      } else {
                                        test1Result[i] = 100;
                                      }

                                      print(test1Result[i]);
                                      setState(() {
                                        test1Result;
                                      });
                                      if (i < 4) {
                                        reset();
                                      } else {
                                        AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.SUCCES,
                                            title: "Reaction Test Complete",
                                            desc:
                                                "Click on the continue button to move on to the next test",
                                            titleTextStyle: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w800,
                                              fontSize: textSize * 25,
                                            ),
                                            descTextStyle: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w700,
                                              fontSize: textSize * 20,
                                            ),
                                            btnOkColor: Colors.green,
                                            btnOkText: "Continue",
                                            btnOkOnPress: () {
                                              setState(() {
                                                for (int fi = 0; fi < 5; fi++) {
                                                  allColorTest
                                                      .add(Random().nextInt(3));
                                                }
                                                print(allColorTest);
                                                print("this is the colorTest");
                                                i = 0;
                                                testingScreen = 1;
                                                print(active);
                                              });
                                            }).show();
                                      }
                                    }
                                  },
                                  style: NeumorphicStyle(
                                      color: hitBuzzerColor,
                                      depth: buzzerDepth,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          const BorderRadius.all(
                                              Radius.circular(100)))),
                                ),
                              ),
                              SizedBox(
                                width: width * 0.6,
                                height: height * 0.13,
                                child: GestureDetector(
                                  onLongPress: () {
                                    print("here");
                                    setState(() {
                                      buzzerDepth = 10;
                                      hitBuzzerColor = Colors.grey;
                                      active = BuzzerActive.init;
                                    });
                                    Future.delayed(
                                        Duration(
                                            seconds: (Random().nextInt(5) + 3)),
                                        () {
                                      if (quickClick == false) {
                                        hitBuzzerColor;
                                        estimatedTime = DateTime.now();
                                        hitBuzzerColor = Colors.green;
                                        active = BuzzerActive.active;
                                        setState(() {});
                                      } else {
                                        quickClick = false;
                                      }
                                    });
                                  },
                                  child: Neumorphic(
                                    style: NeumorphicStyle(
                                        color: buzzerColor,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            // ignore: prefer_const_constructors
                                            BorderRadius.all(
                                                // ignore: prefer_const_constructors
                                                Radius.circular(100)))),
                                  ),
                                ),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              border: Border.all(color: Colors.blue, width: 5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                        ),
                        SizedBox(
                          height: height * 0.03,
                        )
                      ]
                    : showEndScreen
                        ? [
                            Container(
                              height: height * 0.25,
                              child: Lottie.network(
                                "https://assets3.lottiefiles.com/packages/lf20_jy3vmooe.json",
                              ),
                            ),
                            Text(
                              "Results",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w800,
                                  fontSize:
                                      MediaQuery.of(context).textScaleFactor *
                                          50),
                            ),
                            Expanded(
                              child: Container(
                                width: width,
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.05),
                                      child: TabBarView(
                                        controller: tabBarController,
                                        children: [
                                          Container(
                                            height: height * 0.7,
                                            width: width * 0.9,
                                            child: ListView(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              children: [
                                                Container(
                                                  width: width * 0.9,
                                                  height: 50,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: height * 0.05,
                                                        child: Lottie.network(
                                                            "https://assets6.lottiefiles.com/private_files/lf30_dflaa25e.json"),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: height *
                                                                    0.02),
                                                        child: Text(
                                                            "Reaction Test",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .textScaleFactor *
                                                                  30,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: width * 0.05,
                                                        width: width * 0.05,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: width * 0.2),
                                                  height: width * 0.4,
                                                  child: Center(
                                                      child: Text(
                                                    test1AverageScor.toString(),
                                                    style: TextStyle(
                                                        color: test1AverageScor <=
                                                                600
                                                            ? test1AverageScor <=
                                                                    400
                                                                ? Colors.green
                                                                : Colors.orange
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor *
                                                            60),
                                                  )),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: test1AverageScor <=
                                                                600
                                                            ? test1AverageScor <=
                                                                    400
                                                                ? Colors.green
                                                                : Colors.orange
                                                            : Colors.red,
                                                        width: 7),
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                50)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Text(
                                                    test1AverageScor <= 600
                                                        ? test1AverageScor <=
                                                                400
                                                            ? "Attention Status : High"
                                                            : "Attention Status : Medium"
                                                        : "Attention Status : Low",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: test1AverageScor <=
                                                                600
                                                            ? test1AverageScor <=
                                                                    400
                                                                ? Colors.green
                                                                : Colors.orange
                                                            : Colors.red,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor *
                                                            30,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                SizedBox(
                                                    height: height * 0.005),
                                                Text("Stats",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: test1AverageScor <=
                                                                600
                                                            ? test1AverageScor <=
                                                                    400
                                                                ? Colors.green
                                                                : Colors.orange
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor *
                                                            35)),
                                                Container(
                                                    width: width,
                                                    height: height * 0.06,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            padding: EdgeInsets
                                                                .all(width *
                                                                    0.01),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: test1AverageScor <=
                                                                            600
                                                                        ? test1AverageScor <=
                                                                                400
                                                                            ? Color.fromARGB(
                                                                                72,
                                                                                76,
                                                                                175,
                                                                                79)
                                                                            : Color.fromARGB(
                                                                                72,
                                                                                255,
                                                                                153,
                                                                                0)
                                                                        : Color.fromARGB(
                                                                            72,
                                                                            244,
                                                                            67,
                                                                            54),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(100))),
                                                            child: Row(children: [
                                                              ...test1Result
                                                                  .map((e) {
                                                                if (e == -1) {
                                                                  return Container(
                                                                    height:
                                                                        height *
                                                                            0.06,
                                                                    width:
                                                                        height *
                                                                            0.06,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CircleAvatar(
                                                                        radius: height *
                                                                            0.018,
                                                                        backgroundColor:
                                                                            Colors.grey,
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if (e ==
                                                                    0) {
                                                                  return Container(
                                                                    height:
                                                                        height *
                                                                            0.06,
                                                                    child:
                                                                        Center(
                                                                      child: Lottie.network(
                                                                          "https://assets6.lottiefiles.com/private_files/lf30_jtkhrafm.json",
                                                                          repeat:
                                                                              false),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return Container(
                                                                    height:
                                                                        height *
                                                                            0.06,
                                                                    child:
                                                                        Center(
                                                                      child: Lottie.network(
                                                                          "https://assets3.lottiefiles.com/packages/lf20_afs4kbqm.json",
                                                                          repeat:
                                                                              false),
                                                                    ),
                                                                  );
                                                                }
                                                              }).toList()
                                                            ])),
                                                      ],
                                                    )),
                                                SizedBox(
                                                    height: height * 0.015),
                                                Container(
                                                  child: Column(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  40),
                                                          topRight:
                                                              Radius.circular(
                                                                  40),
                                                        ),
                                                        child: Container(
                                                          height:
                                                              height * 0.066,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                        height: height *
                                                                            0.066,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            " Attempt",
                                                                            style: TextStyle(
                                                                                color: Colors.blue,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: MediaQuery.of(context).textScaleFactor * 30),
                                                                          ),
                                                                        )),
                                                              ),
                                                              Container(
                                                                height: height *
                                                                    0.066,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                        height: height *
                                                                            0.066,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            "Time ",
                                                                            style: TextStyle(
                                                                                color: Colors.blue,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: MediaQuery.of(context).textScaleFactor * 30),
                                                                          ),
                                                                        )),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test1Result[0] <= 600 && test1Result[0] != 0
                                                                                  ? test1Result[0] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 1",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test1Result[
                                                                              0]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test1Result[1] <= 600 && test1Result[1] != 0
                                                                                  ? test1Result[1] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 2",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test1Result[
                                                                              1]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test1Result[2] <= 600 && test1Result[2] != 0
                                                                                  ? test1Result[2] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 3",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test1Result[
                                                                              2]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test1Result[3] <= 700 && test1Result[3] != 0
                                                                                  ? test1Result[3] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 4",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test1Result[
                                                                              3]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test1Result[4] <= 600 && test1Result[4] != 0
                                                                                  ? test1Result[4] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 5",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test1Result[
                                                                              4]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      border: Border.all(
                                                          color: Colors.blue,
                                                          width: 5),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  25))),
                                                )
                                              ],
                                            ),
                                          ),
                                          // color test screen=================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================
                                          // color test screen=================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================
                                          // color test screen=================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================
                                          // color test screen=================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================
                                          // color test screen=================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================
                                          Container(
                                            width: width * 0.9,
                                            child: ListView(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              children: [
                                                Container(
                                                  width: width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: height * 0.06,
                                                        child: Lottie.network(
                                                            "https://lottie.host/6fe50d20-f2af-4f18-9fe0-f6c026033cd1/0KmjlgGJch.json"),
                                                      ),
                                                      Text("Color Test",
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .textScaleFactor *
                                                                30,
                                                          )),
                                                      Container(
                                                        height: width * 0.05,
                                                        width: width * 0.05,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: height * 0.02,
                                                ),
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: width * 0.2),
                                                  height: width * 0.4,
                                                  child: Center(
                                                      child: Text(
                                                    test2AverageScor.toString(),
                                                    style: TextStyle(
                                                        color: test2AverageScor <=
                                                                600
                                                            ? test2AverageScor <=
                                                                    400
                                                                ? Colors.green
                                                                : Colors.orange
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor *
                                                            60),
                                                  )),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: test2AverageScor <=
                                                                600
                                                            ? test2AverageScor <=
                                                                    400
                                                                ? Colors.green
                                                                : Colors.orange
                                                            : Colors.red,
                                                        width: 7),
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                50)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Text(
                                                    test2AverageScor <= 600
                                                        ? test2AverageScor <=
                                                                400
                                                            ? "Attention Status : High"
                                                            : "Attention Status : Medium"
                                                        : "Attention Status : Low",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: test2AverageScor <=
                                                                600
                                                            ? test2AverageScor <=
                                                                    400
                                                                ? Colors.green
                                                                : Colors.orange
                                                            : Colors.red,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor *
                                                            30,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                SizedBox(
                                                    height: height * 0.005),
                                                Text("Stats",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: test2AverageScor <=
                                                                600
                                                            ? test2AverageScor <=
                                                                    400
                                                                ? Colors.green
                                                                : Colors.orange
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor *
                                                            35)),
                                                Container(
                                                    width: width,
                                                    height: height * 0.06,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            padding: EdgeInsets
                                                                .all(width *
                                                                    0.01),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: test2AverageScor <=
                                                                            600
                                                                        ? test2AverageScor <=
                                                                                400
                                                                            ? Color.fromARGB(
                                                                                72,
                                                                                76,
                                                                                175,
                                                                                79)
                                                                            : Color.fromARGB(
                                                                                72,
                                                                                255,
                                                                                153,
                                                                                0)
                                                                        : Color.fromARGB(
                                                                            72,
                                                                            244,
                                                                            67,
                                                                            54),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(100))),
                                                            child: Row(children: [
                                                              ...test2Result
                                                                  .map((e) {
                                                                if (e == -1) {
                                                                  return Container(
                                                                    height:
                                                                        height *
                                                                            0.06,
                                                                    width:
                                                                        height *
                                                                            0.06,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CircleAvatar(
                                                                        radius: height *
                                                                            0.018,
                                                                        backgroundColor:
                                                                            Colors.grey,
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if (e ==
                                                                    -2) {
                                                                  return Container(
                                                                    height:
                                                                        height *
                                                                            0.06,
                                                                    child:
                                                                        Center(
                                                                      child: Lottie.network(
                                                                          "https://assets10.lottiefiles.com/packages/lf20_pqpmxbxp.json",
                                                                          repeat:
                                                                              false),
                                                                    ),
                                                                  );
                                                                } else if (e ==
                                                                    0) {
                                                                  return Container(
                                                                    height:
                                                                        height *
                                                                            0.06,
                                                                    child:
                                                                        Center(
                                                                      child: Lottie.network(
                                                                          "https://assets6.lottiefiles.com/private_files/lf30_jtkhrafm.json",
                                                                          repeat:
                                                                              false),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return Container(
                                                                    height:
                                                                        height *
                                                                            0.06,
                                                                    child:
                                                                        Center(
                                                                      child: Lottie.network(
                                                                          "https://assets3.lottiefiles.com/packages/lf20_afs4kbqm.json",
                                                                          repeat:
                                                                              false),
                                                                    ),
                                                                  );
                                                                }
                                                              }).toList()
                                                            ])),
                                                      ],
                                                    )),
                                                SizedBox(
                                                    height: height * 0.015),
                                                Container(
                                                  child: Column(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  40),
                                                          topRight:
                                                              Radius.circular(
                                                                  40),
                                                        ),
                                                        child: Container(
                                                          height:
                                                              height * 0.066,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                        height: height *
                                                                            0.066,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            " Attempt",
                                                                            style: TextStyle(
                                                                                color: Colors.blue,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: MediaQuery.of(context).textScaleFactor * 30),
                                                                          ),
                                                                        )),
                                                              ),
                                                              Container(
                                                                height: height *
                                                                    0.066,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                        height: height *
                                                                            0.066,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            "Time ",
                                                                            style: TextStyle(
                                                                                color: Colors.blue,
                                                                                fontWeight: FontWeight.w700,
                                                                                fontSize: MediaQuery.of(context).textScaleFactor * 30),
                                                                          ),
                                                                        )),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test2Result[0] <= 600 && test2Result[0] > 0
                                                                                  ? test2Result[0] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : 
                                                                                  test2Result[0] == 0 ? 
                                                                                  "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json" : 
                                                                                  "https://assets10.lottiefiles.com/packages/lf20_pqpmxbxp.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 1",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test2Result[
                                                                              0]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test2Result[1] <= 600 && test2Result[1] >= 0
                                                                                  ? test2Result[1] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : test2Result[1] == 0 ? 
                                                                                  "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json" : 
                                                                                  "https://assets10.lottiefiles.com/packages/lf20_pqpmxbxp.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 2",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test2Result[
                                                                              1]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test2Result[2] <= 600 && test2Result[2] >= 0
                                                                                  ? test2Result[2] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : test2Result[2] == 0 ? 
                                                                                  "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json" : 
                                                                                  "https://assets10.lottiefiles.com/packages/lf20_pqpmxbxp.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 3",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test2Result[
                                                                              2]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test2Result[3] <= 700 && test2Result[3] >= 0
                                                                                  ? test2Result[3] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : test2Result[3] == 0 ? 
                                                                                  "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json" : 
                                                                                  "https://assets10.lottiefiles.com/packages/lf20_pqpmxbxp.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 4",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test2Result[
                                                                              3]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: height * 0.0667,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              height * 0.0667,
                                                                          child: Lottie.network(
                                                                              test2Result[4] <= 600 && test2Result[4] >= 0
                                                                                  ? test2Result[4] <= 400
                                                                                      ? "https://assets6.lottiefiles.com/private_files/lf30_yo2zavgg.json"
                                                                                      : "https://assets10.lottiefiles.com/packages/lf20_mm0buiei.json"
                                                                                  : test2Result[4] == 0 ? 
                                                                                  "https://assets3.lottiefiles.com/packages/lf20_87j5x5ty.json" : 
                                                                                  "https://assets10.lottiefiles.com/packages/lf20_pqpmxbxp.json",
                                                                              repeat: false),
                                                                        ),
                                                                        Text(
                                                                          "Attempt 5",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 20),
                                                                        ),
                                                                      ])),
                                                            ),
                                                            Container(
                                                              height: height *
                                                                  0.066,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  height:
                                                                      height *
                                                                          0.066,
                                                                  child: Center(
                                                                    child: Text(
                                                                      test1Result[
                                                                              4]
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 30),
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade300,
                                                      border: Border.all(
                                                          color: Colors.blue,
                                                          width: 5),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  25))),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: height * 0.02,
                                      child: Container(
                                          width: width,
                                          height: height * 0.03,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.all(
                                                      width * 0.01),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color.fromARGB(
                                                              72,
                                                              255,
                                                              255,
                                                              255),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          100))),
                                                  child: Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            tabBarController
                                                                .index = 0;
                                                          });
                                                        },
                                                        child: CircleAvatar(
                                                          radius: height * 0.01,
                                                          backgroundColor:
                                                              testingScreenIndex ==
                                                                      0
                                                                  ? Colors.blue
                                                                  : Colors.grey,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: width * 0.02),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            tabBarController
                                                                .index = 1;
                                                          });
                                                        },
                                                        child: CircleAvatar(
                                                          radius: height * 0.01,
                                                          backgroundColor:
                                                              testingScreenIndex ==
                                                                      1
                                                                  ? Colors.blue
                                                                  : Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          )),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ]
                        : [
                            Container(
                              height: height * 0.2,
                              child: Lottie.network(
                                  "https://lottie.host/6fe50d20-f2af-4f18-9fe0-f6c026033cd1/0KmjlgGJch.json"),
                            ),
                            Text(
                              "Color Test",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: textSize * 40),
                            ),
                            Container(
                                width: width,
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.all(width * 0.01),
                                        decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                                72, 255, 255, 255),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100))),
                                        child: Row(children: [
                                          ...test2Result.map((e) {
                                            if (e == -1) {
                                              return Container(
                                                height: height * 0.06,
                                                width: height * 0.06,
                                                child: Center(
                                                  child: CircleAvatar(
                                                    radius: height * 0.018,
                                                    backgroundColor:
                                                        Colors.grey,
                                                  ),
                                                ),
                                              );
                                            } else if (e == 0 || e == -2) {
                                              return Container(
                                                height: height * 0.06,
                                                child: Center(
                                                  child: Lottie.network(
                                                      "https://assets6.lottiefiles.com/private_files/lf30_jtkhrafm.json",
                                                      repeat: false),
                                                ),
                                              );
                                            } else {
                                              return Container(
                                                height: height * 0.06,
                                                child: Center(
                                                  child: Lottie.network(
                                                      "https://assets3.lottiefiles.com/packages/lf20_afs4kbqm.json",
                                                      repeat: false),
                                                ),
                                              );
                                            }
                                          }).toList()
                                        ])),
                                  ],
                                )),
                            Container(
                              height: height * 0.03,
                            ),
                            Expanded(
                              child: Container(
                                width: width * 0.9,
                                child: Neumorphic(
                                  // ignore: avoid_unnecessary_containers
                                  child: Container(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        Container(
                                          width: width * 0.82,
                                          height: width * 0.4,
                                          child: Neumorphic(
                                            style: NeumorphicStyle(
                                                color: active1 ==
                                                        BuzzerActive.active
                                                    ? possibleColors[
                                                        allColorTest[index]]
                                                    : Colors.grey,
                                                depth: colorButtonDepth,
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(BorderRadius.all(
                                                        Radius.circular(25)))),
                                          ),
                                        ),
                                        SizedBox(height: height * 0.02),
                                        // ignore: sized_box_for_whitespace
                                        Container(
                                            width: width * 0.83,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height: width * 0.3,
                                                    child: NeumorphicButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          print(possibleColors[
                                                                  allColorTest[
                                                                      index]] ==
                                                              Color.fromARGB(
                                                                  255,
                                                                  234,
                                                                  122,
                                                                  244));
                                                          print(possibleColors[
                                                              allColorTest[
                                                                  index]]);
                                                          if (active1 ==
                                                              BuzzerActive
                                                                  .init) {
                                                            test2Result[index] =
                                                                0;
                                                          } else if (possibleColors[
                                                                  allColorTest[
                                                                      index]] ==
                                                              Color.fromARGB(
                                                                  255,
                                                                  234,
                                                                  122,
                                                                  244)) {
                                                            int dif = DateTime
                                                                    .now()
                                                                .difference(
                                                                    colorShowTime)
                                                                .inMilliseconds;
                                                            if (dif >= 500) {
                                                              test2Result[
                                                                      index] =
                                                                  dif - 400;
                                                            } else {
                                                              test2Result[
                                                                  index] = 100;
                                                            }
                                                          } else {
                                                            test2Result[index] =
                                                                -2;
                                                          }
                                                          index++;
                                                          pushEndScreen();
                                                          active1 = BuzzerActive
                                                              .deactive;
                                                          colorButtonDepth = 0;
                                                          print(test2Result);
                                                        });
                                                      },
                                                      style: NeumorphicStyle(
                                                          color: colorButtonDepth == 0
                                                              ? const Color.fromARGB(
                                                                  150,
                                                                  234,
                                                                  122,
                                                                  244)
                                                              : const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  234,
                                                                  122,
                                                                  244),
                                                          depth:
                                                              colorButtonDepth,
                                                          boxShape: NeumorphicBoxShape
                                                              .roundRect(BorderRadius.all(
                                                                  Radius.circular(
                                                                      25)))),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width * 0.05,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    height: width * 0.3,
                                                    child: NeumorphicButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          print(possibleColors[
                                                                  allColorTest[
                                                                      index]] ==
                                                              Color.fromARGB(
                                                                  255,
                                                                  6,
                                                                  186,
                                                                  99));
                                                          if (active1 ==
                                                              BuzzerActive
                                                                  .init) {
                                                            test2Result[index] =
                                                                0;
                                                          } else if (possibleColors[
                                                                  allColorTest[
                                                                      index]] ==
                                                              Color.fromARGB(
                                                                  255,
                                                                  6,
                                                                  186,
                                                                  99)) {
                                                            int dif = DateTime
                                                                    .now()
                                                                .difference(
                                                                    colorShowTime)
                                                                .inMilliseconds;
                                                            if (dif >= 500) {
                                                              test2Result[
                                                                      index] =
                                                                  dif - 400;
                                                            } else {
                                                              test2Result[
                                                                  index] = 100;
                                                            }
                                                          } else {
                                                            test2Result[index] =
                                                                -2;
                                                          }
                                                          index++;
                                                          pushEndScreen();
                                                          active1 = BuzzerActive
                                                              .deactive;
                                                          colorButtonDepth = 0;
                                                          print(test2Result);
                                                        });
                                                      },
                                                      style: NeumorphicStyle(
                                                          color: colorButtonDepth == 0
                                                              ? const Color.fromARGB(
                                                                  150, 6, 186, 99)
                                                              : const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  6,
                                                                  186,
                                                                  99),
                                                          depth:
                                                              colorButtonDepth,
                                                          boxShape: NeumorphicBoxShape
                                                              .roundRect(
                                                                  BorderRadius.all(
                                                                      Radius.circular(
                                                                          25)))),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width * 0.05,
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  height: width * 0.3,
                                                  child: NeumorphicButton(
                                                    onPressed: () {
                                                      print(possibleColors[
                                                              allColorTest[
                                                                  index]] ==
                                                          const Color.fromARGB(
                                                              255,
                                                              231,
                                                              29,
                                                              54));
                                                      setState(() {
                                                        if (active1 ==
                                                            BuzzerActive.init) {
                                                          test2Result[index] =
                                                              0;
                                                        } else if (possibleColors[
                                                                allColorTest[
                                                                    index]] ==
                                                            const Color
                                                                    .fromARGB(
                                                                255,
                                                                231,
                                                                29,
                                                                54)) {
                                                          int dif = DateTime
                                                                  .now()
                                                              .difference(
                                                                  colorShowTime)
                                                              .inMilliseconds;
                                                          if (dif >= 500) {
                                                            test2Result[index] =
                                                                dif - 400;
                                                          } else {
                                                            test2Result[index] =
                                                                100;
                                                          }
                                                        } else {
                                                          test2Result[index] =
                                                              -2;
                                                        }
                                                        index++;
                                                        pushEndScreen();
                                                        active1 = BuzzerActive
                                                            .deactive;
                                                        colorButtonDepth = 0;
                                                        print(test2Result);
                                                      });
                                                    },
                                                    style: NeumorphicStyle(
                                                        color: colorButtonDepth ==
                                                                0
                                                            ? const Color.fromARGB(
                                                                150,
                                                                231,
                                                                29,
                                                                54)
                                                            : const Color.fromARGB(
                                                                255,
                                                                231,
                                                                29,
                                                                54),
                                                        depth: colorButtonDepth,
                                                        boxShape: NeumorphicBoxShape
                                                            .roundRect(
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        25)))),
                                                  ),
                                                ))
                                              ],
                                            )),
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        Expanded(
                                            child: Container(
                                          width: width * 0.82,
                                          child: GestureDetector(
                                            onLongPress: () {
                                              setState(() {
                                                colorButtonDepth = 5;
                                                active1 = BuzzerActive.init;
                                                print("here");
                                              });
                                              int delay =
                                                  (Random().nextInt(5) + 1);
                                              print(delay);
                                              Future.delayed(
                                                  Duration(seconds: delay), () {
                                                colorShowTime = DateTime.now();
                                                print(index);
                                                setState(() {
                                                  active1 = BuzzerActive.active;
                                                });
                                              });
                                            },
                                            child: Neumorphic(
                                              child: Center(
                                                  child: Text(
                                                "Press Here",
                                                style: TextStyle(
                                                    color: Colors.grey.shade300,
                                                    fontSize: MediaQuery.of(
                                                                context)
                                                            .textScaleFactor *
                                                        40,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              )),
                                              style: NeumorphicStyle(
                                                  color: Colors.blue,
                                                  boxShape: NeumorphicBoxShape
                                                      .roundRect(
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  25)))),
                                            ),
                                          ),
                                        )),
                                        SizedBox(
                                          height: height * 0.02,
                                        )
                                      ],
                                    ),
                                  ),
                                  style: NeumorphicStyle(
                                    color: Colors.grey.shade300,
                                    border: NeumorphicBorder(
                                      color: Colors.blue,
                                      width: 5,
                                    ),
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.all(Radius.circular(25))),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: height * 0.03,
                            )
                          ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
