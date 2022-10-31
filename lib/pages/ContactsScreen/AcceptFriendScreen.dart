import 'dart:async';

import 'package:background_sms/background_sms.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../python/searchAlgorithm.dart';

class FriendsScreen extends StatefulWidget {
  double height;
  double width;
  double textSize;
  User currentUser;
  TextEditingController textEditingController;
  FriendsScreen(
    this.height,
    this.width,
    this.textEditingController,
    this.textSize,
    this.currentUser,
  );
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  //begin
  //Variable decleration begins
  List<String> allDisplayNames = [];
  int counter = 0;
  int index = 0;
  int highest = 0;
  late List answer = [];
  late List<String> tempList2 = [];
  List<Color> colorList1 = [Colors.blue, Colors.grey.shade300];
  List<Color> colorTextList1 = [Colors.grey.shade300, Colors.blue];
  List<Color> colorList2 = [Colors.grey.shade300, Colors.blue];
  List<Color> colorTextList2 = [Colors.blue, Colors.grey.shade300];
  List<List> friendsList = [];
  List requestList = [];
  List<String> friendListAnalysisList = [];
  List<String> friendListPhoneNumberList = [];
  List<String> requestListFriendAnalysisList = [];
  List<String> requestListAnalysisList = [];
  int longestFriendListvalue = 0;
  int longestRequestListValue = 0;
  late User currentUser =
      User(" ", " ", " ", " ", 0, [], [], [], [], [], "", false, false, [], "");
  late List<User> allusers = [];
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
    List gaurdians = [];
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

    if (data.containsKey("phoneNumbersChosen")) {
      numberList.addAll(data["phoneNumbersChosen"]);
      print(numberList);
    }
    if (data.containsKey("gaurdians")) {
      chosenNumber.addAll(data["gaurdians"]);
    }
    if (data.containsKey("children")) {
      chosenNumber.addAll(data["children"]);
    }
    User answer = User(
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
      numberList,
      data["userName"],
    );
    answer.gauridians = gaurdians;
    answer.children = children;
    return answer;
  }

  Future<List<User>> getData() async {
    List<User> allUserList = [];
    final finalData = await FirebaseDatabase.instance.ref("User").get();
    print("here");
    Map data = finalData.value as Map;
    print(data["+11234567890"]["friendReqeusts"]);
    print("dfasd");
    data.forEach((key, value) {
      print(key);
      if (data[key].containsKey("friends")) {
        friends.addAll(data[key]["friends"]);
      }
      if (data[key].containsKey("friendReqeusts")) {
        friendRequests.addAll(data[key]["friendReqeusts"]);
        print(data[key]["friendRequests"]);
      }
      if (data[key].containsKey("locationSharingPeople")) {
        LocationSharingPeople.addAll(data[key]["locationSharingPeople"]);
      }
      if (data[key].containsKey("friendRequestsPending")) {
        print(data[key]["friendRequestsPending"]);
        friendRequestsPending.addAll(data[key]["friendRequestsPending"]);
      }

      if (data[key].containsKey("phoneNumbersChosen")) {
        numberList.addAll(data[key]["phoneNumbersChosen"]);
      }
      if (data[key].containsKey("phoneNumbersChosen")) {
        chosenNumber.addAll(data[key]["phoneNumbersChosen"]);
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
          data["userName"]
        ));
      } catch (e) {}
      friends = [];
      friendRequests = [];
      friendRequestsPending = [];
      LocationSharingPeople = [];
      location = [];
      chosenNumber = [];
    });
    return allUserList;
  }

  void collectData() async {
    for (int i = 0; i < allusers.length; i++) {
      answer.add(i);
    }
    await getUserData(widget.currentUser.phoneNumber).then((value) {
      setState(() {
        currentUser = value;
      });
    });
    await getData().then((users) {
      setState(() {
        allusers.addAll(users);
      });
      print(currentUser.friendRequests.length);
      print("this");
      for (int i = 0; i < currentUser.friendRequests.length; i++) {
        for (int j = 0; j < allusers.length; j++) {
          print(currentUser.friendRequests[i]);
          if (allusers[j].phoneNumber == currentUser.friendRequests[i][1]) {
            friendsList.add([currentUser.friendRequests[i], j]);
            friendListAnalysisList
                .add(users[j].firstName + " " + users[j].lastName);
            friendListPhoneNumberList.add(allusers[j].phoneNumber);
            break;
          }
        }
        for (int i = 0; i < friendListAnalysisList.length; i++) {
          if (friendListAnalysisList[i].length > longestFriendListvalue) {
            longestFriendListvalue = friendListAnalysisList[i].length;
          }
        }
        for (int i = 0; i < friendListAnalysisList.length; i++) {
          for (int j = friendListAnalysisList[i].length;
              j < longestFriendListvalue;
              j++) {
            friendListAnalysisList[i] = friendListAnalysisList[i] + " ";
          }
        }
        setState(() {
          friendsList;
        });
        print(currentUser.friendRequestsPending);
      }
      for (int i = 0; i < currentUser.friendRequestsPending.length; i++) {
        for (int j = 0; j < allusers.length; j++) {
          if (allusers[j].phoneNumber == currentUser.friendRequestsPending[i]) {
            requestList.add(j);
            requestListAnalysisList
                .add(allusers[j].firstName + " " + allusers[j].lastName);
            requestListFriendAnalysisList.add(allusers[j].phoneNumber);
            break;
          }
        }
      }

      for (int i = 0; i < requestListAnalysisList.length; i++) {
        if (longestRequestListValue < requestListAnalysisList[i].length) {
          longestRequestListValue = requestListAnalysisList[i].length;
        }
      }
      for (int i = 0; i < requestListAnalysisList.length; i++) {
        for (int j = requestListAnalysisList[i].length;
            j < longestRequestListValue;
            j++) {
          requestListAnalysisList[i] = requestListAnalysisList[i] + " ";
        }
      }

      setState(() {
        requestList;
      });
      answer.addAll(requestList);
    });
  }

  void initFunction() async {
    collectData();
  }

  void initState() {
    initFunction();
    setState(() {
      friendsList;
    });
    setState(() {
      requestList;
    });
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
                                  List<String> dummy = allDisplayNames;
                                  flag = true;
                                  setState(() {
                                    List tempAns = [];
                                    if (counter == 1) {
                                      answer = searchNames(
                                          friendListAnalysisList,
                                          text,
                                          longestFriendListvalue + 1,
                                          true);
                                      if (allusers.length == answer.length ||
                                          answer.isEmpty) {
                                        if (text != "") {
                                          answer = [];
                                          answer.addAll(searchPhoneNumbers(
                                              friendListPhoneNumberList,
                                              text,
                                              flag));
                                        }
                                      }

                                      tempAns.addAll(answer);
                                      answer = [];
                                      for (int i = 0; i < tempAns.length; i++) {
                                        answer.add(friendsList[tempAns[i]]);
                                      }
                                    } else {
                                      answer = searchNames(
                                          requestListAnalysisList,
                                          text,
                                          longestRequestListValue + 1,
                                          true);
                                      if (allusers.length == answer.length ||
                                          answer.isEmpty) {
                                        if (text != "") {
                                          answer = [];

                                          answer.addAll(searchPhoneNumbers(
                                              requestListFriendAnalysisList,
                                              text,
                                              flag));
                                        }
                                      }

                                      tempAns.addAll(answer);
                                      answer = [];
                                      for (int i = 0; i < tempAns.length; i++) {
                                        answer.add(requestList[tempAns[i]]);
                                      }
                                    }
                                    setState(() {
                                      answer;
                                    });
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
                              //    height: widget.height * 0.8,
                              width: widget.width,
                              child: counter == 0
                                  ? ListView(
                                      children: [
                                        ...answer.map((e) {
                                          Color color;
                                          color = Colors.orange;
                                          print(e);
                                          List friends =
                                              currentUser.friendRequestsPending;

                                          bool isGaurdianRequest = false;
                                          for (int i = 0;
                                              i < friends.length;
                                              i++) {
                                            print(friends[i]);
                                            print(allusers[e].phoneNumber);
                                            if (friends[i] ==
                                                allusers[e].phoneNumber) {
                                              print(allusers[e].phoneNumber);
                                              for (int ik = 0;
                                                  ik <
                                                      allusers[e]
                                                          .friendRequests
                                                          .length;
                                                  ik++) {
                                                print(allusers[e]
                                                    .friendRequests[ik]);
                                                print('djf');
                                                if (allusers[e]
                                                            .friendRequests[ik]
                                                        [1] ==
                                                    currentUser.phoneNumber) {
                                                  if (allusers[e]
                                                          .friendRequests[ik]
                                                          .length ==
                                                      3) {
                                                    isGaurdianRequest = true;
                                                  }
                                                }
                                              }
                                            }
                                          }
                                          return isGaurdianRequest
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: widget.height * 0.27,
                                                  margin: EdgeInsets.only(
                                                      left: MediaQuery.of(context).size.width *
                                                          0.025,
                                                      right: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.025,
                                                      bottom:
                                                          widget.height * 0.02),
                                                  //   color: Colors.black,
                                                  child: InkWell(
                                                    child: Neumorphic(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.05,
                                                              ),
                                                              Neumorphic(
                                                                  style: NeumorphicStyle(
                                                                      boxShape:
                                                                          NeumorphicBoxShape
                                                                              .circle(),
                                                                      depth:
                                                                          -15,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300,
                                                                      lightSource:
                                                                          LightSource
                                                                              .topLeft,
                                                                      border: NeumorphicBorder(
                                                                          color:
                                                                              color,
                                                                          width:
                                                                              5),
                                                                      shape: NeumorphicShape
                                                                          .concave),
                                                                  child: allusers[e]
                                                                              .image ==
                                                                          ""
                                                                      ? CircleAvatar(
                                                                          radius:
                                                                              widget.height * (0.11 / 2),
                                                                          backgroundColor: Colors
                                                                              .grey
                                                                              .shade300,
                                                                          child:
                                                                              NeumorphicIcon(
                                                                            Icons.tag_faces,
                                                                            size:
                                                                                widget.textSize * 70,
                                                                            style:
                                                                                NeumorphicStyle(color: color),
                                                                          ),
                                                                        )
                                                                      : CircleAvatar(
                                                                          radius:
                                                                              widget.height * (0.11 / 2),
                                                                          backgroundImage:
                                                                              NetworkImage(allusers[e].image),
                                                                        )),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
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
                                                                    allusers[e]
                                                                        .phoneNumber,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color:
                                                                            color,
                                                                        fontSize:
                                                                            MediaQuery.of(context).textScaleFactor *
                                                                                25),
                                                                  ),
                                                                  SizedBox(
                                                                    height: widget
                                                                            .height *
                                                                        0.01,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        allusers[e].firstName +
                                                                            " " +
                                                                            allusers[e].lastName +
                                                                            " ",
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        overflow:
                                                                            TextOverflow.visible,
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w700,
                                                                            color:
                                                                                color,
                                                                            fontSize:
                                                                                MediaQuery.of(context).textScaleFactor * 20),
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .shield_rounded,
                                                                        color:
                                                                            color,
                                                                        size: MediaQuery.of(context).textScaleFactor *
                                                                            25,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  "This is a Gaurdian Request ",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          MediaQuery.of(context).textScaleFactor *
                                                                              16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              Icon(
                                                                Icons
                                                                    .shield_rounded,
                                                                color:
                                                                    Colors.red,
                                                                size: MediaQuery.of(
                                                                            context)
                                                                        .textScaleFactor *
                                                                    25,
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              NeumorphicButton(
                                                                onPressed:
                                                                    () async {
                                                                  setState((() =>
                                                                      requestList
                                                                          .remove(
                                                                              e)));
                                                                  setState((() =>
                                                                      answer.remove(
                                                                          e)));
                                                                  currentUser
                                                                      .friendRequestsPending
                                                                      .remove(
                                                                    allusers[e]
                                                                        .phoneNumber,
                                                                  );
                                                                  currentUser
                                                                      .numberList
                                                                      .add([
                                                                    allusers[e]
                                                                        .firstName,
                                                                    allusers[e]
                                                                        .lastName,
                                                                    allusers[e]
                                                                        .phoneNumber,
                                                                    "",
                                                                    true
                                                                  ]);
                                                                  print(currentUser
                                                                      .friendRequestsPending);
                                                                  print("this");
                                                                  /* current User update */
                                                                  currentUser
                                                                      .friends
                                                                      .add(allusers[
                                                                              e]
                                                                          .phoneNumber);
                                                                  currentUser
                                                                      .gauridians
                                                                      .add(allusers[
                                                                              e]
                                                                          .phoneNumber);
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(currentUser
                                                                          .phoneNumber)
                                                                      .update({
                                                                    "friendRequestsPending":
                                                                        currentUser
                                                                            .friendRequestsPending,
                                                                    "locationSharingPeople":
                                                                        currentUser
                                                                            .LocationSharingPeople,
                                                                    "phoneNumbersChosen":
                                                                        currentUser
                                                                            .numberList,
                                                                    "friends":
                                                                        currentUser
                                                                            .friends
                                                                  });
                                                                  /* other user update */
                                                                  final finalData = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friendReqeusts")
                                                                      .get();
                                                                  var data =
                                                                      finalData
                                                                          .value;
                                                                  List temp =
                                                                      [];
                                                                  List
                                                                      finalAnswer =
                                                                      [];
                                                                  if (finalData
                                                                      .exists) {
                                                                    temp.addAll(data
                                                                        as List);
                                                                  }
                                                                  print(temp);
                                                                  print(
                                                                      "this si temp");
                                                                  for (int i =
                                                                          0;
                                                                      i < temp.length;
                                                                      i++) {
                                                                    if (temp[i][
                                                                            1] !=
                                                                        currentUser
                                                                            .phoneNumber) {
                                                                      finalAnswer
                                                                          .add(temp[
                                                                              i]);
                                                                    }
                                                                  }
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friendReqeusts")
                                                                      .set(
                                                                          finalAnswer);
                                                                  final friendData = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "children")
                                                                      .get();
                                                                  List answerT =
                                                                      [];
                                                                  if (friendData
                                                                      .exists) {
                                                                    answerT.addAll(
                                                                        friendData.value
                                                                            as List);
                                                                  }
                                                                  answerT.add(
                                                                      currentUser
                                                                          .phoneNumber);
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "children")
                                                                      .set(
                                                                          answerT);
                                                                  final friendData1 = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friends")
                                                                      .get();
                                                                  List
                                                                      answerT1 =
                                                                      [];
                                                                  if (friendData1
                                                                      .exists) {
                                                                    answerT1.addAll(
                                                                        friendData1.value
                                                                            as List);
                                                                  }
                                                                  answerT1.add(
                                                                      currentUser
                                                                          .phoneNumber);
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friends")
                                                                      .set(
                                                                          answerT1);
                                                                  final phoneNumberData = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(currentUser
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "locationSharingPeople")
                                                                      .get();
                                                                  List
                                                                      phoneNumberList =
                                                                      [];
                                                                  if (phoneNumberData
                                                                      .exists) {
                                                                    phoneNumberList.addAll(
                                                                        phoneNumberData.value
                                                                            as List);
                                                                  }
                                                                  phoneNumberList
                                                                      .add(allusers[
                                                                              e]
                                                                          .phoneNumber);
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(currentUser
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "locationSharingPeople")
                                                                      .set(
                                                                          phoneNumberList);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: widget
                                                                          .width *
                                                                      0.28,
                                                                  height: widget
                                                                          .height *
                                                                      0.025,
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Accept",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            widget.textSize *
                                                                                16,
                                                                        fontFamily:
                                                                            "Nunito",
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                style: const NeumorphicStyle(
                                                                    depth: 0,
                                                                    color: Colors
                                                                        .lightGreen,
                                                                    boxShape:
                                                                        NeumorphicBoxShape
                                                                            .stadium(),
                                                                    shape: NeumorphicShape
                                                                        .concave),
                                                              ),
                                                              NeumorphicButton(
                                                                onPressed:
                                                                    () async {
                                                                  //Ui Update
                                                                  setState((() =>
                                                                      requestList
                                                                          .remove(
                                                                              e)));
                                                                  currentUser
                                                                      .friendRequestsPending
                                                                      .remove(
                                                                    allusers[e]
                                                                        .phoneNumber,
                                                                  );
                                                                  /* current User update */
                                                                  currentUser
                                                                      .friends
                                                                      .add(allusers[
                                                                              e]
                                                                          .phoneNumber);
                                                                  currentUser
                                                                      .gauridians
                                                                      .add(allusers[
                                                                              e]
                                                                          .phoneNumber);
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(currentUser
                                                                          .phoneNumber)
                                                                      .set({
                                                                    "age":
                                                                        currentUser
                                                                            .age,
                                                                    "firstName":
                                                                        currentUser
                                                                            .firstName,
                                                                    "lastName":
                                                                        currentUser
                                                                            .lastName,
                                                                    "friendReqeusts":
                                                                        currentUser
                                                                            .friendRequests,
                                                                    "friendRequestsPending":
                                                                        currentUser
                                                                            .friendRequestsPending,
                                                                    "image":
                                                                        currentUser
                                                                            .image,
                                                                    "password":
                                                                        currentUser
                                                                            .password,
                                                                    "friends":
                                                                        friends,
                                                                    "location":
                                                                        currentUser
                                                                            .location,
                                                                    "phoneNumber":
                                                                        currentUser
                                                                            .phoneNumber,
                                                                    "locationSharingPeople":
                                                                        currentUser
                                                                            .LocationSharingPeople,
                                                                    "numberApproved":
                                                                        false,
                                                                    "locationTrackingOn":
                                                                        false,
                                                                    "phoneNumbersChosen":
                                                                        currentUser
                                                                            .numberList,
                                                                    "gaurdian":
                                                                        currentUser
                                                                            .gauridians,
                                                                    "children":
                                                                        currentUser
                                                                            .children
                                                                  });
                                                                  /* other user update */
                                                                  final finalData = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friendRequests")
                                                                      .get();
                                                                  Map data =
                                                                      finalData
                                                                              .value
                                                                          as Map;
                                                                  List temp =
                                                                      [];
                                                                  List
                                                                      finalAnswer =
                                                                      [];
                                                                  if (finalData
                                                                      .exists) {
                                                                    temp.addAll(data
                                                                        as List);
                                                                  }
                                                                  for (int i =
                                                                          0;
                                                                      i < temp.length;
                                                                      i++) {
                                                                    if (temp[i][
                                                                            1] !=
                                                                        currentUser
                                                                            .phoneNumber) {
                                                                      finalAnswer
                                                                          .add(temp[
                                                                              i]);
                                                                    }
                                                                  }
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friendReqeusts")
                                                                      .set(
                                                                          finalAnswer);
                                                                  final friendData = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "children")
                                                                      .get();
                                                                  List answerT =
                                                                      [];
                                                                  if (friendData
                                                                      .exists) {
                                                                    answerT.addAll(
                                                                        friendData.value
                                                                            as List);
                                                                  }
                                                                  answerT.add(
                                                                      currentUser
                                                                          .phoneNumber);
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "children")
                                                                      .set(
                                                                          answerT);
                                                                  List
                                                                      phoneNumberList =
                                                                      allusers[
                                                                              e]
                                                                          .numberList;

                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "phoneNumbersChosen")
                                                                      .set(
                                                                          phoneNumberList);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: widget
                                                                          .width *
                                                                      0.28,
                                                                  height: widget
                                                                          .height *
                                                                      0.025,
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Decline",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            widget.textSize *
                                                                                16,
                                                                        fontFamily:
                                                                            "Nunito",
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                style: const NeumorphicStyle(
                                                                    depth: 0,
                                                                    color: Colors
                                                                        .redAccent,
                                                                    boxShape:
                                                                        NeumorphicBoxShape
                                                                            .stadium(),
                                                                    shape: NeumorphicShape
                                                                        .concave),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      style: NeumorphicStyle(
                                                          boxShape: NeumorphicBoxShape.roundRect(
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          45))),
                                                          depth: 15,
                                                          color: Colors
                                                              .grey.shade300,
                                                          lightSource:
                                                              LightSource
                                                                  .topLeft,
                                                          shape: NeumorphicShape
                                                              .concave),
                                                    ),
                                                  ))
                                              : Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: widget.height * 0.23,
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
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.05,
                                                              ),
                                                              Neumorphic(
                                                                  style: NeumorphicStyle(
                                                                      boxShape:
                                                                          NeumorphicBoxShape
                                                                              .circle(),
                                                                      depth:
                                                                          -15,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300,
                                                                      lightSource:
                                                                          LightSource
                                                                              .topLeft,
                                                                      border: NeumorphicBorder(
                                                                          color:
                                                                              color,
                                                                          width:
                                                                              5),
                                                                      shape: NeumorphicShape
                                                                          .concave),
                                                                  child: allusers[e]
                                                                              .image ==
                                                                          ""
                                                                      ? CircleAvatar(
                                                                          radius:
                                                                              widget.height * (0.11 / 2),
                                                                          backgroundColor: Colors
                                                                              .grey
                                                                              .shade300,
                                                                          child:
                                                                              NeumorphicIcon(
                                                                            Icons.tag_faces,
                                                                            size:
                                                                                widget.textSize * 70,
                                                                            style:
                                                                                NeumorphicStyle(color: color),
                                                                          ),
                                                                        )
                                                                      : CircleAvatar(
                                                                          radius:
                                                                              widget.height * (0.11 / 2),
                                                                          backgroundImage:
                                                                              NetworkImage(allusers[e].image),
                                                                        )),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
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
                                                                    allusers[e]
                                                                        .phoneNumber,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color:
                                                                            color,
                                                                        fontSize:
                                                                            MediaQuery.of(context).textScaleFactor *
                                                                                25),
                                                                  ),
                                                                  SizedBox(
                                                                    height: widget
                                                                            .height *
                                                                        0.01,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        allusers[e].firstName +
                                                                            " " +
                                                                            allusers[e].lastName,
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        overflow:
                                                                            TextOverflow.visible,
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w700,
                                                                            color:
                                                                                color,
                                                                            fontSize:
                                                                                MediaQuery.of(context).textScaleFactor * 20),
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.08,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              NeumorphicButton(
                                                                onPressed:
                                                                    () async {
                                                                  BackgroundSms.sendMessage(
                                                                      phoneNumber:
                                                                          allusers[e]
                                                                              .phoneNumber,
                                                                      message: "Greetings this is a bot from the Drive Safe Application. We are contacting you to inform you that you have been placed in " +
                                                                          currentUser
                                                                              .firstName +
                                                                          " " +
                                                                          currentUser
                                                                              .lastName +
                                                                          "'s list of trusted people. Because of this you will be sent important information about " +
                                                                          currentUser
                                                                              .firstName +
                                                                          " " +
                                                                          currentUser
                                                                              .lastName +
                                                                          " while they are driving for there safety and your information. For more detailed information consider downloading the Drive Safe App. NOTE : If you do not want to recieve any notification please respond with, exactly, Stop The Messages");

                                                                  setState((() =>
                                                                      requestList
                                                                          .remove(
                                                                              e)));
                                                                  setState((() =>
                                                                      answer.remove(
                                                                          e)));
                                                                  currentUser
                                                                      .friendRequestsPending
                                                                      .remove(
                                                                    allusers[e]
                                                                        .phoneNumber,
                                                                  );
                                                                  currentUser
                                                                      .numberList
                                                                      .add([
                                                                    allusers[e]
                                                                        .firstName,
                                                                    allusers[e]
                                                                        .lastName,
                                                                    allusers[e]
                                                                        .phoneNumber,
                                                                    "",
                                                                    true
                                                                  ]);
                                                                  print(currentUser
                                                                      .friendRequestsPending);
                                                                  print("this");
                                                                  /* current User update */
                                                                  currentUser
                                                                      .friends
                                                                      .add(allusers[
                                                                              e]
                                                                          .phoneNumber);
                                                                  currentUser
                                                                      .gauridians
                                                                      .add(allusers[
                                                                              e]
                                                                          .phoneNumber);
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(currentUser
                                                                          .phoneNumber)
                                                                      .update({
                                                                    "friendRequestsPending":
                                                                        currentUser
                                                                            .friendRequestsPending,
                                                                    "locationSharingPeople":
                                                                        currentUser
                                                                            .LocationSharingPeople,
                                                                    "phoneNumbersChosen":
                                                                        currentUser
                                                                            .numberList,
                                                                    "gaurdian":
                                                                        currentUser
                                                                            .gauridians,
                                                                    "friends":
                                                                        currentUser
                                                                            .friends
                                                                  });
                                                                  /* other user update */
                                                                  final finalData = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friendReqeusts")
                                                                      .get();
                                                                  var data =
                                                                      finalData
                                                                          .value;
                                                                  List temp =
                                                                      [];
                                                                  List
                                                                      finalAnswer =
                                                                      [];
                                                                  if (finalData
                                                                      .exists) {
                                                                    temp.addAll(data
                                                                        as List);
                                                                  }
                                                                  print(temp);
                                                                  print(
                                                                      "this si temp");
                                                                  for (int i =
                                                                          0;
                                                                      i < temp.length;
                                                                      i++) {
                                                                    if (temp[i][
                                                                            1] !=
                                                                        currentUser
                                                                            .phoneNumber) {
                                                                      finalAnswer
                                                                          .add(temp[
                                                                              i]);
                                                                    }
                                                                  }
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friendReqeusts")
                                                                      .set(
                                                                          finalAnswer);
                                                                  final friendData = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "children")
                                                                      .get();
                                                                  List answerT =
                                                                      [];
                                                                  if (friendData
                                                                      .exists) {
                                                                    answerT.addAll(
                                                                        friendData.value
                                                                            as List);
                                                                  }
                                                                  answerT.add(
                                                                      currentUser
                                                                          .phoneNumber);
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "children")
                                                                      .set(
                                                                          answerT);
                                                                  final friendData1 = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friends")
                                                                      .get();
                                                                  List
                                                                      answerT1 =
                                                                      [];
                                                                  if (friendData1
                                                                      .exists) {
                                                                    answerT1.addAll(
                                                                        friendData1.value
                                                                            as List);
                                                                  }
                                                                  answerT1.add(
                                                                      currentUser
                                                                          .phoneNumber);
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friends")
                                                                      .set(
                                                                          answerT1);
                                                                  final phoneNumberData = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "phoneNumbersChosen")
                                                                      .get();
                                                                  List
                                                                      phoneNumberList =
                                                                      [];
                                                                  if (phoneNumberData
                                                                      .exists) {
                                                                    phoneNumberList.addAll(
                                                                        phoneNumberData.value
                                                                            as List);
                                                                  }

                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "phoneNumbersChosen")
                                                                      .set(
                                                                          phoneNumberList);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: widget
                                                                          .width *
                                                                      0.28,
                                                                  height: widget
                                                                          .height *
                                                                      0.025,
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Accept",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            widget.textSize *
                                                                                16,
                                                                        fontFamily:
                                                                            "Nunito",
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                style: const NeumorphicStyle(
                                                                    depth: 0,
                                                                    color: Colors
                                                                        .lightGreen,
                                                                    boxShape:
                                                                        NeumorphicBoxShape
                                                                            .stadium(),
                                                                    shape: NeumorphicShape
                                                                        .concave),
                                                              ),
                                                              NeumorphicButton(
                                                                onPressed:
                                                                    () async {
                                                                  setState((() =>
                                                                      requestList
                                                                          .remove(
                                                                              e)));
                                                                  currentUser
                                                                      .friendRequestsPending
                                                                      .remove(
                                                                    allusers[e]
                                                                        .phoneNumber,
                                                                  );
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(currentUser
                                                                          .phoneNumber)
                                                                      .set({
                                                                    "age":
                                                                        currentUser
                                                                            .age,
                                                                    "firstName":
                                                                        currentUser
                                                                            .firstName,
                                                                    "lastName":
                                                                        currentUser
                                                                            .lastName,
                                                                    "friendReqeusts":
                                                                        currentUser
                                                                            .friendRequests,
                                                                    "friendRequestsPending":
                                                                        currentUser
                                                                            .friendRequestsPending,
                                                                    "image":
                                                                        currentUser
                                                                            .image,
                                                                    "password":
                                                                        currentUser
                                                                            .password,
                                                                    "friends":
                                                                        friends,
                                                                    "location":
                                                                        currentUser
                                                                            .location,
                                                                    "phoneNumber":
                                                                        currentUser
                                                                            .phoneNumber,
                                                                    "locationSharingPeople":
                                                                        currentUser
                                                                            .LocationSharingPeople,
                                                                    "numberApproved":
                                                                        false,
                                                                    "locationTrackingOn":
                                                                        false,
                                                                    "phoneNumbersChosen":
                                                                        []
                                                                  });
                                                                  final finalData = await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .get();
                                                                  Map data =
                                                                      finalData
                                                                              .value
                                                                          as Map;
                                                                  print(data);
                                                                  List temp =
                                                                      [];
                                                                  List
                                                                      finalAnswer =
                                                                      [];
                                                                  print(
                                                                      "before jere");
                                                                  temp.addAll(data[
                                                                      "friendReqeusts"]);
                                                                  for (int i =
                                                                          0;
                                                                      i < temp.length;
                                                                      i++) {
                                                                    if (temp[i][
                                                                            1] !=
                                                                        currentUser
                                                                            .phoneNumber) {
                                                                      if (temp[i]
                                                                              [
                                                                              0] ==
                                                                          "pending") {
                                                                        finalAnswer
                                                                            .add(temp[i]);
                                                                      }
                                                                    } else {
                                                                      finalAnswer
                                                                          .add([
                                                                        "rejected",
                                                                        currentUser
                                                                            .phoneNumber
                                                                      ]);
                                                                    }
                                                                  }
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "friendReqeusts")
                                                                      .set(
                                                                          finalAnswer);
                                                                  List
                                                                      phoneNumberList =
                                                                      allusers[
                                                                              e]
                                                                          .numberList;
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          phoneNumberList
                                                                              .length;
                                                                      i++) {
                                                                    if (phoneNumberList[
                                                                        i][2]) {
                                                                      phoneNumberList
                                                                          .removeAt(
                                                                              i);
                                                                      break;
                                                                    }
                                                                  }
                                                                  await FirebaseDatabase
                                                                      .instance
                                                                      .ref(
                                                                          "User")
                                                                      .child(allusers[
                                                                              e]
                                                                          .phoneNumber)
                                                                      .child(
                                                                          "phoneNumbersChosen")
                                                                      .set(
                                                                          phoneNumberList);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: widget
                                                                          .width *
                                                                      0.28,
                                                                  height: widget
                                                                          .height *
                                                                      0.025,
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Decline",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            widget.textSize *
                                                                                16,
                                                                        fontFamily:
                                                                            "Nunito",
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                style: const NeumorphicStyle(
                                                                    depth: 0,
                                                                    color: Colors
                                                                        .redAccent,
                                                                    boxShape:
                                                                        NeumorphicBoxShape
                                                                            .stadium(),
                                                                    shape: NeumorphicShape
                                                                        .concave),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      style: NeumorphicStyle(
                                                          boxShape: NeumorphicBoxShape.roundRect(
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          45))),
                                                          depth: 15,
                                                          color: Colors
                                                              .grey.shade300,
                                                          lightSource:
                                                              LightSource
                                                                  .topLeft,
                                                          shape: NeumorphicShape
                                                              .concave),
                                                    ),
                                                  ));
                                        }).toList(),
                                        SizedBox(
                                            height: widget.height * 0.2,
                                            width: widget.width)

                                        //=> Text(allusers[e[1]].phoneNumber)
                                      ],
                                    )
                                  : ListView(
                                      children: [
                                        ...answer.map((e) {
                                          Color color = Colors.red;
                                          print("tios");
                                          print(e);
                                          print("tios");
                                          bool isGaurdian = false;
                                          if (e[0][0] == "pending") {
                                            color = Colors.orange;
                                          }

                                          if (e[0].length == 3) {
                                            isGaurdian = true;
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
                                              //   color: Colors.black,
                                              child: InkWell(
                                                child: Neumorphic(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
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
                                                                    color:
                                                                        color,
                                                                    width: 5),
                                                            shape:
                                                                NeumorphicShape
                                                                    .concave),
                                                        child: allusers[e[1]]
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
                                                                  Icons
                                                                      .tag_faces,
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
                                                                        allusers[e[1]]
                                                                            .image),
                                                              ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
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
                                                            allusers[e[1]]
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
                                                              Text(
                                                                allusers[e[1]]
                                                                        .firstName +
                                                                    " " +
                                                                    allusers[e[
                                                                            1]]
                                                                        .lastName +
                                                                    " ",
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
                                                              isGaurdian == true
                                                                  ? Icon(
                                                                      Icons
                                                                          .shield,
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
                                                      )
                                                    ],
                                                  ),
                                                  style: NeumorphicStyle(
                                                      boxShape: NeumorphicBoxShape
                                                          .roundRect(
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          45))),
                                                      depth: 15,
                                                      color:
                                                          Colors.grey.shade300,
                                                      lightSource:
                                                          LightSource.topLeft,
                                                      shape: NeumorphicShape
                                                          .concave),
                                                ),
                                              ));
                                        }).toList(),
                                        SizedBox(
                                            height: widget.height * 0.2,
                                            width: widget.width)

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
            Container(
              width: widget.width,
              height: widget.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: widget.width * 0.9,
                      height: widget.height * 0.07,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 3),
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.all(Radius.circular(100))),
                      padding: EdgeInsets.symmetric(
                          vertical: widget.height * 0.005,
                          horizontal: widget.width * 0.02),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => setState(() {
                                counter = 0;
                                answer = [];
                                answer.addAll(requestList);
                                print(requestList);
                              }),
                              child: Container(
                                height: widget.height * (0.06),
                                width: widget.width * (0.82 / 2),
                                child: Center(
                                  child: Text("Pending",
                                      style: TextStyle(
                                          color: colorList2[counter],
                                          fontWeight: FontWeight.w700,
                                          fontSize: widget.textSize * 20)),
                                ),
                                decoration: BoxDecoration(
                                    color: colorList1[counter],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100))),
                              ),
                            ),
                            InkWell(
                                onTap: () => setState(() {
                                      counter = 1;
                                      answer = [];
                                      answer.addAll(friendsList);
                                      print(answer);
                                    }),
                                child: Container(
                                  height: widget.height * (0.06),
                                  width: widget.width * (0.82 / 2),
                                  child: Center(
                                    child: Text("Sent",
                                        style: TextStyle(
                                            color: colorList1[counter],
                                            fontWeight: FontWeight.w700,
                                            fontSize: widget.textSize * 20)),
                                  ),
                                  decoration: BoxDecoration(
                                      color: colorList2[counter],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(100))),
                                )),
                          ])),
                  SizedBox(height: widget.height * 0.04)
                ],
              ),
            )
          ],
        ));
  }
}
//down