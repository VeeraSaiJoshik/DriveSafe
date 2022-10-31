import 'dart:io';
import 'dart:ui';
import 'package:drivesafev2/pages/viewSavedLocations.dart';
import 'package:flutter_latlong/flutter_latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gMap;
import '../addLocation.dart';
import 'phoneNumberWidget.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:drivesafev2/pages/Setting/settingOptionWidget.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:drivesafev2/models/settings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'driveSettingScreen.dart';
import 'package:telephony/telephony.dart';

class settingsPage extends StatefulWidget {
  @override
  String phoneNumber;
  User currentUser;
  settingsPage(this.phoneNumber, this.currentUser);

  _settingsPageState createState() => _settingsPageState();
}

class _settingsPageState extends State<settingsPage> {
  //variable decleration area
  Color SMSTackColor = Colors.red;
  bool SmsPermission = false;
  TextEditingController textEditingController = new TextEditingController();
  TextEditingController replySMS = new TextEditingController();
  static const platform = const MethodChannel('sendSms');

  Location location = new Location();
  late gMap.LatLng currentLonaction;
  final Telephony telephony = Telephony.instance;
  User currentUser =
      User("", "", "", "", 0, [], [], [], [], [], "", false, false, [], "");
  User originalCurrentUser =
      User("", "", "", "", 0, [], [], [], [], [], "", false, false, [], "");
  Settings setting = Settings();
  Settings originalSetting = Settings();
  bool currentUserDataChanged = false;
  bool haveChosen = false;
  String error = "";
  XFile? image = null;
  // function area
  void updateSettingsData() async {}
  void chooseUpdateNewImage() async {
    currentUserDataChanged = true;
    XFile? _image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (_image != null) {
      File image = File(_image.path);
      final firstUrl = await firebase_storage.FirebaseStorage.instance
          .ref()
          .child('user images')
          .child(currentUser.phoneNumber.toString() + '.jpg');
      firebase_storage.UploadTask uploadTask = firstUrl.putFile(image);
      uploadTask.whenComplete(() async {
        final finalUrl = await firstUrl.getDownloadURL();
        setState(() {
          currentUser.image = finalUrl;
          haveChosen = true;
        });
      });
    }
  }

  void getCurrentUserData() async {
    LocationData locData = await location.getLocation();
    currentLonaction = gMap.LatLng(locData.latitude!, locData.longitude!);
    final Data =
        await FirebaseDatabase.instance.ref("User/" + widget.phoneNumber).get();
    Map data = Data.value as Map;

    if (data.containsKey("friends")) {
      currentUser.friends = data["friends"];
    }
    if (data.containsKey("friendReqeusts")) {
      currentUser.friendRequests = data["friendReqeusts"];
    }
    if (data.containsKey("locationSharingPeople")) {
      currentUser.LocationSharingPeople.addAll(data["locationSharingPeople"]);
    }
    if (data.containsKey("friendRequestsPending")) {
      currentUser.friendRequestsPending
          .addAll(data["friefriendRequestsPendingndRequestsPending"]);
    }
    if (data.containsKey("location")) {
      currentUser.location.addAll(["location"]);
    }
    if (data.containsKey("phoneNumbersChosen")) {
      currentUser.numberList.addAll(data["phoneNumbersChosen"]);
    }
    currentUser.firstName = data["firstName"];
    currentUser.lastName = data["lastName"];
    currentUser.phoneNumber = data["phoneNumber"];
    currentUser.password = data["password"];
    currentUser.age = data["age"];
    currentUser.image = data["image"];
    currentUser.numberApproved = data["numberApproved"];
    currentUser.locationTrackingOn = data["locationTrackingOn"];
    currentUser.userName = data["userName"];

    setState(() {
      currentUser;
      originalCurrentUser.firstName = currentUser.firstName;
      originalCurrentUser.lastName = currentUser.lastName;
      originalCurrentUser.phoneNumber = currentUser.phoneNumber;
      originalCurrentUser.location = currentUser.location;
      originalCurrentUser.image = currentUser.image;
      originalCurrentUser.friendRequests = currentUser.friendRequests;
      originalCurrentUser.friendRequestsPending =
          currentUser.friendRequestsPending;
      originalCurrentUser.friends = currentUser.friends;
      originalCurrentUser.numberList = currentUser.numberList;
      originalCurrentUser.password = currentUser.password;
      originalCurrentUser.numberApproved = currentUser.numberApproved;
      originalCurrentUser.numberList = currentUser.numberList;
      originalCurrentUser.locationTrackingOn = currentUser.locationTrackingOn;
      originalCurrentUser.age = currentUser.age;
      originalCurrentUser.LocationSharingPeople =
          currentUser.LocationSharingPeople;
      originalCurrentUser.userName = originalCurrentUser.userName;
    });
    getSettings();
    if (setting.messageReplyString.isNotEmpty) {
      setState(() {
        replySMS.text = setting.messageReplyString;
      });
    }
  }

  void getSettings() async {
    final Data = await FirebaseDatabase.instance
        .ref("User")
        .child(widget.phoneNumber)
        .child("Settings")
        .get();
    if (Data.exists) {
      setting.jsonToSettings(Data.value as Map);
      originalSetting.jsonToSettings(Data.value as Map);
    } else {
      setting = Settings();
      originalSetting = Settings();
    }
    setState(() {
      setting;
      textEditingController.text = setting.sendMessageEverXMinutes.toString();
      originalSetting;
    });
  }

  void updateFirstName(textSize, width, height) async {
    currentUserDataChanged = true;
    TextEditingController firstNameController = new TextEditingController();
    AwesomeDialog(
            context: context,
            dialogType: DialogType.QUESTION,
            animType: AnimType.SCALE,
            headerAnimationLoop: false,
            desc: "Are you sure you do not want to add a profile picture",
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "First Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: "Nunito",
                    fontSize: textSize * 25,
                    color: Colors.orangeAccent,
                  ),
                ),
                Text(
                  "Enter the new First Name",
                  style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: textSize * 20,
                      color: Colors.orangeAccent),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: TextField(
                    controller: firstNameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: textSize * 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.orangeAccent),
                    decoration: const InputDecoration(
                      focusColor: Colors.orangeAccent,
                      fillColor: Colors.orangeAccent,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 3),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    cursorColor: Colors.orangeAccent,
                  ),
                )
              ],
            ),
            btnOkOnPress: () {
              currentUser.firstName = firstNameController.text;
              setState(() {
                currentUser;
              });
            },
            btnOkText: "Yes",
            btnOkColor: Colors.green,
            btnCancelText: "No",
            btnCancelOnPress: () {},
            btnCancelColor: Colors.red)
        .show();
    print("firstName");
  }

  void updateLastName(textSize, length, width) async {
    currentUserDataChanged = true;
    TextEditingController firstNameController = new TextEditingController();
    AwesomeDialog(
            context: context,
            dialogType: DialogType.QUESTION,
            animType: AnimType.SCALE,
            headerAnimationLoop: false,
            desc: "Are you sure you do not want to add a profile picture",
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Last Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: "Nunito",
                    fontSize: textSize * 25,
                    color: Colors.orangeAccent,
                  ),
                ),
                Text(
                  "Enter the new Last Name",
                  style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: textSize * 20,
                      color: Colors.orangeAccent),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: TextField(
                    controller: firstNameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: textSize * 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.orangeAccent),
                    decoration: const InputDecoration(
                      focusColor: Colors.orangeAccent,
                      fillColor: Colors.orangeAccent,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 3),
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    cursorColor: Colors.orangeAccent,
                  ),
                )
              ],
            ),
            btnOkOnPress: () {
              currentUser.lastName = firstNameController.text;
              setState(() {
                currentUser;
              });
            },
            btnOkText: "Yes",
            btnOkColor: Colors.green,
            btnCancelText: "No",
            btnCancelOnPress: () {},
            btnCancelColor: Colors.red)
        .show();
    print("firstName");
  }

  void functionSendSMS(condition) {
    setting.sendSMS = condition;
    if (setting.shareLocationToSelectedFriends == false &&
        setting.shareLocationToPhoneNumber == false &&
        setting.shareLocationToAllFriends == false) {
      setting.shareLocationToAllFriends = false;
      setting.shareLocationToPhoneNumber = true;
      setting.shareLocationToSelectedFriends = true;
    } else if (setting.shareLocationToSelectedFriends == true &&
        setting.shareLocationToPhoneNumber == true &&
        setting.shareLocationToAllFriends == true) {
      setting.shareLocationToAllFriends = false;
      setting.shareLocationToPhoneNumber = true;
      setting.shareLocationToSelectedFriends = true;
    }
    setState(() {
      setting;
    });
  }

  void functionOffline(condition) {
    setState(() {
      setting.offlineMode = condition;
    });
  }

  void functionAllFriends(condition) {
    if (condition == true) {
      setting.shareLocationToSelectedFriends = false;
    } else {
      if (setting.shareLocationToSelectedFriends ==
              setting.shareLocationToPhoneNumber &&
          setting.shareLocationToSelectedFriends == false) {
        setting.sendSMS = false;
      }
    }

    setting.shareLocationToAllFriends = condition;
    setState(() {
      setting;
    });
  }

  void crashAlerts(condition) {
    setState(() {
      setting.crashAlerts = condition;
    });
  }

  void replyToIncomingSMS(condition) {
    setState(() {
      setting.replyToIncomingSMS = condition;
    });
  }

  void functionIncludeEndTime(condition) {
    setState(() {
      setting.includeEndTime = condition;
    });
  }

  void sendNotification(condition) {
    setState(() {
      setting.sendNotification = condition;
    });
  }

  void blockCalls(condition) {
    setState(() {
      setting.alertSpeeding = condition;
    });
  }

  void sleepDetection(condition) {
    setState(() {
      setting.sleepDetection = condition;
    });
  }

  void trafficInfo(condition) {
    setState(() {
      setting.trafficInfo = condition;
    });
  }

  void functionSelecteFriends(condition) {
    if (condition == true) {
      setting.shareLocationToAllFriends = false;
    } else {
      if (setting.shareLocationToAllFriends ==
              setting.shareLocationToPhoneNumber &&
          setting.shareLocationToAllFriends == false) {
        setting.sendSMS = false;
      }
    }

    setting.shareLocationToSelectedFriends = condition;
    setState(() {
      setting;
    });
  }

  void functionPhoneNumber(condition) {
    if (condition == false) {
      if (setting.shareLocationToAllFriends ==
              setting.shareLocationToSelectedFriends &&
          setting.shareLocationToAllFriends == false) {
        setting.sendSMS = false;
      }
    }
    setState(() {
      setting.shareLocationToPhoneNumber = condition;
    });
  }

  void resetAllData() {
    currentUserDataChanged = false;
    currentUser.firstName = originalCurrentUser.firstName;
    currentUser.lastName = originalCurrentUser.lastName;
    currentUser.phoneNumber = originalCurrentUser.phoneNumber;
    currentUser.location = originalCurrentUser.location;
    currentUser.image = originalCurrentUser.image;
    currentUser.friendRequests = originalCurrentUser.friendRequests;
    currentUser.friendRequestsPending =
        originalCurrentUser.friendRequestsPending;
    currentUser.friends = originalCurrentUser.friends;
    currentUser.numberList = originalCurrentUser.numberList;
    currentUser.password = originalCurrentUser.password;
    currentUser.numberApproved = originalCurrentUser.numberApproved;
    currentUser.numberList = originalCurrentUser.numberList;
    currentUser.locationTrackingOn = originalCurrentUser.locationTrackingOn;
    currentUser.age = originalCurrentUser.age;
    currentUser.LocationSharingPeople =
        originalCurrentUser.LocationSharingPeople;
    currentUser.userName = originalCurrentUser.userName;

    setting.locationSharingPeople = originalSetting.locationSharingPeople;
    setting.sendNotification = originalSetting.sendNotification;
    setting.offlineMode = originalSetting.offlineMode;
    setting.sendMessageEverXMinutes = originalSetting.sendMessageEverXMinutes;
    setting.sendNotification = originalSetting.sendNotification;
    setting.sendSMS = originalSetting.sendSMS;
    setting.shareLocationToAllFriends =
        originalSetting.shareLocationToAllFriends;
    setting.shareLocationToPhoneNumber =
        originalSetting.shareLocationToPhoneNumber;
    setting.shareLocationToSelectedFriends =
        originalSetting.shareLocationToSelectedFriends;
    setting.sleepDetection = originalSetting.sleepDetection;
    textEditingController.text = setting.sendMessageEverXMinutes.toString();
    setState(() {
      currentUser;
      currentUserDataChanged;
    });
  }

  void initStateFunctino() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
  }

  void initState() {
    getCurrentUserData();
    print(widget.currentUser.userName);
    print(currentUser.firstName);
    setState(() {
      currentUser.userName;
      currentUser.lastName;
      currentUser.phoneNumber;
      widget.currentUser.userName;
    });
    super.initState();
  }

  void viewSavedPositions() {}
  void addSavedPositions() {}
  void deleteSavedPositions() {}
  //code
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Container(
            width: width,
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        height: height * 0.07,
                        width: height * 0.07,
                        child: NeumorphicButton(
                            onPressed: () async {
                              print("this1");
                              print(widget.currentUser.userName);
                              FirebaseDatabase.instance
                                  .ref("User")
                                  .child(widget.phoneNumber)
                                  .update({
                                "age": currentUser.age,
                                "firstName": currentUser.firstName,
                                "lastName": currentUser.lastName,
                                "friendReqeusts": currentUser.friendRequests,
                                "friendRequestsPending":
                                    currentUser.friendRequestsPending,
                                "image": currentUser.image,
                                "password": currentUser.password,
                                "friends": currentUser.friends,
                                "location": currentUser.location,
                                "phoneNumber": currentUser.phoneNumber,
                                "locationSharingPeople":
                                    currentUser.LocationSharingPeople,
                                "numberApproved": currentUser.numberApproved,
                                "locationTrackingOn":
                                    currentUser.locationTrackingOn,
                                "phoneNumbersChosen": currentUser.numberList,
                                "userName": widget.currentUser.userName
                              });
                              FirebaseDatabase.instance
                                  .ref("User")
                                  .child(widget.phoneNumber)
                                  .child("Settings")
                                  .update({
                                "blockCall": setting.blockCall,
                                "alertSpeeding": setting.alertSpeeding,
                                "locationSharingPeople":
                                    setting.locationSharingPeople,
                                "offlineMode": setting.offlineMode,
                                "sendMessageEverXMinutes":
                                    setting.sendMessageEverXMinutes,
                                "sendNotification": setting.sendNotification,
                                "sendSMS": setting.sendSMS,
                                "shareLocationToAllFriends":
                                    setting.shareLocationToAllFriends,
                                "shareLocationToPhoneNumber":
                                    setting.shareLocationToPhoneNumber,
                                "shareLocationToSelectedFriends":
                                    setting.shareLocationToSelectedFriends,
                                "sleepDetection": setting.sleepDetection,
                                "crashAlerts": setting.crashAlerts,
                                "trafficInfo": setting.trafficInfo,
                                "replyToIcomingSMS": setting.replyToIncomingSMS,
                                "messageReplyString":
                                    setting.messageReplyString,
                                "includeEndTime": setting.includeEndTime
                              });
                              print("this2");
                              print(widget.currentUser.userName);
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
                                    size: textScaleFactor * 25,
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
                        "Settings",
                        style: TextStyle(
                          fontSize: textScaleFactor * 40,
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
                        height: height * 0.07,
                        width: height * 0.07,
                        child: NeumorphicButton(
                            child: Icon(Icons.restore,
                                color: Colors.blue, size: textScaleFactor * 25),
                            onPressed: resetAllData,
                            padding: EdgeInsets.fromLTRB(
                                width * 0, height * 0, width * 0, height * 0),
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(
                                  const BorderRadius.all(Radius.circular(100))),
                              depth: 50,
                              color: Colors.grey.shade300,
                              lightSource: LightSource.topLeft,
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.01),
                Container(
                    height: height * 0.2,
                    width: height * 0.2,
                    child: Neumorphic(
                      style: NeumorphicStyle(
                          boxShape: const NeumorphicBoxShape.circle(),
                          border: const NeumorphicBorder(
                            color: Colors.blue,
                            width: 7,
                          ),
                          color: Colors.grey.shade300,
                          depth: -10),
                      child: InkWell(
                        onDoubleTap: chooseUpdateNewImage,
                        child: currentUser.image == ""
                            ? CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                radius: height * 0.15,
                                child: Center(
                                    child: NeumorphicIcon(
                                  Icons.tag_faces,
                                  size: textScaleFactor * 150,
                                  style: NeumorphicStyle(color: Colors.blue),
                                )),
                              )
                            : CircleAvatar(
                                backgroundImage:
                                    NetworkImage(currentUser.image),
                                radius: height * 0.1,
                              ),
                      ),
                    )),
                SizedBox(
                  height: height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        updateFirstName(textScaleFactor, width, height);
                      },
                      child: Text(
                        currentUser.firstName + " ",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: textScaleFactor * 40,
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
                    ),
                    InkWell(
                      onTap: () {
                        //updateLastName(textScaleFactor, height, width);
                        print(widget.currentUser.userName);
                      },
                      child: Text(
                        currentUser.lastName,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: textScaleFactor * 40,
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
                    ),
                  ],
                ),
                Text(
                  widget.currentUser.userName == null
                      ? ""
                      : widget.currentUser.userName,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: textScaleFactor * 25,
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
                  height: height * 0.005,
                ),
                Text(
                  widget.phoneNumber,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: textScaleFactor * 25,
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
                Expanded(
                  child: Container(
                    width: width,
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        ColorCodeWidget(height, width, textScaleFactor),
                        phoneNumberWidget(
                          height,
                          width,
                          textScaleFactor,
                          setting,
                          functionSendSMS,
                          functionOffline,
                          functionAllFriends,
                          functionSelecteFriends,
                          functionPhoneNumber,
                          textEditingController,
                          replyToIncomingSMS,
                          functionIncludeEndTime,
                          replySMS,
                        ),
                        DriveSettingScreen(
                            height,
                            width,
                            textScaleFactor,
                            setting,
                            crashAlerts,
                            sendNotification,
                            blockCalls,
                            sleepDetection,
                            trafficInfo),
                        Neumorphic(
                            style: NeumorphicStyle(
                                color: Colors.grey.shade300,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.all(Radius.circular(40))),
                                border: const NeumorphicBorder(
                                  color: Colors.blue,
                                  width: 5,
                                ),
                                depth: -20),
                            child: Container(
                                width: width * 0.95,
                                height: height * 0.46 + height * 0.025,
                                color: Colors.grey.shade300,
                                padding: EdgeInsets.fromLTRB(
                                    height * 0.025,
                                    height * 0.015,
                                    height * 0.025,
                                    height * 0.025),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Saved Locations",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: textScaleFactor * 35,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.007),
                                    NeumorphicButton(
                                      child: Container(
                                          width:
                                              width * 0.95 - height * 0.025 * 2,
                                          height: height * 0.25 / 3,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: Lottie.network(
                                                  "https://assets4.lottiefiles.com/packages/lf20_nhv85sha.json",
                                                ),
                                              ),
                                              Text(
                                                "View",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize:
                                                      textScaleFactor * 35,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              )
                                            ],
                                          )),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (builder) {
                                          return viewSavedLocations(
                                              widget.phoneNumber, false, []);
                                        }));
                                      },
                                      style: NeumorphicStyle(
                                          color: Colors.grey.shade300,
                                          border: const NeumorphicBorder(
                                              color: Colors.blue, width: 5),
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                  const BorderRadius.all(
                                                      Radius.circular(40)))),
                                    ),
                                    SizedBox(
                                      height: height * 0.02,
                                    ),
                                    NeumorphicButton(
                                      child: Container(
                                        width:
                                            width * 0.95 - height * 0.025 * 2,
                                        height: height * 0.25 / 3,
                                        child: Container(
                                            width: width * 0.95 -
                                                height * 0.025 * 2,
                                            height: height * 0.25 / 3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Lottie.network(
                                                      "https://assets9.lottiefiles.com/private_files/lf30_kxkxycqz.json"),
                                                ),
                                                Text(
                                                  "Add",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize:
                                                        textScaleFactor * 35,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder: (c) {
                                          return addLocation(
                                              location,
                                              widget.currentUser,
                                              LatLng(currentLonaction.latitude,
                                                  currentLonaction.longitude));
                                        }));
                                      },
                                      style: NeumorphicStyle(
                                          color: Colors.grey.shade300,
                                          border: const NeumorphicBorder(
                                              color: Colors.blue, width: 5),
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                  const BorderRadius.all(
                                                      Radius.circular(40)))),
                                    ),
                                    SizedBox(
                                      height: height * 0.02,
                                    ),
                                    NeumorphicButton(
                                      child: Container(
                                        width:
                                            width * 0.95 - height * 0.025 * 2,
                                        height: height * 0.25 / 3,
                                        child: Container(
                                            width: width * 0.95 -
                                                height * 0.025 * 2,
                                            height: height * 0.25 / 3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Lottie.network(
                                                      "https://assets2.lottiefiles.com/packages/lf20_VmD8Sl.json"),
                                                ),
                                                Text(
                                                  "Delete ",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize:
                                                        textScaleFactor * 35,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                      onPressed: () {
                                        FirebaseDatabase.instance
                                            .ref("User")
                                            .child(widget.phoneNumber)
                                            .child("shortCuts")
                                            .set([]);
                                      },
                                      style: NeumorphicStyle(
                                          color: Colors.grey.shade300,
                                          border: const NeumorphicBorder(
                                              color: Colors.red, width: 5),
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                  const BorderRadius.all(
                                                      Radius.circular(40)))),
                                    )
                                  ],
                                ))),
                      ],
                      padding: EdgeInsets.only(
                          left: width * 0.035,
                          right: width * 0.035,
                          top: height * 0.02),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
