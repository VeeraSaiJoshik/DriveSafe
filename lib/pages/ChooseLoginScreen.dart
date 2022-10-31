import 'dart:ffi';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

/*
MEASURMENTS
 main body is about 0.92 width 
 0.85 -> 0.815 -> 0.4075
*/

class _SignUpScreenState extends State<SignUpScreen> {
  late XFile? _image;
  bool haveChosen = false;
  Future _getImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      haveChosen = true;
    });
  }

  @override
  double ageValue = 13;
  String firstName = "";
  TextEditingController firstNameController = TextEditingController();
  String lastName = "";
  TextEditingController lastNameController = TextEditingController();
  String userName = "";
  TextEditingController userNameController = TextEditingController();
  String phoneNumber = "";
  TextEditingController phoneNumberController = TextEditingController();
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String fullName;
    double textSize = MediaQuery.of(context).textScaleFactor;
    Color mainColor = Color(0XFFcadde0);

    return Scaffold(
      backgroundColor: Color(0XFFcadde0),
      body: Center(
        child: Container(
          height: height,
          width: width,
          child: Column(
            children: [
              SizedBox(
                height: height * 0.04,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(width * 0.04, 0, width * 0.04, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: height * 0.08,
                      width: height * 0.08,
                      child: NeumorphicButton(
                          onPressed: () {},
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
                          style: const NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: 50,
                              color: Color(0XFFcadde0),
                              lightSource: LightSource.topLeft,
                              shape: NeumorphicShape.concave)),
                    ),
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: textSize * 30,
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
                          onPressed: () {},
                          child: Icon(Icons.login,
                              color: Colors.blue, size: textSize * 25),
                          padding: EdgeInsets.fromLTRB(
                              width * 0, height * 0, width * 0, height * 0),
                          style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(
                                  const BorderRadius.all(Radius.circular(100))),
                              depth: 50,
                              color: const Color(0XFFcadde0),
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
                          style: const NeumorphicStyle(
                              border: NeumorphicBorder(
                                isEnabled: true,
                                color: Colors.blue,
                                width: 2,
                              ),
                              shape: NeumorphicShape.flat,
                              intensity: 0.9,
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: -50,
                              lightSource: LightSource.topLeft,
                              color: Color(0XFFcadde0)),
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
                                  lastName, lastNameController),
                              NeumorphicTextField("Last Name", width * 0.41,
                                  lastName, lastNameController),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NeumorphicTextField(
                                "User Name",
                                width * (0.92 - (2 * 0.10 / 3)),
                                userName,
                                userNameController),
                          ],
                        ),
                        SizedBox(height: height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NeumorphicTextField(
                                "Phone Number",
                                width * (0.92 - (2 * 0.10 / 3)),
                                phoneNumber,
                                phoneNumberController),
                          ],
                        ),
                        SizedBox(height: height * 0.005),
                        Row(
                          children: [
                            Container(
                              width: width * (0.805 - (2 * 0.10 / 3)),
                              child: NeumorphicSlider(
                                height: height * 0.04,
                                onChanged: (double value) {
                                  setState(() {
                                    if (value < 13) {
                                      ageValue = 13;
                                    } else {
                                      ageValue = value;
                                    }
                                  });
                                },
                                onChangeStart: (val) {},
                                onChangeEnd: (val) {},
                                style: const SliderStyle(
                                    depth: -15,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100)),
                                    border: NeumorphicBorder(
                                      isEnabled: true,
                                      color: Colors.blue,
                                      width: 2,
                                    )),
                                max: 80,
                                min: 1,
                                value: ageValue,
                              ),
                            ),
                            Neumorphic(
                              child: Container(
                                height: height * 0.14,
                                width: width * 0.14,
                                child: Center(
                                    child: Text(ageValue.toInt().toString(),
                                        style: TextStyle(
                                            fontSize: textSize * 24,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w700))),
                              ),
                              style: NeumorphicStyle(
                                  color: mainColor,
                                  border: NeumorphicBorder(
                                      color: Colors.blue, width: 2),
                                  depth: -20,
                                  shape: NeumorphicShape.flat,
                                  boxShape: NeumorphicBoxShape.circle()),
                            )
                          ],
                        )
                      ]),
                  style: NeumorphicStyle(
                      depth: 50,
                      color: Color(0XFFcadde0),
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
    );
  }
}

class NeumorphicTextField extends StatefulWidget {
  String title;
  double width;
  String storeVariable;
  TextEditingController textEditingController;
  NeumorphicTextField(
      this.title, this.width, this.storeVariable, this.textEditingController);

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
              height: height * 0.065,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontSize: textSize * 25,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100))),
                    contentPadding: EdgeInsets.only(
                        bottom: height * 0.01,
                        left: width * 0.03,
                        right: width * 0.03)),
                onChanged: (text) {
                  setState(() {
                    widget.storeVariable = text;
                  });
                },
              )),
          style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(
                  const BorderRadius.all(Radius.circular(100))),
              depth: -15,
              color: const Color(0XFFcadde0),
              border: NeumorphicBorder(color: Colors.blue, width: 2),
              lightSource: LightSource.topLeft,
              shape: NeumorphicShape.concave),
        ),
      ],
    );
  }
}
