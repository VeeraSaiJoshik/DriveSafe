import 'dart:ffi';
import 'dart:ui';
import 'dart:io';

import 'package:drivesafev2/pages/DriveSafeHomePage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SignUpLoadScreen.dart';
import 'package:lottie/lottie.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

/*
MEASURMENTS
 main body is about 0.92 width 
 0.85 -> 0.815 -> 0.4075
*/

class errorDelivery {
  bool pass = false;
  String title = "";
  String description = "";
  User existerUser;
  errorDelivery(this.pass, this.title, this.description, this.existerUser);
}

Future<errorDelivery> authorizeUser(String phoneNumber, String firstName,
    String lastName, String passWord, Function updateFCM) async {
  phoneNumber = phoneNumber.trim();
  phoneNumber = phoneNumber.replaceAll(" ", "");
  if (phoneNumber[0] != "+") {
    phoneNumber = "+1" + phoneNumber;
  }
  final Data = await FirebaseDatabase.instance.ref("User/" + phoneNumber).get();
  if (Data.exists) {
    Map data = Data.value as Map;

    if (data["firstName"].toUpperCase() != firstName.toUpperCase()) {
      return errorDelivery(
          false,
          data["firstName"],
          "We are sorry but the given name is not matching up with the phone number.",
          User(
              "", "", "", "", 0, [], [], [], [], [], "", false, false, [], ""));
    } else if (data["lastName"].toUpperCase() != lastName.toUpperCase()) {
      return errorDelivery(
          false,
          "Name",
          "We are sorry but the given name is not matching up with the phone number.",
          User(
              "", "", "", "", 0, [], [], [], [], [], "", false, false, [], ""));
    } else if (data["password"] != passWord) {
      return errorDelivery(
          false,
          "Password",
          "We are sorry but the given password is not correct.",
          User(
              "", "", "", "", 0, [], [], [], [], [], "", false, false, [], ""));
    }
    List friends = [];
    List friendRequests = [];
    List LocationSharingPeople = [];
    List friendRequestsPending = [];
    List location = [];
    List numberList = [];
    List chosenNumber = [];
    if (data.containsKey("friends")) {
      friends = data["friends"];
    }
    if (data.containsKey("friendReqeusts")) {
      friendRequests.addAll(data["friendReqeusts"]);
    }
    if (data.containsKey("locationSharingPeople")) {
      LocationSharingPeople.addAll(data["locationSharingPeople"]);
    }
    if (data.containsKey("friendRequestsPending")) {
      friendRequestsPending.addAll(data["friendRequestsPending"]);
    }
    if (data.containsKey("location")) {
      location.addAll(["location"]);
    }
    if (data.containsKey("phoneNumbersChosen")) {
      numberList.addAll(["phoneNumbersChosen"]);
    }
    if (data.containsKey("phoneNumbersChosen")) {
      chosenNumber.addAll(data["phoneNumbersChosen"]);
    }
    updateFCM(data, phoneNumber);
    return errorDelivery(
        true,
        "",
        "",
        User(
            data["firstName"],
            data["lastName"],
            data["phoneNumber"],
            data["password"],
            data["age"],
            friends,
            friendRequests,
            friendRequestsPending,
            LocationSharingPeople,
            location,
            data["image"],
            data["numberApproved"],
            data["locationTrackingOn"],
            chosenNumber,
            data["userName"]));
  } else {
    return errorDelivery(
        false,
        "Phone Number",
        "The phone number could not be found.",
        User("", "", "", "", 0, [], [], [], [], [], "", false, false, [], ""));
  }
}

class _LogInScreenState extends State<LogInScreen> {
  @override
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  TextEditingController phoneNumberController = TextEditingController();
  DatabaseReference reference = FirebaseDatabase.instance.ref("users");
  String FFCM = "";
  void getData() {
    if (prefs.getString("phoneNumber") != null) {
      setState(() {
        firstNameController.text = prefs.getString("firstName")!;
        lastNameController.text = prefs.getString("lastName")!;
        phoneNumberController.text = prefs.getString("phoneNumber")!;
        passwordController.text = prefs.getString("password")!;
      });
    }
  }

  void initStateF() async {
    String? FCM = await FirebaseMessaging.instance.getToken();
    prefs = await SharedPreferences.getInstance();
    getData();
    if (FCM != null) {
      FFCM = FCM;
    }
  }

  void updateFCM(Map data, String phoneNumber) async {
    print(FFCM);
    print(phoneNumber);
    print("here fcm");

    FirebaseDatabase.instance.ref("User/" + phoneNumber).child("FCM").set(FFCM);
  }

  void initState() {
    initStateF();
    super.initState();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String fullName;
    double textSize = MediaQuery.of(context).textScaleFactor;
    Color mainColor = Colors.white;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: height,
            width: width,
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.04,
                ),
                Padding(
                  padding:
                      EdgeInsets.fromLTRB(width * 0.04, 0, width * 0.04, 0),
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
                                    size: textSize * 25,
                                    color: Colors.blue.shade500,
                                  ),
                                ]),
                            style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.circle(),
                                depth: 50,
                                color: Colors.grey.shade300,
                                lightSource: LightSource.topLeft,
                                shape: NeumorphicShape.concave)),
                      ),
                      Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: textSize * 0,
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.w700,
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
                          color: Colors.blue,
                        ),
                      ),
                      Container(
                        height: height * 0.08,
                        width: height * 0.08,
                        child: NeumorphicButton(
                            onPressed: () async {
                              late errorDelivery answer;
                              await authorizeUser(
                                      phoneNumberController.text,
                                      firstNameController.text,
                                      lastNameController.text,
                                      passwordController.text,
                                      updateFCM)
                                  .then((value) {
                                if (value.pass) {
                                  final String? counter =
                                      prefs.getString('phoneNumber');
                                  if (counter == null) {
                                    AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.QUESTION,
                                        animType: AnimType.SCALE,
                                        headerAnimationLoop: false,
                                        title: "Success",
                                        desc: "Welcome Back " +
                                            value.existerUser.firstName +
                                            " " +
                                            value.existerUser.lastName +
                                            ". It seems that your data is not on the device. Do you want to save your log in info to the device ?",
                                        titleTextStyle: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "Nunito",
                                          fontSize: textSize * 25,
                                          color: Colors.orange,
                                        ),
                                        descTextStyle: TextStyle(
                                            fontFamily: "orange",
                                            fontSize: textSize * 20,
                                            color: Colors.orange),
                                        btnOkOnPress: () {
                                          prefs.setString(
                                              "phoneNumber",
                                              phoneNumberController.text
                                                  .toString());
                                          prefs.setString(
                                              "firstName",
                                              firstNameController.text
                                                  .toString());
                                          prefs.setString(
                                              "lastName",
                                              lastNameController.text
                                                  .toString());
                                          prefs.setString(
                                              "password",
                                              passwordController.text
                                                  .toString());
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: ((context) =>
                                                      DriveSafeHomePage(
                                                          value.existerUser,
                                                          context))),
                                              (route) => false);
                                        },
                                        btnOkText: "Yes",
                                        btnOkColor: Colors.green,
                                        btnCancelColor: Colors.red,
                                        btnCancelText: "No",
                                        btnCancelOnPress: () {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: ((context) =>
                                                      DriveSafeHomePage(
                                                          value.existerUser,
                                                          context))),
                                              (route) => false);
                                        }).show();
                                  } else {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.SUCCES,
                                      animType: AnimType.SCALE,
                                      headerAnimationLoop: false,
                                      title: "Success",
                                      desc: "Welcome Back " +
                                          value.existerUser.firstName +
                                          " " +
                                          value.existerUser.lastName,
                                      titleTextStyle: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "Nunito",
                                        fontSize: textSize * 25,
                                        color: Colors.green,
                                      ),
                                      descTextStyle: TextStyle(
                                          fontFamily: "Nunito",
                                          fontSize: textSize * 20,
                                          color: Colors.green),
                                      btnOkOnPress: () {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    DriveSafeHomePage(
                                                        value.existerUser,
                                                        context))),
                                            (route) => false);
                                      },
                                      btnOkText: "Continue",
                                      btnOkColor: Colors.green,
                                    ).show();
                                  }
                                } else {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.ERROR,
                                    animType: AnimType.SCALE,
                                    headerAnimationLoop: false,
                                    title: value.title,
                                    desc: value.description,
                                    titleTextStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Nunito",
                                      fontSize: textSize * 25,
                                      color: Colors.red,
                                    ),
                                    descTextStyle: TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: textSize * 20,
                                        color: Colors.redAccent),
                                    btnOkOnPress: () {},
                                    btnOkText: "Ok",
                                    btnOkColor: Colors.red,
                                  ).show();
                                }
                              });
                            },
                            child: Icon(Icons.login,
                                color: Colors.blue, size: textSize * 25),
                            padding: EdgeInsets.fromLTRB(
                                width * 0, height * 0, width * 0, height * 0),
                            style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.roundRect(
                                    const BorderRadius.all(
                                        Radius.circular(100))),
                                depth: 50,
                                color: Colors.grey.shade300,
                                lightSource: LightSource.topLeft,
                                shape: NeumorphicShape.concave)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.04,
                ),
                Container(
                  height: height * 0.81,
                  width: width * 0.92,
                  child: Neumorphic(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.network(
                              "https://assets8.lottiefiles.com/packages/lf20_xyadoh9h.json",
                              height: height * 0.4),
                          Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: width * 0.03),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                NeumorphicTextField("First Name", width * 0.41,
                                    firstNameController),
                                NeumorphicTextField("Last Name", width * 0.41,
                                    lastNameController),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NeumorphicTextField(
                                  "Phone Number",
                                  width * (0.92 - (2 * 0.10 / 3)),
                                  phoneNumberController),
                            ],
                          ),
                          SizedBox(height: height * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NeumorphicTextField(
                                  "Password",
                                  width * (0.92 - (2 * 0.10 / 3)),
                                  passwordController),
                            ],
                          ),
                        ]),
                    style: NeumorphicStyle(
                        depth: 50,
                        color: Colors.grey.shade300,
                        intensity: 0.9,
                        lightSource: LightSource.topLeft,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(10))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NeumorphicTextField extends StatefulWidget {
  String title;
  double width;
  TextEditingController textEditingController;
  NeumorphicTextField(this.title, this.width, this.textEditingController);

  @override
  _NeumorphicTextFieldState createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  @override
  String FFCM = "";

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: width * 0.04,
            ),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.blue,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
        SizedBox(
          height: height * 0.003,
        ),
        Neumorphic(
          child: Container(
              width: widget.width,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                obscureText: widget.title == "Password" ? true : false,
                style: TextStyle(
                    fontSize: textSize * 25,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    contentPadding: EdgeInsets.only(
                        bottom: height * 0.01,
                        left: width * 0.03,
                        right: width * 0.03)),
                controller: widget.textEditingController,
              )),
          style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(
                  const BorderRadius.all(Radius.circular(100))),
              depth: -15,
              color: Colors.grey.shade300,
              border: NeumorphicBorder(color: Colors.blue, width: 2),
              lightSource: LightSource.topLeft,
              shape: NeumorphicShape.concave),
        ),
      ],
    );
  }
}
