/*import 'dart:async';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/User.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'addPhoneNumberScreen.dart';

class PhoneNumberScreen extends StatefulWidget {
  double height;
  double width;
  double textSize;
  User currentUser;
  TextEditingController textEditingController;
  Timer timer;
  PhoneNumberScreen(this.height, this.width, this.textEditingController,
      this.textSize, this.currentUser, this.timer);
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  int counter = 0;
  int index = 0;
  int highest = 0;
  List<String> tempList2 = [];
  List<Color> colorList1 = [Colors.blue, Colors.grey.shade300];
  List<Color> colorTextList1 = [Colors.grey.shade300, Colors.blue];
  List<Color> colorList2 = [Colors.grey.shade300, Colors.blue];
  List<Color> colorTextList2 = [Colors.blue, Colors.grey.shade300];
  List phoneNumberList = [];
  late User currentUser =
      User(" ", " ", " ", " ", 0, [], [], [], [], [], "", false, false, []);
  Future<User> getUserData(String phoneNumber) async {
    final Data =
        await FirebaseDatabase.instance.ref("User/" + phoneNumber).get();
    phoneNumber = phoneNumber.trim();
    phoneNumber = phoneNumber.replaceAll(" ", "");
    print(Data);
    Map data = Data.value as Map;
    List friends = [];
    List friendRequests = [];
    List LocationSharingPeople = [];
    List friendRequestsPending = [];
    List location = [];
    List numberList = [];
    List chosenNumber = [];
    if (phoneNumber[0] != "+") {
      phoneNumber = "+1" + phoneNumber;
    }

    if (data.containsKey("friends")) {
      friends.addAll(data["friends"]);
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
      location.addAll(data["location"]);
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
    );
  }

  void collectData() async {
    await getUserData(widget.currentUser.phoneNumber)
        .then((value) => setState(() {
              currentUser = value;
              widget.currentUser = value;
            }));
  }

  void initFunction() async {
    collectData();
  }

  void initState() {
    initFunction();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                Container(
                  width: widget.width,
                  height: widget.height,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: widget.height * 0.07,
                        ),
                        Container(
                          height: widget.height * 0.08,
                          width: widget.width * 0.95,
                          child: Row(
                            children: [
                              Neumorphic(
                                child: Container(
                                    width: widget.width * 0.95,
                                    child: TextField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: TextStyle(
                                          fontSize: widget.textSize * 30,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue),
                                      textAlign: TextAlign.center,
                                      onChanged: (text) {},
                                      decoration: InputDecoration(
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.only(
                                                left: widget.width * 0.03),
                                            child: IconButton(
                                              icon: Icon(Icons.arrow_back_ios),
                                              onPressed: () {
                                                widget.timer.cancel();
                                                Navigator.pop(context);
                                              },
                                              color: Colors.blue,
                                              iconSize: widget.textSize * 40,
                                            ),
                                          ),
                                          suffixIcon: Padding(
                                            padding: EdgeInsets.only(
                                                right: widget.width * 0.03),
                                            child: IconButton(
                                              icon: Icon(CupertinoIcons.search),
                                              color: Colors.blue,
                                              iconSize: widget.textSize * 40,
                                              onPressed: () {},
                                            ),
                                          ),
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100))),
                                          contentPadding: EdgeInsets.only(
                                            bottom: widget.height * 0.01,
                                            top: widget.height * 0.01,
                                            left: 0,
                                          )),
                                      controller: widget.textEditingController,
                                    )),
                                style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        const BorderRadius.all(
                                            Radius.circular(100))),
                                    depth: 15,
                                    color: Colors.grey.shade300,
                                    border: NeumorphicBorder(
                                        color: Colors.blue, width: 3),
                                    lightSource: LightSource.topLeft,
                                    shape: NeumorphicShape.concave),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                              width: widget.width,
                              child: ListView(
                                children: [
                                  ...currentUser.numberList.map((e) {
                                    print(e);
                                    Color color;
                                    if (e[4]) {
                                      color = Colors.blue;
                                    } else {
                                      color = Colors.cyan;
                                    }
                                    return Container(
                                        width: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.95,
                                        height: widget.height * 0.15,
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.025,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.025,
                                            bottom: widget.height * 0.02),
                                        child: Neumorphic(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              Neumorphic(
                                                  style: NeumorphicStyle(
                                                      boxShape:
                                                          NeumorphicBoxShape
                                                              .circle(),
                                                      depth: -15,
                                                      color:
                                                          Colors.grey.shade300,
                                                      lightSource:
                                                          LightSource.topLeft,
                                                      border: NeumorphicBorder(
                                                          color: color,
                                                          width: 5),
                                                      shape: NeumorphicShape
                                                          .concave),
                                                  child: e[3] == "" ||
                                                          e[3] == " "
                                                      ? CircleAvatar(
                                                          radius:
                                                              widget.height *
                                                                  (0.11 / 2),
                                                          backgroundColor:
                                                              Colors.grey
                                                                  .shade300,
                                                          child: NeumorphicIcon(
                                                            Icons.tag_faces,
                                                            size: widget
                                                                    .textSize *
                                                                70,
                                                            style:
                                                                NeumorphicStyle(
                                                                    color:
                                                                        color),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            print(e[3]);
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                widget.height *
                                                                    (0.11 / 2),
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    e[3]),
                                                          ),
                                                        )),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    e[2],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: color,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor *
                                                            25),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        widget.height * 0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      (e[0] as String).length +
                                                                  1 +
                                                                  (e[1] as String)
                                                                      .length <=
                                                              20
                                                          ? Text(
                                                              e[0] + " " + e[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: color,
                                                                  fontSize:
                                                                      MediaQuery.of(context)
                                                                              .textScaleFactor *
                                                                          20),
                                                            )
                                                          : Text(
                                                              e[0],
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: color,
                                                                  fontSize:
                                                                      MediaQuery.of(context)
                                                                              .textScaleFactor *
                                                                          20),
                                                            ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.08,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      onPressed: () async {
                                                        BackgroundSms.sendMessage(
                                                            phoneNumber: e[2]
                                                                .toString()
                                                                .substring(2),
                                                            message: "Greetings this is a bot from the Drive Safe Application. We are contacting you to inform you that you have been removed from" +
                                                                currentUser
                                                                    .firstName +
                                                                " " +
                                                                currentUser
                                                                    .lastName +
                                                                "'s list of trusted people");
                                                        BackgroundSms.sendMessage(
                                                            phoneNumber: e[2]
                                                                .toString()
                                                                .substring(2),
                                                            message:
                                                                "Therefore you will not be getting the data you usually are getting.");
                                                        for (int i = 0;
                                                            i <
                                                                currentUser
                                                                    .numberList
                                                                    .length;
                                                            i++) {
                                                          if (currentUser
                                                                      .numberList[
                                                                  i][2] ==
                                                              e[2]) {
                                                            setState(() {
                                                              currentUser
                                                                  .numberList
                                                                  .removeAt(i);
                                                            });

                                                            break;
                                                          }
                                                        }
                                                        await FirebaseDatabase
                                                            .instance
                                                            .ref("User")
                                                            .child(currentUser
                                                                .phoneNumber)
                                                            .child(
                                                                "phoneNumbersChosen")
                                                            .set(currentUser
                                                                .numberList);
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: widget.textSize *
                                                            50,
                                                      )),
                                                  SizedBox(
                                                    height:
                                                        widget.height * 0.025,
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          style: NeumorphicStyle(
                                              boxShape:
                                                  NeumorphicBoxShape.roundRect(
                                                      const BorderRadius.all(
                                                          Radius.circular(45))),
                                              depth: 15,
                                              border: NeumorphicBorder(
                                                  color: color, width: 4),
                                              color: Colors.grey.shade300,
                                              shadowLightColor:
                                                  Colors.transparent,
                                              lightSource: LightSource.topLeft,
                                              shape: NeumorphicShape.concave),
                                        ));
                                    //return Text(e.toString());
                                  }).toList()
                                ],
                              )),
                        )
                      ]),
                ),
                Positioned(
                    bottom: widget.height * 0.03,
                    right: widget.width * 0.03,
                    child: Container(
                      height: widget.width * 0.17,
                      width: widget.width * 0.17,
                      margin: EdgeInsets.only(right: widget.width * 0.025),
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(100))),
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddPhoneNumberScreen(
                                        currentUser,
                                        widget.textSize))).whenComplete(() {
                              setState(() {
                                currentUser;
                                widget.currentUser = currentUser;
                              });
                            });
                          },
                          child: Icon(
                            Icons.add_call,
                            color: Colors.grey.shade300,
                            size: widget.textSize * 30,
                          ),
                        ),
                      ),
                    ))
              ],
            )));
  }
}
*/
import 'dart:async';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/User.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'addPhoneNumberScreen.dart';

class PhoneNumberScreen extends StatefulWidget {
  double height;
  double width;
  double textSize;
  User currentUser;
  TextEditingController textEditingController;
  PhoneNumberScreen(this.height, this.width, this.textEditingController,
      this.textSize, this.currentUser);
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  int counter = 0;
  int index = 0;
  int highest = 0;
  List<String> tempList2 = [];
  List<Color> colorList1 = [Colors.blue, Colors.grey.shade300];
  List<Color> colorTextList1 = [Colors.grey.shade300, Colors.blue];
  List<Color> colorList2 = [Colors.grey.shade300, Colors.blue];
  List<Color> colorTextList2 = [Colors.blue, Colors.grey.shade300];
  List phoneNumberList = [];
  late User currentUser =
      User(" ", " ", " ", " ", 0, [], [], [], [], [], "", false, false, [], "");
  Future<User> getUserData(String phoneNumber) async {
    final Data =
        await FirebaseDatabase.instance.ref("User/" + phoneNumber).get();
    phoneNumber = phoneNumber.trim();
    phoneNumber = phoneNumber.replaceAll(" ", "");
    Map data = Data.value as Map;
    List friends = [];
    List friendRequests = [];
    List LocationSharingPeople = [];
    List friendRequestsPending = [];
    List location = [];
    List numberList = [];
    List chosenNumber = [];
    if (phoneNumber[0] != "+") {
      phoneNumber = "+1" + phoneNumber;
    }

    if (data.containsKey("friends")) {
      friends.addAll(data["friends"]);
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

  void collectData() async {
    await getUserData(widget.currentUser.phoneNumber)
        .then((value) => setState(() {
              currentUser = value;
              widget.currentUser = value;
            }));
  }

  void initFunction() async {
    collectData();
  }

  void initState() {
    initFunction();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                Container(
                  width: widget.width,
                  height: widget.height,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: widget.height * 0.07,
                        ),
                        Container(
                          height: widget.height * 0.08,
                          width: widget.width * 0.95,
                          child: Row(
                            children: [
                              Neumorphic(
                                child: Container(
                                    width: widget.width * 0.95,
                                    child: TextField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: TextStyle(
                                          fontSize: widget.textSize * 30,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue),
                                      textAlign: TextAlign.center,
                                      onChanged: (text) {},
                                      decoration: InputDecoration(
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.only(
                                                left: widget.width * 0.03),
                                            child: IconButton(
                                              icon: Icon(Icons.arrow_back_ios),
                                              onPressed: () {
                                                
                                                Navigator.pop(context);
                                              },
                                              color: Colors.blue,
                                              iconSize: widget.textSize * 40,
                                            ),
                                          ),
                                          suffixIcon: Padding(
                                            padding: EdgeInsets.only(
                                                right: widget.width * 0.03),
                                            child: IconButton(
                                              icon: Icon(CupertinoIcons.search),
                                              color: Colors.blue,
                                              iconSize: widget.textSize * 40,
                                              onPressed: () {},
                                            ),
                                          ),
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100))),
                                          contentPadding: EdgeInsets.only(
                                            bottom: widget.height * 0.01,
                                            top: widget.height * 0.01,
                                            left: 0,
                                          )),
                                      controller: widget.textEditingController,
                                    )),
                                style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        const BorderRadius.all(
                                            Radius.circular(100))),
                                    depth: 15,
                                    color: Colors.grey.shade300,
                                    border: NeumorphicBorder(
                                        color: Colors.blue, width: 3),
                                    lightSource: LightSource.topLeft,
                                    shape: NeumorphicShape.concave),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                              width: widget.width,
                              child: ListView(
                                children: [
                                  ...currentUser.numberList.map((e) {
                                    print(e);
                                    Color color;
                                    if (e[4]) {
                                      color = Colors.blue;
                                    } else {
                                      color = Colors.cyan;
                                    }
                                    return Container(
                                        width: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.95,
                                        height: widget.height * 0.15,
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.025,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.025,
                                            bottom: widget.height * 0.02),
                                        child: Neumorphic(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              Neumorphic(
                                                  style: NeumorphicStyle(
                                                      boxShape:
                                                          NeumorphicBoxShape
                                                              .circle(),
                                                      depth: -15,
                                                      color:
                                                          Colors.grey.shade300,
                                                      lightSource:
                                                          LightSource.topLeft,
                                                      border: NeumorphicBorder(
                                                          color: color,
                                                          width: 5),
                                                      shape: NeumorphicShape
                                                          .concave),
                                                  child: e[3] == "" ||
                                                          e[3] == " "
                                                      ? CircleAvatar(
                                                          radius:
                                                              widget.height *
                                                                  (0.11 / 2),
                                                          backgroundColor:
                                                              Colors.grey
                                                                  .shade300,
                                                          child: NeumorphicIcon(
                                                            Icons.tag_faces,
                                                            size: widget
                                                                    .textSize *
                                                                70,
                                                            style:
                                                                NeumorphicStyle(
                                                                    color:
                                                                        color),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            print(e[3]);
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                widget.height *
                                                                    (0.11 / 2),
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    e[3]),
                                                          ),
                                                        )),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    e[2],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: color,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .textScaleFactor *
                                                            25),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        widget.height * 0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      (e[0] as String).length +
                                                                  1 +
                                                                  (e[1] as String)
                                                                      .length <=
                                                              20
                                                          ? Text(
                                                              e[0] + " " + e[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: color,
                                                                  fontSize:
                                                                      MediaQuery.of(context)
                                                                              .textScaleFactor *
                                                                          20),
                                                            )
                                                          : Text(
                                                              e[0],
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: color,
                                                                  fontSize:
                                                                      MediaQuery.of(context)
                                                                              .textScaleFactor *
                                                                          20),
                                                            ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.08,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      onPressed: () async {
                                                        BackgroundSms.sendMessage(
                                                            phoneNumber: e[2]
                                                                .toString()
                                                                .substring(2),
                                                            message: "Greetings this is a bot from the Drive Safe Application. We are contacting you to inform you that you have been removed from" +
                                                                currentUser
                                                                    .firstName +
                                                                " " +
                                                                currentUser
                                                                    .lastName +
                                                                "'s list of trusted people");
                                                        BackgroundSms.sendMessage(
                                                            phoneNumber: e[2]
                                                                .toString()
                                                                .substring(2),
                                                            message:
                                                                "Therefore you will not be getting the data you usually are getting.");
                                                        for (int i = 0;
                                                            i <
                                                                currentUser
                                                                    .numberList
                                                                    .length;
                                                            i++) {
                                                          if (currentUser
                                                                      .numberList[
                                                                  i][2] ==
                                                              e[2]) {
                                                            setState(() {
                                                              currentUser
                                                                  .numberList
                                                                  .removeAt(i);
                                                            });

                                                            break;
                                                          }
                                                        }
                                                        await FirebaseDatabase
                                                            .instance
                                                            .ref("User")
                                                            .child(currentUser
                                                                .phoneNumber)
                                                            .child(
                                                                "phoneNumbersChosen")
                                                            .set(currentUser
                                                                .numberList);
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: widget.textSize *
                                                            50,
                                                      )),
                                                  SizedBox(
                                                    height:
                                                        widget.height * 0.025,
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          style: NeumorphicStyle(
                                              boxShape:
                                                  NeumorphicBoxShape.roundRect(
                                                      const BorderRadius.all(
                                                          Radius.circular(45))),
                                              depth: 15,
                                              border: NeumorphicBorder(
                                                  color: color, width: 4),
                                              color: Colors.grey.shade300,
                                              shadowLightColor:
                                                  Colors.transparent,
                                              lightSource: LightSource.topLeft,
                                              shape: NeumorphicShape.concave),
                                        ));
                                    //return Text(e.toString());
                                  }).toList()
                                ],
                              )),
                        )
                      ]),
                ),
                Positioned(
                    bottom: widget.height * 0.03,
                    right: widget.width * 0.03,
                    child: Container(
                      height: widget.width * 0.17,
                      width: widget.width * 0.17,
                      margin: EdgeInsets.only(right: widget.width * 0.025),
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(100))),
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddPhoneNumberScreen(
                                        currentUser,
                                        widget.textSize))).whenComplete(() {
                              setState(() {
                                currentUser;
                                widget.currentUser = currentUser;
                              });
                            });
                          },
                          child: Icon(
                            Icons.add_call,
                            color: Colors.grey.shade300,
                            size: widget.textSize * 30,
                          ),
                        ),
                      ),
                    ))
              ],
            )));
  }
}
