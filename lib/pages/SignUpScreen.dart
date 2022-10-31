import 'dart:ffi';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:mobile_number/mobile_number.dart';
import 'SignUpLoadScreen.dart';
import 'SignUpLoadScreenWithImage.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class userDrivingData {
  double latitude;
  double longitude;
  double speed;
  double altitude;
  String firstName;
  String lastName;
  String city;
  String country;
  double directionX;
  double directionY;
  double directionZ;
  String formattedAddress;
  double speedLimit;
  String state;
  String description;
  String time;
  double temp;
  double feel_like;
  double humidity;
  String id;
  double windSpeed;
  double windDeg;
  double gust;
  double visibility;
  String cityName;
  double groundLevel;
  userDrivingData(
      this.latitude,
      this.longitude,
      this.speed,
      this.altitude,
      this.firstName,
      this.lastName,
      this.cityName,
      this.country,
      this.city,
      this.directionX,
      this.directionY,
      this.directionZ,
      this.formattedAddress,
      this.speedLimit,
      this.state,
      this.description,
      this.time,
      this.temp,
      this.feel_like,
      this.humidity,
      this.id,
      this.windDeg,
      this.windSpeed,
      this.gust,
      this.groundLevel,
      this.visibility);
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
  errorDelivery(this.pass, this.title, this.description);
}

class _SignUpScreenState extends State<SignUpScreen> {
  late XFile? _image;
  String mobileNumber = "";
  bool haveChosen = false;
  String error = "";
  Future _getImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
        haveChosen = true;
      });
    }
  }

  @override
  double ageValue = 13;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  DatabaseReference reference = FirebaseDatabase.instance.ref("Hello");
  /*void createUser() async {
    await reference.set({
      "name": "John",
      "age": 18,
      "address": {"line1": "100 Mountain View"}
    });
  }*/
  Map finalData = {};
  Future<errorDelivery> checkIfUserPhoneNumber() async {
    DataSnapshot tempData = await FirebaseDatabase.instance.ref("User").get();
    var tempData1 = tempData.value;
    if (tempData1 != null) {
      finalData = tempData.value as Map;
      print(finalData.keys);
      if (finalData.containsKey(phoneNumberController.text)) {
        return errorDelivery(true, "Phone Number",
            "There is already an account registered on the following phone number. Please try logging in");
      }
    }
    return errorDelivery(false, "", "");
    //
  }

  errorDelivery chekcForPassWordMisconduct() {
    if (passwordController.text.length < 8) {
      return errorDelivery(true, "Password",
          "please make sure that your password is atleast 8 characters long");
    }
    if (!(passwordController.text.contains('1') ||
        passwordController.text.contains('2') ||
        passwordController.text.contains('3') ||
        passwordController.text.contains('4') ||
        passwordController.text.contains('6') ||
        passwordController.text.contains('6') ||
        passwordController.text.contains('7') ||
        passwordController.text.contains('5') ||
        passwordController.text.contains('8') ||
        passwordController.text.contains('9') ||
        passwordController.text.contains('0'))) {
      return errorDelivery(true, "Password",
          "please make sure that your password has at least one number in it");
    }
    String badChars = "£\$%^&*";
    for (int i = 0; i < 6; i++) {
      if (passwordController.text.contains(badChars[i])) {
        return errorDelivery(true, "Password",
            "please make sure that your password doest not contain the follwing : £\$%^&*");
      }
    }
    return errorDelivery(false, "", "");
  }

  errorDelivery userNameMis() {
    bool doesContain = false;
    finalData.forEach((key, value) {
      if(value["userName"] == userNameController.text){
        doesContain = true;
      }
    });
    if (doesContain) {
      return errorDelivery(true, "Username",
          "The following username is already taken. Please choose another one");
    }
    if (userNameController.text.length < 10) {
      return errorDelivery(true, "Username",
          "please make sure that your Username is atleast 10 characters long");
    }

    if (userNameController.text.contains(" ")) {
      return errorDelivery(true, "Username",
          "please make sure that your username does not contain spaces");
    }
    String badChars = "£\$%^&*";
    for (int i = 0; i < 6; i++) {
      if (userNameController.text.contains(badChars[i])) {
        return errorDelivery(true, "Password",
            "please make sure that your username doest not contain the follwing : £\$%^&*");
      }
    }
    return errorDelivery(false, "", "");
  }

  errorDelivery allFieldsFilled() {
    if (firstNameController.text == "") {
      return errorDelivery(false, "First Name", "Please fill all textfields");
    } else if (lastNameController.text == "") {
      return errorDelivery(false, "Last Name", "Please fill all textfields");
    } else if (passwordController.text == "") {
      return errorDelivery(false, "User Name", "Please fill all textfields");
    } else if (phoneNumberController.text == "") {
      return errorDelivery(false, "Phone Number", "Please fill all textfields");
    }

    return errorDelivery(true, "", "");
  }

  errorDelivery checkPhoneNumber() {
    phoneNumberController.text = phoneNumberController.text.replaceAll(" ", "");
    if (phoneNumberController.text[0] == "+") {
      if (phoneNumberController.text.length == 12) {
        return errorDelivery(true, "", "");
      }
    } else if (phoneNumberController.text.length == 10) {
      phoneNumberController.text = "+1" + phoneNumberController.text;
      return errorDelivery(true, "", "");
    }
    return errorDelivery(false, "phone number",
        "Please make sure that the phone number is valid");
  }

  Future<errorDelivery> completeCheck() async {
    errorDelivery phoneCheck = await checkIfUserPhoneNumber();
    if (phoneCheck.pass) {
      return checkIfUserPhoneNumber();
    }
    if (!allFieldsFilled().pass) {
      return allFieldsFilled();
    }
    if (chekcForPassWordMisconduct().pass) {
      return chekcForPassWordMisconduct();
    }
    if (userNameMis().pass) {
      return userNameMis();
    }
    if (!checkPhoneNumber().pass) {
      return checkPhoneNumber();
    }
    return errorDelivery(false, "", "");
  }

  void getPhoneNumberData() async {
    if (MobileNumber.mobileNumber != null) {
      MobileNumber.mobileNumber?.then((value) => setState(() {
            phoneNumberController.text = value.substring(2);
          }));
    }
  }

  void initState() {
    getPhoneNumberData();
    super.initState();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String fullName;
    double textSize = MediaQuery.of(context).textScaleFactor;
    Color mainColor = Colors.grey.shade300;
    Color theTextFieldMainColor = Colors.blue;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: Container(
          height: height,
          width: width,
          child: SingleChildScrollView(
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
                        "Sign Up",
                        style: TextStyle(
                          fontSize: textSize * 40,
                          fontFamily: "Nunito",
                          fontWeight: FontWeight.w700,
                          shadows: [
                            const Shadow(
                                offset: Offset(2, 2),
                                color: Colors.black38,
                                blurRadius: 10),
                            Shadow(
                                offset: Offset(-2, -2),
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
                              completeCheck().then((value) {
                                if (value.description == "") {
                                  if (haveChosen == false) {
                                    AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.WARNING,
                                            animType: AnimType.SCALE,
                                            headerAnimationLoop: false,
                                            title: "Image",
                                            desc:
                                                "Are you sure you do not want to add a profile picture",
                                            titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontFamily: "Nunito",
                                              fontSize: textSize * 25,
                                              color: Colors.orangeAccent,
                                            ),
                                            descTextStyle: TextStyle(
                                                fontFamily: "Nunito",
                                                fontSize: textSize * 20,
                                                color: Colors.orangeAccent),
                                            btnOkOnPress: () {
                                              User newUser = User(
                                                  firstNameController.text,
                                                  lastNameController.text,
                                                  phoneNumberController.text,
                                                  passwordController.text,
                                                  ageValue.toInt(),
                                                  [],
                                                  [],
                                                  [],
                                                  [],
                                                  [],
                                                  "",
                                                  false,
                                                  false,
                                                  [],
                                                  userNameController.text);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignUpLoadScreenWithImage(
                                                              newUser)));
                                            },
                                            btnOkText: "Yes",
                                            btnOkColor: Colors.green,
                                            btnCancelText: "No",
                                            btnCancelOnPress: () {},
                                            btnCancelColor: Colors.red)
                                        .show();
                                  } else {
                                    User newUser = User(
                                        firstNameController.text,
                                        lastNameController.text,
                                        phoneNumberController.text,
                                        passwordController.text,
                                        ageValue.toInt(),
                                        [],
                                        [],
                                        [],
                                        [],
                                        [],
                                        _image!.path,
                                        false,
                                        false,
                                        [],
                                        userNameController.text);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignUpLoadScreen(newUser)));
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
                                        color: Colors.red),
                                    btnOkOnPress: () {},
                                    btnOkIcon: Icons.cancel,
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
                          SizedBox(
                            height: height * 0.05,
                          ),
                          Neumorphic(
                            child: haveChosen
                                ? InkWell(
                                    splashColor: Colors.blue,
                                    onTap: _getImage,
                                    child: CircleAvatar(
                                      backgroundColor: mainColor,
                                      radius: height * 0.11,
                                      backgroundImage:
                                          FileImage(File(_image!.path)),
                                    ))
                                : CircleAvatar(
                                    backgroundColor: mainColor,
                                    radius: height * 0.11,
                                    child: Center(
                                      child: InkWell(
                                        splashColor: Colors.blue,
                                        onTap: _getImage,
                                        child: NeumorphicIcon(
                                          Icons.tag_faces,
                                          size: textSize * 135,
                                          style: NeumorphicStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    )),
                            style: NeumorphicStyle(
                                border: NeumorphicBorder(
                                  isEnabled: true,
                                  color: Colors.blue,
                                  width: 4,
                                ),
                                shape: NeumorphicShape.flat,
                                intensity: 0.9,
                                boxShape: NeumorphicBoxShape.circle(),
                                depth: -50,
                                lightSource: LightSource.topLeft,
                                color: Colors.grey.shade300),
                          ),
                          SizedBox(
                            height: height * 0.025,
                          ),
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
                                  "Username",
                                  width * (0.92 - (2 * 0.10 / 3)),
                                  userNameController),
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
                          SizedBox(height: height * 0.005),
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
                style: TextStyle(
                    fontSize: textSize * 25,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue),
                textAlign: TextAlign.center,
                obscureText: widget.title == "Password" ? true : false,
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
              border: NeumorphicBorder(color: Colors.blue, width: 3),
              lightSource: LightSource.topLeft,
              shape: NeumorphicShape.concave),
        ),
      ],
    );
  }
}

class NeumorphicTextFieldWithNumPad extends StatefulWidget {
  String title;
  double width;
  TextEditingController textEditingController;
  NeumorphicTextFieldWithNumPad(
      this.title, this.width, this.textEditingController);

  @override
  _NeumorphicTextFieldWithNumPadState createState() =>
      _NeumorphicTextFieldWithNumPadState();
}

class _NeumorphicTextFieldWithNumPadState
    extends State<NeumorphicTextFieldWithNumPad> {
  @override
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
                keyboardType: TextInputType.phone,
                textAlignVertical: TextAlignVertical.center,
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
              border: NeumorphicBorder(color: Colors.black, width: 0),
              lightSource: LightSource.topLeft,
              shape: NeumorphicShape.concave),
        ),
      ],
    );
  }
}
