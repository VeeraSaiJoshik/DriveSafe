import 'dart:async';

import 'package:drivesafev2/pages/ContactsScreen/driveSummary.dart';
import 'package:drivesafev2/pages/MapPageScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:flutter_latlong/flutter_latlong.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gMap;
import 'package:location/location.dart';
import '../../python/searchAlgorithm.dart';

class MainFriendScreen extends StatefulWidget {
  double height;
  double width;
  double textSize;
  User currentUser;
  TextEditingController textEditingController;
  bool remap;
  List users;
  Map rawUserData;
  MainFriendScreen(
      this.height,
      this.width,
      this.textEditingController,
      this.textSize,
      this.currentUser,
      this.remap,
      this.users,
      this.rawUserData);

  @override
  MainFriendScreenState createState() => MainFriendScreenState();
}

class MainFriendScreenState extends State<MainFriendScreen> {
  @override
  //begin
  //Variable decleration begins
  List<String> allDisplayNames = [];
  int index = 0;
  int highest = 0;
  late gMap.LatLng Clocation = gMap.LatLng(0, 0);
  late List answer = [];
  List<Color> colorList1 = [Colors.blue, Colors.blue.shade900];
  List<Color> colorList2 = [Colors.blue.shade900, Colors.blue];
  List<List> friendsList = [];
  List<int> requestList = [];
  List<String> requestListAnalysisList = [];
  List<String> phoneNumberList = [];
  late Map data1;
  int longestRequestListValue = 0;
  late User currentUser =
      User(" ", " ", " ", " ", 0, [], [], [], [], [], "", false, false, [], "");
  bool flag = false;
  List friends = [];
  List friendRequests = [];
  List LocationSharingPeople = [];
  List friendRequestsPending = [];
  List location = [];
  List numberList = [];
  List chosenNumber = [];
  List<bool> _selected = List.generate(2, (_) => false);
  //Variable declertion ends
  Future<void> getLocation() async {
    var data = await Location.instance.getLocation();
    Clocation = gMap.LatLng(data.latitude!, data.longitude!);
  }

  Future<User> getUserData(String phoneNumber) async {
    print("bactch");
    print(phoneNumber);
    final Data =
        await FirebaseDatabase.instance.ref("User/" + phoneNumber).get();
    phoneNumber = phoneNumber.trim();
    phoneNumber = phoneNumber.replaceAll(" ", "");
    Map data = Data.value as Map;
    print(data);

    List friends = [];
    List friendRequests = [];
    List friendRequestsPending = [];
    List location = [];
    List numberList = [];
    List chosenNumber = [];
    List gaurdian = [];
    List children = [];
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
      location.addAll(["location"]);
    }
    if (data.containsKey("phoneNumbersChosen")) {
      numberList.addAll(data["phoneNumbersChosen"]);
    }
    if (data.containsKey("phoneNumbersChosen")) {
      chosenNumber.addAll(data["phoneNumbersChosen"]);
    }
    if (data.containsKey("gaurdian")) {
      gaurdian.addAll(data["gaurdian"]);
    }
    if (data.containsKey("children")) {
      children.addAll(data["children"]);
    }
    User returnUser = User(
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
    print(gaurdian);
    print(children);
    returnUser.gauridians = gaurdian;
    returnUser.children = children;
    return returnUser;
  }

  List<String> LocationSharingUsers = [];
  Future<List<String>> getAllSharingUsers(User currentUser) async {
    List<String> answer = [];

    for (int i = 0; i < currentUser.friends.length; i++) {
      List acceptedPhoneNumber = [];

      List value = widget.rawUserData[currentUser.friends[i]]
          ["locationSharingPeople"] as List;
      if (value != null) {
        acceptedPhoneNumber.addAll(value as List);
      }

      if (acceptedPhoneNumber == []) {
        continue;
      } else {
        if (acceptedPhoneNumber.contains(currentUser.phoneNumber)) {
          answer.add(currentUser.friends[i]);
        } else {
          continue;
        }
      }
    }
    print(answer);
    return answer;
  }

  void goToUserMapPage() async {
    getAllSharingUsers(currentUser).then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MapPageScreen(currentUser, value, Clocation, widget.rawUserData);
      }));
    });
  }

  Future<void> collectData() async {
    await getUserData(widget.currentUser.phoneNumber).then((value) {
      setState(() {
        currentUser = value;
      });
    });

    setState(() {
      friendsList;
    });
    print(widget.users.length);
    int ting = 0;
    for (int j = 0; j < widget.users.length; j++) {
      for (int i = 0; i < currentUser.friends.length; i++) {
        if (widget.users[j].phoneNumber == currentUser.friends[i]) {
          requestList.add(j);
          print(widget.users[j].firstName + widget.users[j].lastName);
          requestListAnalysisList
              .add(widget.users[j].firstName + " " + widget.users[j].lastName);
          if (longestRequestListValue < requestListAnalysisList[ting].length) {
            longestRequestListValue = requestListAnalysisList[ting].length;
          }
          ting++;
          phoneNumberList.add(widget.users[j].phoneNumber);
          break;
        }
      }
    }
    print(friendsList);
    for (int i = 0; i < requestListAnalysisList.length; i++) {
      for (int j = requestListAnalysisList[i].length;
          j < longestRequestListValue;
          j++) {
        requestListAnalysisList[i] = requestListAnalysisList[i] + " ";
      }
    }
    print(requestList);
    print("this is this");
    setState(() {
      requestList;
      answer.addAll(requestList);
      print(answer);
    });
  }

  void initFunction() async {
    getLocation().whenComplete(() {
      collectData().whenComplete(() {
        if (widget.remap) {
          goToUserMapPage();
        }
      });
    });
  }

  void initState() {
    print("this is");
    initFunction();
    setState(() {
      friendsList;
    });
    setState(() {
      requestList;
    });
    print(friendsList);

    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
        height: widget.height,
        width: widget.width,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
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
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(
                                    fontSize: widget.textSize * 30,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue),
                                textAlign: TextAlign.center,
                                onChanged: (text) {
                                  flag = true;
                                  List<String> dummy = allDisplayNames;
                                  setState(() {
                                    List tempAns = [];

                                    answer = searchNames(
                                        requestListAnalysisList,
                                        text,
                                        longestRequestListValue + 1,
                                        true);
                                    if (widget.users.length == answer.length ||
                                        answer.isEmpty) {
                                      if (text != "") {
                                        answer = [];
                                        print(searchPhoneNumbers(
                                            phoneNumberList, text, flag));
                                        answer.addAll(searchPhoneNumbers(
                                            phoneNumberList, text, flag));
                                        print(answer);
                                      }
                                    }
                                    tempAns.addAll(answer);
                                    answer = [];
                                    for (int i = 0; i < tempAns.length; i++) {
                                      answer.add(requestList[tempAns[i]]);
                                    }
                                    setState(() {
                                      answer;
                                    });
                                    print(longestRequestListValue);
                                    print(text);
                                    print(requestListAnalysisList);
                                    print(answer);
                                  });
                                },
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
                                  const BorderRadius.all(Radius.circular(100))),
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
                  Container(
                    width: widget.width,
                    height: widget.height * 0.9,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                              //height: widget.height * 0.8,
                              width: widget.width,
                              child: ListView(
                                children: [
                                  ...answer.map((e) {
                                    Color color = Colors.green;
                                    bool isGaurdian = false;
                                    bool isChild = false;
                                    print(currentUser.gauridians);
                                    print(currentUser.children);
                                    if (currentUser.gauridians.contains(
                                        widget.users[e].phoneNumber)) {
                                      isGaurdian = true;
                                    }
                                    if (currentUser.children.contains(
                                        widget.users[e].phoneNumber)) {
                                      isChild = true;
                                    }
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (builder) {
                                          return DriveSummary(
                                              widget.users[e].phoneNumber,
                                              widget.users[e],
                                              widget.currentUser.phoneNumber);
                                        }));
                                        print("here");
                                      },
                                      child: Container(
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
                                          //   color: Colors.black,
                                          child: InkWell(
                                            child: Neumorphic(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                      child: Row(children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
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
                                                          color: Colors
                                                              .grey.shade300,
                                                          lightSource:
                                                              LightSource
                                                                  .topLeft,
                                                          border:
                                                              NeumorphicBorder(
                                                                  color: color,
                                                                  width: 5),
                                                          shape: NeumorphicShape
                                                              .concave),
                                                      child: widget.users[e]
                                                                  .image ==
                                                              ""
                                                          ? CircleAvatar(
                                                              radius: widget
                                                                      .height *
                                                                  (0.11 / 2),
                                                              backgroundColor:
                                                                  Colors.grey
                                                                      .shade300,
                                                              child:
                                                                  NeumorphicIcon(
                                                                Icons.tag_faces,
                                                                size: widget
                                                                        .textSize *
                                                                    70,
                                                                style: NeumorphicStyle(
                                                                    color:
                                                                        color),
                                                              ),
                                                            )
                                                          : CircleAvatar(
                                                              radius: widget
                                                                      .height *
                                                                  (0.11 / 2),
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      widget
                                                                          .users[
                                                                              e]
                                                                          .image),
                                                            ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.02,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          widget.users[e]
                                                              .phoneNumber,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: color,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .textScaleFactor *
                                                                  25),
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              widget.height *
                                                                  0.01,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            widget.users[e].firstName.length +
                                                                        1 +
                                                                        widget
                                                                            .users[e]
                                                                            .lastName
                                                                            .length <=
                                                                    20
                                                                ? Text(
                                                                    widget
                                                                            .users[
                                                                                e]
                                                                            .firstName +
                                                                        " " +
                                                                        widget
                                                                            .users[e]
                                                                            .lastName,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .visible,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color:
                                                                            color,
                                                                        fontSize:
                                                                            MediaQuery.of(context).textScaleFactor *
                                                                                20),
                                                                  )
                                                                : Text(
                                                                    widget
                                                                        .users[
                                                                            e]
                                                                        .firstName,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .visible,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color:
                                                                            color,
                                                                        fontSize:
                                                                            MediaQuery.of(context).textScaleFactor *
                                                                                20),
                                                                  ),
                                                            isChild
                                                                ? Icon(
                                                                    Icons
                                                                        .child_care,
                                                                    color:
                                                                        color,
                                                                    size: MediaQuery.of(context)
                                                                            .textScaleFactor *
                                                                        20,
                                                                  )
                                                                : Container()
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ])),
                                                  Container(
                                                    child: Row(
                                                      children: [
                                                        AnimatedSwitcher(
                                                          duration: Duration(
                                                              seconds: 10),
                                                          transitionBuilder: (Widget
                                                                      child,
                                                                  Animation<
                                                                          double>
                                                                      animation) =>
                                                              FadeTransition(
                                                                  opacity:
                                                                      animation,
                                                                  child: child),
                                                          child: isGaurdian
                                                              ? NeumorphicIcon(
                                                                  Icons
                                                                      .shield_rounded,
                                                                  size: widget
                                                                          .textSize *
                                                                      55,
                                                                  style: NeumorphicStyle(
                                                                      color: Colors
                                                                          .green
                                                                          .shade600),
                                                                )
                                                              : currentUser
                                                                          .LocationSharingPeople
                                                                      .contains(widget
                                                                          .users[
                                                                              e]
                                                                          .phoneNumber)
                                                                  ? InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        setState(() => currentUser.LocationSharingPeople.remove(widget
                                                                            .users[e]
                                                                            .phoneNumber));
                                                                        print(currentUser
                                                                            .LocationSharingPeople);
                                                                        await FirebaseDatabase
                                                                            .instance
                                                                            .ref("User")
                                                                            .child(currentUser.phoneNumber)
                                                                            .child("locationSharingPeople")
                                                                            .set(currentUser.LocationSharingPeople);
                                                                      },
                                                                      child:
                                                                          NeumorphicIcon(
                                                                        Icons
                                                                            .location_on,
                                                                        size: widget.textSize *
                                                                            55,
                                                                        style:
                                                                            NeumorphicStyle(
                                                                          color: Colors
                                                                              .lightGreen
                                                                              .shade700,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : InkWell(
                                                                      child:
                                                                          NeumorphicIcon(
                                                                        Icons
                                                                            .location_off,
                                                                        size: widget.textSize *
                                                                            55,
                                                                        style: NeumorphicStyle(
                                                                            color:
                                                                                Colors.red.shade600),
                                                                      ),
                                                                      onTap:
                                                                          () async {
                                                                        setState(() => currentUser.LocationSharingPeople.add(widget
                                                                            .users[e]
                                                                            .phoneNumber));
                                                                        await FirebaseDatabase
                                                                            .instance
                                                                            .ref("User")
                                                                            .child(currentUser.phoneNumber)
                                                                            .child("locationSharingPeople")
                                                                            .set(currentUser.LocationSharingPeople);
                                                                      },
                                                                    ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.015,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              style: NeumorphicStyle(
                                                  boxShape: NeumorphicBoxShape
                                                      .roundRect(
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  45))),
                                                  depth: 15,
                                                  color: Colors.grey.shade300,
                                                  lightSource:
                                                      LightSource.topLeft,
                                                  shape:
                                                      NeumorphicShape.concave),
                                            ),
                                          )),
                                    );
                                  }).toList()
                                  //=> Text(allusers[e[1]].phoneNumber)
                                ],
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
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
                        goToUserMapPage();
                      },
                      child: Icon(
                        Icons.map,
                        color: Colors.grey.shade300,
                        size: widget.textSize * 30,
                      ),
                    ),
                  ),
                )),
          ],
        ));
  }
}
//down