import 'dart:async';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:drivesafev2/python/searchAlgorithm.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:lottie/lottie.dart';

class searchPeople extends StatefulWidget {
  double height;
  double width;
  var textSize;
  TextEditingController textEditingController;
  User currentUser;
  Function color;
  List<User> users;
  searchPeople(this.height, this.width, this.textEditingController,
      this.textSize, this.currentUser, this.color, this.users);

  @override
  _searchPeopleState createState() => _searchPeopleState();
}

class _searchPeopleState extends State<searchPeople> {
  @override
  List<String> allDisplayNames = [];
  late User curChosenUser;
  late User mainChosenAppUser;
  late int chosenUserCurrentLocation;
  late Color theColor;
  double status = 0;
  Color chooseColor = Colors.transparent;
  int highest = 0;
  double chooseWidth = 0;
  double chooseHeight = 0;
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
        data["userName"]);
  }

  bool isFirst = true;
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
            value["userName"]));
      } catch (e) {}
    });
    return allUserList;
  }

  void collectData() async {
    allusers.addAll(widget.users);
    for (int i = 0; i < allusers.length; i++) {
      allDisplayNames.add(allusers[i].userName);
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

  Widget build(BuildContext context) {
    double textSize = MediaQuery.of(context).textScaleFactor;
    double height = widget.height;
    double width = widget.width;
    return Center(
      child: SingleChildScrollView(
        child: Container(
          height: widget.height,
          width: widget.width,
          child: Stack(
            children: [
              Container(
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
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(
                                        fontSize: widget.textSize * 30,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue),
                                    textAlign: TextAlign.center,
                                    onChanged: (text) {
                                      /*  List<String> dummy = allDisplayNames;
                                      flag = true;
                                      print("=============================");
                                      print(allusers.length);
                                      answer = searchNames(
                                          tempList2, text, highest, flag);
                                      print(answer.length);
                                      print(tempList2.length);
                                      print(text);
                                      if (allusers.length == answer.length ||
                                          answer.isEmpty) {
                                        if (text != "") {
                                          answer = [];
                                          print(searchPhoneNumbers(
                                              phoneNumberSearchList,
                                              text,
                                              flag));
                                          answer.addAll(searchPhoneNumbers(
                                              phoneNumberSearchList,
                                              text,
                                              flag));
                                          print(answer);
                                        }
                                      }
                                      setState(() {});*/
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
                                            onPressed: () {
                                              print("here");
                                              print(allDisplayNames);
                                              print(allDisplayNames.contains(
                                                  widget.textEditingController
                                                      .text));

                                              if (allDisplayNames.contains(
                                                  widget.textEditingController
                                                      .value.text)) {
                                                setState(() {
                                                  answer = [
                                                    allDisplayNames.indexOf(widget
                                                        .textEditingController
                                                        .value
                                                        .text)
                                                  ];
                                                  isFirst = false;
                                                });
                                              } else {
                                                setState(() {
                                                  answer = [];
                                                });
                                              }
                                            },
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
                            /*color: Colors.black,*/
                            //   color: Colors.pink,
                            child: isFirst
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          height: height * 0.25,
                                          child: Lottie.network(
                                              "https://assets2.lottiefiles.com/packages/lf20_9e8yoqkm.json")),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.05),
                                        child: Text(
                                          "Enter the unique username of the person who you want to share the data with. You can ask the person you want to share the data with for this id.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w800,
                                              fontSize: MediaQuery.of(context)
                                                      .textScaleFactor *
                                                  15),
                                        ),
                                      )
                                    ],
                                  )
                                : answer.isEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.05),
                                            child: Text(
                                              "There is no registered account under " +
                                                  widget.textEditingController
                                                      .value.text +
                                                  ". Please try double checking the username the driver has given you.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .textScaleFactor *
                                                          15),
                                            ),
                                          )
                                        ],
                                      )
                                    : Scrollbar(
                                        thickness: 10,
                                        radius: Radius.circular(50),
                                        child: ListView(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02),
                                            children: [
                                              ...answer.map((userArea) {
                                                double height = widget.height;
                                                User user = allusers[userArea];
                                                User appUser = currentUser;
                                                List<String> awaitList =
                                                    requestList;

                                                // giant code
                                                Color finalColor = Colors.blue;
                                                bool flag = true;
                                                int index = 0;
                                                bool isGaurdian = false;
                                                for (int i = 0;
                                                    i <
                                                        appUser.friendRequests
                                                            .length;
                                                    i++) {
                                                  if (user.phoneNumber ==
                                                      appUser.friendRequests[i]
                                                          [1]) {
                                                    print(
                                                        appUser.friendRequests);
                                                    if (appUser.friendRequests[
                                                            i][0] ==
                                                        "pending") {
                                                      finalColor =
                                                          Colors.orange;
                                                      if (appUser
                                                              .friendRequests[i]
                                                              .length ==
                                                          3) {
                                                        isGaurdian = true;
                                                      }
                                                    } else {
                                                      finalColor = Colors.red;
                                                    }
                                                    index = i;
                                                    break;
                                                  }
                                                }
                                                if (currentUser.friends
                                                    .contains(allusers[userArea]
                                                        .phoneNumber)) {
                                                  finalColor = Colors.green;
                                                }
                                                Color color = finalColor;

                                                return Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.95,
                                                    height:
                                                        widget.height * 0.15,
                                                    margin: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.025,
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.025,
                                                        bottom: widget.height *
                                                            0.02),
                                                    //   color: Colors.black,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        mainChosenAppUser =
                                                            appUser;
                                                        curChosenUser = user;
                                                        theColor = finalColor;

                                                        chosenUserCurrentLocation =
                                                            userArea;
                                                        if (curChosenUser
                                                                .phoneNumber ==
                                                            mainChosenAppUser
                                                                .phoneNumber) {
                                                          AwesomeDialog(
                                                            context: context,
                                                            dialogType:
                                                                DialogType
                                                                    .ERROR,
                                                            animType:
                                                                AnimType.SCALE,
                                                            headerAnimationLoop:
                                                                false,
                                                            title: "ERROR",
                                                            desc:
                                                                "You cannot send a contact-request to yourself",
                                                            titleTextStyle:
                                                                TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontFamily:
                                                                  "Nunito",
                                                              fontSize:
                                                                  textSize * 25,
                                                              color: Colors.red,
                                                            ),
                                                            descTextStyle:
                                                                TextStyle(
                                                                    fontFamily:
                                                                        "Nunito",
                                                                    fontSize:
                                                                        textSize *
                                                                            20,
                                                                    color: Colors
                                                                        .red),
                                                            btnOkOnPress: () {},
                                                            btnOkText: "Ok",
                                                            btnOkColor:
                                                                Colors.red,
                                                          ).show();
                                                        } else if (theColor ==
                                                            Colors.green) {
                                                          AwesomeDialog(
                                                            context: context,
                                                            dialogType:
                                                                DialogType
                                                                    .ERROR,
                                                            animType:
                                                                AnimType.SCALE,
                                                            headerAnimationLoop:
                                                                false,
                                                            title: "ERROR",
                                                            desc:
                                                                "The chosen user is already your friend. You can not send requests to your friend",
                                                            titleTextStyle:
                                                                TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontFamily:
                                                                  "Nunito",
                                                              fontSize:
                                                                  textSize * 25,
                                                              color: Colors.red,
                                                            ),
                                                            descTextStyle:
                                                                TextStyle(
                                                                    fontFamily:
                                                                        "Nunito",
                                                                    fontSize:
                                                                        textSize *
                                                                            20,
                                                                    color: Colors
                                                                        .red),
                                                            btnOkOnPress: () {},
                                                            btnOkText: "Ok",
                                                            btnOkColor:
                                                                Colors.red,
                                                          ).show();
                                                        } else if (theColor ==
                                                            Colors.orange) {
                                                          AwesomeDialog(
                                                            context: context,
                                                            dialogType:
                                                                DialogType
                                                                    .ERROR,
                                                            animType:
                                                                AnimType.SCALE,
                                                            headerAnimationLoop:
                                                                false,
                                                            title: "ERROR",
                                                            desc:
                                                                "You have already sent a friend request to the person. The request is currently pending.",
                                                            titleTextStyle:
                                                                TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontFamily:
                                                                  "Nunito",
                                                              fontSize:
                                                                  textSize * 25,
                                                              color: Colors.red,
                                                            ),
                                                            descTextStyle:
                                                                TextStyle(
                                                                    fontFamily:
                                                                        "Nunito",
                                                                    fontSize:
                                                                        textSize *
                                                                            20,
                                                                    color: Colors
                                                                        .red),
                                                            btnOkOnPress: () {},
                                                            btnOkText: "Ok",
                                                            btnOkColor:
                                                                Colors.red,
                                                          ).show();
                                                        } else {
                                                          AwesomeDialog(
                                                                  context:
                                                                      context,
                                                                  dialogType:
                                                                      DialogType
                                                                          .INFO,
                                                                  animType: AnimType
                                                                      .SCALE,
                                                                  headerAnimationLoop:
                                                                      false,
                                                                  title:
                                                                      "Warning",
                                                                  desc: "Are you sure you want to send a gaurdian request to " +
                                                                      allusers[
                                                                              chosenUserCurrentLocation]
                                                                          .firstName +
                                                                      " " +
                                                                      allusers[
                                                                              chosenUserCurrentLocation]
                                                                          .lastName,
                                                                  titleTextStyle:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontFamily:
                                                                        "Nunito",
                                                                    fontSize:
                                                                        textSize *
                                                                            25,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                  descTextStyle: TextStyle(
                                                                      fontFamily:
                                                                          "Nunito",
                                                                      fontSize:
                                                                          textSize *
                                                                              20,
                                                                      color:
                                                                          Colors
                                                                              .blueAccent),
                                                                  btnOkOnPress:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      chooseColor =
                                                                          Colors
                                                                              .transparent;
                                                                      chooseWidth =
                                                                          0;
                                                                      chooseHeight =
                                                                          0;
                                                                      status =
                                                                          0;
                                                                      widget.color(
                                                                          false);
                                                                    });
                                                                    print(mainChosenAppUser
                                                                        .numberList);
                                                                    mainChosenAppUser
                                                                        .numberList
                                                                        .add(
                                                                      [
                                                                        allusers[chosenUserCurrentLocation]
                                                                            .firstName,
                                                                        allusers[chosenUserCurrentLocation]
                                                                            .lastName,
                                                                        allusers[chosenUserCurrentLocation]
                                                                            .phoneNumber,
                                                                        allusers[chosenUserCurrentLocation]
                                                                            .image,
                                                                        true,
                                                                      ],
                                                                    );

                                                                    for (int k =
                                                                            0;
                                                                        k < mainChosenAppUser.friendRequests.length;
                                                                        k++) {
                                                                      if (mainChosenAppUser.friendRequests[k]
                                                                              [
                                                                              1] ==
                                                                          curChosenUser
                                                                              .phoneNumber) {
                                                                        mainChosenAppUser
                                                                            .friendRequests
                                                                            .removeAt(k);
                                                                      }
                                                                    }
                                                                    setState(
                                                                        () {
                                                                      mainChosenAppUser
                                                                          .friendRequests
                                                                          .add([
                                                                        "pending",
                                                                        curChosenUser
                                                                            .phoneNumber,
                                                                        "gaurdian"
                                                                      ]);
                                                                      answer =
                                                                          answer;
                                                                    });
                                                                    // code
                                                                    await FirebaseDatabase
                                                                        .instance
                                                                        .ref(
                                                                            "User")
                                                                        .update({
                                                                      mainChosenAppUser
                                                                          .phoneNumber: {
                                                                        "age": mainChosenAppUser
                                                                            .age,
                                                                        "firstName":
                                                                            mainChosenAppUser.firstName,
                                                                        "lastName":
                                                                            mainChosenAppUser.lastName,
                                                                        "friendReqeusts":
                                                                            mainChosenAppUser.friendRequests,
                                                                        "friendRequestsPending":
                                                                            mainChosenAppUser.friendRequestsPending,
                                                                        "image":
                                                                            mainChosenAppUser.image,
                                                                        "password":
                                                                            mainChosenAppUser.password,
                                                                        "friends":
                                                                            mainChosenAppUser.friends,
                                                                        "location":
                                                                            mainChosenAppUser.location,
                                                                        "phoneNumber":
                                                                            mainChosenAppUser.phoneNumber,
                                                                        "locationSharingPeople":
                                                                            mainChosenAppUser.LocationSharingPeople,
                                                                        "numberApproved":
                                                                            false,
                                                                        "locationTrackingOn":
                                                                            false,
                                                                        "phoneNumbersChosen":
                                                                            mainChosenAppUser.numberList
                                                                      }
                                                                    });
                                                                    final requestUserData = await FirebaseDatabase
                                                                        .instance
                                                                        .ref(
                                                                            "User/")
                                                                        .child(curChosenUser
                                                                            .phoneNumber)
                                                                        .child(
                                                                            "friendRequestsPending")
                                                                        .get();
                                                                    List
                                                                        tempFriendList =
                                                                        [];
                                                                    if (requestUserData
                                                                            .value !=
                                                                        null) {
                                                                      List
                                                                          requestUserFinalData =
                                                                          requestUserData.value
                                                                              as List;
                                                                      tempFriendList
                                                                          .addAll(
                                                                              requestUserFinalData);
                                                                    }
                                                                    print(
                                                                        tempFriendList);
                                                                    tempFriendList.add(
                                                                        mainChosenAppUser
                                                                            .phoneNumber);
                                                                    print(
                                                                        tempFriendList);
                                                                    await FirebaseDatabase
                                                                        .instance
                                                                        .ref(
                                                                            "User")
                                                                        .child(curChosenUser
                                                                            .phoneNumber)
                                                                        .update({
                                                                      "friendRequestsPending":
                                                                          tempFriendList
                                                                    });
                                                                  },
                                                                  btnOkText:
                                                                      "Yes",
                                                                  btnOkColor:
                                                                      Colors
                                                                          .green,
                                                                  btnCancelText:
                                                                      "No",
                                                                  btnCancelColor:
                                                                      Colors
                                                                          .red,
                                                                  btnCancelOnPress:
                                                                      () {})
                                                              .show();
                                                        }
                                                        /*bool flag = true;
                                          for (int i = 0;
                                              i < appUser.friendRequests.length;
                                              i++) {
                                            if (user.phoneNumber ==
                                                appUser.friendRequests[i][1]) {
                                              flag = false;
                                              break;
                                            }
                                          }
                                          if (user.phoneNumber ==
                                              appUser.phoneNumber) {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.ERROR,
                                              animType: AnimType.SCALE,
                                              headerAnimationLoop: false,
                                              title: "ERROR",
                                              desc:
                                                  "You cannot send a contact-request to yourself",
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
                                              btnOkText: "Ok",
                                              btnOkColor: Colors.red,
                                            ).show();
                                          } else if (color == Colors.green) {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.ERROR,
                                              animType: AnimType.SCALE,
                                              headerAnimationLoop: false,
                                              title: "ERROR",
                                              desc:
                                                  "The chosen user is already your friend. You can not send requests to your friend",
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
                                              btnOkText: "Ok",
                                              btnOkColor: Colors.red,
                                            ).show();
                                          } else if (color == Colors.orange) {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.ERROR,
                                              animType: AnimType.SCALE,
                                              headerAnimationLoop: false,
                                              title: "ERROR",
                                              desc:
                                                  "You have already sent a friend request to the person. The request is currently pending.",
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
                                              btnOkText: "Ok",
                                              btnOkColor: Colors.red,
                                            ).show();
                                          } else {
                                            AwesomeDialog(
                                                    context: context,
                                                    dialogType: DialogType.INFO,
                                                    animType: AnimType.SCALE,
                                                    headerAnimationLoop: false,
                                                    title: "Warning",
                                                    desc:
                                                        "Are you sure you want to send a friend request to " +
                                                            allusers[userArea]
                                                                .firstName +
                                                            " " +
                                                            allusers[userArea]
                                                                .lastName,
                                                    titleTextStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: "Nunito",
                                                      fontSize: textSize * 25,
                                                      color: Colors.blue,
                                                    ),
                                                    descTextStyle: TextStyle(
                                                        fontFamily: "Nunito",
                                                        fontSize: textSize * 20,
                                                        color:
                                                            Colors.blueAccent),
                                                    btnOkOnPress: () async {
                                                      BackgroundSms.sendMessage(
                                                          phoneNumber:
                                                              allusers[userArea]
                                                                  .phoneNumber
                                                                  .substring(2),
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
                                                      appUser.numberList.add(
                                                        [
                                                          allusers[userArea]
                                                              .firstName,
                                                          allusers[userArea]
                                                              .lastName,
                                                          allusers[userArea]
                                                              .phoneNumber,
                                                          allusers[userArea]
                                                              .image,
                                                          true,
                                                        ],
                                                      );
                                                      String smsMessage = "Hello, this is a bot from the DriveSafe application. We are writing this message to inform you that the phone number " +
                                                          currentUser
                                                              .phoneNumber +
                                                          ", owned by " +
                                                          currentUser
                                                              .firstName +
                                                          " " +
                                                          currentUser.lastName +
                                                          ", has chosen to send you his location data for safety when he is driving. Whenever Mr." +
                                                          currentUser.lastName +
                                                          " starts to drive his car you will recieve data like a link to his current location, his speed, the quality of the roads he is driving on, and other data regarding his safety every 2 or so minutes. If you want more indepth data, like live location updating, then you can download the DriveSafe app to access such data. If you already have downloaded the drive safe app, make sure you accept Mr." +
                                                          currentUser
                                                              .firstName +
                                                          "'s friend request to access data in the app.\n" +
                                                          "Note : if you reject the user in the app, you will no longer get messages";
                                                      for (int k = 0;
                                                          k <
                                                              appUser
                                                                  .friendRequests
                                                                  .length;
                                                          k++) {
                                                        if (appUser.friendRequests[
                                                                k][1] ==
                                                            user.phoneNumber) {
                                                          appUser.friendRequests
                                                              .removeAt(k);
                                                        }
                                                      }
                                                      setState(() {
                                                        appUser.friendRequests
                                                            .add([
                                                          "pending",
                                                          user.phoneNumber
                                                        ]);
                                                        answer = answer;
                                                      });
                                                      // code
                                                      await FirebaseDatabase
                                                          .instance
                                                          .ref("User")
                                                          .update({
                                                        appUser.phoneNumber: {
                                                          "age": appUser.age,
                                                          "firstName":
                                                              appUser.firstName,
                                                          "lastName":
                                                              appUser.lastName,
                                                          "friendReqeusts":
                                                              appUser
                                                                  .friendRequests,
                                                          "friendRequestsPending":
                                                              appUser
                                                                  .friendRequestsPending,
                                                          "image":
                                                              appUser.image,
                                                          "password":
                                                              appUser.password,
                                                          "friends":
                                                              appUser.friends,
                                                          "location":
                                                              appUser.location,
                                                          "phoneNumber": appUser
                                                              .phoneNumber,
                                                          "locationSharingPeople":
                                                              appUser
                                                                  .LocationSharingPeople,
                                                          "numberApproved":
                                                              false,
                                                          "locationTrackingOn":
                                                              false,
                                                          "phoneNumbersChosen":
                                                              appUser.numberList
                                                        }
                                                      });
                                                      final requestUserData =
                                                          await FirebaseDatabase
                                                              .instance
                                                              .ref("User/")
                                                              .child(user
                                                                  .phoneNumber)
                                                              .child(
                                                                  "friendRequestsPending")
                                                              .get();
                                                      List tempFriendList = [];
                                                      if (requestUserData
                                                              .value !=
                                                          null) {
                                                        List
                                                            requestUserFinalData =
                                                            requestUserData
                                                                .value as List;
                                                        tempFriendList.addAll(
                                                            requestUserFinalData);
                                                      }
                                                      tempFriendList.add(
                                                          appUser.phoneNumber);
                                                      await FirebaseDatabase
                                                          .instance
                                                          .ref("User")
                                                          .child(
                                                              user.phoneNumber)
                                                          .update({
                                                        "friendRequestsPending":
                                                            tempFriendList
                                                      });
                                                    },
                                                    btnOkText: "Yes",
                                                    btnOkColor: Colors.green,
                                                    btnCancelText: "No",
                                                    btnCancelColor: Colors.red,
                                                    btnCancelOnPress: () {})
                                                .show();
                                          }*/
                                                      },
                                                      onLongPress: () {},
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
                                                                child: user.image ==
                                                                        ""
                                                                    ? CircleAvatar(
                                                                        radius: widget.height *
                                                                            (0.11 /
                                                                                2),
                                                                        backgroundColor: Colors
                                                                            .grey
                                                                            .shade300,
                                                                        child:
                                                                            NeumorphicIcon(
                                                                          Icons
                                                                              .tag_faces,
                                                                          size: textSize *
                                                                              70,
                                                                          style:
                                                                              NeumorphicStyle(color: color),
                                                                        ),
                                                                      )
                                                                    : InkWell(
                                                                        onTap:
                                                                            () {
                                                                          print(
                                                                              user.image);
                                                                        },
                                                                        child:
                                                                            CircleAvatar(
                                                                          radius:
                                                                              widget.height * (0.11 / 2),
                                                                          backgroundImage:
                                                                              NetworkImage(user.image),
                                                                        ),
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
                                                                  user.firstName +
                                                                      " " +
                                                                      user.lastName,
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
                                                                      user.userName,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .visible,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              color,
                                                                          fontSize:
                                                                              MediaQuery.of(context).textScaleFactor * 20),
                                                                    ),
                                                                    isGaurdian ==
                                                                            true
                                                                        ? Icon(
                                                                            Icons.shield,
                                                                            color:
                                                                                color,
                                                                            size:
                                                                                MediaQuery.of(context).textScaleFactor * 20,
                                                                          )
                                                                        : Container(),
                                                                  ],
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        style: NeumorphicStyle(
                                                            boxShape: NeumorphicBoxShape
                                                                .roundRect(const BorderRadius
                                                                        .all(
                                                                    Radius.circular(
                                                                        45))),
                                                            depth: 15,
                                                            color: Colors
                                                                .grey.shade300,
                                                            lightSource:
                                                                LightSource
                                                                    .topLeft,
                                                            shape:
                                                                NeumorphicShape
                                                                    .concave),
                                                      ),
                                                    ));
                                              }).toList()
                                            ]),
                                      )),
                      )
                    ]),
              ),
              InkWell(
                onDoubleTap: () {
                  setState(() {
                    status = 0;
                    chooseColor = Colors.transparent;
                    chooseWidth = 0;
                    chooseHeight = 0;
                    widget.color(false);
                  });
                },
                child: AnimatedContainer(
                    duration: Duration(seconds: 0),
                    width: 0 + width * status,
                    height: 0 + height * status,
                    color: chooseColor,
                    child: Center(
                        child: AnimatedContainer(
                            curve: Curves.bounceInOut,
                            duration: const Duration(milliseconds: 700),
                            width: chooseWidth,
                            height: chooseHeight,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              border: Border.all(color: Colors.blue, width: 5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    if (curChosenUser.phoneNumber ==
                                        mainChosenAppUser.phoneNumber) {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        animType: AnimType.SCALE,
                                        headerAnimationLoop: false,
                                        title: "ERROR",
                                        desc:
                                            "You cannot send a contact-request to yourself",
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
                                        btnOkText: "Ok",
                                        btnOkColor: Colors.red,
                                      ).show();
                                    } else if (theColor == Colors.green) {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        animType: AnimType.SCALE,
                                        headerAnimationLoop: false,
                                        title: "ERROR",
                                        desc:
                                            "The chosen user is already your friend. You can not send requests to your friend",
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
                                        btnOkText: "Ok",
                                        btnOkColor: Colors.red,
                                      ).show();
                                    } else if (theColor == Colors.orange) {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        animType: AnimType.SCALE,
                                        headerAnimationLoop: false,
                                        title: "ERROR",
                                        desc:
                                            "You have already sent a friend request to the person. The request is currently pending.",
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
                                        btnOkText: "Ok",
                                        btnOkColor: Colors.red,
                                      ).show();
                                    } else {
                                      AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.INFO,
                                              animType: AnimType.SCALE,
                                              headerAnimationLoop: false,
                                              title: "Warning",
                                              desc: "Are you sure you want to send a friend request to " +
                                                  allusers[
                                                          chosenUserCurrentLocation]
                                                      .firstName +
                                                  " " +
                                                  allusers[
                                                          chosenUserCurrentLocation]
                                                      .lastName,
                                              titleTextStyle: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontFamily: "Nunito",
                                                fontSize: textSize * 25,
                                                color: Colors.blue,
                                              ),
                                              descTextStyle: TextStyle(
                                                  fontFamily: "Nunito",
                                                  fontSize: textSize * 20,
                                                  color: Colors.blueAccent),
                                              btnOkOnPress: () async {
                                                setState(() {
                                                  chooseColor =
                                                      Colors.transparent;
                                                  chooseWidth = 0;
                                                  chooseHeight = 0;
                                                  status = 0;
                                                  widget.color(false);
                                                });
                                                BackgroundSms.sendMessage(
                                                    phoneNumber: allusers[
                                                            chosenUserCurrentLocation]
                                                        .phoneNumber
                                                        .substring(2),
                                                    message: "Greetings this is a bot from the Drive Safe Application. We are contacting you to inform you that you have been placed in " +
                                                        currentUser.firstName +
                                                        " " +
                                                        currentUser.lastName +
                                                        "'s list of trusted people. Because of this you will be sent important information about " +
                                                        currentUser.firstName +
                                                        " " +
                                                        currentUser.lastName +
                                                        " while they are driving for there safety and your information. For more detailed information consider downloading the Drive Safe App.");
                                                mainChosenAppUser.numberList
                                                    .add(
                                                  [
                                                    allusers[
                                                            chosenUserCurrentLocation]
                                                        .firstName,
                                                    allusers[
                                                            chosenUserCurrentLocation]
                                                        .lastName,
                                                    allusers[
                                                            chosenUserCurrentLocation]
                                                        .phoneNumber,
                                                    allusers[
                                                            chosenUserCurrentLocation]
                                                        .image,
                                                    true,
                                                  ],
                                                );
                                                String smsMessage = "Hello, this is a bot from the DriveSafe application. We are writing this message to inform you that the phone number " +
                                                    currentUser.phoneNumber +
                                                    ", owned by " +
                                                    currentUser.firstName +
                                                    " " +
                                                    currentUser.lastName +
                                                    ", has chosen to send you his location data for safety when he is driving. Whenever Mr." +
                                                    currentUser.lastName +
                                                    " starts to drive his car you will recieve data like a link to his current location, his speed, the quality of the roads he is driving on, and other data regarding his safety every 2 or so minutes. If you want more indepth data, like live location updating, then you can download the DriveSafe app to access such data. If you already have downloaded the drive safe app, make sure you accept Mr." +
                                                    currentUser.firstName +
                                                    "'s friend request to access data in the app.\n" +
                                                    "Note : if you reject the user in the app, you will no longer get messages";
                                                for (int k = 0;
                                                    k <
                                                        mainChosenAppUser
                                                            .friendRequests
                                                            .length;
                                                    k++) {
                                                  if (mainChosenAppUser
                                                              .friendRequests[k]
                                                          [1] ==
                                                      curChosenUser
                                                          .phoneNumber) {
                                                    mainChosenAppUser
                                                        .friendRequests
                                                        .removeAt(k);
                                                  }
                                                }
                                                setState(() {
                                                  mainChosenAppUser
                                                      .friendRequests
                                                      .add([
                                                    "pending",
                                                    curChosenUser.phoneNumber
                                                  ]);
                                                  answer = answer;
                                                });
                                                // code
                                                await FirebaseDatabase.instance
                                                    .ref("User")
                                                    .update({
                                                  mainChosenAppUser.phoneNumber:
                                                      {
                                                    "age":
                                                        mainChosenAppUser.age,
                                                    "firstName":
                                                        mainChosenAppUser
                                                            .firstName,
                                                    "lastName":
                                                        mainChosenAppUser
                                                            .lastName,
                                                    "friendReqeusts":
                                                        mainChosenAppUser
                                                            .friendRequests,
                                                    "friendRequestsPending":
                                                        mainChosenAppUser
                                                            .friendRequestsPending,
                                                    "image":
                                                        mainChosenAppUser.image,
                                                    "password":
                                                        mainChosenAppUser
                                                            .password,
                                                    "friends": mainChosenAppUser
                                                        .friends,
                                                    "location":
                                                        mainChosenAppUser
                                                            .location,
                                                    "phoneNumber":
                                                        mainChosenAppUser
                                                            .phoneNumber,
                                                    "locationSharingPeople":
                                                        mainChosenAppUser
                                                            .LocationSharingPeople,
                                                    "numberApproved": false,
                                                    "locationTrackingOn": false,
                                                    "phoneNumbersChosen":
                                                        mainChosenAppUser
                                                            .numberList
                                                  }
                                                });
                                                final requestUserData =
                                                    await FirebaseDatabase
                                                        .instance
                                                        .ref("User/")
                                                        .child(curChosenUser
                                                            .phoneNumber)
                                                        .child(
                                                            "friendRequestsPending")
                                                        .get();
                                                List tempFriendList = [];
                                                if (requestUserData.value !=
                                                    null) {
                                                  List requestUserFinalData =
                                                      requestUserData.value
                                                          as List;
                                                  tempFriendList.addAll(
                                                      requestUserFinalData);
                                                }
                                                tempFriendList.add(
                                                    mainChosenAppUser
                                                        .phoneNumber);
                                                await FirebaseDatabase.instance
                                                    .ref("User")
                                                    .child(curChosenUser
                                                        .phoneNumber)
                                                    .update({
                                                  "friendRequestsPending":
                                                      tempFriendList
                                                });
                                              },
                                              btnOkText: "Yes",
                                              btnOkColor: Colors.green,
                                              btnCancelText: "No",
                                              btnCancelColor: Colors.red,
                                              btnCancelOnPress: () {})
                                          .show();
                                    }
                                  },
                                  child: Container(
                                    child: Stack(children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Lottie.network(
                                              "https://assets9.lottiefiles.com/packages/lf20_5aaicf2r.json"),
                                          //"https://assets2.lottiefiles.com/packages/lf20_2scSKA.json"),
                                          SizedBox(height: height * 0.02)
                                        ],
                                      ),
                                      Positioned(
                                        bottom: height * 0.02,
                                        right: width * 0.05,
                                        child: Text(
                                          "Friends",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: textSize * 25,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      )
                                    ]),
                                  ),
                                )),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: chooseHeight * 0.025),
                                  width: 5,
                                  height: chooseHeight * 0.95,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50))),
                                ),
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    if (curChosenUser.phoneNumber ==
                                        mainChosenAppUser.phoneNumber) {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        animType: AnimType.SCALE,
                                        headerAnimationLoop: false,
                                        title: "ERROR",
                                        desc:
                                            "You cannot send a contact-request to yourself",
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
                                        btnOkText: "Ok",
                                        btnOkColor: Colors.red,
                                      ).show();
                                    } else if (theColor == Colors.green) {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        animType: AnimType.SCALE,
                                        headerAnimationLoop: false,
                                        title: "ERROR",
                                        desc:
                                            "The chosen user is already your friend. You can not send requests to your friend",
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
                                        btnOkText: "Ok",
                                        btnOkColor: Colors.red,
                                      ).show();
                                    } else if (theColor == Colors.orange) {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        animType: AnimType.SCALE,
                                        headerAnimationLoop: false,
                                        title: "ERROR",
                                        desc:
                                            "You have already sent a friend request to the person. The request is currently pending.",
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
                                        btnOkText: "Ok",
                                        btnOkColor: Colors.red,
                                      ).show();
                                    } else {
                                      AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.INFO,
                                              animType: AnimType.SCALE,
                                              headerAnimationLoop: false,
                                              title: "Warning",
                                              desc: "Are you sure you want to send a gaurdian request to " +
                                                  allusers[
                                                          chosenUserCurrentLocation]
                                                      .firstName +
                                                  " " +
                                                  allusers[
                                                          chosenUserCurrentLocation]
                                                      .lastName,
                                              titleTextStyle: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontFamily: "Nunito",
                                                fontSize: textSize * 25,
                                                color: Colors.blue,
                                              ),
                                              descTextStyle: TextStyle(
                                                  fontFamily: "Nunito",
                                                  fontSize: textSize * 20,
                                                  color: Colors.blueAccent),
                                              btnOkOnPress: () async {
                                                setState(() {
                                                  chooseColor =
                                                      Colors.transparent;
                                                  chooseWidth = 0;
                                                  chooseHeight = 0;
                                                  status = 0;
                                                  widget.color(false);
                                                });
                                                print(mainChosenAppUser
                                                    .numberList);
                                                mainChosenAppUser.numberList
                                                    .add(
                                                  [
                                                    allusers[
                                                            chosenUserCurrentLocation]
                                                        .firstName,
                                                    allusers[
                                                            chosenUserCurrentLocation]
                                                        .lastName,
                                                    allusers[
                                                            chosenUserCurrentLocation]
                                                        .phoneNumber,
                                                    allusers[
                                                            chosenUserCurrentLocation]
                                                        .image,
                                                    true,
                                                  ],
                                                );

                                                for (int k = 0;
                                                    k <
                                                        mainChosenAppUser
                                                            .friendRequests
                                                            .length;
                                                    k++) {
                                                  if (mainChosenAppUser
                                                              .friendRequests[k]
                                                          [1] ==
                                                      curChosenUser
                                                          .phoneNumber) {
                                                    mainChosenAppUser
                                                        .friendRequests
                                                        .removeAt(k);
                                                  }
                                                }
                                                setState(() {
                                                  mainChosenAppUser
                                                      .friendRequests
                                                      .add([
                                                    "pending",
                                                    curChosenUser.phoneNumber,
                                                    "gaurdian"
                                                  ]);
                                                  answer = answer;
                                                });
                                                // code
                                                await FirebaseDatabase.instance
                                                    .ref("User")
                                                    .update({
                                                  mainChosenAppUser.phoneNumber:
                                                      {
                                                    "age":
                                                        mainChosenAppUser.age,
                                                    "firstName":
                                                        mainChosenAppUser
                                                            .firstName,
                                                    "lastName":
                                                        mainChosenAppUser
                                                            .lastName,
                                                    "friendReqeusts":
                                                        mainChosenAppUser
                                                            .friendRequests,
                                                    "friendRequestsPending":
                                                        mainChosenAppUser
                                                            .friendRequestsPending,
                                                    "image":
                                                        mainChosenAppUser.image,
                                                    "password":
                                                        mainChosenAppUser
                                                            .password,
                                                    "friends": mainChosenAppUser
                                                        .friends,
                                                    "location":
                                                        mainChosenAppUser
                                                            .location,
                                                    "phoneNumber":
                                                        mainChosenAppUser
                                                            .phoneNumber,
                                                    "locationSharingPeople":
                                                        mainChosenAppUser
                                                            .LocationSharingPeople,
                                                    "numberApproved": false,
                                                    "locationTrackingOn": false,
                                                    "phoneNumbersChosen":
                                                        mainChosenAppUser
                                                            .numberList
                                                  }
                                                });
                                                final requestUserData =
                                                    await FirebaseDatabase
                                                        .instance
                                                        .ref("User/")
                                                        .child(curChosenUser
                                                            .phoneNumber)
                                                        .child(
                                                            "friendRequestsPending")
                                                        .get();
                                                List tempFriendList = [];
                                                if (requestUserData.value !=
                                                    null) {
                                                  List requestUserFinalData =
                                                      requestUserData.value
                                                          as List;
                                                  tempFriendList.addAll(
                                                      requestUserFinalData);
                                                }
                                                print(tempFriendList);
                                                tempFriendList.add(
                                                    mainChosenAppUser
                                                        .phoneNumber);
                                                print(tempFriendList);
                                                await FirebaseDatabase.instance
                                                    .ref("User")
                                                    .child(curChosenUser
                                                        .phoneNumber)
                                                    .update({
                                                  "friendRequestsPending":
                                                      tempFriendList
                                                });
                                              },
                                              btnOkText: "Yes",
                                              btnOkColor: Colors.green,
                                              btnCancelText: "No",
                                              btnCancelColor: Colors.red,
                                              btnCancelOnPress: () {})
                                          .show();
                                    }
                                  },
                                  child: Container(
                                    child: Stack(children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Lottie.network(
                                              "https://assets9.lottiefiles.com/packages/lf20_phirz1xm.json"),
                                          SizedBox(height: height * 0.02)
                                          //"https://assets2.lottiefiles.com/packages/lf20_2scSKA.json"),
                                        ],
                                      ),
                                      Positioned(
                                        bottom: height * 0.02,
                                        right: width * 0.07,
                                        child: Text(
                                          "Family",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: textSize * 25,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      )
                                    ]),
                                  ),
                                ))
                              ],
                            )))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
