import 'package:drivesafev2/chooseCurrentLocation2.dart';
import 'package:drivesafev2/models/IdtoFile.dart';
import 'package:drivesafev2/models/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_latlong/flutter_latlong.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:lottie/lottie.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gMap;
import 'package:location/location.dart' as lot;

class savedLocations {
  String name;
  int iconId;
  String Address;
  gMap.LatLng destinationLocation;
  savedLocations(
      this.name, this.iconId, this.Address, this.destinationLocation);
}

/*
Location location;
  User user;
  LatLng currentLocation;
  bool isChooseScreen;
  LatLng destiantionLocation;
 */
class viewSavedLocations extends StatefulWidget {
  String phoneNumber;
  bool isChooseScreen;
  List data;
  viewSavedLocations(this.phoneNumber, this.isChooseScreen, this.data);
  @override
  State<viewSavedLocations> createState() => _viewSavedLocationsState();
}

class _viewSavedLocationsState extends State<viewSavedLocations> {
  @override
  Map<int, IconData> intToIcon = {
    1: Icons.school,
    2: Icons.shopping_bag_rounded,
    3: Icons.sports_soccer_outlined,
    4: Icons.movie,
    5: Icons.local_hospital,
    6: Icons.house,
    7: Icons.park_rounded,
    8: Icons.fastfood,
    9: Icons.add
  };
  List<savedLocations> shortCuts = [];
  List<savedLocations> displayShortCuts = [];
  TextEditingController textEditingController = new TextEditingController();
  void initStateFunction() async {
    DataSnapshot data = await FirebaseDatabase.instance
        .ref("User")
        .child(widget.phoneNumber)
        .child("shortCuts")
        .get();
    if (data.exists) {
      List shortCutsList = data.value as List;
      for (int i = 0; i < shortCutsList.length; i++) {
        shortCuts.add(savedLocations(
            shortCutsList[i]["GeneralData"]["name"],
            shortCutsList[i]["GeneralData"]["id"],
            (shortCutsList[i]["destinationLocation"]["Formatted"] as String),
            gMap.LatLng(shortCutsList[i]["destinationLocation"]["Latitude"],
                shortCutsList[i]["destinationLocation"]["Longitude"])));
      }
      displayShortCuts.addAll(shortCuts);
    }
    setState(() {
      shortCuts;
      displayShortCuts;
    });
  }

  void searchFunction() {}
  void initState() {
    initStateFunction();
    super.initState();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Container(
        height: height,
        width: width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            height: height * 0.07,
          ),
          Container(
            height: height * 0.08,
            width: width * 0.95,
            child: Row(
              children: [
                Neumorphic(
                  child: Container(
                      width: width * 0.95,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                            fontSize: textSize * 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue),
                        textAlign: TextAlign.center,
                        onChanged: (text) {
                          searchFunction();
                        },
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: width * 0.03),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                color: Colors.blue,
                                iconSize: textSize * 40,
                              ),
                            ),
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: width * 0.03),
                              child: IconButton(
                                icon: Icon(CupertinoIcons.search),
                                color: Colors.blue,
                                iconSize: textSize * 40,
                                onPressed: () {},
                              ),
                            ),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100))),
                            contentPadding: EdgeInsets.only(
                              bottom: height * 0.01,
                              top: height * 0.01,
                              left: 0,
                            )),
                        controller: textEditingController,
                      )),
                  style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.roundRect(
                          const BorderRadius.all(Radius.circular(100))),
                      depth: 15,
                      color: Colors.grey.shade300,
                      border: NeumorphicBorder(color: Colors.blue, width: 3),
                      lightSource: LightSource.topLeft,
                      shape: NeumorphicShape.concave),
                ),
              ],
            ),
          ),
          Expanded(
              child: Container(
                  width: width * 0.95,
                  child: displayShortCuts.length == 0
                      ? Lottie.network(
                          "https://assets8.lottiefiles.com/private_files/lf30_zncbuxbi.json")
                      : ListView(
                          children: [
                            ...displayShortCuts.map((e) {
                              print(e.iconId);
                              return InkWell(
                                onTap: () async {
                                  var ting = await FirebaseDatabase.instance
                                      .ref("User")
                                      .child(widget.phoneNumber)
                                      .child("Settings")
                                      .get();
                                  Map datA = ting.value as Map;
                                  print(datA);
                                  Settings currentUserSettings = Settings();
                                  currentUserSettings.jsonToSettings(datA);
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (c) {
                                    return chooseCurrentLocationScreen1(
                                        widget.data[0],
                                        widget.data[1],
                                        widget.data[2],
                                        widget.data[3],
                                        e.destinationLocation, 
                                        currentUserSettings
                                        );
                                  }));
                                },
                                child: Container(
                                  height: height * 0.13,
                                  margin: EdgeInsets.only(
                                      right: width * 0.025,
                                      left: width * 0.025,
                                      bottom: height * 0.02),
                                  child: Neumorphic(
                                    child: Container(
                                      child: Row(
                                        children: [
                                          SizedBox(width: width * 0.03),
                                          CircleAvatar(
                                              radius: height * 0.05,
                                              backgroundColor: Colors.blue,
                                              child: Center(
                                                child: CircleAvatar(
                                                  radius: height * 0.045,
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                  child: NeumorphicIcon(
                                                    intToIcon[e.iconId]!,
                                                    size: textSize * 50,
                                                    style: NeumorphicStyle(
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                          SizedBox(width: width * 0.01),
                                          Container(
                                            width: width * 0.63,
                                            margin: EdgeInsets.only(
                                                right: width * 0.02),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.name,
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: textSize * 20),
                                                ),
                                                Text(
                                                  e.Address,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    style: NeumorphicStyle(
                                        color: Colors.grey.shade300,
                                        depth: 5,
                                        shadowLightColor: Colors.transparent,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            const BorderRadius.all(
                                                Radius.circular(25))),
                                        border: const NeumorphicBorder(
                                            color: Colors.blue, width: 5)),
                                  ),
                                ),
                              );
                            }).toList()
                          ],
                        )))
        ]),
      ),
    );
  }
}
