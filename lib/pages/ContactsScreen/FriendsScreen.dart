import 'dart:async';

import 'package:drivesafev2/pages/MapPageScreen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:telephony/telephony.dart';
import 'searchPeople.dart';
import 'AcceptFriendScreen.dart';
import 'PhoneNumber.dart';
import 'MainFriendScreen.dart';
import 'package:drivesafev2/models/User.dart';

class FriendScreen extends StatefulWidget {
  User currentUser;
  List<User> allUsers;
  bool remap;
  Map raw;
  FriendScreen(this.currentUser, this.allUsers, this.remap, this.raw);
  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  int index = 0;
  List<SmsMessage> messages = [];
  Color bottomColor = Colors.grey.shade300;
  void changeBottomColor(bool check) {
    if (check) {
      setState(() {
        bottomColor = Color.fromARGB(165, 0, 0, 0);
      });
    } else {
      setState(() {
        bottomColor = Colors.grey.shade300;
      });
    }
  }

  List<String> value = [];
  LatLng Clocation = LatLng(0, 0);
  Future<void> getLocation() async {
    var data = await Location.instance.getLocation();
    Clocation = LatLng(data.latitude!, data.longitude!);
  }

  void initFunction() async {
    List<String> answer = [];

    for (int i = 0; i < widget.currentUser.friends.length; i++) {
      List acceptedPhoneNumber = [];

      List value = widget.raw[widget.currentUser.friends[i]]
          ["locationSharingPeople"] as List;
      if (value != null) {
        acceptedPhoneNumber.addAll(value as List);
      }

      if (acceptedPhoneNumber == []) {
        continue;
      } else {
        if (acceptedPhoneNumber.contains(widget.currentUser.phoneNumber)) {
          answer.add(widget.currentUser.friends[i]);
        } else {
          continue;
        }
      }
      getLocation();
    }
    setState(() {
      value = answer;
    });
  }

  @override
  void getSMS() async {
    /*print(messages.length.toString() + "length");
    for (int i = 0; i < messages.length; i++) {
      for (int j = 0; j < widget.currentUser.numberList.length; j++) {
        if (widget.currentUser.numberList[j][2] == messages[i].address) {
          widget.currentUser.numberList.removeAt(j);
          break;
        }
      }*/

    //}

    /*FirebaseDatabase.instance
        .ref("User")
        .child(widget.currentUser.phoneNumber)
        .child("phoneNumbersChosen")
        .update({widget.currentUser.numberList});*/
  }

  void initState() {
    initFunction();
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String fullName;
    double textSize = MediaQuery.of(context).textScaleFactor;
    Color mainColor = Colors.grey.shade300;
    TextEditingController textEditingController = TextEditingController();
    TextEditingController textEditingController2 = TextEditingController();
    List<User> allUsers = widget.allUsers;
    List<Widget> pageList = [
      searchPeople(height - 60, width, textEditingController, textSize,
          widget.currentUser, changeBottomColor, widget.allUsers),
      PhoneNumberScreen(height - 60, width, textEditingController2, textSize,
          widget.currentUser),
      MainFriendScreen(height - 60, width, textEditingController2, textSize,
          widget.currentUser, widget.remap, allUsers, widget.raw),
      FriendsScreen(height - 60, width, textEditingController2, textSize,
          widget.currentUser),
      MapPageScreen(widget.currentUser, value, Clocation, widget.raw)
    ];
    return Container(
      color: Colors.blue,
      child: SafeArea(
        top: false,
        child: ClipRect(
          child: Scaffold(
            backgroundColor: mainColor,
            body: pageList[index],
            bottomNavigationBar: CurvedNavigationBar(
              items: <Widget>[
                Icon(
                  Icons.phone_android_rounded,
                  size: textSize * 40,
                  color: mainColor,
                ),
                Icon(
                  Icons.phone,
                  size: textSize * 40,
                  color: mainColor,
                ),
                Icon(
                  Icons.person,
                  size: textSize * 40,
                  color: mainColor,
                ),
                Icon(
                  Icons.people_alt,
                  size: textSize * 40,
                  color: mainColor,
                ),
                Icon(
                  Icons.map_rounded,
                  size: textSize * 40,
                  color: mainColor,
                ),
              ],
              onTap: (number) {
                index = number;
                if(index == 4){
                  bottomColor = Colors.blue;
                }else{
                  bottomColor = Colors.grey.shade300;
                }
                setState(() {
                  bottomColor;
                  index;
                });
              },
              color: Colors.blue,
              height: 60,
              backgroundColor: bottomColor,
            ),
          ),
        ),
      ),
    );
  }
}
