// ignore_for_file: unrelated_type_equality_checks

import 'dart:math';
import 'dart:ui';

import 'package:drivesafev2/models/settings.dart';
import 'package:drivesafev2/pages/LogInPage.dart';
import 'package:flutter/material.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gMap;
import 'package:latlong/latlong.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:lottie/lottie.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'drivingScreen.dart';
import 'dataWidgetMapScreen.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

class MapPageScreen extends StatefulWidget {
  @override
  User currentUser;
  List<String> LocationSharingUsers;
  gMap.LatLng currentLocation;
  Map allUsers;
  MapPageScreen(this.currentUser, this.LocationSharingUsers,
      this.currentLocation, this.allUsers);
  _MapPageScreenState createState() => _MapPageScreenState();
}

class _MapPageScreenState extends State<MapPageScreen>
    with SingleTickerProviderStateMixin {
  @override
  int timeCurrentData = 0;
  List<blinkSession> primaryData = [];
  late gMap.GoogleMapController controller;
  int currentIndex = 0;
  Settings currentUserSettings = Settings();
  List<StreamSubscription<DatabaseEvent>> listeners = [];
  Map<String, int> ProblemAreas = {};
  Map allData = {};
  late TabController tabBarController;
  late Duration lastWarnignTime;
  bool numberClickedOn = false;
  bool flag = false;
  Location location = new Location();
  bool hasPermission = false;
  bool showingBlinkHistoryPage = false;
  String chosenNumber = "";
  String weatherDisplayText = "Show Weather";
  bool animationDone = false;
  double bottomContainerHeight = 0.45;
  List<blinkSession> sleepingDataList = [];
  List<blinkSession> blinkingDataList = [];
  List<speedingHistoryVal> speedingHistoryList = [];
  String speedingTime = "";
  Map<String, List<weatherLocation>> weatherDestinationDataMap = {};
  Map<String, LocationData> locationData = {};
  Map<String, startingData> arrivalData = {};
  String warning = "";
  List allCarCrashAlerts = [];
  Map<String, destinationData> destinationDataMap = {};
  Map<String, generalDestinationData> generalDestinationDataMap = {};
  Map<String, bool> currentlyIsDrivingMap = {};
  late gMap.BitmapDescriptor cloudyDescriptor;
  late gMap.BitmapDescriptor mcloudyDescriptor;
  late gMap.BitmapDescriptor lastMeasuredDescriptor;
  late gMap.BitmapDescriptor fastBreakDescriptor;
  late gMap.BitmapDescriptor carCrashDescriptor;
  Timer? timer2;
  late gMap.BitmapDescriptor sunDescriptor;
  late gMap.BitmapDescriptor rainingDescriptor;
  late gMap.BitmapDescriptor thunderDescriptor;
  int chosenSpeedLimit = -1;
  late gMap.BitmapDescriptor windyDescriptor;
  late gMap.BitmapDescriptor sleepWarningDescriptor;
  late StreamSubscription listenThing;
  late gMap.BitmapDescriptor blinkWarningDescriptor;
  late gMap.BitmapDescriptor speedingWarningDescriptor;
  List<LocationData> locationDataList = [];
  List<startingData> startingDataList = [];
  List<destinationData> destinationDataList = [];
  List<generalDestinationData> generalDestinationDataList = [];
  List<gMap.Marker> weatherDestinationDataList = [];
  String title = "";
  List<Widget> weatherDestinationDataListShow = [];
  late gMap.BitmapDescriptor suvDescriptor;
  late gMap.BitmapDescriptor
      destinationDescriptor; //assets/images/pin-map-bf.png
  late gMap.BitmapDescriptor
      destinationDescriptorBW; //assets/images/pin-map-bf.png
  void onLongTap(LatLng location) {
    controller.animateCamera(gMap.CameraUpdate.newCameraPosition(
        gMap.CameraPosition(
            target: gMap.LatLng(location.latitude, location.longitude),
            bearing: 0,
            zoom: 13)));
  }

  Future<void> initStateFunction() async {
    tabBarController = TabController(length: 9, vsync: this);
    suvDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/suv-car.png",
    );
    destinationDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/pin-map.png",
    );
    destinationDescriptorBW = await gMap.BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/pin-map-bf.png",
    );
    sunDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/small_images/day/sun.png");
    cloudyDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/small_images/day/cloudy.png");
    mcloudyDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/small_images/day/mild_cloudy.png");
    rainingDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/small_images/day/raining.png");
    thunderDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/small_images/day/thunder.png");
    windyDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/small_images/day/windy.png");
    sleepWarningDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/sleepWarning.png");
    blinkWarningDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/blink.png");
    speedingWarningDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/speeding.png");
    lastMeasuredDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/lastMeasured.png");
    fastBreakDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/breaks1.png");
    carCrashDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/roadIncidents/carCrash.png");
    print("hereasdfasdf");
  }

  void initState() {
    initStateFunction();
    tabBarController.addListener(() {
      setState(() {
        currentIndex = tabBarController.index;
      });
      print(tabBarController.index);
      print(warning);
    });
    timer2 = Timer.periodic(Duration(seconds: 1), (timer) {
      if (numberClickedOn) {
        LocationData cur = locationData[chosenNumber]!;
        if (cur.cloaseEyeHistory.isNotEmpty) {
          List<blinkSession> things = cur.cloaseEyeHistory;
          Duration lastWarnignTime1 = DateTime.now()
              .difference(cur
                  .cloaseEyeHistory[cur.cloaseEyeHistory.length - 1].timeEnded)
              .abs();
          if (things[things.length - 1].contintuing == false) {
            String tempwarning = "";
            if (lastWarnignTime1.inDays > 0) {
              tempwarning =
                  tempwarning + lastWarnignTime1.inDays.toString() + " Days ";
            }
            if (lastWarnignTime1.inHours > 0) {
              tempwarning = tempwarning +
                  (lastWarnignTime1.inHours % 24).toString() +
                  " Hrs ";
            }
            if (lastWarnignTime1.inMinutes > 0) {
              tempwarning = tempwarning +
                  (lastWarnignTime1.inMinutes % 60).toString() +
                  " Mins ";
            }
            if (lastWarnignTime1.inHours > 0) {
              tempwarning = tempwarning +
                  (lastWarnignTime1.inSeconds % 60).toString() +
                  " Secs ";
            }
            if (warning != tempwarning) {
              setState(() {
                warning = tempwarning;
              });
            }
          }
        }
      }
    });

    listenThing =
        FirebaseDatabase.instance.ref("location").onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        setState(() {
          allData = data;
        });
        for (int character = 0;
            character < widget.LocationSharingUsers.length;
            character++) {
          if (data.containsKey(widget.LocationSharingUsers[character])) {
            Map locationDataCur = (data[widget.LocationSharingUsers[character]]
                as Map)["travelData"] as Map;
            currentlyIsDrivingMap[widget.LocationSharingUsers[character]] =
                (data[widget.LocationSharingUsers[character]]
                    as Map)["isDriving"];
            generalDestinationDataMap[widget.LocationSharingUsers[character]] =
                generalDestinationData(
                    locationDataCur["PollyLine"],
                    locationDataCur["northEastLat"].toDouble(),
                    locationDataCur["northEastLong"].toDouble(),
                    locationDataCur["ArrivalsTime"],
                    locationDataCur["distance"],
                    locationDataCur["southWestLong"].toDouble(),
                    locationDataCur["southWestLat"].toDouble(),
                    widget.LocationSharingUsers[character],
                    locationDataCur["DuartionTime"]);
            List locationDataCur1 =
                (data[widget.LocationSharingUsers[character]]
                    as Map)["weather"];
            List<weatherLocation> locationDataCur23 = [];
            if (chosenNumber == widget.LocationSharingUsers[character]) {
              weatherDestinationDataListShow = [];
            }
            print(locationDataCur1);
            if (locationDataCur1 != null) {
              for (int i = 0; i < locationDataCur1.length; i++) {
                Map weatherData = locationDataCur1[i];
                weather data = weather(
                    weatherData["time"],
                    weatherData["temp"].toDouble(),
                    weatherData["feel_like"].toDouble(),
                    weatherData["humidity"].toDouble(),
                    weatherData["id"].toInt(),
                    weatherData["type"],
                    weatherData["description"],
                    weatherData["windSpeed"].toDouble(),
                    weatherData["windDeg"].toDouble(),
                    weatherData["gust"].toDouble(),
                    weatherData["visibility"].toDouble(),
                    weatherData["cityName"],
                    weatherData["groundLevel"].toDouble());
                weatherLocation dataWeather = weatherLocation(
                    LatLng(
                        weatherData["locationLat"], weatherData["locationLon"]),
                    data,
                    data.id.toString());
                if (chosenNumber == widget.LocationSharingUsers[character]) {
                  String link = "";
                  if (data.id == 2) {
                    link = "assets/images/big_images/morning/thunder.png";
                  } else if (data.id == 3) {
                    link = "assets/images/big_images/morning/raining.png";
                  } else if (data.id == 5) {
                    link = "assets/images/big_images/morning/raining.png";
                  } else if (data.id == 7) {
                    link = "assets/images/big_images/morning/windy.png";
                  } else if (data.id == 8) {
                    link = "assets/images/big_images/morning/sun.png";
                  } else if (data.id == 9) {
                    link = "assets/images/big_images/morning/mild_cloudy.png";
                  } else {
                    link = "assets/images/big_images/morning/cloudy.png";
                  }
                  weatherDestinationDataListShow.add(weatherShowWidget(
                    link,
                    data,
                    LatLng(dataWeather.location.latitude,
                        dataWeather.location.longitude),
                    dataWeather.weatherData.description,
                    onLongTap,
                  ));
                }
                locationDataCur23.add(dataWeather);
                print(weatherData["id"]);
              }
            }

            print(1);
            weatherDestinationDataMap[widget.LocationSharingUsers[character]] =
                locationDataCur23;
            print(1);
            print((data[widget.LocationSharingUsers[character]]
                as Map)["destinationLocation"] as Map);
            locationDataCur = (data[widget.LocationSharingUsers[character]]
                as Map)["destinationLocation"] as Map;
            print(1);
            destinationDataMap[widget.LocationSharingUsers[character]] =
                destinationData(
                    locationDataCur["Country"],
                    locationDataCur["State"],
                    locationDataCur["City"],
                    locationDataCur["Street"],
                    locationDataCur["PostalCode"],
                    locationDataCur["Formatted"],
                    locationDataCur["Latitude"].toDouble(),
                    locationDataCur["Longitude"].toDouble(),
                    widget.LocationSharingUsers[character]);
            print(1);
            print((data[widget.LocationSharingUsers[character]]
                as Map)["startingLocation"] as Map);
            locationDataCur = (data[widget.LocationSharingUsers[character]]
                as Map)["startingLocation"] as Map;
            print(1);
            arrivalData[widget.LocationSharingUsers[character]] = startingData(
                locationDataCur["Country"],
                locationDataCur["State"],
                locationDataCur["City"],
                locationDataCur["Street"],
                locationDataCur["PostalCode"],
                locationDataCur["Formatted"],
                locationDataCur["Latitude"].toDouble(),
                locationDataCur["Longitude"].toDouble(),
                widget.LocationSharingUsers[character]);
            print(1);
            locationDataCur = (data[widget.LocationSharingUsers[character]]
                as Map)["locationData"] as Map;
            print(1);
            int averageBlinksPerMinute = 0;
            int blinksPerMinute = 0;

            List<blinkSession> blink = [];
            List<blinkSession> sleep = [];
            List<speedingHistoryVal> speed = [];
            if (locationDataCur.containsKey("blinksPerMinute")) {
              blinksPerMinute = locationDataCur["blinksPerMinute"];
            }
            if (locationDataCur.containsKey("averageBlinksPerMinute")) {
              averageBlinksPerMinute =
                  locationDataCur["averageBlinksPerMinute"];
            }
            if (locationDataCur.containsKey("closeProblemHistory")) {
              List tempList = locationDataCur["closeProblemHistory"];
              for (int i = 0; i < tempList.length; i++) {
                sleep.add(blinkSession(
                  DateTime.parse(tempList[i]["timeStarted"]),
                  DateTime.parse(tempList[i]["timeEnded"]),
                  tempList[i]["contitnue"],
                  tempList[i]["latitude"],
                  tempList[i]["longitude"],
                  tempList[i]["address"],
                ));
              }
            }
            if (locationDataCur.containsKey("speedingHistory")) {
              List tempList = locationDataCur["speedingHistory"];
              for (int i = 0; i < tempList.length; i++) {
                print(tempList[i]["latitude"]);
                print(tempList[i]);
                print("sleedf");
                speed.add(speedingHistoryVal(
                  tempList[i]["speed"].toDouble(),
                  tempList[i]["speedLimit"].toDouble(),
                  DateTime.parse(tempList[i]["DateTime"]),
                  tempList[i]["state"],
                  tempList[i]["Address"],
                  tempList[i]["latitude"],
                  tempList[i]["longitude"],
                ));
              }
            }
            warning = "";
            if (sleep.isNotEmpty) {
              if (sleep[sleep.length - 1].contintuing) {
                setState(() {
                  warning = "Right Now";
                });
                ProblemAreas[widget.LocationSharingUsers[character]] = 1;
              } else {
                lastWarnignTime = DateTime.now()
                    .difference(sleep[sleep.length - 1].timeEnded)
                    .abs();
                warning = "";
                if (lastWarnignTime.inDays > 0) {
                  warning =
                      warning + lastWarnignTime.inDays.toString() + " Days ";
                }
                if (lastWarnignTime.inHours > 0) {
                  warning = warning +
                      (lastWarnignTime.inHours % 24).toString() +
                      " Hrs ";
                }
                if (lastWarnignTime.inMinutes > 0) {
                  warning = warning +
                      (lastWarnignTime.inMinutes % 60).toString() +
                      " Mins ";
                }
                if (lastWarnignTime.inHours > 0) {
                  warning = warning +
                      (lastWarnignTime.inSeconds % 60).toString() +
                      " Secs ";
                }
              }
            } else {
              warning = "Not Warned Yet";
            }

            if (locationDataCur.containsKey("blinkProblemHistory")) {
              List tempList1 = locationDataCur["blinkProblemHistory"];
              for (int i = 0; i < tempList1.length; i++) {
                blink.add(blinkSession(
                  DateTime.parse(tempList1[i]["timeStarted"]),
                  DateTime.parse(tempList1[i]["timeEnded"]),
                  tempList1[i]["contitnue"],
                  tempList1[i]["latitude"],
                  tempList1[i]["longitude"],
                  tempList1[i]["address"],
                ));
              }
            }
            if (blink.isNotEmpty) {
              if (blink[blink.length - 1].contintuing) {
                setState(() {
                  warning = "Right Now";
                });
                ProblemAreas[widget.LocationSharingUsers[character]] = 2;
              } else {
                if (lastWarnignTime.compareTo(DateTime.now()
                        .difference(blink[blink.length - 1].timeEnded)
                        .abs()) <
                    1) {
                  warning = "";
                  lastWarnignTime = DateTime.now()
                      .difference(blink[blink.length - 1].timeEnded)
                      .abs();
                  if (lastWarnignTime.inDays > 0) {
                    warning =
                        warning + lastWarnignTime.inDays.toString() + " Days ";
                  }
                  if (lastWarnignTime.inHours > 0) {
                    warning = warning +
                        (lastWarnignTime.inDays % 24).toString() +
                        " Hrs ";
                  }
                  if (lastWarnignTime.inMinutes > 0) {
                    warning = warning +
                        (lastWarnignTime.inMinutes % 60).toString() +
                        " Mins ";
                  }
                  if (lastWarnignTime.inSeconds > 0) {
                    warning = warning +
                        (lastWarnignTime.inSeconds % 60).toString() +
                        " Secs ";
                  }
                } else if (warning == "") {
                  warning = warning +
                      (lastWarnignTime.inSeconds % 60).toString() +
                      " Secs ";
                }
              }
            } else {
              if (warning == "") {
                warning = "Not Warned Yet";
              }
            }
            String time = "";
            DateTime t = DateTime.parse(locationDataCur["time"]);
            print(DateTime.now().toString());
            print("what do yu want");
            time = time + t.hour.toString();
            if (t.minute <= 9) {
              time = time + ":0" + t.minute.toString();
            } else {
              time = time + ":" + t.minute.toString();
            }
            List hardDecelerationLists = [];
            print(locationDataCur["hardDecelerationList"]);
            if (locationDataCur.containsKey("hardDecelerationList")) {
              hardDecelerationLists
                  .addAll(locationDataCur["hardDecelerationList"]);
              ProblemAreas[widget.LocationSharingUsers[character]] = 4;
            }
            Map crashAlerts = {};
            if (locationDataCur.containsKey("crashAlerts")) {
              crashAlerts = locationDataCur["crashAlerts"];
              allCarCrashAlerts.add(locationDataCur);
              ProblemAreas[widget.LocationSharingUsers[character]] = 5;
            }
            if (locationDataCur["faceDetected"]) {
              warning = "No Face Detected";
            }
            setState(() {
              warning;
            });
            locationData[widget.LocationSharingUsers[character]] = LocationData(
                locationDataCur["latitude"],
                locationDataCur["longitude"],
                locationDataCur["speed"].toDouble(),
                locationDataCur["altitude"].toDouble(),
                locationDataCur["firstName"],
                locationDataCur["lastName"],
                locationDataCur["city"],
                locationDataCur["Gx"].toDouble(),
                locationDataCur["Gy"].toDouble(),
                locationDataCur["Gz"].toDouble(),
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                locationDataCur["formattedAddress"],
                locationDataCur["speedLimit"],
                locationDataCur["state"],
                locationDataCur["description"],
                time,
                locationDataCur["temp"].toDouble(),
                locationDataCur["windSpeed"].toDouble(),
                locationDataCur["feel_like"].toDouble(),
                locationDataCur["humidity"].toDouble(),
                locationDataCur["id"],
                locationDataCur["windDeg"].toDouble(),
                locationDataCur["gust"].toDouble(),
                locationDataCur["visibility"].toDouble(),
                locationDataCur["cityName"],
                locationDataCur["groundLevel"].toDouble(),
                widget.LocationSharingUsers[character],
                averageBlinksPerMinute,
                blink,
                blinksPerMinute,
                blink.length,
                sleep.length,
                sleep,
                speed,
                locationDataCur["callsBlocked"],
                locationDataCur["smsBlocked"],
                locationDataCur["warningsGiven"],
                locationDataCur["crashed"],
                crashAlerts,
                hardDecelerationLists,
                locationDataCur["faceDetected"]);
            LocationData locationCheck =
                locationData[widget.LocationSharingUsers[character]]!;
            if (locationCheck.crashed) {
              ProblemAreas[widget.LocationSharingUsers[character]] = 2;
            } else if (locationCheck.cloaseEyeHistory.isNotEmpty &&
                locationCheck
                        .cloaseEyeHistory[
                            locationCheck.cloaseEyeHistory.length - 1]
                        .contintuing ==
                    true) {
              ProblemAreas[widget.LocationSharingUsers[character]] = 1;
            } else if (locationCheck.blinkEyeHistory.isNotEmpty &&
                locationCheck
                        .cloaseEyeHistory[
                            locationCheck.blinkEyeHistory.length - 1]
                        .contintuing ==
                    true) {
              ProblemAreas[widget.LocationSharingUsers[character]] = 0;
            } else if (locationCheck.speed > locationCheck.speedLimit + 3) {
              ProblemAreas[widget.LocationSharingUsers[character]] = 3;
            } else {
              ProblemAreas[widget.LocationSharingUsers[character]] = -1;
            }
            if (currentlyIsDrivingMap[widget.LocationSharingUsers[character]] ==
                false) {
              ProblemAreas[chosenNumber] = -1;
            }

            print(averageBlinksPerMinute);
            print(blink);
            print(sleep);
          }
        }
        destinationDataList = [];
        startingDataList = [];
        locationDataList = [];
        generalDestinationDataList = [];
        destinationDataMap.forEach((x, y) {
          destinationDataList.add(y);
        });
        arrivalData.forEach((x, y) {
          startingDataList.add(y);
        });
        locationData.forEach((x, y) {
          locationDataList.add(y);
        });
        generalDestinationDataMap.forEach((x, y) {
          generalDestinationDataList.add(y);
        });
        if (chosenNumber != "") {
          speedingHistoryList = [];
          blinkingDataList = [];
          sleepingDataList = [];
          speedingHistoryList
              .addAll(locationData[chosenNumber]!.speedingHistory);
          blinkingDataList.addAll(locationData[chosenNumber]!.blinkEyeHistory);
          sleepingDataList.addAll(locationData[chosenNumber]!.cloaseEyeHistory);
        }
        setState(() {
          destinationDataMap;
          arrivalData;
          warning;
          locationData;
          ProblemAreas;
          generalDestinationDataList;
          destinationDataList;
          generalDestinationDataMap;
          weatherDestinationDataMap;
          speedingHistoryList;
          blinkingDataList;
          sleepingDataList;
        });
      }
    });

    super.initState();
  }

  void dispose() {
    timer2!.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Stack(children: [
        InkWell(
          onDoubleTap: () {
            if (chosenNumber.isNotEmpty) {
              controller.animateCamera(
                gMap.CameraUpdate.newLatLngBounds(
                    gMap.LatLngBounds(
                        northeast: gMap.LatLng(
                            generalDestinationDataMap[chosenNumber]!
                                .northEastLat,
                            generalDestinationDataMap[chosenNumber]!
                                .northEastLong),
                        southwest: gMap.LatLng(
                            generalDestinationDataMap[chosenNumber]!
                                .southWestLat,
                            generalDestinationDataMap[chosenNumber]!
                                .southWestLong)),
                    height * 0.2),
              );
            }
          },
          child: Container(
              height: height,
              width: width,
              child: gMap.GoogleMap(
                  mapType: gMap.MapType.hybrid,
                  buildingsEnabled: true,
                  onMapCreated: ((c1ontroller) {
                    setState(() {
                      controller = c1ontroller;
                    });
                  }),
                  markers: {
                    ...allCarCrashAlerts.map((e) {
                      return gMap.Marker(
                          markerId: gMap.MarkerId(e["time"] + "crash"),
                          icon: carCrashDescriptor,
                          position: gMap.LatLng(e["latitude"], e["longitude"]),
                          zIndex: 200);
                    }),
                    if (chosenNumber != "") ...weatherDestinationDataList,
                    if (chosenNumber != "" && currentIndex == 8)
                      ...locationData[chosenNumber]!.hardDeceleration.map((e) {
                        return gMap.Marker(
                            markerId: gMap.MarkerId(e["time"]),
                            position: gMap.LatLng(e["lat"], e["lon"]),
                            zIndex: 110,
                            icon: fastBreakDescriptor);
                      }),
                    if (chosenNumber != "")
                      gMap.Marker(
                          markerId: gMap.MarkerId("Last Measured"),
                          position: gMap.LatLng(
                           35.497870, -93.666172
                          ),
                          zIndex: 97,
                          icon: lastMeasuredDescriptor),
                    ...sleepingDataList.map((e) {
                      return gMap.Marker(
                        markerId: gMap.MarkerId(
                            e.latitude.toString() + e.longitude.toString()),
                        zIndex: 99,
                        position: gMap.LatLng(e.latitude, e.longitude),
                        infoWindow: gMap.InfoWindow(title: e.address),
                        icon: sleepWarningDescriptor,
                      );
                    }),
                    ...blinkingDataList.map((e) {
                      return gMap.Marker(
                        markerId: gMap.MarkerId(
                            e.latitude.toString() + e.longitude.toString()),
                        zIndex: 98,
                        position: gMap.LatLng(e.latitude, e.longitude),
                        infoWindow: gMap.InfoWindow(title: e.address),
                        icon: blinkWarningDescriptor,
                      );
                    }),
                    ...startingDataList.map(
                      (data) {
                        print(data.number);
                        print(chosenNumber);
                        if (currentlyIsDrivingMap[data.number]! == false) {
                          if (data.number != chosenNumber) {
                            return gMap.Marker(
                                alpha: 0.7,
                                icon: destinationDescriptorBW,
                                position:
                                    gMap.LatLng(data.latitude, data.longitude),
                                markerId:
                                    gMap.MarkerId(data.latitude.toString()));
                          } else {
                            print("here");
                            return gMap.Marker(
                                icon: destinationDescriptorBW,
                                position:
                                    gMap.LatLng(data.latitude, data.longitude),
                                markerId: gMap.MarkerId(
                                    data.latitude.toString() +
                                        getRandomString(15)));
                          }
                        } else {
                          if (data.number != chosenNumber) {
                            return gMap.Marker(
                                alpha: 0.5,
                                icon: destinationDescriptor,
                                position:
                                    gMap.LatLng(data.latitude, data.longitude),
                                markerId:
                                    gMap.MarkerId(data.latitude.toString()));
                          } else {
                            print("here");
                            return gMap.Marker(
                                icon: destinationDescriptor,
                                position:
                                    gMap.LatLng(data.latitude, data.longitude),
                                markerId: gMap.MarkerId(
                                    data.latitude.toString() +
                                        getRandomString(15)));
                          }
                        }
                      },
                    ),
                    ...locationDataList.map((data) {
                      print(data.latitude);
                      print(data.longitude);
                      print(data.number);
                      print(chosenNumber);
                      if (data.number != chosenNumber) {
                        return gMap.Marker(
                            alpha: 0.5,
                            zIndex: 500,
                            icon: suvDescriptor,
                            position:
                                gMap.LatLng(data.latitude, data.longitude),
                            markerId: gMap.MarkerId(data.number.toString()));
                      } else {
                        print("here234");
                        var string = "what";
                        setState(() {
                          locationDataList;
                        });
                        
                        return gMap.Marker(
                            icon: suvDescriptor,
                            alpha: 1,
                            zIndex: 11000,
                            position:
                                gMap.LatLng(data.latitude, data.longitude),
                            markerId: gMap.MarkerId(data.number.toString()  +
                                        getRandomString(15)));
                      }
                    }).toList(),
                    ...speedingHistoryList.map((e) {
                      print(speedingHistoryList);
                      return gMap.Marker(
                          zIndex: 100,
                          markerId: gMap.MarkerId(
                              "a;sldkfja;sdlkfja;sdlfkja;sldkfj" +
                                  e.latitude.toString() +
                                  e.longitude.toString() +
                                  'sleep'),
                          onTap: () {
                            int ih = 0;
                            for (ih = 0;
                                ih < speedingHistoryList.length;
                                ih++) {
                              if (speedingHistoryList[ih].latitude ==
                                      e.latitude &&
                                  speedingHistoryList[ih].longitude ==
                                      e.longitude) {
                                break;
                              }
                            }
                            DateTime currentTime = e.time;
                            speedingTime = "";
                            String end = "PM";
                            if (currentTime.hour <= 12) {
                              end = "AM";
                              speedingTime =
                                  speedingTime + currentTime.hour.toString();
                            } else {
                              speedingTime = speedingTime +
                                  (currentTime.hour - 12).toString();
                            }
                            if (currentTime.minute < 10) {
                              speedingTime = speedingTime +
                                  ":0" +
                                  currentTime.minute.toString();
                            } else {
                              speedingTime = speedingTime +
                                  ":" +
                                  currentTime.minute.toString();
                            }
                            speedingTime = speedingTime + " " + end;
                            setState(() {
                              chosenSpeedLimit = ih;
                              speedingTime;
                            });
                          },
                          alpha: 1,
                          icon: speedingWarningDescriptor,
                          position: gMap.LatLng(e.latitude, e.longitude));
                    }),
                    ...destinationDataList.map((data) {
                      if (currentlyIsDrivingMap[data.number]! == false) {
                        if (data.number != chosenNumber) {
                          return gMap.Marker(
                              alpha: 0.5,
                              icon: destinationDescriptorBW,
                              position:
                                  gMap.LatLng(data.latitude, data.longitude),
                              markerId:
                                  gMap.MarkerId(data.latitude.toString()));
                        } else {
                          return gMap.Marker(
                              icon: destinationDescriptorBW,
                              position:
                                  gMap.LatLng(data.latitude, data.longitude),
                              markerId: gMap.MarkerId(data.latitude.toString() +
                                  getRandomString(15)));
                        }
                      } else {
                        if (data.number != chosenNumber) {
                          return gMap.Marker(
                              alpha: 0.5,
                              icon: destinationDescriptor,
                              position:
                                  gMap.LatLng(data.latitude, data.longitude),
                              markerId:
                                  gMap.MarkerId(data.latitude.toString()));
                        } else {
                          return gMap.Marker(
                              icon: destinationDescriptor,
                              position:
                                  gMap.LatLng(data.latitude, data.longitude),
                              markerId: gMap.MarkerId(data.latitude.toString() +
                                  getRandomString(15)));
                        }
                      }
                    }),
                  },
                  polylines: {
                    ...generalDestinationDataList.map((data) {
                      if (currentlyIsDrivingMap[data.number]! == false) {
                        if (data.number != chosenNumber) {
                          return gMap.Polyline(
                              polylineId: gMap.PolylineId(data.pollyLine),
                              color: Color.fromARGB(145, 158, 158, 158),
                              width: 8,
                              points: PolylinePoints()
                                  .decodePolyline(data.pollyLine)
                                  .map((e) =>
                                      gMap.LatLng(e.latitude, e.longitude))
                                  .toList());
                        } else {
                          return gMap.Polyline(
                              polylineId: gMap.PolylineId(data.pollyLine),
                              color: Colors.grey,
                              width: 8,
                              points: PolylinePoints()
                                  .decodePolyline(data.pollyLine)
                                  .map((e) =>
                                      gMap.LatLng(e.latitude, e.longitude))
                                  .toList());
                        }
                      } else {
                        if (data.number != chosenNumber) {
                          return gMap.Polyline(
                              polylineId: gMap.PolylineId(data.pollyLine),
                              color: Color.fromARGB(145, 33, 149, 243),
                              width: 8,
                              points: PolylinePoints()
                                  .decodePolyline(data.pollyLine)
                                  .map((e) =>
                                      gMap.LatLng(e.latitude, e.longitude))
                                  .toList());
                        } else {
                          return gMap.Polyline(
                              polylineId: gMap.PolylineId(data.pollyLine),
                              color: Color.fromARGB(255, 33, 149, 243),
                              width: 8,
                              points: PolylinePoints()
                                  .decodePolyline(data.pollyLine)
                                  .map((e) =>
                                      gMap.LatLng(e.latitude, e.longitude))
                                  .toList());
                        }
                      }
                    }).toList()
                  },
                  initialCameraPosition: gMap.CameraPosition(
                      zoom: 10,
                      target: gMap.LatLng(widget.currentLocation.latitude,
                          widget.currentLocation.longitude)))),
        ),
        Positioned(
          bottom: height * 0.01,
          left: width * 0.025,
          child: InkWell(
            onDoubleTap: () {
              setState(() {
                if (bottomContainerHeight == 0.1) {
                  bottomContainerHeight = 0.45;
                } else {
                  bottomContainerHeight = 0.1;
                }
              });
            },
            child: AnimatedContainer(
              width: width * 0.95,
              duration: const Duration(
                seconds: 1,
              ),
              height: bottomContainerHeight * height,
              child: Neumorphic(
                  child: bottomContainerHeight == 0.45
                      ? Container(
                          child: numberClickedOn
                              ? Container(
                                  width: 0.95,
                                  height: height * 0.45,
                                  child: Stack(
                                    children: [
                                      TabBarView(
                                          controller: tabBarController,
                                          children: [
                                            Container(
                                                width: 0.95,
                                                height: height * 0.45,
                                                decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade300),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        height: height * 0.01),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            height:
                                                                height * 0.1,
                                                            child: Lottie.network(
                                                                "https://assets8.lottiefiles.com/packages/lf20_mofrbkmc.json")),
                                                        Text("Route Data",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    textScaleFactor *
                                                                        30)),
                                                      ],
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                            width: width * 0.9,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  width: width *
                                                                      0.95,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: width * 0.01),
                                                                        child:
                                                                            Text(
                                                                          "Starting Address: ",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontSize: textScaleFactor * 15,
                                                                              fontWeight: FontWeight.w800),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: width * 0.01),
                                                                        child:
                                                                            Text(
                                                                          arrivalData[chosenNumber]!
                                                                              .formattedAddress
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontSize: textScaleFactor * 15,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  margin: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          width *
                                                                              0.05),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.01),
                                                                Container(
                                                                  width: width *
                                                                      0.95,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: width * 0.01),
                                                                        child:
                                                                            Text(
                                                                          "Destination Data: ",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontSize: textScaleFactor * 15,
                                                                              fontWeight: FontWeight.w800),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: width * 0.01),
                                                                        child:
                                                                            Text(
                                                                          destinationDataMap[chosenNumber]!
                                                                              .formattedAddress
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontSize: textScaleFactor * 15,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  margin: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          width *
                                                                              0.05),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.01),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          if (timeCurrentData ==
                                                                              1) {
                                                                            timeCurrentData =
                                                                                0;
                                                                          } else {
                                                                            timeCurrentData =
                                                                                1;
                                                                          }
                                                                        });
                                                                      },
                                                                      child: Container(
                                                                          height: height * 0.15,
                                                                          width: width * 0.35,
                                                                          child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Text("Time", style: TextStyle(fontSize: textScaleFactor * 30, color: Colors.blue, fontWeight: FontWeight.w800)),
                                                                              Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Container(
                                                                                    width: width * 0.25,
                                                                                    padding: EdgeInsets.all(width * 0.01),
                                                                                    child: FittedBox(
                                                                                        child: Text(
                                                                                          timeCurrentData == 1 ? generalDestinationDataMap[chosenNumber]!.totalTime : generalDestinationDataMap[chosenNumber]!.arrivalTime,
                                                                                          style: TextStyle(
                                                                                            color: Colors.blue,
                                                                                            fontWeight: FontWeight.w700,
                                                                                          ),
                                                                                        ),
                                                                                        fit: BoxFit.contain),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            border:
                                                                                Border.all(
                                                                              color: Colors.blue,
                                                                              width: 5,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(15)),
                                                                          )),
                                                                    ),
                                                                    Container(
                                                                        height: height *
                                                                            0.15,
                                                                        width: width *
                                                                            0.35,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Text("Dist.",
                                                                                style: TextStyle(fontSize: textScaleFactor * 30, color: Colors.blue, fontWeight: FontWeight.w800)),
                                                                            Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Container(
                                                                                  width: width * 0.28,
                                                                                  child: FittedBox(
                                                                                      child: Text(
                                                                                        generalDestinationDataMap[chosenNumber]!.distance,
                                                                                        style: TextStyle(
                                                                                          color: Colors.blue,
                                                                                          fontWeight: FontWeight.w700,
                                                                                        ),
                                                                                      ),
                                                                                      fit: BoxFit.contain),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.blue,
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(15)),
                                                                        )),
                                                                  ],
                                                                ),
                                                              ],
                                                            )))
                                                  ],
                                                )),
                                            //break
                                            Container(
                                                width: 0.95,
                                                height: height * 0.45,
                                                decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade300),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        height: height * 0.01),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            height:
                                                                height * 0.1,
                                                            child: Lottie.network(
                                                                "https://assets1.lottiefiles.com/packages/lf20_drrpbqcu.json")),
                                                        Text("Location Data",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    textScaleFactor *
                                                                        30)),
                                                      ],
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                            width: width * 0.9,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: width * 0.01),
                                                                            child:
                                                                                Text(
                                                                              "State: ",
                                                                              style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 15, fontWeight: FontWeight.w600),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: width * 0.01),
                                                                            child:
                                                                                Text(
                                                                              locationData[chosenNumber]!.state.toString(),
                                                                              style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 20, fontWeight: FontWeight.w600),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(right: width * 0.01),
                                                                            child:
                                                                                Text(
                                                                              "City: ",
                                                                              style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 15, fontWeight: FontWeight.w600),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(right: width * 0.01),
                                                                            child:
                                                                                Text(
                                                                              locationData[chosenNumber]!.city.toString(),
                                                                              style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 20, fontWeight: FontWeight.w600),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  width: width *
                                                                      0.95,
                                                                  height:
                                                                      height *
                                                                          0.07,
                                                                  margin: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          width *
                                                                              0.05),
                                                                ),
                                                                Container(
                                                                  width: width *
                                                                      0.95,
                                                                  height:
                                                                      height *
                                                                          0.09,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: width * 0.01),
                                                                        child:
                                                                            Text(
                                                                          "Address: ",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontSize: textScaleFactor * 15,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(left: width * 0.01),
                                                                        child:
                                                                            Text(
                                                                          locationData[chosenNumber]!
                                                                              .formattedAddress
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontSize: textScaleFactor * 15,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  margin: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          width *
                                                                              0.05),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.01),
                                                                Row(
                                                                    children: [
                                                                      Container(
                                                                        width: width *
                                                                            0.3,
                                                                        height: height *
                                                                            0.15,
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text("Speed\nLimit",
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700, color: Colors.blue, fontSize: textScaleFactor * 17)),
                                                                            Text(locationData[chosenNumber]!.speedLimit.toString(),
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue, fontSize: textScaleFactor * 40)),
                                                                          ],
                                                                        ),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.grey.shade300,
                                                                            border: Border.all(color: Colors.blue, width: 4),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                      ),
                                                                      Container(
                                                                          width: height *
                                                                              0.15,
                                                                          height: height *
                                                                              0.15,
                                                                          child:
                                                                              Neumorphic(
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                SfRadialGauge(
                                                                                  animationDuration: 500,
                                                                                  enableLoadingAnimation: true,
                                                                                  axes: <RadialAxis>[
                                                                                    RadialAxis(showTicks: false, maximumLabels: 0, minimum: 0, maximum: locationData[chosenNumber]!.speedLimit + 10, showLabels: false, pointers: <GaugePointer>[
                                                                                      RangePointer(
                                                                                        animationDuration: 500,
                                                                                        animationType: AnimationType.linear,
                                                                                        enableAnimation: true,
                                                                                        value: locationData[chosenNumber]!.speed.toDouble(),
                                                                                        cornerStyle: CornerStyle.bothCurve,
                                                                                        gradient: locationData[chosenNumber]!.speed > locationData[chosenNumber]!.speedLimit || ProblemAreas[chosenNumber] == 3
                                                                                            ? SweepGradient(colors: [
                                                                                                Colors.red,
                                                                                                Colors.red.shade600
                                                                                              ])
                                                                                            : SweepGradient(colors: [
                                                                                                Colors.blue,
                                                                                                Colors.blue.shade600
                                                                                              ]),
                                                                                      )
                                                                                    ])
                                                                                  ],
                                                                                ),
                                                                                Stack(
                                                                                  children: [
                                                                                    Center(
                                                                                        child: Row(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          locationData[chosenNumber]!.speed.toInt().toString(),
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(
                                                                                            color: locationData[chosenNumber]!.speed > locationData[chosenNumber]!.speedLimit ? Colors.red : Colors.blue,
                                                                                            fontWeight: FontWeight.w800,
                                                                                            fontSize: MediaQuery.of(context).textScaleFactor * 30,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          " M/H",
                                                                                          textAlign: TextAlign.end,
                                                                                          style: TextStyle(
                                                                                            color: locationData[chosenNumber]!.speed > locationData[chosenNumber]!.speedLimit ? Colors.red : Colors.blue,
                                                                                            fontWeight: FontWeight.w800,
                                                                                            fontSize: MediaQuery.of(context).textScaleFactor * 10,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    )),
                                                                                    Padding(
                                                                                      padding: EdgeInsets.only(
                                                                                        top: height * 0.1,
                                                                                      ),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Text("Speed", style: TextStyle(color: locationData[chosenNumber]!.speed > locationData[chosenNumber]!.speedLimit ? Colors.red : Colors.blue, fontSize: textScaleFactor * 15, fontWeight: FontWeight.w700)),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            style:
                                                                                NeumorphicStyle(
                                                                              depth: 1,
                                                                              boxShape: NeumorphicBoxShape.circle(),
                                                                            ),
                                                                          ))
                                                                    ],
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceAround),
                                                              ],
                                                            )))
                                                  ],
                                                )),
                                            Container(
                                              width: 0.95,
                                              height: height * 0.45,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                      height: height * 0.02),
                                                  Container(
                                                    width: width * 0.85,
                                                    height: height * 0.1,
                                                    child: NeumorphicButton(
                                                      onPressed: () {
                                                        for (int i = 0;
                                                            i <
                                                                weatherDestinationDataMap[
                                                                        chosenNumber]!
                                                                    .length;
                                                            i++) {
                                                          weatherLocation
                                                              currentDataWeather =
                                                              weatherDestinationDataMap[
                                                                  chosenNumber]![i];
                                                          currentDataWeather
                                                              .imageID;
                                                          late gMap
                                                                  .BitmapDescriptor
                                                              tempIcon;
                                                          if (currentDataWeather
                                                                  .imageID ==
                                                              "2") {
                                                            tempIcon =
                                                                thunderDescriptor;
                                                          } else if (currentDataWeather
                                                                  .imageID ==
                                                              "3") {
                                                            tempIcon =
                                                                rainingDescriptor;
                                                          } else if (currentDataWeather
                                                                  .imageID ==
                                                              "5") {
                                                            tempIcon =
                                                                rainingDescriptor;
                                                          } else if (currentDataWeather
                                                                  .imageID ==
                                                              "6") {
                                                            tempIcon =
                                                                thunderDescriptor;
                                                          } else if (currentDataWeather
                                                                  .imageID ==
                                                              "7") {
                                                            tempIcon =
                                                                windyDescriptor;
                                                          } else if (currentDataWeather
                                                                  .imageID ==
                                                              "8") {
                                                            tempIcon =
                                                                sunDescriptor;
                                                          } else if (currentDataWeather
                                                                  .imageID ==
                                                              "9") {
                                                            tempIcon =
                                                                mcloudyDescriptor;
                                                          } else {
                                                            tempIcon =
                                                                cloudyDescriptor;
                                                          }
                                                          weatherDestinationDataList.add(gMap.Marker(
                                                              icon: tempIcon,
                                                              zIndex: 300,
                                                              markerId: gMap.MarkerId(
                                                                  currentDataWeather
                                                                      .location
                                                                      .latitude
                                                                      .toString()),
                                                              position: gMap.LatLng(
                                                                  currentDataWeather
                                                                      .location
                                                                      .latitude,
                                                                  currentDataWeather
                                                                      .location
                                                                      .longitude)));
                                                        }
                                                        setState(() {
                                                          if (weatherDisplayText ==
                                                              "Show Weather") {
                                                            weatherDestinationDataList;
                                                            weatherDisplayText =
                                                                "Hide Weather";
                                                          } else {
                                                            weatherDestinationDataList =
                                                                [];

                                                            weatherDisplayText =
                                                                "Show Weather";
                                                          }
                                                        });
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                              child: Lottie.network(
                                                                  "https://assets9.lottiefiles.com/packages/lf20_mwnl7iyc.json")),
                                                          Expanded(
                                                              child: FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Text(
                                                              weatherDisplayText,
                                                              style:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ))
                                                        ],
                                                      ),
                                                      style: NeumorphicStyle(
                                                          color: Colors
                                                              .grey.shade300,
                                                          border:
                                                              NeumorphicBorder(
                                                            color: Colors.blue,
                                                            width: 5,
                                                          ),
                                                          depth: 5,
                                                          boxShape: NeumorphicBoxShape
                                                              .roundRect(BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          25)))),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.01),
                                                  Expanded(
                                                    child: Container(
                                                      width: width * 0.9,
                                                      child: Scrollbar(
                                                        isAlwaysShown: true,
                                                        child: ListView(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 10),
                                                          children: [
                                                            ...weatherDestinationDataListShow
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            showingBlinkHistoryPage
                                                ? Container(
                                                    width: width * 0.95,
                                                    height: height * 0.45,
                                                    color: Colors.grey.shade300,
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                            height:
                                                                height * 0.015),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Lottie.network(
                                                                "https://assets6.lottiefiles.com/packages/lf20_qimp2p.json",
                                                                height: height *
                                                                    0.07),
                                                            SizedBox(
                                                                width: width *
                                                                    0.02),
                                                            Text(title,
                                                                style: TextStyle(
                                                                    color: ProblemAreas[chosenNumber] ==
                                                                                2 ||
                                                                            ProblemAreas[chosenNumber] ==
                                                                                3
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .blue,
                                                                    fontSize:
                                                                        MediaQuery.of(context).textScaleFactor *
                                                                            30,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700)),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.015),
                                                        Expanded(
                                                            child: Container(
                                                          width: width * 0.95,
                                                          child: ListView(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        height *
                                                                            0.01),
                                                            children: [
                                                              ...primaryData
                                                                  .map((e) {
                                                                String
                                                                    startingTime =
                                                                    "";
                                                                String endTime =
                                                                    "";
                                                                startingTime =
                                                                    startingTime +
                                                                        e.timeStarted
                                                                            .hour
                                                                            .toString();
                                                                if (e.timeStarted
                                                                        .minute <=
                                                                    9) {
                                                                  startingTime = startingTime +
                                                                      ":0" +
                                                                      e.timeStarted
                                                                          .minute
                                                                          .toString();
                                                                } else {
                                                                  startingTime = startingTime +
                                                                      ":" +
                                                                      e.timeStarted
                                                                          .minute
                                                                          .toString();
                                                                }
                                                                if (e.timeStarted
                                                                        .second <=
                                                                    9) {
                                                                  startingTime = startingTime +
                                                                      ":0" +
                                                                      e.timeStarted
                                                                          .second
                                                                          .toString();
                                                                } else {
                                                                  startingTime = startingTime +
                                                                      ":" +
                                                                      e.timeStarted
                                                                          .second
                                                                          .toString();
                                                                }
                                                                endTime = endTime +
                                                                    e.timeEnded
                                                                        .hour
                                                                        .toString();
                                                                if (e
                                                                    .contintuing) {
                                                                  endTime =
                                                                      "Present";
                                                                } else {
                                                                  if (e.timeEnded
                                                                          .minute <=
                                                                      9) {
                                                                    endTime = endTime +
                                                                        ":0" +
                                                                        e.timeEnded
                                                                            .minute
                                                                            .toString();
                                                                  } else {
                                                                    endTime = endTime +
                                                                        ":" +
                                                                        e.timeEnded
                                                                            .minute
                                                                            .toString();
                                                                  }
                                                                  if (e.timeEnded
                                                                          .second <=
                                                                      9) {
                                                                    endTime = endTime +
                                                                        ":0" +
                                                                        e.timeEnded
                                                                            .second
                                                                            .toString();
                                                                  } else {
                                                                    endTime = endTime +
                                                                        ":" +
                                                                        e.timeEnded
                                                                            .second
                                                                            .toString();
                                                                  }
                                                                }
                                                                return InkWell(
                                                                  onTap: () {
                                                                    controller.animateCamera(gMap.CameraUpdate.newCameraPosition(gMap.CameraPosition(
                                                                        target: gMap.LatLng(
                                                                            e.latitude,
                                                                            e.longitude),
                                                                        bearing: 0,
                                                                        zoom: 13)));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            width *
                                                                                0.05),
                                                                    margin: EdgeInsets.only(
                                                                        bottom: height *
                                                                            0.015),
                                                                    width:
                                                                        width *
                                                                            0.1,
                                                                    height:
                                                                        height *
                                                                            0.12,
                                                                    child: Neumorphic(
                                                                        child: Row(
                                                                          children: [
                                                                            SizedBox(width: width * 0.03),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Icon(Icons.timer_outlined, color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 3 ? Colors.red : Colors.blue, size: MediaQuery.of(context).textScaleFactor * 30),
                                                                                    SizedBox(width: width * 0.01),
                                                                                    Text(startingTime, textAlign: TextAlign.left, style: TextStyle(color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 3 ? Colors.red : Colors.blue, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).textScaleFactor * 30)),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Icon(Icons.timer_rounded, color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 3 ? Colors.red : Colors.blue, size: MediaQuery.of(context).textScaleFactor * 30),
                                                                                    SizedBox(width: width * 0.01),
                                                                                    Text(endTime, textAlign: TextAlign.left, style: TextStyle(color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 3 ? Colors.red : Colors.blue, fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).textScaleFactor * 30)),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Expanded(child: Container()),
                                                                            Container(
                                                                              padding: EdgeInsets.all(width * 0.01),
                                                                              child: FittedBox(
                                                                                  fit: BoxFit.contain,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Text(e.timeStarted.difference(e.timeEnded).abs().inSeconds.toString(), style: TextStyle(fontWeight: FontWeight.w700, color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 3 ? Colors.red : Colors.blue)),
                                                                                      Text("s", style: TextStyle(fontSize: MediaQuery.of(context).textScaleFactor * 15, fontWeight: FontWeight.w700, color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 3 ? Colors.red : Colors.blue)),
                                                                                    ],
                                                                                  )),
                                                                              width: width * 0.24,
                                                                              height: height * 0.095,
                                                                              decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 3 ? Colors.red : Colors.blue, width: 5), borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                            ),
                                                                            SizedBox(width: width * 0.03)
                                                                          ],
                                                                        ),
                                                                        style: NeumorphicStyle(color: Colors.grey.shade300, border: NeumorphicBorder(color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 3 ? Colors.red : Colors.blue, width: 5), boxShape: NeumorphicBoxShape.roundRect(BorderRadius.all(Radius.circular(25))))),
                                                                  ),
                                                                );
                                                              }).toList()
                                                            ],
                                                          ),
                                                        ))
                                                      ],
                                                    ))
                                                : Container(
                                                    width: width * 0.95,
                                                    height: height * 0.45,
                                                    color: Colors.grey.shade300,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            width: width * 0.88,
                                                            height:
                                                                height * 0.11,
                                                            child: Neumorphic(
                                                              style: NeumorphicStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  boxShape: NeumorphicBoxShape.roundRect(
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              25))),
                                                                  border: NeumorphicBorder(
                                                                      color: ProblemAreas[chosenNumber] == 2 ||
                                                                              ProblemAreas[chosenNumber] ==
                                                                                  1
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .blue,
                                                                      width:
                                                                          5)),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned(
                                                                      top: height *
                                                                          0.005,
                                                                      child:
                                                                          Container(
                                                                        width: width *
                                                                            0.9,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            locationData[chosenNumber]!.faceDetected
                                                                                ? Container(height: height * 0.03, child: Image.asset("assets/images/noFaceFound.png"))
                                                                                : Container(),
                                                                            locationData[chosenNumber]!.faceDetected
                                                                                ? SizedBox(width: width * 0.02)
                                                                                : Container(),
                                                                            Text("Last Warned : ",
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 1 ? Colors.red : Colors.blue, fontWeight: FontWeight.w700, fontSize: textScaleFactor * 20)),
                                                                          ],
                                                                        ),
                                                                      )),
                                                                  Container(
                                                                      height:
                                                                          height *
                                                                              0.11,
                                                                      width: width *
                                                                          0.88,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(top: height * 0.03),
                                                                            width:
                                                                                width * 0.8,
                                                                            height:
                                                                                height * 0.08,
                                                                            child:
                                                                                FittedBox(
                                                                              fit: BoxFit.contain,
                                                                              child: Text(warning == "Right Now" ? warning : warning + "Ago", textAlign: TextAlign.center, style: TextStyle(color: ProblemAreas[chosenNumber] == 2 || ProblemAreas[chosenNumber] == 1 ? Colors.red : Colors.blue, fontWeight: FontWeight.w700, fontSize: textScaleFactor * 20)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                ],
                                                              ),
                                                            )),
                                                        SizedBox(
                                                          height: height * 0.02,
                                                        ),
                                                        Container(
                                                            width: width * 0.88,
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                    child:
                                                                        Container(
                                                                  height:
                                                                      height *
                                                                          0.13,
                                                                  child: Neumorphic(
                                                                      child: Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                              "Blinks Per Minute",
                                                                              style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 13, fontWeight: FontWeight.w700)),
                                                                          Text(
                                                                              locationData[chosenNumber]!.blinksPerMinute == 0 ? "--" : locationData[chosenNumber]!.blinksPerMinute.toString(),
                                                                              style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 45, fontWeight: FontWeight.w700))
                                                                        ],
                                                                      ),
                                                                      style: NeumorphicStyle(
                                                                          color: Colors.grey.shade300,
                                                                          border: NeumorphicBorder(
                                                                            color:
                                                                                Colors.blue,
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.all(Radius.circular(25))))),
                                                                )),
                                                                SizedBox(
                                                                  width: width *
                                                                      0.05,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        Container(
                                                                  height:
                                                                      height *
                                                                          0.13,
                                                                  child: Neumorphic(
                                                                      child: Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                              "Average Blinks / Min",
                                                                              style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 12, fontWeight: FontWeight.w700)),
                                                                          Text(
                                                                              locationData[chosenNumber]!.averageBlinksPerMinute == 0 ? "--" : locationData[chosenNumber]!.averageBlinksPerMinute.toString(),
                                                                              style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 45, fontWeight: FontWeight.w700))
                                                                        ],
                                                                      ),
                                                                      style: NeumorphicStyle(
                                                                          color: Colors.grey.shade300,
                                                                          border: NeumorphicBorder(
                                                                            color:
                                                                                Colors.blue,
                                                                            width:
                                                                                5,
                                                                          ),
                                                                          boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.all(Radius.circular(25))))),
                                                                )),
                                                              ],
                                                            )),
                                                        SizedBox(
                                                          height: height * 0.02,
                                                        ),
                                                        InkWell(
                                                          child: Container(
                                                              width:
                                                                  width * 0.88,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                      child:
                                                                          InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        primaryData =
                                                                            [];
                                                                        primaryData
                                                                            .addAll(locationData[chosenNumber]!.blinkEyeHistory);
                                                                        title =
                                                                            "Blink History";
                                                                        showingBlinkHistoryPage =
                                                                            true;
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          height *
                                                                              0.13,
                                                                      child: Neumorphic(
                                                                          child: Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text("Blink Warnings", style: TextStyle(color: ProblemAreas[chosenNumber] == 1 ? Colors.red : Colors.blue, fontSize: textScaleFactor * 13, fontWeight: FontWeight.w700)),
                                                                              Text(locationData[chosenNumber]!.blinkEyeWarning == 0 ? "--" : locationData[chosenNumber]!.blinkEyeWarning.toString(), style: TextStyle(color: ProblemAreas[chosenNumber] == 1 ? Colors.red : Colors.blue, fontSize: textScaleFactor * 45, fontWeight: FontWeight.w700))
                                                                            ],
                                                                          ),
                                                                          style: NeumorphicStyle(
                                                                              color: Colors.grey.shade300,
                                                                              border: NeumorphicBorder(
                                                                                color: ProblemAreas[chosenNumber] == 2 ? Colors.red : Colors.blue,
                                                                                width: 5,
                                                                              ),
                                                                              boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.all(Radius.circular(25))))),
                                                                    ),
                                                                  )),
                                                                  SizedBox(
                                                                    width:
                                                                        width *
                                                                            0.05,
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Container(
                                                                    height:
                                                                        height *
                                                                            0.13,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          primaryData =
                                                                              [];
                                                                          primaryData
                                                                              .addAll(locationData[chosenNumber]!.cloaseEyeHistory);
                                                                          title =
                                                                              "Drowsy History";
                                                                          showingBlinkHistoryPage =
                                                                              true;
                                                                        });
                                                                      },
                                                                      child: Neumorphic(
                                                                          child: Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text("Closed Eyes Warnings", style: TextStyle(color: ProblemAreas[chosenNumber] == 2 ? Colors.red : Colors.blue, fontSize: textScaleFactor * 11, fontWeight: FontWeight.w700)),
                                                                              Text(locationData[chosenNumber]!.closeEyeWarning == 0 ? "--" : locationData[chosenNumber]!.closeEyeWarning.toString(), style: TextStyle(color: ProblemAreas[chosenNumber] == 2 ? Colors.red : Colors.blue, fontSize: textScaleFactor * 45, fontWeight: FontWeight.w700))
                                                                            ],
                                                                          ),
                                                                          style: NeumorphicStyle(
                                                                              color: Colors.grey.shade300,
                                                                              border: NeumorphicBorder(
                                                                                color: ProblemAreas[chosenNumber] == 2 ? Colors.red : Colors.blue,
                                                                                width: 5,
                                                                              ),
                                                                              boxShape: NeumorphicBoxShape.roundRect(const BorderRadius.all(Radius.circular(25))))),
                                                                    ),
                                                                  )),
                                                                ],
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            Container(
                                              width: width * 0.95,
                                              height: height * 0.45,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade300),
                                              child: chosenSpeedLimit == -1
                                                  ? Center(
                                                      child: Stack(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(),
                                                              ),
                                                              Image(
                                                                  image: NetworkImage(
                                                                      "https://cdn-icons-png.flaticon.com/512/2218/2218136.png"),
                                                                  height:
                                                                      height *
                                                                          0.2),
                                                              Container(
                                                                  height:
                                                                      height *
                                                                          0.05),
                                                              Expanded(
                                                                child:
                                                                    Container(),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                    color: Colors
                                                                        .transparent),
                                                              ),
                                                              Container(
                                                                color: Colors
                                                                    .transparent,
                                                                height: height *
                                                                    0.17,
                                                              ),
                                                              Text(
                                                                  "Click on one of the speeding Icons to see data \n about that speeding event",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade500,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                  )),
                                                              Expanded(
                                                                child: Container(
                                                                    color: Colors
                                                                        .transparent),
                                                              ),
                                                              Text(
                                                                  "Note : No speeding Icons means the user has no speed alerts",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue
                                                                          .shade500,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          MediaQuery.of(context).textScaleFactor *
                                                                              10)),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.006),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ) //speeding data
                                                  : Container(
                                                      width: 0.95,
                                                      height: height * 0.45,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey.shade300),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                              height: height *
                                                                  0.01),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                  height:
                                                                      height *
                                                                          0.1,
                                                                  child: Lottie.network(
                                                                      "https://assets6.lottiefiles.com/packages/lf20_zbyipz72.json",
                                                                      repeat:
                                                                          false)),
                                                              Text(
                                                                  "Speeding Data",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              30)),
                                                            ],
                                                          ),
                                                          Expanded(
                                                              child: Container(
                                                                  width: width *
                                                                      0.9,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Container(
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(left: width * 0.01),
                                                                                  child: Text(
                                                                                    "State: ",
                                                                                    style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 15, fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(left: width * 0.01),
                                                                                  child: Text(
                                                                                    speedingHistoryList[chosenSpeedLimit].state.toString(),
                                                                                    style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 20, fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            SizedBox(width: width * 0.2),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(right: width * 0.01),
                                                                                  child: Text(
                                                                                    "Time: ",
                                                                                    style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 15, fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(right: width * 0.01),
                                                                                  child: Text(
                                                                                    speedingTime,
                                                                                    style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 20, fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        width: width *
                                                                            0.95,
                                                                        height: height *
                                                                            0.07,
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                width * 0.05),
                                                                      ),
                                                                      Container(
                                                                        width: width *
                                                                            0.95,
                                                                        height: height *
                                                                            0.09,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              padding: EdgeInsets.only(left: width * 0.01),
                                                                              child: Text(
                                                                                "Address: ",
                                                                                style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 15, fontWeight: FontWeight.w600),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.only(left: width * 0.01),
                                                                              child: Text(
                                                                                speedingHistoryList[chosenSpeedLimit].address.toString(),
                                                                                style: TextStyle(color: Colors.blue, fontSize: textScaleFactor * 15, fontWeight: FontWeight.w600),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                width * 0.05),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              height * 0.01),
                                                                      Row(
                                                                          children: [
                                                                            Container(
                                                                              width: width * 0.3,
                                                                              height: height * 0.15,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text("Speed\nLimit", textAlign: TextAlign.center, style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700, color: Colors.blue, fontSize: textScaleFactor * 17)),
                                                                                  Text(speedingHistoryList[chosenSpeedLimit].speedLimit.toInt().toString(), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue, fontSize: textScaleFactor * 40)),
                                                                                ],
                                                                              ),
                                                                              decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.blue, width: 4), borderRadius: BorderRadius.all(Radius.circular(15))),
                                                                            ),
                                                                            Container(
                                                                                width: height * 0.15,
                                                                                height: height * 0.15,
                                                                                child: Neumorphic(
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      SfRadialGauge(
                                                                                        animationDuration: 500,
                                                                                        enableLoadingAnimation: true,
                                                                                        axes: <RadialAxis>[
                                                                                          RadialAxis(showTicks: false, maximumLabels: 0, minimum: 0, maximum: speedingHistoryList[chosenSpeedLimit].speedLimit + 10, showLabels: false, pointers: <GaugePointer>[
                                                                                            RangePointer(
                                                                                              animationDuration: 500,
                                                                                              animationType: AnimationType.linear,
                                                                                              enableAnimation: true,
                                                                                              value: speedingHistoryList[chosenSpeedLimit].speed.toDouble(),
                                                                                              cornerStyle: CornerStyle.bothCurve,
                                                                                              gradient:  SweepGradient(colors: [Colors.red, Colors.red.shade600])
                                                                                            )
                                                                                          ])
                                                                                        ],
                                                                                      ),
                                                                                      Stack(
                                                                                        children: [
                                                                                          Center(
                                                                                              child: Row(
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Text(
                                                                                                speedingHistoryList[chosenSpeedLimit].speed.toInt().toString(),
                                                                                                textAlign: TextAlign.center,
                                                                                                style: TextStyle(
                                                                                                  color: speedingHistoryList[chosenSpeedLimit].speed > speedingHistoryList[chosenSpeedLimit].speedLimit ? Colors.red : Colors.blue,
                                                                                                  fontWeight: FontWeight.w800,
                                                                                                  fontSize: MediaQuery.of(context).textScaleFactor * 30,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                " M/H",
                                                                                                textAlign: TextAlign.end,
                                                                                                style: TextStyle(
                                                                                                  color: speedingHistoryList[chosenSpeedLimit].speed > speedingHistoryList[chosenSpeedLimit].speedLimit ? Colors.red : Colors.blue,
                                                                                                  fontWeight: FontWeight.w800,
                                                                                                  fontSize: MediaQuery.of(context).textScaleFactor * 10,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )),
                                                                                          Padding(
                                                                                            padding: EdgeInsets.only(
                                                                                              top: height * 0.1,
                                                                                            ),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Text("Speed", style: TextStyle(color:  Colors.red , fontSize: textScaleFactor * 15, fontWeight: FontWeight.w700)),
                                                                                              ],
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  style: NeumorphicStyle(
                                                                                    depth: 1,
                                                                                    boxShape: NeumorphicBoxShape.circle(),
                                                                                  ),
                                                                                ))
                                                                          ],
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround),
                                                                    ],
                                                                  )))
                                                        ],
                                                      )),
                                            ),
                                            Container(
                                                width: width * 0.95,
                                                height: height * 0.45,
                                                decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade300),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        height: height * 0.02),
                                                    InkWell(
                                                      onDoubleTap: () {
                                                        print("her3e");
                                                        controller.animateCamera(gMap
                                                                .CameraUpdate
                                                            .newCameraPosition(gMap.CameraPosition(
                                                                target: gMap.LatLng(
                                                                    locationData[
                                                                            chosenNumber]!
                                                                        .latitude,
                                                                    locationData[
                                                                            chosenNumber]!
                                                                        .longitude),
                                                                bearing: 0,
                                                                zoom: 20)));
                                                      },
                                                      child: Container(
                                                          width: width * 0.95,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                  height:
                                                                      height *
                                                                          0.05,
                                                                  child: Lottie
                                                                      .network(
                                                                          "https://assets8.lottiefiles.com/packages/lf20_ndLURGQdmU.json")),
                                                              Text("Weather",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              30,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700))
                                                            ],
                                                          )),
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.015),
                                                    Container(
                                                      height: height * 0.08,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  width *
                                                                      0.025),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Container(
                                                            height:
                                                                height * 0.1,
                                                            child: Image.asset(
                                                                getBack(locationData[
                                                                        chosenNumber]!
                                                                    .id
                                                                    .toString())),
                                                          ),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  locationData[
                                                                          chosenNumber]!
                                                                      .description,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              23,
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              Text(
                                                                  locationData[
                                                                              chosenNumber]!
                                                                          .city +
                                                                      ", " +
                                                                      locationData[
                                                                              chosenNumber]!
                                                                          .state,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              15,
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700))
                                                            ],
                                                          ),
                                                          CircleAvatar(
                                                            radius:
                                                                height * 0.043,
                                                            backgroundColor:
                                                                Colors.blue,
                                                            child: Center(
                                                                child: Text(
                                                                    ((locationData[chosenNumber]!.temp - 273.15) * 9 / 5 +
                                                                                32)
                                                                            .toInt()
                                                                            .toString() +
                                                                        "°",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w800,
                                                                        fontSize:
                                                                            textScaleFactor *
                                                                                23))),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: height * 0.015,
                                                    ),
                                                    Container(
                                                      width: width * 0.95,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  width * 0.05),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text("Feels Like",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              Text(
                                                                  ((locationData[chosenNumber]!.feel_like - 273.15) *
                                                                              9 /
                                                                              5)
                                                                          .toInt()
                                                                          .toString() +
                                                                      "°",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              40,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text("Humidity",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              Text(
                                                                  locationData[
                                                                              chosenNumber]!
                                                                          .humidity
                                                                          .toInt()
                                                                          .toString() +
                                                                      "%",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              37,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text("Visibility",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      (locationData[chosenNumber]!
                                                                              .visibility)
                                                                          .toInt()
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontSize: textScaleFactor *
                                                                              35,
                                                                          fontWeight:
                                                                              FontWeight.w700)),
                                                                  Text("KM",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontSize: textScaleFactor *
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.w700)),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: width * 0.95,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  width * 0.05),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(
                                                                  "W Direction",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              SizedBox(
                                                                  height:
                                                                      height *
                                                                          0.005),
                                                              Container(
                                                                height: height *
                                                                    0.07,
                                                                width: height *
                                                                    0.07,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(2),
                                                                child:
                                                                    RotationTransition(
                                                                  turns: AlwaysStoppedAnimation(
                                                                      ((180 + locationData[chosenNumber]!.windDeg) %
                                                                              360) /
                                                                          360),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        height *
                                                                            0.06,
                                                                    width:
                                                                        height *
                                                                            0.06,
                                                                    child: const FittedBox(
                                                                        fit: BoxFit.contain,
                                                                        child: Icon(
                                                                          Icons
                                                                              .arrow_back,
                                                                          color:
                                                                              Colors.blue,
                                                                        )),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(100)),
                                                                    ),
                                                                  ),
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            100)),
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .blue,
                                                                        width:
                                                                            4)),
                                                              )
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text("W Speed",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              Container(
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                        locationData[chosenNumber]!
                                                                            .windSpeed
                                                                            .toInt()
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .blue,
                                                                            fontSize: textScaleFactor *
                                                                                45,
                                                                            fontWeight:
                                                                                FontWeight.w700)),
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          bottom:
                                                                              height * 0.01),
                                                                      child: Text(
                                                                          "kmh",
                                                                          textAlign: TextAlign
                                                                              .end,
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontSize: textScaleFactor * 15,
                                                                              fontWeight: FontWeight.w700)),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text("Time",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: height *
                                                                            0.01),
                                                                    child: Text(
                                                                        (locationData[chosenNumber]!.time)
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .blue,
                                                                            fontSize: textScaleFactor *
                                                                                35,
                                                                            fontWeight:
                                                                                FontWeight.w700)),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            //"weather data",
                                            Container(
                                                width: 0.95,
                                                height: height * 0.45,
                                                decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade300),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        height: height * 0.01),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            height:
                                                                height * 0.1,
                                                            child:
                                                                Lottie.network(
                                                              "https://assets9.lottiefiles.com/packages/lf20_jxuqojvt.json",
                                                            )),
                                                        Text("Other Data",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    textScaleFactor *
                                                                        30)),
                                                        SizedBox(
                                                            width: width * 0.1)
                                                      ],
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      width: width * 0.95,
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          width *
                                                                              0.03),
                                                              child: Row(
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      RotationTransition(
                                                                        turns: AlwaysStoppedAnimation(locationData[chosenNumber]!.Gy /
                                                                            600),
                                                                        child:
                                                                            Container(
                                                                          child: Padding(
                                                                              child: Center(child: Image.asset("assets/images/carTop.png")),
                                                                              padding: EdgeInsets.all(20)),
                                                                          height:
                                                                              width * 0.27,
                                                                          width:
                                                                              width * 0.27,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.grey.shade300,
                                                                              border: Border.all(color: Colors.blue, width: 3),
                                                                              borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              height * 0.002),
                                                                      Text(
                                                                          "Top View",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 15))
                                                                    ],
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Container()),
                                                                  Column(
                                                                    children: [
                                                                      RotationTransition(
                                                                        turns: AlwaysStoppedAnimation(locationData[chosenNumber]!.Gz /
                                                                            600),
                                                                        child:
                                                                            Container(
                                                                          child: Padding(
                                                                              child: Center(child: Image.asset("assets/images/carFront.png")),
                                                                              padding: EdgeInsets.all(20)),
                                                                          height:
                                                                              width * 0.27,
                                                                          width:
                                                                              width * 0.27,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.grey.shade300,
                                                                              border: Border.all(color: Colors.blue, width: 3),
                                                                              borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              height * 0.002),
                                                                      Text(
                                                                          "Front View",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 15))
                                                                    ],
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Container()),
                                                                  Column(
                                                                    children: [
                                                                      RotationTransition(
                                                                        turns: AlwaysStoppedAnimation(locationData[chosenNumber]!.Gx /
                                                                            600),
                                                                        child:
                                                                            Container(
                                                                          child: Padding(
                                                                              child: Center(child: Image.asset("assets/images/carSide.png")),
                                                                              padding: EdgeInsets.all(10)),
                                                                          height:
                                                                              width * 0.27,
                                                                          width:
                                                                              width * 0.27,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.grey.shade300,
                                                                              border: Border.all(color: Colors.blue, width: 3),
                                                                              borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              height * 0.002),
                                                                      Text(
                                                                          "Side View",
                                                                          style: TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 15))
                                                                    ],
                                                                  ),
                                                                ],
                                                              )),
                                                          Expanded(
                                                            child: Container(
                                                                width:
                                                                    width * 0.9,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: width *
                                                                          0.03,
                                                                    ),
                                                                    Expanded(
                                                                        child:
                                                                            Container(
                                                                      height:
                                                                          height *
                                                                              0.15,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Container(
                                                                                height: height * 0.06,
                                                                                child: Lottie.network("https://lottie.host/57c22264-2023-4d69-877f-f05cfbc7453b/ZYIgDphcry.json", repeat: false),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Container(
                                                                              child: FittedBox(
                                                                                fit: BoxFit.contain,
                                                                                child: Text(
                                                                                  locationData[chosenNumber]!.callsBlocked.toString(),
                                                                                  style: TextStyle(
                                                                                    color: Colors.blue,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )),
                                                                    SizedBox(
                                                                      width: width *
                                                                          0.03,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        height: height *
                                                                            0.15,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Container(
                                                                                  height: height * 0.06,
                                                                                  child: Lottie.network("https://assets10.lottiefiles.com/packages/lf20_55bbjdzw.json", repeat: false),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            Expanded(
                                                                              child: Container(
                                                                                child: FittedBox(
                                                                                  fit: BoxFit.contain,
                                                                                  child: Text(
                                                                                    locationData[chosenNumber]!.phonesBlocked.toString(),
                                                                                    style: TextStyle(
                                                                                      color: Colors.blue,
                                                                                      fontWeight: FontWeight.w700,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: width *
                                                                          0.03,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        height: height *
                                                                            0.15,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Container(
                                                                                  height: height * 0.06,
                                                                                  child: Lottie.network("https://assets7.lottiefiles.com/private_files/lf30_dfxejf4d.json", repeat: false),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            Expanded(
                                                                              child: Container(
                                                                                child: FittedBox(
                                                                                  fit: BoxFit.contain,
                                                                                  child: Text(
                                                                                    locationData[chosenNumber]!.warningsGiven.toString(),
                                                                                    style: const TextStyle(
                                                                                      color: Colors.blue,
                                                                                      fontWeight: FontWeight.w700,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: width *
                                                                          0.04,
                                                                    ),
                                                                  ],
                                                                )),
                                                          ),
                                                          SizedBox(
                                                              height: height *
                                                                  0.02),
                                                        ],
                                                      ),
                                                    ))
                                                  ],
                                                )),
                                            Container(
                                                width: 0.95,
                                                height: height * 0.45,
                                                decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade300),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        height: height * 0.01),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            height:
                                                                height * 0.1,
                                                            child:
                                                                Lottie.network(
                                                              "https://assets9.lottiefiles.com/packages/lf20_jxuqojvt.json",
                                                            )),
                                                        Text("Other Data",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    textScaleFactor *
                                                                        30)),
                                                        SizedBox(
                                                            width: width * 0.1)
                                                      ],
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      width: width * 0.95,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: width *
                                                                    0.05,
                                                                right: width *
                                                                    0.07,
                                                                bottom: height *
                                                                    0.032),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                        height: height *
                                                                            0.05,
                                                                        child: Lottie.network(
                                                                            "https://assets2.lottiefiles.com/packages/lf20_zbyipz72.json")),
                                                                    Text(
                                                                        "Speeding Alert On",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.blue,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              textScaleFactor * 20,
                                                                        )),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    allData[chosenNumber]["settings"]
                                                                            [
                                                                            "alertSPeeding"]
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              20,
                                                                    )),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                        height: height *
                                                                            0.05,
                                                                        child: Lottie.network(
                                                                            "https://assets8.lottiefiles.com/packages/lf20_txli4cbw.json")),
                                                                    Text(
                                                                        "Sleep Detection On",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.blue,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              textScaleFactor * 20,
                                                                        )),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    allData[chosenNumber]["settings"]
                                                                            [
                                                                            "sleepDetection"]
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              20,
                                                                    )),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                        height: height *
                                                                            0.05,
                                                                        child: Lottie.network(
                                                                            "https://assets1.lottiefiles.com/private_files/lf30_6inghz1i.json")),
                                                                    Text(
                                                                        "Offline Mode",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.blue,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              textScaleFactor * 20,
                                                                        )),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    allData[chosenNumber]["settings"]
                                                                            [
                                                                            "offlineMode"]
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              20,
                                                                    )),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                        height: height *
                                                                            0.05,
                                                                        child: Lottie.network(
                                                                            "https://assets9.lottiefiles.com/packages/lf20_znbkacgx.json")),
                                                                    Text(
                                                                        "Reply To Messages",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.blue,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              textScaleFactor * 20,
                                                                        )),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    allData[chosenNumber]["settings"]
                                                                            [
                                                                            "replyToIncom∂ingSMS"]
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              20,
                                                                    )),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                        height: height *
                                                                            0.05,
                                                                        child: Lottie.network(
                                                                            "https://lottie.host/43e0e134-aba8-4e4f-9460-ac7affb673a4/f1Sx2QrLLW.json")),
                                                                    Text(
                                                                        "Send SMS",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.blue,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              textScaleFactor * 20,
                                                                        )),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    allData[chosenNumber]["settings"]
                                                                            [
                                                                            "sendSMS"]
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              20,
                                                                    )),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                        height: height *
                                                                            0.05,
                                                                        child: Lottie.network(
                                                                            "https://assets10.lottiefiles.com/packages/lf20_gjsy1lag.json")),
                                                                    SizedBox(
                                                                        width: width *
                                                                            0.01),
                                                                    Text(
                                                                        "Send SMS Every",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.blue,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              textScaleFactor * 20,
                                                                        )),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    allData[chosenNumber]["settings"]["sendMessageEverXMinutes"]
                                                                            .toString() +
                                                                        " mins",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          textScaleFactor *
                                                                              20,
                                                                    )),
                                                              ],
                                                            ),
                                                            /* Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Text("hello there"), 
                                                                        Text("hello there"), 
                                                                      ],
                                                                    ),  */
                                                          ],
                                                        ),
                                                      ),
                                                    ))
                                                  ],
                                                )),
                                            Container(
                                              width: 0.95,
                                              height: height * 0.45,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade300),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        height: height * 0.01),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            height:
                                                                height * 0.08,
                                                            child: Lottie.network(
                                                                "https://assets5.lottiefiles.com/packages/lf20_Tkwjw8.json",
                                                                repeat: false)),
                                                        Text(
                                                            "Harsh Driving Data",
                                                            style: TextStyle(
                                                                color: locationData[
                                                                            chosenNumber]!
                                                                        .crashed
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    textScaleFactor *
                                                                        20)),
                                                        SizedBox(
                                                            width: width * 0.1)
                                                      ],
                                                    ),
                                                    locationData[chosenNumber]!
                                                            .crashed
                                                        ? Expanded(
                                                            child: Container(
                                                                width: width *
                                                                    0.95,
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Container(
                                                                          height: height *
                                                                              0.2,
                                                                          child:
                                                                              Image.asset("assets/images/crashBig.png")),
                                                                      Text(
                                                                          widget.currentUser.firstName +
                                                                              " " +
                                                                              widget
                                                                                  .currentUser.lastName +
                                                                              " has curently crashed",
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: TextStyle(
                                                                              color: Colors.red,
                                                                              fontSize: textScaleFactor * 20,
                                                                              fontWeight: FontWeight.w800)),
                                                                      Text(DateTime.parse(locationData[chosenNumber]!.crashedLocations["time"]).minute < 10 ? "He has crashed at : " + locationData[chosenNumber]!.crashedLocations["location"] + "(" + DateTime.parse(locationData[chosenNumber]!.crashedLocations["time"]).hour.toString() + ":0" + DateTime.parse(locationData[chosenNumber]!.crashedLocations["time"]).minute.toString() : "He has crashed at : " + locationData[chosenNumber]!.crashedLocations["location"] + "(" + DateTime.parse(locationData[chosenNumber]!.crashedLocations["time"]).hour.toString() + ":" + DateTime.parse(locationData[chosenNumber]!.crashedLocations["time"]).minute.toString(),
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style: TextStyle(
                                                                              color: Colors.red,
                                                                              fontSize: textScaleFactor * 16,
                                                                              fontWeight: FontWeight.w700))
                                                                    ])),
                                                          )
                                                        : Expanded(
                                                            child: Container(
                                                                width: width *
                                                                    0.95,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                ),
                                                                child: ListView(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              10),
                                                                  children: [
                                                                    ...locationData[
                                                                            chosenNumber]!
                                                                        .hardDeceleration
                                                                        .map(
                                                                            (e) {
                                                                      String
                                                                          time =
                                                                          "";
                                                                      DateTime
                                                                          curTime =
                                                                          DateTime.parse(
                                                                              e["time"]);
                                                                      time = time +
                                                                          curTime
                                                                              .hour
                                                                              .toString() +
                                                                          ":";
                                                                      if (curTime
                                                                              .minute <
                                                                          10) {
                                                                        time = time +
                                                                            "0";
                                                                      }
                                                                      time = time +
                                                                          curTime
                                                                              .minute
                                                                              .toString();
                                                                      print(
                                                                          time);
                                                                      return InkWell(
                                                                        onTap:
                                                                            () {
                                                                          controller.animateCamera(gMap.CameraUpdate.newCameraPosition(gMap.CameraPosition(
                                                                              zoom: 20,
                                                                              target: gMap.LatLng(e["lat"], e["lon"]))));
                                                                        },
                                                                        child: Container(
                                                                            height: height * 0.11,
                                                                            margin: EdgeInsets.only(bottom: height * 0.02, left: width * 0.05, right: width * 0.05),
                                                                            child: Neumorphic(
                                                                                child: Row(
                                                                                  children: [
                                                                                    Container(width: width * 0.15, height: height * 0.1, padding: EdgeInsets.symmetric(horizontal: width * 0.02), child: Image.asset("assets/images/breaks.png")),
                                                                                    SizedBox(width: width * 0.01),
                                                                                    Container(
                                                                                        height: height * 0.11,
                                                                                        width: width * 0.53,
                                                                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                                          Text(
                                                                                            (e["location"] as String).substring(0, (e["location"] as String).indexOf(",") + 1),
                                                                                            textAlign: TextAlign.left,
                                                                                            style: TextStyle(
                                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 15,
                                                                                              color: Colors.blue,
                                                                                              fontWeight: FontWeight.w700,
                                                                                            ),
                                                                                            maxLines: 1,
                                                                                          ),
                                                                                          SizedBox(height: height * 0.01),
                                                                                          Text(
                                                                                            (e["location"] as String).substring((e["location"] as String).indexOf(",") + 2, (e["location"] as String).length),
                                                                                            textAlign: TextAlign.left,
                                                                                            style: TextStyle(
                                                                                              fontSize: MediaQuery.of(context).textScaleFactor * 15,
                                                                                              color: Colors.blue,
                                                                                              fontWeight: FontWeight.w700,
                                                                                            ),
                                                                                            maxLines: 1,
                                                                                          ),
                                                                                        ])),
                                                                                    Expanded(
                                                                                      child: Container(
                                                                                        height: height * 0.1,
                                                                                        child: FittedBox(
                                                                                          fit: BoxFit.contain,
                                                                                          child: Text(
                                                                                            time,
                                                                                            textAlign: TextAlign.right,
                                                                                            style: TextStyle(
                                                                                              color: Colors.blue,
                                                                                              fontWeight: FontWeight.w700,
                                                                                            ),
                                                                                            maxLines: 1,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(width: width * 0.02)
                                                                                  ],
                                                                                ),
                                                                                style: NeumorphicStyle(color: Colors.grey.shade300, border: NeumorphicBorder(color: Colors.blue, width: 5), boxShape: NeumorphicBoxShape.roundRect(BorderRadius.all(Radius.circular(25)))))),
                                                                      );
                                                                    }).toList()
                                                                  ],
                                                                )),
                                                          )
                                                  ]),

                                              //
                                            )
                                          ]),
                                      Positioned(
                                        bottom: height * 0.02,
                                        child: Container(
                                            width: width * 0.95,
                                            height: height * 0.03,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    padding: EdgeInsets.all(
                                                        width * 0.01),
                                                    decoration: const BoxDecoration(
                                                        color: Color.fromARGB(
                                                            72, 255, 255, 255),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    100))),
                                                    child: Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              tabBarController
                                                                  .index = 0;
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                height * 0.01,
                                                            backgroundColor:
                                                                currentIndex == 0
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              tabBarController
                                                                  .index = 1;
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                height * 0.01,
                                                            backgroundColor: currentIndex ==
                                                                    1
                                                                ? (ProblemAreas[
                                                                            chosenNumber] ==
                                                                        3)
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .blue
                                                                : (ProblemAreas[
                                                                            chosenNumber] ==
                                                                        3)
                                                                    ? const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        216,
                                                                        122,
                                                                        122)
                                                                    : Colors
                                                                        .grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              tabBarController
                                                                  .index = 2;
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                height * 0.01,
                                                            backgroundColor:
                                                                currentIndex == 2
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              tabBarController
                                                                  .index = 3;
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                height * 0.01,
                                                            backgroundColor: currentIndex ==
                                                                    3
                                                                ? (ProblemAreas[chosenNumber] ==
                                                                            2 ||
                                                                        ProblemAreas[chosenNumber] ==
                                                                            1)
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .blue
                                                                : (ProblemAreas[chosenNumber] ==
                                                                            2 ||
                                                                        ProblemAreas[chosenNumber] ==
                                                                            1)
                                                                    ? const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        216,
                                                                        122,
                                                                        122)
                                                                    : Colors
                                                                        .grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              tabBarController
                                                                  .index = 4;
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                height * 0.01,
                                                            backgroundColor:
                                                                currentIndex == 4
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              tabBarController
                                                                  .index = 5;
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                height * 0.01,
                                                            backgroundColor:
                                                                currentIndex == 5
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              tabBarController
                                                                  .index = 6;
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                height * 0.01,
                                                            backgroundColor:
                                                                currentIndex == 6
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              tabBarController
                                                                  .index = 7;
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                height * 0.01,
                                                            backgroundColor:
                                                                currentIndex == 7
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              tabBarController
                                                                  .index = 8;
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius:
                                                                height * 0.01,
                                                            backgroundColor:
                                                                currentIndex == 8
                                                                    ? Colors
                                                                        .blue
                                                                    : Colors
                                                                        .grey,
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            )),
                                      )
                                    ],
                                  ))
                              : ListView(
                                  padding: EdgeInsets.all(width * 0.01),
                                  children: [
                                    ...generalDestinationDataList.map((e) {
                                      return InkWell(
                                        onTap: () async {
                                          controller.animateCamera(
                                            gMap.CameraUpdate.newLatLngBounds(
                                                gMap.LatLngBounds(
                                                    northeast: gMap.LatLng(
                                                        e.northEastLat,
                                                        e.northEastLong),
                                                    southwest: gMap.LatLng(
                                                        e.southWestLat,
                                                        e.southWestLong)),
                                                height * 0.2),
                                          );
                                          weatherDestinationDataListShow = [];
                                          for (int i = 0;
                                              i <
                                                  weatherDestinationDataMap[
                                                          e.number]!
                                                      .length;
                                              i++) {
                                            weatherLocation temp =
                                                weatherDestinationDataMap[
                                                    e.number]![i];
                                            String link = "";
                                            print(temp.imageID);
                                            if (temp.imageID == "2") {
                                              link =
                                                  "assets/images/big_images/morning/thunder.png";
                                            } else if (temp.imageID == "3") {
                                              link =
                                                  "assets/images/big_images/morning/raining.png";
                                            } else if (temp.imageID == "5") {
                                              link =
                                                  "assets/images/big_images/morning/raining.png";
                                            } else if (temp.imageID == "7") {
                                              link =
                                                  "assets/images/big_images/morning/windy.png";
                                            } else if (temp.imageID == "8") {
                                              link =
                                                  "assets/images/big_images/morning/sun.png";
                                            } else if (temp.imageID == "9") {
                                              link =
                                                  "assets/images/big_images/morning/mild_cloudy.png";
                                            } else {
                                              link =
                                                  "assets/images/big_images/morning/cloudy.png";
                                            }
                                            bool flag = false;
                                            String address =
                                                temp.weatherData.description;
                                            for (int i = 0;
                                                i < address.length;
                                                i++) {
                                              if (address[i] == " ") {
                                                address.replaceRange(
                                                    i,
                                                    i + 1,
                                                    address[i + 1]
                                                        .toUpperCase());
                                              }
                                            }
                                            weatherDestinationDataListShow.add(
                                                weatherShowWidget(
                                                    link,
                                                    temp.weatherData,
                                                    temp.location,
                                                    address,
                                                    onLongTap));
                                          }
                                          setState(() {
                                            weatherDestinationDataListShow;
                                          });

                                          setState(() {
                                            chosenNumber = e.number;
                                            numberClickedOn = true;
                                            currentUserSettings;
                                            blinkingDataList = [];
                                            blinkingDataList.addAll(
                                                locationData[chosenNumber]!
                                                    .blinkEyeHistory);
                                            sleepingDataList = [];
                                            sleepingDataList.addAll(
                                                locationData[chosenNumber]!
                                                    .cloaseEyeHistory);
                                            speedingHistoryList = [];
                                            speedingHistoryList.addAll(
                                                locationData[chosenNumber]!
                                                    .speedingHistory);
                                            print(speedingHistoryList);
                                            setState(() {
                                              speedingHistoryList;
                                              sleepingDataList;
                                              blinkingDataList;
                                            });
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: width * 0.02,
                                              horizontal: width * 0.02),
                                          height: height * 0.12,
                                          child: Neumorphic(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(width: width * 0.02),
                                                widget.allUsers[e.number]
                                                            ["image"] !=
                                                        ""
                                                    ? CircleAvatar(
                                                        radius: width * 0.1,
                                                        backgroundColor:
                                                            ProblemAreas[e
                                                                        .number] !=
                                                                    -1
                                                                ? Colors.red
                                                                : Colors.blue,
                                                        child: CircleAvatar(
                                                          radius: width * 0.09,
                                                          backgroundImage:
                                                              NetworkImage(widget
                                                                          .allUsers[
                                                                      e.number]
                                                                  ["image"]),
                                                        ))
                                                    : CircleAvatar(
                                                        radius: width * 0.1,
                                                        backgroundColor: Colors
                                                            .grey.shade300,
                                                        child: NeumorphicIcon(
                                                          Icons.tag_faces,
                                                          size:
                                                              textScaleFactor *
                                                                  70,
                                                          style: NeumorphicStyle(
                                                              color: ProblemAreas[e
                                                                          .number] !=
                                                                      -1
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .blue),
                                                        ),
                                                      ),
                                                SizedBox(width: width * 0.02),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(e.number,
                                                        style: TextStyle(
                                                            color: ProblemAreas[e
                                                                        .number] !=
                                                                    -1
                                                                ? Colors.red
                                                                : Colors.blue,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize:
                                                                textScaleFactor *
                                                                    23)),
                                                    Text(
                                                        widget.allUsers[e.number]
                                                                ["firstName"] +
                                                            " " +
                                                            widget.allUsers[
                                                                    e.number]
                                                                ["lastName"],
                                                        style: TextStyle(
                                                            color: ProblemAreas[e
                                                                        .number] !=
                                                                    -1
                                                                ? Colors.red
                                                                : Colors.blue,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize:
                                                                textScaleFactor *
                                                                    20))
                                                  ],
                                                )
                                              ],
                                            ),
                                            style: NeumorphicStyle(
                                                border: NeumorphicBorder(
                                                  color:
                                                      ProblemAreas[e.number] !=
                                                              -1
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  width: 5,
                                                ),
                                                color: Colors.grey.shade300,
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(BorderRadius.all(
                                                        Radius.circular(25)))),
                                          ),
                                        ),
                                      );
                                    }).toList()
                                  ],
                                ))
                      : Container(),
                  style: NeumorphicStyle(
                      border: NeumorphicBorder(
                          color: chosenNumber == ""
                              ? Colors.blue
                              : ProblemAreas[chosenNumber] != -1
                                  ? Colors.red
                                  : Colors.blue,
                          width: 5),
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.all(Radius.circular(25))),
                      color: Colors.grey.shade300)),
            ),
          ),
        ),
        Positioned(
            left: width * 0.02,
            top: width * 0.03,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (numberClickedOn == false) {
                    listenThing.cancel();
                    Navigator.of(context).pop();
                    timer2!.cancel();
                  } else {
                    if (showingBlinkHistoryPage) {
                      setState(() {
                        showingBlinkHistoryPage = false;
                      });
                    } else {
                      numberClickedOn = false;
                      speedingHistoryList = [];
                      sleepingDataList = [];
                      blinkingDataList = [];
                      chosenSpeedLimit = -1;
                      setState(() {
                        speedingHistoryList;
                        sleepingDataList;
                        blinkingDataList;
                        chosenSpeedLimit;
                      });
                      chosenNumber = "";
                    }
                  }
                });
              },
              child: Container(
                width: width * 0.16,
                height: width * 0.16,
                padding: EdgeInsets.all(width * 0.03),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.red,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  border: Border.all(
                    color: Colors.red,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
              ),
            )),
        Positioned(
          left: width * 0.2,
          top: width * 0.03,
          child: Stack(
            children: [
              // The text border
              Text(
                'Map Page',
                style: TextStyle(
                  fontSize: textScaleFactor * 45,
                  letterSpacing: 5,
                  fontWeight: FontWeight.w800,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 10
                    ..color = Colors.white,
                ),
              ),
              // The text inside
              Text(
                'Map Page',
                style: TextStyle(
                  fontSize: textScaleFactor * 45,
                  letterSpacing: 5,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

// Functions
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class weather {
  String time;
  double temp;
  double feel_like;
  double humidity;
  int id;
  String type;
  String description;
  double windSpeed;
  double windDeg;
  double gust;
  double visibility;
  String cityName;
  double groundLevel;

  weather(
      this.time,
      this.temp,
      this.feel_like,
      this.humidity,
      this.id,
      this.type,
      this.description,
      this.windSpeed,
      this.windDeg,
      this.gust,
      this.visibility,
      this.cityName,
      this.groundLevel);
}

class weatherLocation {
  LatLng location;
  weather weatherData;
  String imageID;
  weatherLocation(this.location, this.weatherData, this.imageID);
}

String getBack(String imageID) {
  String link = "";
  if (imageID == "2") {
    link = "assets/images/big_images/morning/thunder.png";
  } else if (imageID == "3") {
    link = "assets/images/big_images/morning/raining.png";
  } else if (imageID == "5") {
    link = "assets/images/big_images/morning/raining.png";
  } else if (imageID == "7") {
    link = "assets/images/big_images/morning/windy.png";
  } else if (imageID == "8") {
    link = "assets/images/big_images/morning/sun.png";
  } else if (imageID == "9") {
    link = "assets/images/big_images/morning/mild_cloudy.png";
  } else {
    link = "assets/images/big_images/morning/cloudy.png";
  }
  return link;
}

class weatherShowWidget extends StatefulWidget {
  String assetLink;
  weather data;
  LatLng location;
  String description;
  Function onLongTap;
  weatherShowWidget(this.assetLink, this.data, this.location, this.description,
      this.onLongTap);
  @override
  State<weatherShowWidget> createState() => _weatherShowWidgetState();
}

class _weatherShowWidgetState extends State<weatherShowWidget> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return InkWell(
      onLongPress: () {
        widget.onLongTap(widget.location);
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          print(widget.data.time);
          DateTime currentDateTime = DateTime.parse(widget.data.time);
          return weatherDataWidget1(widget.data.cityName, widget.data,
              widget.assetLink, currentDateTime);
        }));
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: width * 0.02),
            Container(
              child: Image.asset(widget.assetLink),
              height: height * 0.09,
              width: height * 0.09,
              padding: EdgeInsets.all(height * 0.01),
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(100))),
            ),
            SizedBox(width: width * 0.02),
            Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.data.cityName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w800,
                          fontSize:
                              MediaQuery.of(context).textScaleFactor * 14),
                    ),
                    Text(
                      widget.description,
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w800,
                          fontSize:
                              MediaQuery.of(context).textScaleFactor * 15),
                    )
                  ]),
            ),
            Expanded(child: Container()),
            Text(
              widget.data.temp.toInt().toString() + "°",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: MediaQuery.of(context).textScaleFactor * 30),
            ),
            SizedBox(width: width * 0.02),
          ],
        ),
        margin: EdgeInsets.only(
            left: width * 0.03, right: width * 0.03, bottom: height * 0.01),
        height: height * 0.12,
        padding: EdgeInsets.symmetric(vertical: height * 0.01),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(
              color: Colors.blue,
              width: 5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25))),
      ),
    );
  }
}

//Classes
class LocationData {
  double latitude;
  double longitude;
  double speed;
  double altitude;
  String firstName;
  String lastName;
  String city;
  double Gx;
  double Gy;
  double Gz;
  double Ax;
  double Ay;
  double Az;
  double Mx;
  double My;
  double Mz;
  String formattedAddress;
  int speedLimit;
  String state;
  String description;
  String time;
  double temp;
  double feel_like;
  double humidity;
  int id;
  double windSpeed;
  double windDeg;
  double gust;
  double visibility;
  String cityName;
  double groundLevel;
  String number;
  int averageBlinksPerMinute;
  int blinksPerMinute;
  int closeEyeWarning;
  int blinkEyeWarning;
  List<blinkSession> cloaseEyeHistory;
  List<blinkSession> blinkEyeHistory;
  List<speedingHistoryVal> speedingHistory;
  int callsBlocked;
  int phonesBlocked;
  int warningsGiven;
  List hardDeceleration;
  bool crashed;
  Map crashedLocations;
  bool faceDetected;

  LocationData(
      this.latitude,
      this.longitude,
      this.speed,
      this.altitude,
      this.firstName,
      this.lastName,
      this.city,
      this.Gx,
      this.Gy,
      this.Gz,
      this.Ax,
      this.Ay,
      this.Az,
      this.Mx,
      this.My,
      this.Mz,
      this.formattedAddress,
      this.speedLimit,
      this.state,
      this.description,
      this.time,
      this.temp,
      this.windSpeed,
      this.feel_like,
      this.humidity,
      this.id,
      this.windDeg,
      this.gust,
      this.visibility,
      this.cityName,
      this.groundLevel,
      this.number,
      this.averageBlinksPerMinute,
      this.blinkEyeHistory,
      this.blinksPerMinute,
      this.blinkEyeWarning,
      this.closeEyeWarning,
      this.cloaseEyeHistory,
      this.speedingHistory,
      this.callsBlocked,
      this.phonesBlocked,
      this.warningsGiven,
      this.crashed,
      this.crashedLocations,
      this.hardDeceleration,
      this.faceDetected);
}

class startingData {
  String country;
  String state;
  String city;
  String street;
  String postalCode;
  String formattedAddress;
  double latitude;
  double longitude;
  String number;
  startingData(
      this.country,
      this.state,
      this.city,
      this.street,
      this.postalCode,
      this.formattedAddress,
      this.latitude,
      this.longitude,
      this.number);
}

class destinationData {
  String country;
  String state;
  String city;
  String street;
  String postalCode;
  String formattedAddress;
  double latitude;
  double longitude;
  String number;
  destinationData(
      this.country,
      this.state,
      this.city,
      this.street,
      this.postalCode,
      this.formattedAddress,
      this.latitude,
      this.longitude,
      this.number);
}

class generalDestinationData {
  String pollyLine;
  double northEastLat;
  double northEastLong;
  double southWestLong;
  double southWestLat;
  String arrivalTime;
  String distance;
  String number;
  String totalTime;
  generalDestinationData(
      this.pollyLine,
      this.northEastLat,
      this.northEastLong,
      this.arrivalTime,
      this.distance,
      this.southWestLong,
      this.southWestLat,
      this.number,
      this.totalTime);
}
