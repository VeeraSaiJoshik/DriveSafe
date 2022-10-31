import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:drivesafev2/pages/Setting/settingsPage.dart';
import 'package:drivesafev2/pages/sendNotification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'ContactsScreen/FriendsScreen.dart';
import 'DrivingChooseScreen.dart';

String constructFCMPayload(String? token) {
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': '1',
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification  was created via FCM!',
    },
  });
}

class DriveSafeHomePage extends StatefulWidget {
  User UserProfile;
  BuildContext context;
  DriveSafeHomePage(this.UserProfile, this.context);

  @override
  _DriveSafeHomePageState createState() => _DriveSafeHomePageState();
}

// Main test case : 2670440300

class _DriveSafeHomePageState extends State<DriveSafeHomePage> {
  @override
  late final AnimationController controller;
  bool imageAppeared = false;
  Future<User> getUserData(String phoneNumber) async {
    phoneNumber = phoneNumber.trim();
    phoneNumber = phoneNumber.replaceAll(" ", "");
    if (phoneNumber[0] != "+") {
      phoneNumber = "+1" + phoneNumber;
    }
    final Data =
        await FirebaseDatabase.instance.ref("User/" + phoneNumber).get();
    List<String> friendsList = [];
    List<String> requestList = [];
    List friends = [];
    List friendRequests = [];
    List LocationSharingPeople = [];
    List friendRequestsPending = [];
    List location = [];
    List numberList = [];
    List chosenNumber = [];
    Map data = Data.value as Map;
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
    print(data["userName"]);
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
        numberList,
        data["userName"]);
  }

  Map raw = {};
  Future<List<User>> getData() async {
    List<User> allUserList = [];
    final finalData = await FirebaseDatabase.instance.ref("User").get();
    Map data = finalData.value as Map;
    raw = finalData.value as Map;
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
      } catch (e) {
        print(e);
      }
    });
    return allUserList;
  }

  bool? permissionGranted;

  late List<User> Allusers;
  void getPermission() async {
    bool? permissionGranted = await Telephony.instance.requestSmsPermissions;
    print(permissionGranted);
  }

  void initState() {
    getPermission();
    getData().then((users) {
      setState(() {
        Allusers = users;
        imageAppeared = true;
      });
    });
    FirebaseMessaging.instance.subscribeToTopic("10987654321");
    FirebaseMessaging.instance.subscribeToTopic("14793679994");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("ere");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
          id: 10,
          channelKey: 'scheduled_channel',
          title: notification.title,
          body: notification.body,
        ));
      }
    });

    print("subscribed");
    AwesomeNotifications()
        .actionStream
        .listen((ReceivedNotification receivedNotification) {
      print("clicked");
      String title = receivedNotification.title!;
      print("clicked");
      String imageAssetLink = "";
      if (title == "New Town") {
        imageAssetLink = "assets/images/village.png";
      } else if (title == "Crash Alert") {
        imageAssetLink = "assets/images/roadIncidents/carCrash.png";
      } else if (title == "Harsh Acceleration") {
        imageAssetLink = "assets/images/clock.png";
      } else if (title == "Harsh Breaks") {
        imageAssetLink = "assets/images/delay.png";
      } else if (title.trim() == "Speeding Alert") {
        imageAssetLink = "assets/images/speeding.png";
      } else if (title == "Blinking Alert") {
        imageAssetLink = "assets/images/eye.png";
      } else if (title == "Sleeping Alert") {
        imageAssetLink = "assets/images/sleepWarning.png";
      } else if (title == "Inclement Weather Alert") {
        imageAssetLink = "assets/images/big_images/morning/thunder.png";
      } else if (title == "Trip Started") {
        imageAssetLink = "assets/images/start.png";
      } else if (title == "Trip Finished") {
        imageAssetLink = "assets/images/finish.png";
      } else if (title == "Drive Report") {
        imageAssetLink = "assets/images/analysis.png";
      } else {
        imageAssetLink = "assets/images/roadIncidents/unkown.png";
      }
      double height = MediaQuery.of(widget.context).size.height;
      AwesomeDialog(
              context: widget.context,
              body: Container(
                child: Column(
                  children: [
                    Text(
                      receivedNotification.title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(widget.context).textScaleFactor *
                                  30,
                          color: Colors.blue,
                          fontWeight: FontWeight.w800),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(receivedNotification.body!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: MediaQuery.of(widget.context)
                                      .textScaleFactor *
                                  15,
                              fontWeight: FontWeight.w700)),
                    )
                  ],
                ),
              ),
              customHeader: Container(
                height: height * 0.12,
                width: height * 0.12,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100))),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    color: Colors.white,
                    border: NeumorphicBorder(color: Colors.blue, width: 3),
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.all(Radius.circular(100))),
                    depth: -10,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(height * 0.02),
                    child: Image.asset(imageAssetLink),
                  ),
                ),
              ),
              btnOkText: "Redirect",
              btnCancelText: "Cancel",
              btnOkColor: Colors.green,
              btnCancelColor: Colors.red,
              btnOkOnPress: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return FriendScreen(widget.UserProfile, Allusers, true, raw);
                }));
              },
              btnCancelOnPress: () {})
          .show();
      ;
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String fullName;
    double textSize = MediaQuery.of(context).textScaleFactor;
    Color mainColor = Colors.grey.shade300;

    return Scaffold(
        backgroundColor: mainColor,
        body: Center(
            child: Container(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.06,
              ),
              Neumorphic(
                  style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.circle(),
                      depth: 10,
                      shadowLightColor: Color.fromARGB(255, 193, 217, 221),
                      intensity: 1,
                      border: NeumorphicBorder(
                          color: Colors.blue, width: height * 0.01)),
                  child: widget.UserProfile.image == ""
                      ? Neumorphic(
                          child: CircleAvatar(
                            radius: height * 0.15,
                            backgroundColor: Colors.grey.shade300,
                            child: NeumorphicIcon(
                              Icons.tag_faces,
                              size: textSize * 200,
                              style: NeumorphicStyle(color: Colors.blue),
                            ),
                          ),
                          style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: -20,
                              shadowLightColor:
                                  Color.fromARGB(255, 193, 217, 221),
                              intensity: 1,
                              border: NeumorphicBorder(
                                  color: Colors.grey.shade300,
                                  width: height * 0.01)))
                      : imageAppeared == true
                          ? CircleAvatar(
                              radius: height * 0.15,
                              backgroundImage:
                                  NetworkImage(widget.UserProfile.image),
                            )
                          : Shimmer.fromColors(
                              child: CircleAvatar(
                                radius: height * 0.15,
                                backgroundImage:
                                    NetworkImage(widget.UserProfile.image),
                              ),
                              baseColor: Colors.blue,
                              highlightColor: Colors.blue.shade600)),
              SizedBox(
                height: height * 0.01,
              ),
              Text(
                widget.UserProfile.firstName +
                    " " +
                    widget.UserProfile.lastName,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: textSize * 45,
                  fontFamily: "Nunito",
                  fontWeight: FontWeight.w800,
                  shadows: [
                    const Shadow(
                        offset: Offset(1.5, 1.5),
                        color: Colors.black38,
                        blurRadius: 10),
                    Shadow(
                        offset: Offset(-1.5, -1.5),
                        color: Colors.white.withOpacity(0.85),
                        blurRadius: 10)
                  ],
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                height: height * 0.015,
              ),
              Container(
                  width: width * 0.9,
                  height: height * 0.533,
                  child: Column(children: [
                    Row(
                      children: [
                        Container(
                          width: width * (0.9 - 0.025) / 2,
                          height: height * 0.46 / 2,
                          child: NeumorphicButton(
                            onPressed: () async {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return FriendScreen(
                                    widget.UserProfile, Allusers, false, raw);
                              }));
                              FirebaseMessaging.instance.requestPermission();
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: width * (0.9 - 0.025) / 2,
                                  child: Lottie.asset(
                                      "assets/animations/contacts.json"),
                                  //Lottie.network(
                                  //"https://assets6.lottiefiles.com/private_files/lf30_uvrwjrrs.json"),
                                  height: height * 0.16,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: width * (0.95 - 0.05) / 2,
                                      height: height * 0.13854,
                                    ),
                                    Text(
                                      "Contacts",
                                      style: TextStyle(
                                          color: mainColor,
                                          fontSize: textSize * 29,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ) //https://assets6.lottiefiles.com/packages/lf20_ligemumo.json
                              ],
                            ),
                            style: NeumorphicStyle(
                                depth: 5,
                                color: Colors.blue,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.all(Radius.circular(30)))),
                          ),
                        ),
                        SizedBox(
                          width: width * 0.025,
                        ),
                        Container(
                          width: width * (0.9 - 0.025) / 2,
                          height: height * 0.46 / 2,
                          child: NeumorphicButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                print(widget.UserProfile.phoneNumber);
                                print(widget.UserProfile);
                                return settingsPage(
                                    widget.UserProfile.phoneNumber,
                                    widget.UserProfile);
                              })).whenComplete(() =>
                                  getUserData(widget.UserProfile.phoneNumber)
                                      .then((value) {
                                    setState(() {
                                      widget.UserProfile = value;
                                      print(widget.UserProfile.userName);
                                    });
                                  }));
                              //    print(Allusers);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: width * (0.95 - 0.025) / 2,
                                  child: Lottie.asset(
                                      "assets/animations/settings.json"),
                                  //"https://assets6.lottiefiles.com/packages/lf20_ligemumo.json"),
                                  height: height * 0.16,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: width * (0.95 - 0.025) / 2,
                                      height: height * 0.13854,
                                    ),
                                    Text(
                                      "Settings",
                                      style: TextStyle(
                                          color: mainColor,
                                          fontSize: textSize * 29,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ) //
                              ],
                            ),
                            drawSurfaceAboveChild: true,
                            style: NeumorphicStyle(
                                depth: 5,
                                color: Colors.blue,
                                border: NeumorphicBorder(),
                                shadowLightColor: Colors.transparent,
                                lightSource: LightSource.topLeft,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.all(Radius.circular(30)))),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Container(
                      width: width * (0.95),
                      height: height * ((0.46 / 2) + 0.04),
                      child: NeumorphicButton(
                        onPressed: () {
                          getUserData(widget.UserProfile.phoneNumber)
                              .then((value) {
                            print(value.numberList.toString() + "value ");
                            print("value.numberList");
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return drivingChooseScreen(value);
                            }));
                          });
                        },
                        child: Stack(
                          children: [
                            Lottie.asset(
                                //"https://assets7.lottiefiles.com/temporary_files/GvQobl.json",
                                "assets/animations/steeringWheel.json",
                                height: 300,
                                width: 300,
                                animate: true,
                                repeat: false),
                            Column(
                              children: [
                               Expanded(child: Container()),
                                Text(
                                  "Drive",
                                  style: TextStyle(
                                      color: mainColor,
                                      fontSize: textSize * 29,
                                      fontWeight: FontWeight.w800),
                                ),

                              ],
                            ) //https://assets6.lottiefiles.com/packages/lf20_ligemumo.json
                          ],
                        ),
                        style: NeumorphicStyle(
                            depth: 5,
                            color: Colors.blue,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.all(Radius.circular(30)))),
                      ),
                    ),
                  ]))
            ],
          ),
        )));
  }
}
