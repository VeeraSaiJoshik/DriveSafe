import 'dart:ffi';
import 'dart:math';
import 'dart:ui';
import 'dart:io';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddPhoneNumberScreen extends StatefulWidget {
  User currentUser;
  double textSize;
  AddPhoneNumberScreen(this.currentUser, this.textSize);
  @override
  AddPhoneNumberScreenstate createState() => AddPhoneNumberScreenstate();
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

class AddPhoneNumberScreenstate extends State<AddPhoneNumberScreen> {
  List<String> allDisplayNames = [];
  int highest = 0;
  late List<int> answer = [];
  late List<String> tempList2 = [];
  List<String> friendsList = [];
  List<String> requestList = [];
  List friends = [];
  List friendRequests = [];
  List LocationSharingPeople = [];
  List friendRequestsPending = [];
  List location = [];
  List numberList = [];
  List chosenNumber = [];
  List<String> phoneNumberSearchList = [];
  late User currentUser =
      User(" ", " ", " ", " ", 0, [], [], [], [], [], "", false, false, [], "");
  late List<User> allusers = [];
  bool flag = false;

  Future<User> getUserData(String phoneNumber) async {
    phoneNumber = phoneNumber.trim();
    phoneNumber = phoneNumber.replaceAll(" ", "");
    if (phoneNumber[0] != "+") {
      phoneNumber = "+1" + phoneNumber;
    }
    final Data =
        await FirebaseDatabase.instance.ref("User/" + phoneNumber).get();
    Map data = Data.value as Map;
    print(data);
    if (data.containsKey("friends")) {
      friends.addAll(data["friends"]);
      print(friends);
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
    return User(
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
      data["userName"]
    );
  }

  Future<List<User>> getData() async {
    List<User> allUserList = [];
    final finalData = await FirebaseDatabase.instance.ref("User").get();
    Map data = finalData.value as Map;

    List friends = [];
    List friendRequests = [];
    List LocationSharingPeople = [];
    List friendRequestsPending = [];
    List location = [];
    List numberList = [];
    List chosenNumber = [];
    data.forEach((key, value) {
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
      try {
        allUserList.add(User(
          value["firstName"],
          value["lastName"],
          key,
          value["password"],
          value["age"],
          friends,
          friendRequests,
          friendRequestsPending,
          LocationSharingPeople,
          location,
          value["image"],
          value["numberApproved"],
          value["locationTrackingOn"],
          chosenNumber,
          value["userName"]
        ));
      } catch (e) {}
    });
    return allUserList;
  }

  void collectData() async {
    await getData().then((users) {
      setState(() {
        allusers.addAll(users);
        for (int i = 0; i < allusers.length; i++) {
          allDisplayNames
              .add(allusers[i].firstName + " " + allusers[i].lastName);
          phoneNumberSearchList.add(allusers[i].phoneNumber);
        }
        tempList2.addAll(allDisplayNames);
        for (int k = 0; k < tempList2.length; k++) {
          if (tempList2[k].length > highest) {
            highest = tempList2[k].length;
          }
        }
        for (int k = 0; k < tempList2.length; k++) {
          for (int spaceI = tempList2[k].length; spaceI < highest; spaceI++) {
            tempList2[k] = tempList2[k] + " ";
          }
        }
      });
    });
    for (int i = 0; i < allusers.length; i++) {
      answer.add(i);
    }
    await getUserData(widget.currentUser.phoneNumber).then((value) {
      setState(() {
        currentUser = value;
      });
    });
  }

  void initState() {
    collectData();
    print(friends);
    super.initState();
  }

  late XFile? _image;
  bool haveChosen = false;
  String error = "";
  Future _getImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      haveChosen = true;
    });
  }

  @override
  double ageValue = 13;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  /*void createUser() async {
    await reference.set({
      "name": "John",
      "age": 18,
      "address": {"line1": "100 Mountain View"}
    });
  }*/

  Future<errorDelivery> checkIfUserPhoneNumber() async {
    DataSnapshot tempData = await FirebaseDatabase.instance.ref("User").get();
    var tempData1 = tempData.value;
    if (tempData1 != null) {
      Map finalData1 = tempData.value as Map;
      print(finalData1.keys);
      if (finalData1.containsKey(phoneNumberController.text)) {
        return errorDelivery(true, phoneNumberController.text, "");
      }
    }
    return errorDelivery(false, "", "");
    //
  }

  int alreadyPhoneNumber() {
    return -1;
  }

  errorDelivery checkForPhoneNumberMisConduct() {
    return errorDelivery(true, "", "");
  }

  errorDelivery allFieldsFilled() {
    if (firstNameController.text == "") {
      return errorDelivery(false, "First Name", "Please fill all textfields");
    } else if (lastNameController.text == "") {
      return errorDelivery(false, "Last Name", "Please fill all textfields");
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

  String generateRandomCode() {
    String answer = "";
    List<String> options = [
      'a',
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
      'h',
      'i',
      'j',
      'k',
      'l',
      'm',
      'n',
      'o',
      'p',
      'q',
      'r',
      's',
      't',
      'u',
      'v',
      'w',
      'x',
      'y',
      'z'
    ];
    int n = options.length;
    for (int i = 0; i < n; i++) {
      options.add(options[i].toUpperCase());
    }
    for (int i = 0; i < 10; i++) {
      options.add((i + 1).toString());
    }
    int nextInt = options.length;
    for (int i = 0; i < 10; i++) {
      int j = Random().nextInt(nextInt);
      answer = answer + options[j];
      options.removeAt(j);
      nextInt--;
    }
    return answer;
  }

  void completeCheck() async {
    DataSnapshot tempData = await FirebaseDatabase.instance.ref("User").get();
    var tempData1 = tempData.value;
    errorDelivery phoneCheck = await checkIfUserPhoneNumber();
    if (checkForPhoneNumberMisConduct().pass) {
      if (firstNameController.text.isEmpty && lastNameController.text.isEmpty) {
        Map finalData = tempData.value as Map;
        String currentLastName = finalData[phoneCheck.title]["lastName"];
        String currentFirstName = finalData[phoneCheck.title]["firstName"];
        String image = finalData[phoneCheck.title]["image"];
        BackgroundSms.sendMessage(
            phoneNumber: phoneNumberController.text.substring(2),
            message:
                "Greetings this is a bot from the Drive Safe Application. We are contacting you to inform you that you have been placed in " +
                    currentUser.firstName +
                    " " +
                    currentUser.lastName +
                    "'s list of trusted people.");
        BackgroundSms.sendMessage(
            phoneNumber: phoneNumberController.text.substring(2),
            message:
                "This means that you will be getting imporant information about the users well being while they are driving");
        String code = generateRandomCode();
        BackgroundSms.sendMessage(
            phoneNumber: phoneNumberController.text.substring(2),
            message:
                "NOTE : If you do not want to get information type the follwing : " +
                    code);

        currentUser.numberList.add([
          currentFirstName,
          currentLastName,
          phoneCheck.title,
          image,
          true,
          code
        ]);
        print(currentUser.phoneNumber);
        await FirebaseDatabase.instance
            .ref("User")
            .child(currentUser.phoneNumber)
            .child("phoneNumbersChosen")
            .set(currentUser.numberList);
        widget.currentUser.numberList = currentUser.numberList;

        Navigator.of(context).pop();
        print("this is working");
        //  Navigator.of(context).pop();

      } else {
        if (allFieldsFilled().pass) {
          if (checkPhoneNumber().pass) {
            if (!(firstNameController.text.contains(" ") &&
                !(lastNameController.text.contains(" ")))) {
              if (haveChosen) {
                File image = File(_image!.path);
                BackgroundSms.sendMessage(
                    phoneNumber: phoneNumberController.text.substring(2),
                    message:
                        "Greetings this is a bot from the Drive Safe Application. We are contacting you to inform you that you have been placed in " +
                            currentUser.firstName +
                            " " +
                            currentUser.lastName +
                            "'s list of trusted people.");
                BackgroundSms.sendMessage(
                    phoneNumber: phoneNumberController.text.substring(2),
                    message:
                        "This means that you will be getting imporant information about the users well being while they are driving");
                currentUser.numberList.add([
                  firstNameController.text,
                  lastNameController.text,
                  phoneNumberController.text,
                  " ",
                  false
                ]);
                String code = generateRandomCode();
                BackgroundSms.sendMessage(
                    phoneNumber: phoneNumberController.text.substring(2),
                    message:
                        "NOTE : If you do not want to get information type the follwing : " +
                            code);
                final firstUrl = await firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child('user images')
                    .child(currentUser.phoneNumber.toString() + '.jpg');
                firebase_storage.UploadTask uploadTask =
                    firstUrl.putFile(image);
                uploadTask.whenComplete(() async {
                  final finalUrl = await firstUrl.getDownloadURL();
                  currentUser.numberList.add([
                    firstNameController.text,
                    lastNameController.text,
                    phoneCheck.title,
                    finalUrl,
                    false,
                    code
                  ]);
                  await FirebaseDatabase.instance
                      .ref("User")
                      .child(currentUser.phoneNumber)
                      .child("phoneNumbersChosen")
                      .set(currentUser.numberList);
                });
              } else {
                AwesomeDialog(
                        context: context,
                        dialogType: DialogType.INFO,
                        animType: AnimType.SCALE,
                        headerAnimationLoop: false,
                        title: "Image",
                        desc: "Are you sure you dont want to choose an image",
                        titleTextStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: "Nunito",
                          fontSize: widget.textSize * 25,
                          color: Colors.blue,
                        ),
                        descTextStyle: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: widget.textSize * 20,
                            color: Colors.blue),
                        btnOkOnPress: () async {
                          BackgroundSms.sendMessage(
                              phoneNumber:
                                  phoneNumberController.text.substring(2),
                              message:
                                  "Greetings this is a bot from the Drive Safe Application. We are contacting you to inform you that you have been placed in " +
                                      currentUser.firstName +
                                      " " +
                                      currentUser.lastName +
                                      "'s list of trusted people.");
                          BackgroundSms.sendMessage(
                              phoneNumber:
                                  phoneNumberController.text.substring(2),
                              message:
                                  "This means that you will be getting imporant information about the users well being while they are driving");
                          String code = generateRandomCode();
                          BackgroundSms.sendMessage(
                              phoneNumber:
                                  phoneNumberController.text.substring(2),
                              message:
                                  "NOTE : If you do not want to get information type the follwing : " +
                                      code);
                          currentUser.numberList.add([
                            firstNameController.text,
                            lastNameController.text,
                            phoneNumberController.text,
                            " ",
                            false,
                            code
                          ]);
                          await FirebaseDatabase.instance
                              .ref("User")
                              .child(currentUser.phoneNumber)
                              .child("phoneNumbersChosen")
                              .set(currentUser.numberList);
                          widget.currentUser.numberList =
                              currentUser.numberList;

                          Navigator.of(context).pop();
                          print("this is working");
                        },
                        btnOkText: "Yes",
                        btnOkColor: Colors.green,
                        btnCancelText: "No",
                        btnCancelColor: Colors.red,
                        btnCancelOnPress: () {})
                    .show();
              }
            } else {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.ERROR,
                animType: AnimType.SCALE,
                headerAnimationLoop: false,
                title: "Name",
                desc: "The first or last name can not have a space in it",
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: "Nunito",
                  fontSize: widget.textSize * 25,
                  color: Colors.red,
                ),
                descTextStyle: TextStyle(
                    fontFamily: "Nunito",
                    fontSize: widget.textSize * 20,
                    color: Colors.redAccent),
                btnOkOnPress: () {},
                btnOkText: "Ok",
                btnOkColor: Colors.redAccent,
              ).show();
            }
          } else {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              animType: AnimType.SCALE,
              headerAnimationLoop: false,
              title: "Phone Number",
              desc:
                  "The given phone number is not a valid phone number, please try re-entering a valid phone number",
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: "Nunito",
                fontSize: widget.textSize * 25,
                color: Colors.red,
              ),
              descTextStyle: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: widget.textSize * 20,
                  color: Colors.redAccent),
              btnOkOnPress: () {},
              btnOkText: "Ok",
              btnOkColor: Colors.redAccent,
            ).show();
          }
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.SCALE,
            headerAnimationLoop: false,
            title: "Empty",
            desc: "All the fields are not filled, please fill all the fields",
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: "Nunito",
              fontSize: widget.textSize * 25,
              color: Colors.red,
            ),
            descTextStyle: TextStyle(
                fontFamily: "Nunito",
                fontSize: widget.textSize * 20,
                color: Colors.redAccent),
            btnOkOnPress: () {},
            btnOkText: "Ok",
            btnOkColor: Colors.redAccent,
          ).show();
        }
      }
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: false,
        title: "Phone Number",
        desc:
            "The phone number and the phone number check fields are not matching up, please check the fields",
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: "Nunito",
          fontSize: widget.textSize * 25,
          color: Colors.red,
        ),
        descTextStyle: TextStyle(
            fontFamily: "Nunito",
            fontSize: widget.textSize * 20,
            color: Colors.redAccent),
        btnOkOnPress: () {},
        btnOkText: "Ok",
        btnOkColor: Colors.redAccent,
      ).show();
    }
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
                  height: height * 0.1,
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
                        "Register",
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
                              completeCheck();
                            },
                            child: Icon(Icons.add_call,
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
                  height: height * 0.7,
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
                                          style: const NeumorphicStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    )),
                            style: NeumorphicStyle(
                                border: const NeumorphicBorder(
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
