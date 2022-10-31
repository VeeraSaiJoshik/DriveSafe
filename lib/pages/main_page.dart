import 'package:flutter/material.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';

class mainPage extends StatefulWidget {
  const mainPage({Key? key}) : super(key: key);

  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double textSize = MediaQuery.of(context).textScaleFactor;
    void hasPermission() async {
      bool isPermissionGranted = await MobileNumber.hasPhonePermission;
      if (!isPermissionGranted) {
        MobileNumber.requestPhonePermission;
      }
    }

    void initState() {
      super.initState();
    }

    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: Stack(
            children: [
              Container(
                  width: width,
                  height: height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Lottie.asset(
                          //"https://assets8.lottiefiles.com/packages/lf20_zzky7hfk.json",
                          "assets/animations/mainScreencarLogo.json",
                          height: height * 0.45,
                        ),
                      ),
                    ],
                  )),
              Container(
                  width: width,
                  height: height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: height * 0.4,
                      ),
                      Text(
                        "DriveSafe",
                        style: TextStyle(
                          fontSize: textSize * 60,
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.w800,
                          shadows: [
                            const Shadow(
                                offset: Offset(1, 1),
                                color: Colors.black38,
                                blurRadius: 10),
                            Shadow(
                                offset: Offset(-1, -1),
                                color: Colors.white.withOpacity(0.85),
                                blurRadius: 10)
                          ],
                          color: Colors.blue,
                        ),
                      ),
                      Container(
                          width: width * 0.7679,
                          child: Text(
                            "The app that helps you, your family, and your friends drive safe ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                                fontSize: textSize * 15),
                          )),
                      SizedBox(
                        height: height * 0.048,
                      ),
                      NeumorphicButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("LogInPage");
                          //print(Polyline.Decode(encodedString: "BGwynmkD}", precision: 5).decodedCoords);
                        },
                        child: Container(
                          width: width * 0.6,
                          height: height * 0.06,
                          child: Center(
                            child: Text(
                              "Log In",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: textSize * 30,
                                fontFamily: "Nunito",
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        style: NeumorphicStyle(
                            depth: 5,
                            border:
                                NeumorphicBorder(color: Colors.blue, width: 2),
                            color: Colors.grey.shade200,
                            lightSource: LightSource.topLeft,
                            boxShape: NeumorphicBoxShape.stadium(),
                            shape: NeumorphicShape.concave),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Container(
                        width: width * 0.6,
                        child: Row(
                          children: [
                            Container(
                              width: width * 0.23,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100))),
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            Text(
                              "OR",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: textSize * 20),
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            Container(
                              width: width * 0.23,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100))),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      NeumorphicButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("SignUpPage");
                        },
                        child: Container(
                          width: width * 0.6,
                          height: height * 0.06,
                          child: Center(
                            child: Text(
                              "Sign Up",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: textSize * 30,
                                fontFamily: "Nunito",
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        style: NeumorphicStyle(
                            depth: 5,
                            border:
                                NeumorphicBorder(color: Colors.blue, width: 2),
                            color: Colors.grey.shade200,
                            lightSource: LightSource.topLeft,
                            boxShape: NeumorphicBoxShape.stadium(),
                            shape: NeumorphicShape.concave),
                      ),
                    ],
                  ))
            ],
          ),
        ));
  }
}
/*
Text(
                    "DriveSafe",
                    style: TextStyle(
                      fontSize: textSize * 50,
                      fontFamily: "Nunito",
                      fontWeight: FontWeight.w800,
                      shadows: [
                        const Shadow(
                            offset: Offset(1, 1),
                            color: Colors.black38,
                            blurRadius: 10),
                        Shadow(
                            offset: Offset(-1, -1),
                            color: Colors.white.withOpacity(0.85),
                            blurRadius: 10)
                      ],
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                      width: width * 0.8,
                      child: const Text(
                          "to the app that helps you and your family drive safe")),
                  NeumorphicButton(
                    child: Container(
                        width: width * 0.5,
                        height: height * 0.15,
                        child: const Center(
                          child: Text(
                            "Sign Up",
                          ),
                        )),
                  )
 */
