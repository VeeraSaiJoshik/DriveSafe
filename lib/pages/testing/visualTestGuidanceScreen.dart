import 'package:drivesafev2/pages/testing/visualTestScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';

import '../../models/User.dart';

class VtGuidanceScreen extends StatefulWidget {
  User user;
  VtGuidanceScreen(this.user);
  @override
  State<VtGuidanceScreen> createState() => _VtGuidanceScreenState();
}

class _VtGuidanceScreenState extends State<VtGuidanceScreen>
    with SingleTickerProviderStateMixin {
  @override
  int index = 0;
  late TabController controller;
  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      index = controller.index;
      setState(() {
        index;
      });
    });
    print(index);
    super.initState();
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Container(
        height: height,
        width: width,
        child: Column(
          children: [
            SizedBox(
              height: height * 0.02,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: width * 0.15,
                    height: width * 0.15,
                    child: NeumorphicButton(
                      onPressed: () {
                        if (index != 0) {
                          print(index);
                          controller.animateTo(index - 1);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      style: NeumorphicStyle(
                          color: index == 0 ? Colors.red : Colors.blue,
                          depth: 5,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(100))),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.05,
                  ),
                  Text(
                    "Instructions",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                      fontSize: textSize * 35,
                      shadows: [
                        const Shadow(
                            offset: Offset(3, 3),
                            color: Colors.black38,
                            blurRadius: 10),
                        Shadow(
                            offset: Offset(-3, -3),
                            color: Colors.white.withOpacity(0.85),
                            blurRadius: 10)
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width * 0.05,
                  ),
                  Container(
                    width: width * 0.15,
                    height: width * 0.15,
                    child: NeumorphicButton(
                      onPressed: () {
                        if (index != 2) {
                          print(index + 1);
                          controller.animateTo(index + 1);
                        }
                      },
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios_sharp,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      style: NeumorphicStyle(
                          color: index == 2 ? Colors.grey : Colors.blue,
                          depth: 5,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(100))),
                    ),
                  ),
                ],
              ),
              width: width,
            ),
            SizedBox(
              height: height * 0.03,
            ),
            Expanded(
              child: Container(
                width: width,
                child: TabBarView(
                  controller: controller,
                  children: [
                    Container(
                      color: Colors.grey.shade300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Lottie.network(
                                "https://assets7.lottiefiles.com/packages/lf20_72qqCT.json"),
                            height: height * 0.4,
                          ),
                          Text(
                            "Test 1 : The Reaction Test",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: textSize * 25,
                                fontWeight: FontWeight.w800),
                          ),
                          SizedBox(
                            height: height * 0.04,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.15),
                            child: Text(
                              "In this test, there will be two button on the screen. Place your thumb on the bottom button to start. Then, after a random interval, the other button will turn green. Press the button as fast as you can",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: textSize * 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.15,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Lottie.network(
                                "https://assets1.lottiefiles.com/packages/lf20_ig53qvih.json"),
                            height: height * 0.4,
                          ),
                          Text(
                            "Test 2 : The Color Test",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: textSize * 25,
                                fontWeight: FontWeight.w800),
                          ),
                          SizedBox(
                            height: height * 0.04,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.15),
                            child: Text(
                              "In this test, there will be three button on the bottom and one circle on top. The circle will change colors at random times. Click on the correct color as quick as you can. Accuracy and speed will be coutned. ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: textSize * 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ), 
                          SizedBox(
                            height: height * 0.15,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .popAndPushNamed("VisualTest", arguments : widget.user.phoneNumber);
                            },
                            child: Container(
                              child: Lottie.network(
                                  "https://lottie.host/ef849c34-239b-4d65-aa86-3bf174146cd5/ViTkq6Hs2k.json",
                                  repeat: false),
                              height: height * 0.4,
                            ),
                          ),
                          Text(
                            "Complete",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: textSize * 30,
                                fontWeight: FontWeight.w800),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.05),
                            child: Text(
                              "Good Job, you are done. Press the green circle to continue and take the test ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: textSize * 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ), 
                          SizedBox(
                            height: height * 0.15,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
                width: width,
                height: height * 0.03,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: EdgeInsets.all(width * 0.01),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(72, 255, 255, 255),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: height * 0.01,
                              backgroundColor:
                                  index == 0 ? Colors.blue : Colors.grey,
                            ),
                            SizedBox(width: width * 0.02),
                            CircleAvatar(
                              radius: height * 0.01,
                              backgroundColor:
                                  index == 1 ? Colors.blue : Colors.grey,
                            ),
                            SizedBox(width: width * 0.02),
                            CircleAvatar(
                              radius: height * 0.01,
                              backgroundColor: index == 2
                                  ? Colors.green
                                  : Colors.green.shade300,
                            ),
                          ],
                        )),
                  ],
                )),
            SizedBox(
              height: height * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
