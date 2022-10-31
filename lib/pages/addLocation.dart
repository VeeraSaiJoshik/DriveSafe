import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:drivesafev2/pages/giveName.dart';
import 'package:drivesafev2/pages/weatherDataWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';
import 'package:time/time.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_latlong/flutter_latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gMap;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;
import 'package:http_requests/http_requests.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart' as lottie;
import '../models/CategoryToIcon.dart';
import '../models/DirectionsModel.dart';
import '../models/Place.dart';
import '../models/User.dart';
import '../models/settings.dart';
import '../python/distanceAlgorithm.dart';
import 'drivingScreen.dart';

enum ProcessingStatus { isProcessing, locked, dataAvaible, unLocked }

enum SearchingData { isSearching, dataAvailable }

enum animationStatus { notActive, processing, done }

int abs(int absoluteValue) {
  if (absoluteValue < 0) {
    return absoluteValue * -1;
  }
  return absoluteValue;
}

class ArivalTime {
  int minute = 0;
  int hour = 0;
  int day = 0;
  String timeAsString;
  LatLng location;
  ArivalTime(this.location, this.timeAsString);
  void formatedTime() {
    timeAsString = timeAsString + " ";
    print(timeAsString);
    int currentInt = 0;
    String parsedString = "";
    for (int i = 0; i < timeAsString.length; i++) {
      if (timeAsString[i] == " ") {
        if (int.tryParse(parsedString) != null) {
          currentInt = int.parse(parsedString);
          parsedString = "";
        } else {
          if (parsedString == "mins" || parsedString == "min") {
            minute = currentInt;
          } else if (parsedString == "hours" || parsedString == "hour") {
            hour = currentInt;
          } else {
            day = currentInt;
          }
          parsedString = "";
          currentInt = 0;
        }
      } else {
        parsedString = parsedString + timeAsString[i];
      }
    }
  }
}

class placeData {
  String formattedAddress;
  bool isInits = false;
  int accidents;
  Directions directionsData = Directions(
      gMap.LatLngBounds(
          northeast: gMap.LatLng(0, 0), southwest: gMap.LatLng(0, 0)),
      [],
      "",
      "",
      "",
      "");
  placeData(this.formattedAddress, this.accidents);
}

class addLocation extends StatefulWidget {
  @override
  Location location;
  User user;
  LatLng currentLocation;
  addLocation(this.location, this.user, this.currentLocation);

  State<addLocation> createState() => addLocationState();
}

class addLocationState extends State<addLocation>
    with SingleTickerProviderStateMixin {
  SearchingData searchByTextStatus = SearchingData.isSearching;
  int destinationType = 0;
  String googleMapsApi = "Insert Google Maps API";
  String weatherApi = "Insert weather API";
  String geoApifyApi = "Insert Geoapify API";
  String tomTomApi = "Insert tomTom API";
  bool processingWeatherData = false;
  late final directionsService = DirectionsService();
  List<ArivalTime> arrivalsTimes = [];
  late Map directionsData;
  Color clear = Colors.grey.shade300;
  Color mild_cloudy = Colors.grey.shade300;
  Color cloudy = Colors.grey.shade300;
  Settings setting = Settings();
  late List answers;
  Color raining = Colors.grey.shade300;
  Color thunder = Colors.grey.shade300;
  TextEditingController textEditingController = new TextEditingController();
  Color windy = Colors.grey.shade300;
  void getSettings() async {
    final Data = await FirebaseDatabase.instance
        .ref("User")
        .child(widget.user.phoneNumber)
        .child("Settings")
        .get();
    if (Data.exists) {
      setting.jsonToSettings(Data.value as Map);
    } else {
      setting = Settings();
    }
    setState(() {
      setting;
    });
  }

  List<gMap.Marker> markerList = [];
  int resultsLength = 0;
  gMap.Marker? startingLocation;
  double suggestionsHeight = 0.1;
  Map weatherData = {};
  late gMap.LatLngBounds bounds;
  late List<PointLatLng> pollyLinePoints;
  late String totalDistance;
  late String totalDuration;
  Map openweatherData = {};
  double suggestionsWidth = 0.95;
  gMap.Marker? destinationLocation = null;

  late DateTime destinationTime;
  late StreamSubscription<LocationData> locationChangeController;
  // ignore: prefer_typing_uninitialized_variables
  late gMap.BitmapDescriptor destinationDescriptor;
  List<searchingPlace> suggestions = [];
  animationStatus searchAnimation = animationStatus.done;
  bool firstPolylLineSearch = false;
  late bool gatherCurrentLocationGeoCodingData = true,
      gatherDestinationLocationGeoCodingData = false;
  TextEditingController currentLocationController = new TextEditingController();
  bool searchingUsingText = false;
  double? latitude = 0;
  double? longitude = 0;

  searchingPlace startingLocationName = searchingPlace(
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    0,
    0,
    "",
    "",
  );
  searchingPlace destinationLocationName = searchingPlace(
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    0,
    0,
    "",
    "",
  );
  placeData destinationLocationData = placeData("", -1);
  bool gatheringData = true;
  bool first = true;
  late LocationData locationData;
  Location location = Location.instance;
  late LatLng destination;
  late LatLng current;
  double bottomPositionedHeight = 10;
  late gMap.CameraPosition initialCameraPosition;
  Set<gMap.Marker> markers = {};
  IconData buttonIcon = CupertinoIcons.lock_fill;
  ProcessingStatus isProcessing = ProcessingStatus.unLocked;
  Color infomrationColor = Colors.grey;
  Color staringAdressColor = Colors.grey;
  Color destinationAdressColor = Colors.grey;
  bool isLocked = false;
  List baseData1 = [];
  late double containerHeight = 0.47;
  List colors = [Colors.blue, Colors.grey.shade300];
  int decisionListIndex = 0;
  late gMap.BitmapDescriptor suvDescriptor;
  bool shortContianer = false;
  late TabController tabController;
  List returnDestinationTime(String time) {
    time = time.toLowerCase();
    time = time.replaceAll("days", "d");
    time = time.replaceAll("hours", "h");
    time = time.replaceAll("mins", "m");
    print("toekn");
    time = time + " ";
    int days = 0;
    int hours = 0;
    int minutes = 0;
    String parsedString = "";
    int? parsedInt = 0;
    for (int i = 0; i < time.length; i++) {
      print(time[i]);
      print(parsedString);
      print(parsedInt);
      print(hours);
      print(minutes);
      print("dkl;ajf;sdklj");
      if (time[i] == " ") {
        if (parsedString == "d" || parsedString == "h" || parsedString == "m") {
          if (parsedString == "d") {
            days = parsedInt!;
            parsedInt = 0;
          } else if (parsedString == "m") {
            minutes = parsedInt!;
            parsedInt = 0;
          } else {
            hours = parsedInt!;
            parsedInt = 0;
          }
        } else {
          int? time = int.tryParse(parsedString);
          parsedInt = time as int?;
        }
        parsedString = "";
      } else {
        parsedString = parsedString + time[i];
      }
    }
    print(minutes);
    DateTime answer = DateTime.now();

    answer = answer + days.days + hours.hours + minutes.minutes;
    return [time, answer];
  }

  void onCancellAnimation() async {
    setState(() {
      searchAnimation = animationStatus.processing;
      if (searchingUsingText == false) {
        if (containerHeight == 0.08) {
          containerHeight = 0.47;
          shortContianer = false;
        } else {
          containerHeight = 0.08;
          shortContianer = true;
        }
      } else {
        searchingUsingText = false;
        containerHeight = 0.47;
        shortContianer = false;
        bottomPositionedHeight = 10;
      }

      print("here");
      print(containerHeight);
    });
  }

  void onTapFunction(searchingPlace chosenAddress) {
    FocusScope.of(context).unfocus();
    setState(() {
      if (searchingUsingText == false) {
        if (containerHeight == 0.08) {
          containerHeight = 0.47;
          shortContianer = false;
        } else {
          containerHeight = 0.08;
          shortContianer = true;
        }
      } else {
        searchingUsingText = false;
        containerHeight = 0.47;
        shortContianer = false;
        bottomPositionedHeight = 10;
      }
    });
    if (!isLocked) {
      destination = LatLng(chosenAddress.Latitude, chosenAddress.Longitude);
      destinationAdressColor = Colors.blue;

      controller.animateCamera(gMap.CameraUpdate.newCameraPosition(
          gMap.CameraPosition(
              target: gMap.LatLng(destination.latitude, destination.longitude),
              bearing: 0,
              zoom: 13)));
      setState(() {
        destinationLocationName = chosenAddress;
        destinationLocationData.formattedAddress =
            destinationLocationName.formattedAddress;
        destinationLocationData.accidents = 0;
        gatherDestinationLocationGeoCodingData = false;
        first = false;
      });

      setState(() {
        destinationLocation = gMap.Marker(
            position: gMap.LatLng(destination.latitude, destination.longitude),
            markerId: gMap.MarkerId("Destination"),
            icon: destinationDescriptor);
        destinationLocationName;
      });
    }
  }

  void searching(String text) async {
    //api.geoapify.com/'
    List distanceList = [];
    Map latLongToIndexMap = {};
    setState(() {
      searchByTextStatus = SearchingData.isSearching;
      suggestionsHeight = 0.1;
    });
    Response jsonData = await HttpRequests.get(
        "https://api.geoapify.com/v1/geocode/autocomplete?text=" +
            text +
            "&apiKey=" + geoApifyApi,
        headers: {"Accept": "application/json"});
    Map data = jsonData.json;
    print(data["features"]);
    List JsonDataList1 = data["features"];
    suggestions = [];
    for (int i = 0; i < JsonDataList1.length; i++) {
      print(JsonDataList1[i]);
      var JsonDataList = JsonDataList1[i]["properties"];
      String name = "";
      String housenumber = "";
      String street = "";
      String city = "";
      String county = "";
      String state = "";
      String postcode = "";
      String country = "";
      double lat = 0;
      double lon = 0;
      String formattedAddress = "";
      String category = "";
      String countryCode = "";
      if (JsonDataList.containsKey("name")) {
        name = JsonDataList["name"];
      }
      if (JsonDataList.containsKey("housenumber")) {
        housenumber = JsonDataList["housenumber"];
      }
      if (JsonDataList.containsKey("street")) {
        street = JsonDataList["street"];
      }
      if (JsonDataList.containsKey("city")) {
        city = JsonDataList["city"];
      }
      if (JsonDataList.containsKey("county")) {
        name = JsonDataList["county"];
      }
      if (JsonDataList.containsKey("state")) {
        state = JsonDataList["state"];
      }
      if (JsonDataList.containsKey("postcode")) {
        postcode = JsonDataList["postcode"];
      }
      if (JsonDataList.containsKey("country")) {
        country = JsonDataList["country"];
      }

      if (JsonDataList.containsKey("lat")) {
        lat = JsonDataList["lat"];
      }
      if (JsonDataList.containsKey("lon")) {
        lon = JsonDataList["lon"];
      }
      print(JsonDataList);
      print(lon);
      if (JsonDataList.containsKey("formatted")) {
        formattedAddress = JsonDataList["formatted"];
      }
      if (JsonDataList.containsKey("category")) {
        category = JsonDataList["category"];
      }
      if (JsonDataList["country_code"] != null) {
        countryCode = JsonDataList["country_code"];
      }

      searchingPlace subAnswer = searchingPlace(
          name,
          housenumber,
          street,
          city,
          county,
          state,
          postcode,
          country,
          lat,
          lon,
          formattedAddress,
          category);
      num? distanceAnswer = 0;
      distanceAnswer = findDistance(
          subAnswer.Latitude,
          subAnswer.Longitude,
          startingLocation!.position.latitude,
          startingLocation!.position.longitude);
      distanceAnswer ??= 0;
      while (true) {
        if (latLongToIndexMap.containsKey(distanceAnswer)) {
          distanceAnswer = distanceAnswer! + 1;
        } else {
          break;
        }
      }
      distanceList.add(distanceAnswer);
      latLongToIndexMap[distanceAnswer] = i;
      print("this is formattedAddres ");
      subAnswer.formatAddress(countryCode);
      suggestions.add(subAnswer);
    }
    List tempSuggestions = [];
    tempSuggestions.addAll(suggestions);
    print(distanceList);
    distanceList.sort();
    print(distanceList);
    for (int i = 0; i < distanceList.length; i++) {
      suggestions[i] = tempSuggestions[latLongToIndexMap[distanceList[i]]];
    }
    print(suggestions);
    suggestionsHeight = 0.3;

    setState(() {
      searchByTextStatus = SearchingData.dataAvailable;
    });

    setState(() {
      suggestions;
      suggestionsHeight;
    });
  }

  List<int> authourizedNumbers = [2, 3, 5, 7, 8, 9, 10];
  void onLongTap(LatLng location) {
    controller.animateCamera(gMap.CameraUpdate.newCameraPosition(
        gMap.CameraPosition(
            target: gMap.LatLng(location.latitude, location.longitude),
            bearing: 0,
            zoom: 13)));
  }

  Future<searchingPlace> reverseGeoCoding(
      double longitude, double latitude) async {
    print(latitude);
    Response jsonData = await HttpRequests.get(
        "https://api.geoapify.com/v1/geocode/reverse?lat=" +
            latitude.toString() +
            "&lon=" +
            longitude.toString() +
            "&apiKey=" + geoApifyApi,
        headers: {"Accept": "application/json"});
    print(jsonData.json["features"].length);

    Map JsonDataList = jsonData.json["features"][0]["properties"];
    String name = "";
    String housenumber = "";
    String street = "";
    String city = "";
    String county = "";
    String state = "";
    String postcode = "";
    String country = "";
    double lat = 0;
    double lon = 0;
    String formattedAddress = "";
    String category = "";
    String countryCode = "";
    if (JsonDataList.containsKey("name")) {
      name = JsonDataList["name"].toString();
    }
    if (JsonDataList.containsKey("housenumber")) {
      housenumber = JsonDataList["housenumber"].toString();
    }
    if (JsonDataList.containsKey("street")) {
      street = JsonDataList["street"].toString();
    }
    if (JsonDataList.containsKey("city")) {
      city = JsonDataList["city"].toString();
    }
    if (JsonDataList.containsKey("county")) {
      name = JsonDataList["county"].toString();
    }
    if (JsonDataList.containsKey("state")) {
      state = JsonDataList["state"].toString();
    }
    if (JsonDataList.containsKey("postcode")) {
      postcode = JsonDataList["postcode"].toString();
    }
    if (JsonDataList.containsKey("country")) {
      country = JsonDataList["country"].toString();
    }

    if (JsonDataList.containsKey("lat")) {
      lat = JsonDataList["lat"];
    }
    if (JsonDataList.containsKey("lon")) {
      lon = JsonDataList["lon"];
    }
    print(JsonDataList);
    print(lon);
    if (JsonDataList.containsKey("formatted")) {
      formattedAddress = JsonDataList["formatted"].toString();
    }
    if (JsonDataList.containsKey("category")) {
      category = JsonDataList["category"].toString();
    }
    if (JsonDataList["country_code"] != null) {
      countryCode = JsonDataList["country_code"].toString();
    }

    searchingPlace subAnswer = searchingPlace(name, housenumber, street, city,
        county, state, postcode, country, lat, lon, formattedAddress, category);
    subAnswer.formatAddress(JsonDataList["country_code"]);
    return subAnswer;
  }

  @override
  Future<placeData> getAllData() async {
    return placeData(" ", 1);
  }

  void initStateFunction() async {
    destinationTime = DateTime.now();
    DirectionsService.init('AIzaSyDtj9GVjhkfqL2Gg1EB6LFyBUW5q2xopqc');
    suvDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/suv-car.png",
    );
    destinationDescriptor = await gMap.BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/pin-map.png",
    );

    latitude = widget.currentLocation.latitude;
    longitude = widget.currentLocation.longitude;
    current = widget.currentLocation;
    initialCameraPosition = gMap.CameraPosition(
        target: gMap.LatLng(latitude!, longitude!), zoom: 13);
    startingLocation = gMap.Marker(
        markerId: const gMap.MarkerId("FromMarker"),
        icon: suvDescriptor,
        position: gMap.LatLng(latitude!, longitude!),
        onTap: () {});
    setState(() {
      gatheringData = false;
    });

    startingLocationName = await reverseGeoCoding(longitude!, latitude!)
        .whenComplete(() => setState(() {
              startingLocationName;
              gatherCurrentLocationGeoCodingData = false;
            }));

    print(latitude.toString);
    print(longitude.toString());
  }

  void initState() {
    print("here");
    setState(() {
      tabController = TabController(length: 1, vsync: this);
    });

    initStateFunction();

    super.initState();
  }

  late gMap.GoogleMapController controller;
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double textSize = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade300,
      body: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            gatheringData == true
                ? InkWell(
                    onTap: () {
                      print(latitude);
                      print(longitude);
                    },
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Center(child: Text("Loading")),
                    ),
                  )
                : SizedBox(
                    width: width,
                    height: height,
                    child: InkWell(
                      onDoubleTap: () {
                        if (destinationLocationData.accidents != -1) {
                          controller.animateCamera(
                              gMap.CameraUpdate.newLatLngBounds(
                                  destinationLocationData.directionsData.bounds,
                                  100));
                        } else {
                          if (destinationLocation == null) {
                            controller.animateCamera(
                                gMap.CameraUpdate.newCameraPosition(
                                    gMap.CameraPosition(
                                        target:
                                            gMap.LatLng(latitude!, longitude!),
                                        bearing: 0,
                                        zoom: 13)));
                          } else {
                            controller.animateCamera(
                                gMap.CameraUpdate.newCameraPosition(
                                    gMap.CameraPosition(
                                        target: gMap.LatLng(
                                            destination.latitude,
                                            destination.longitude),
                                        bearing: 0,
                                        zoom: 12)));
                          }
                        }
                      },
                      child: gMap.GoogleMap(
                          onMapCreated: ((c1ontroller) {
                            setState(() {
                              controller = c1ontroller;
                            });
                          }),
                          onLongPress: (latLong) {
                            if (!isLocked) {
                              destination =
                                  LatLng(latLong.latitude, latLong.longitude);
                              destinationAdressColor = Colors.blue;
                              setState(() {
                                gatherDestinationLocationGeoCodingData = true;
                                first = false;
                              });

                              reverseGeoCoding(
                                      latLong.longitude, latLong.latitude)
                                  .then((value) {
                                setState(() {
                                  destinationLocationName = value;
                                  destinationLocationData.formattedAddress =
                                      destinationLocationName.formattedAddress;
                                  gatherDestinationLocationGeoCodingData =
                                      false;
                                });
                              });

                              setState(() {
                                destinationLocation = gMap.Marker(
                                    position: latLong,
                                    markerId: gMap.MarkerId("Destination"),
                                    icon: destinationDescriptor);
                                destinationLocationName;
                              });
                            }
                          },
                          markers: {
                            if (startingLocation != null) startingLocation!,
                            if (destinationLocation != null)
                              destinationLocation!,
                          },
                          polylines: {
                            gMap.Polyline(
                                polylineId: const gMap.PolylineId("Directions"),
                                color: Colors.blue,
                                width: 10,
                                points: destinationLocationData
                                    .directionsData.polyLinePoints
                                    .map((e) =>
                                        gMap.LatLng(e.latitude, e.longitude))
                                    .toList())
                          },
                          compassEnabled: false,
                          mapToolbarEnabled: false,
                          mapType: gMap.MapType.hybrid,
                          trafficEnabled: false,
                          initialCameraPosition: initialCameraPosition),
                    ),
                  ),
            SizedBox(
              width: width,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.05,
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
                                print("ere");
                                if (buttonIcon == Icons.save) {
                                  setState(() {
                                    print("here");
                                    buttonIcon = CupertinoIcons.lock_fill;
                                    isLocked = false;
                                    isProcessing = ProcessingStatus.unLocked;
                                    infomrationColor = Colors.blue.shade700;
                                  });
                                } else {
                                  setState(() {
                                    processingWeatherData = false;
                                  });
                                  Navigator.of(context).pop();
                                }
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
                                      color: Colors.red,
                                    ),
                                  ]),
                              style: NeumorphicStyle(
                                  border: const NeumorphicBorder(
                                      color: Colors.red, width: 3),
                                  boxShape: NeumorphicBoxShape.circle(),
                                  depth: 0,
                                  color: Colors.grey.shade300,
                                  lightSource: LightSource.topLeft,
                                  shape: NeumorphicShape.concave)),
                        ),
                        Stack(
                          children: [
                            // The text border
                            Text(
                              'Set Up',
                              style: TextStyle(
                                fontSize: textSize * 45,
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
                              'Set Up',
                              style: TextStyle(
                                fontSize: textSize * 45,
                                letterSpacing: 5,
                                fontWeight: FontWeight.w800,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: height * 0.08,
                          width: height * 0.08,
                          child: NeumorphicButton(
                              onPressed: () async {
                                // Map jsonData = jsonDecode(response.body);
                                if (buttonIcon == CupertinoIcons.lock_fill) {
                                  setState(() {
                                    buttonIcon = Icons.save;
                                    isProcessing =
                                        ProcessingStatus.isProcessing;

                                    setState(() {
                                      isProcessing =
                                          ProcessingStatus.dataAvaible;
                                    });
                                    isLocked = true;
                                    infomrationColor = Colors.blue;
                                  });
                                  print("hjere");
                                  print("here take to");
                                  Response answer = await HttpRequests.get(
                                    "https://maps.googleapis.com/maps/api/directions/json?origin=" +
                                        startingLocation!.position.latitude
                                            .toString() +
                                        "," +
                                        startingLocation!.position.longitude
                                            .toString() +
                                        "&destination=" +
                                        destinationLocation!.position.latitude
                                            .toString() +
                                        "," +
                                        destinationLocation!.position.longitude
                                            .toString() +
                                        "&key=" + googleMapsApi,
                                  );
                                  directionsData = answer.json;
                                  setState(() {
                                    directionsData;
                                  });
                                  var data = directionsData["routes"][0];

                                  if (data != null) {
                                    final northeast =
                                        data["bounds"]["northeast"];
                                    final southwest =
                                        data["bounds"]["southwest"];
                                    bounds = gMap.LatLngBounds(
                                        southwest: gMap.LatLng(
                                            southwest["lat"], southwest["lng"]),
                                        northeast: gMap.LatLng(northeast["lat"],
                                            northeast["lng"]));
                                    controller.animateCamera(
                                        gMap.CameraUpdate.newLatLngBounds(
                                            bounds, 100));
                                    if ((data["legs"] as List).isNotEmpty) {
                                      final leg = data["legs"][0];
                                      totalDistance = leg["distance"]["text"];
                                      totalDuration = leg["duration"]["text"];
                                    } else {
                                      totalDistance = "0";
                                      totalDuration = "0";
                                    }
                                    print("datch");
                                    print(totalDuration);
                                    pollyLinePoints = PolylinePoints()
                                        .decodePolyline(
                                            data["overview_polyline"]
                                                ["points"]);
                                    answers =
                                        returnDestinationTime(totalDuration);
                                    print(answers);
                                    destinationTime = answers[1] as DateTime;

                                    if (destinationTime.hour > 12) {
                                      totalDuration = (destinationTime.hour -
                                                  12)
                                              .toString() +
                                          ":" +
                                          destinationTime.minute.toString() +
                                          " PM";
                                    } else {
                                      totalDuration = destinationTime.hour
                                              .toString() +
                                          ":" +
                                          destinationTime.minute.toString() +
                                          " AM";
                                    }
                                    Duration totalTime = DateTime.now()
                                        .difference(destinationTime);

                                    print(pollyLinePoints.length);
                                    destinationLocationData.directionsData =
                                        Directions(
                                            bounds,
                                            pollyLinePoints,
                                            totalDistance,
                                            totalDuration,
                                            data["overview_polyline"]["points"],
                                            answers[0]);
                                  }
                                  setState(() {
                                    destinationLocationData;
                                    isProcessing = ProcessingStatus.dataAvaible;
                                  });
                                } else {
                                  DataSnapshot baseData = await FirebaseDatabase
                                      .instance
                                      .ref("User")
                                      .child(widget.user.phoneNumber)
                                      .child("shortCuts")
                                      .get();
                                  baseData1 = [];
                                  if (baseData.value != null) {
                                    baseData1.addAll(baseData.value as List<Object>);
                                  }
                                  baseData1.add({
                                    "startingLocation": {
                                      "Latitude":
                                          startingLocation!.position.latitude,
                                      "Longitude":
                                          startingLocation!.position.longitude,
                                      "Country": startingLocationName.country,
                                      "State": startingLocationName.state,
                                      "City": startingLocationName.city,
                                      "Street": startingLocationName.street,
                                      "PostalCode":
                                          startingLocationName.postcode,
                                      "Formatted":
                                          startingLocationName.formattedAddress
                                    },
                                    "destinationLocation": {
                                      "Latitude": destinationLocation!
                                          .position.latitude,
                                      "Longitude": destinationLocation!
                                          .position.longitude,
                                      "Country":
                                          destinationLocationName.country,
                                      "State": destinationLocationName.state,
                                      "City": destinationLocationName.city,
                                      "Street": destinationLocationName.street,
                                      "PostalCode":
                                          destinationLocationName.postcode,
                                      "Formatted": destinationLocationName
                                          .formattedAddress
                                    },
                                    "travelData": {
                                      "PollyLine": destinationLocationData
                                          .directionsData.pollyLine,
                                      "northEastLat": destinationLocationData
                                          .directionsData
                                          .bounds
                                          .northeast
                                          .latitude,
                                      "northEastLong": destinationLocationData
                                          .directionsData
                                          .bounds
                                          .northeast
                                          .longitude,
                                      "southWestLat": destinationLocationData
                                          .directionsData
                                          .bounds
                                          .southwest
                                          .latitude,
                                      "southWestLong": destinationLocationData
                                          .directionsData
                                          .bounds
                                          .southwest
                                          .longitude,
                                      "ArrivalsTime": destinationLocationData
                                          .directionsData.totalDuration,
                                      "distance": destinationLocationData
                                          .directionsData.totalDistance,
                                      "DuartionTime": destinationLocationData
                                          .directionsData.totalTime
                                    }
                                  });
                                  setState(() {
                                    baseData1;
                                  });
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (c) {
                                    return GiveNameScreen(
                                        baseData1, widget.user.phoneNumber);
                                  }));
                                }
                              },
                              padding: EdgeInsets.fromLTRB(
                                  width * 0, height * 0, width * 0, height * 0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      buttonIcon,
                                      size: textSize * 25,
                                      color: Colors.blue,
                                    ),
                                  ]),
                              style: NeumorphicStyle(
                                  border: const NeumorphicBorder(
                                      color: Colors.blue, width: 3),
                                  boxShape: NeumorphicBoxShape.circle(),
                                  depth: 0,
                                  color: Colors.grey.shade300,
                                  lightSource: LightSource.topLeft,
                                  shape: NeumorphicShape.concave)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox()
                ],
              ),
            ),
            AnimatedPositioned(
                duration: Duration(seconds: 1),
                bottom: bottomPositionedHeight,
                onEnd: () {
                  setState(() {
                    searchAnimation = animationStatus.done;
                  });
                },
                right: width * 0.025,
                child: InkWell(
                  onDoubleTap: () {
                    setState(() {
                      setState(() {
                        searchAnimation = animationStatus.processing;
                        decisionListIndex = 0;
                        tabController.index = 0;
                      });

                      if (searchingUsingText == false) {
                        if (containerHeight == 0.08) {
                          containerHeight = 0.47;
                          shortContianer = false;
                        } else {
                          containerHeight = 0.08;
                          shortContianer = true;
                        }
                      } else {
                        searchingUsingText = false;
                        containerHeight = 0.47;
                        shortContianer = false;
                        bottomPositionedHeight = 10;
                      }

                      print("here");
                      print(containerHeight);
                    });
                  },
                  child: AnimatedContainer(
                    onEnd: () {
                      setState(() {
                        searchAnimation = animationStatus.done;
                      });
                    },
                    duration: const Duration(seconds: 1),
                    child: Neumorphic(
                      child: shortContianer
                          ? searchAnimation == animationStatus.done
                              ? searchingUsingText == true
                                  ? Container(
                                      width: width * 0.95,
                                      height: height * 0.01,
                                      child: NeumorphicTextField(
                                          width,
                                          currentLocationController,
                                          height,
                                          textSize,
                                          searching,
                                          onCancellAnimation))
                                  : Container(
                                      child: Center(
                                          child: Column(children: [
                                      Container(
                                        height: height * 0.08,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TabBar(
                                                indicator: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100)),
                                                controller: tabController,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: width * 0.01),
                                                tabs: [
                                                  Tab(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons
                                                              .map_pin_ellipse,
                                                          size: textSize * 30,
                                                          color: colors[
                                                              decisionListIndex],
                                                        ),
                                                        Text(
                                                          " From",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  textSize * 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: colors[
                                                                  decisionListIndex]),
                                                        )
                                                      ],
                                                    ),
                                                    height: height * 0.07,
                                                  ),
                                                  Tab(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons
                                                              .map_pin_ellipse,
                                                          size: textSize * 30,
                                                          color: colors[1 -
                                                              decisionListIndex],
                                                        ),
                                                        Text(
                                                          " To",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  textSize * 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: colors[1 -
                                                                  decisionListIndex]),
                                                        )
                                                      ],
                                                    ),
                                                    height: height * 0.07,
                                                  ),
                                                ],
                                                onTap: (value) {
                                                  if (value == 0) {
                                                    controller.animateCamera(gMap
                                                            .CameraUpdate
                                                        .newCameraPosition(gMap.CameraPosition(
                                                            target: gMap.LatLng(
                                                                startingLocationName
                                                                    .Latitude,
                                                                startingLocationName
                                                                    .Longitude),
                                                            bearing: 0,
                                                            zoom: 13)));
                                                  } else if (destinationLocationName
                                                          .Latitude !=
                                                      0) {
                                                    controller.animateCamera(gMap
                                                            .CameraUpdate
                                                        .newCameraPosition(gMap.CameraPosition(
                                                            target: gMap.LatLng(
                                                                destinationLocationName
                                                                    .Latitude,
                                                                destinationLocationName
                                                                    .Longitude),
                                                            bearing: 0,
                                                            zoom: 13)));
                                                  } else {
                                                    controller
                                                        .animateCamera(
                                                            gMap.CameraUpdate
                                                                .zoomBy(1))
                                                        .whenComplete(() =>
                                                            controller.animateCamera(
                                                                gMap.CameraUpdate
                                                                    .zoomBy(
                                                                        -1)));
                                                  }
                                                  setState(() {
                                                    decisionListIndex = value;
                                                  });
                                                }),
                                          ],
                                        ),
                                        decoration: const BoxDecoration(
                                            color: Colors.lightBlue,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(40))),
                                      )
                                    ])))
                              : Container()
                          : searchAnimation == animationStatus.done
                              ? Container(
                                  height: height * 0.4,
                                  width: width * 0.95,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(40)),
                                  ),
                                  child: Column(children: [
                                    Container(
                                      width: width * 0.9,
                                      height: height * 0.08,
                                      margin: EdgeInsets.all(width * 0.025),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TabBar(
                                              indicator: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              controller: tabController,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.01),
                                              tabs: [
                                                Tab(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.route,
                                                        size: textSize * 30,
                                                        color: colors[
                                                            decisionListIndex],
                                                      ),
                                                      Text(
                                                        " Route",
                                                        style: TextStyle(
                                                            fontSize:
                                                                textSize * 25,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: colors[
                                                                decisionListIndex]),
                                                      )
                                                    ],
                                                  ),
                                                  height: height * 0.07,
                                                ),
                                              ],
                                              onTap: (value) => setState(() {
                                                    decisionListIndex = value;
                                                  })),
                                        ],
                                      ),
                                      decoration: const BoxDecoration(
                                          color: Colors.lightBlue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40))),
                                    ),
                                    Expanded(
                                        child: TabBarView(
                                            controller: tabController,
                                            children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: width * 0.95,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: width *
                                                                      0.05),
                                                          child:
                                                              const AutoSizeText(
                                                            "From : ",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  width * 0.06,
                                                            ),
                                                            gatherCurrentLocationGeoCodingData ==
                                                                    false
                                                                ? Icon(
                                                                    CupertinoIcons
                                                                        .map_pin_ellipse,
                                                                    color: Colors
                                                                        .blue,
                                                                    size:
                                                                        textSize *
                                                                            40,
                                                                  )
                                                                : Shimmer
                                                                    .fromColors(
                                                                        child:
                                                                            Icon(
                                                                          CupertinoIcons
                                                                              .map_pin_ellipse,
                                                                          color:
                                                                              Colors.blue,
                                                                          size: textSize *
                                                                              40,
                                                                        ),
                                                                        baseColor:
                                                                            Colors
                                                                                .blue,
                                                                        highlightColor: Colors
                                                                            .blue
                                                                            .shade300),
                                                            SizedBox(
                                                                width: width *
                                                                    0.02),
                                                            gatherCurrentLocationGeoCodingData ==
                                                                    true
                                                                ? Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Shimmer.fromColors(
                                                                          child: Container(
                                                                            width:
                                                                                width * 0.7,
                                                                            height:
                                                                                height * 0.025,
                                                                            decoration:
                                                                                const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                          ),
                                                                          baseColor: Colors.blue,
                                                                          highlightColor: Colors.blue.shade300),
                                                                      SizedBox(
                                                                          height:
                                                                              height * 0.003),
                                                                      Shimmer.fromColors(
                                                                          child: Container(
                                                                            width:
                                                                                width * 0.3,
                                                                            height:
                                                                                height * 0.025,
                                                                            decoration:
                                                                                const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                          ),
                                                                          baseColor: Colors.blue,
                                                                          highlightColor: Colors.blue.shade300),
                                                                    ],
                                                                  )
                                                                : Expanded(
                                                                    child: Container(
                                                                        alignment: Alignment.centerLeft,
                                                                        margin: EdgeInsets.only(
                                                                          right:
                                                                              width * 0.01,
                                                                        ),
                                                                        height: height * 0.069,
                                                                        child: Text(
                                                                          startingLocationName
                                                                              .formattedAddress,
                                                                          maxLines:
                                                                              2,
                                                                          style: const TextStyle(
                                                                              color: Colors.blue,
                                                                              fontWeight: FontWeight.w700),
                                                                        )),
                                                                  )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.005),
                                                  InkWell(
                                                    onLongPress: () {
                                                      if (isLocked == false) {
                                                        setState(() {
                                                          searchAnimation =
                                                              animationStatus
                                                                  .processing;
                                                          searchingUsingText =
                                                              true;
                                                          containerHeight =
                                                              0.08;
                                                          shortContianer = true;
                                                          bottomPositionedHeight =
                                                              height * 0.78;
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      width: width * 0.95,
                                                      height: height * 0.095,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: width *
                                                                        0.05),
                                                            child: AutoSizeText(
                                                              "To : ",
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  color:
                                                                      destinationAdressColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: width *
                                                                    0.06,
                                                              ),
                                                              gatherDestinationLocationGeoCodingData ==
                                                                      false
                                                                  ? first ==
                                                                          true
                                                                      ? Icon(
                                                                          CupertinoIcons
                                                                              .map_pin_ellipse,
                                                                          color:
                                                                              Colors.grey,
                                                                          size: textSize *
                                                                              40,
                                                                        )
                                                                      : Icon(
                                                                          CupertinoIcons
                                                                              .map_pin_ellipse,
                                                                          color:
                                                                              Colors.blue,
                                                                          size: textSize *
                                                                              40,
                                                                        )
                                                                  : Icon(
                                                                      CupertinoIcons
                                                                          .map_pin_ellipse,
                                                                      color: Colors
                                                                          .blue,
                                                                      size:
                                                                          textSize *
                                                                              40,
                                                                    ),
                                                              SizedBox(
                                                                  width: width *
                                                                      0.02),
                                                              gatherDestinationLocationGeoCodingData ==
                                                                      true
                                                                  ? Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Shimmer.fromColors(
                                                                            child: Container(
                                                                              width: width * 0.7,
                                                                              height: height * 0.025,
                                                                              decoration: const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                            ),
                                                                            baseColor: Colors.blue,
                                                                            highlightColor: Colors.blue.shade300),
                                                                        SizedBox(
                                                                            height:
                                                                                height * 0.003),
                                                                        Shimmer.fromColors(
                                                                            child: Container(
                                                                              width: width * 0.3,
                                                                              height: height * 0.025,
                                                                              decoration: const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                            ),
                                                                            baseColor: Colors.blue,
                                                                            highlightColor: Colors.blue.shade300),
                                                                      ],
                                                                    )
                                                                  : first ==
                                                                          true
                                                                      ? Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              width: width * 0.7,
                                                                              height: height * 0.025,
                                                                              decoration: BoxDecoration(color: infomrationColor, borderRadius: BorderRadius.all(Radius.circular(100))),
                                                                            ),
                                                                            SizedBox(height: height * 0.003),
                                                                            Container(
                                                                              width: width * 0.3,
                                                                              height: height * 0.025,
                                                                              decoration: BoxDecoration(color: infomrationColor, borderRadius: const BorderRadius.all(Radius.circular(100))),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : Expanded(
                                                                          child: Container(
                                                                              alignment: Alignment.centerLeft,
                                                                              margin: EdgeInsets.only(
                                                                                right: width * 0.01,
                                                                              ),
                                                                              height: height * 0.069,
                                                                              child: Text(
                                                                                destinationLocationName.formattedAddress,
                                                                                maxLines: 2,
                                                                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                              )),
                                                                        )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Container(
                                                          width: width * 0.95,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              DataWidget(
                                                                  infomrationColor,
                                                                  "Arrival Time",
                                                                  destinationLocationData
                                                                      .directionsData
                                                                      .totalDuration,
                                                                  isProcessing),
                                                              DataWidget(
                                                                  infomrationColor,
                                                                  "Distance(Mi)",
                                                                  destinationLocationData
                                                                      .directionsData
                                                                      .totalDistance,
                                                                  isProcessing),
                                                            ],
                                                          )))
                                                ],
                                              )),
                                        ]))
                                  ]))
                              : Container(),
                      style: NeumorphicStyle(
                          color: Colors.grey.shade100,
                          depth: 0,
                          border: const NeumorphicBorder(
                              color: Colors.blue, width: 5),
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.all(Radius.circular(30)))),
                    ),
                    height: height * containerHeight,
                    width: width * 0.95,
                  ),
                )),
            searchingUsingText
                ? Positioned(
                    top: height * 0.231,
                    right: width * 0.025,
                    child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        height: searchAnimation == animationStatus.done
                            ? suggestionsHeight * height
                            : 0,
                        width: suggestionsWidth * width,
                        child: Neumorphic(
                          child: suggestions.length == 0
                              ? searchByTextStatus !=
                                      SearchingData.dataAvailable
                                  ? Container(
                                      child: Center(
                                          child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Press the ",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: textSize * 20,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Icon(
                                          CupertinoIcons.search,
                                          size: textSize * 22,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          " button for places ",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: textSize * 20,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    )))
                                  : Container(
                                      height: height * 0.1,
                                      width: width * suggestionsWidth,
                                      child: Center(
                                          child: lottie.Lottie.network(
                                              "https://assets9.lottiefiles.com/packages/lf20_fyye8szy.json")),
                                    )
                              : Center(
                                  child: searchByTextStatus ==
                                          SearchingData.dataAvailable
                                      ? Container(
                                          height:
                                              suggestionsHeight * height * 1,
                                          width: suggestionsWidth * width,
                                          child: ListView(
                                            padding: EdgeInsets.symmetric(
                                                vertical: height * 0.025),
                                            children: [
                                              ...suggestions.map((e) {
                                                String answer = "";
                                                Color? thingColor =
                                                    Colors.pink.shade400;
                                                for (int i = 0;
                                                    i < e.category.length;
                                                    i++) {
                                                  if (e.category[i] == ".") {
                                                    answer = e.category
                                                        .substring(0, i);
                                                  }
                                                }

                                                if (categoryToColor
                                                    .containsKey(answer)) {
                                                  thingColor =
                                                      categoryToColor[answer];
                                                } else {
                                                  answer = "nothing";
                                                }
                                                return SearchWidget(
                                                    e,
                                                    thingColor,
                                                    answer,
                                                    onTapFunction);
                                              }).toList()
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: height * 0.1,
                                          width: width * suggestionsWidth,
                                          child: Center(
                                              child: lottie.Lottie.network(
                                                  "https://assets9.lottiefiles.com/packages/lf20_fyye8szy.json")),
                                        )),
                          style: NeumorphicStyle(
                              depth: 0,
                              color: Colors.grey.shade300,
                              border: NeumorphicBorder(
                                  color: Colors.blue,
                                  width: searchAnimation == animationStatus.done
                                      ? 5
                                      : 0),
                              boxShape: NeumorphicBoxShape.roundRect(
                                  const BorderRadius.all(Radius.circular(25)))),
                        )))
                : Container()
          ],
        ),
      ),
    );
  }
}

// data widget

class DataWidget extends StatefulWidget {
  Color informationColor;
  String descriptorText;
  String data;
  ProcessingStatus status;
  DataWidget(
      this.informationColor, this.descriptorText, this.data, this.status);
  @override
  State<DataWidget> createState() => _DataWidgetState();
}

class _DataWidgetState extends State<DataWidget> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Neumorphic(
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        height: height * 0.15,
        width: height * 0.2,
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: height * 0.01),
                height: height * 0.15,
                width: height * 0.17,
                child: Center(
                  child: widget.informationColor == Colors.blue
                      ? widget.status == ProcessingStatus.dataAvaible
                          ? AutoSizeText(
                              widget.data,
                              maxLines: 1,
                              style: TextStyle(
                                  color: widget.informationColor,
                                  fontSize: textSize * 50,
                                  fontWeight: FontWeight.w800),
                            )
                          : Container(
                              margin: EdgeInsets.only(top: height * 0.02),
                              child: lottie.Lottie.network(
                                  "https://assets1.lottiefiles.com/packages/lf20_kwdztvog.json"),
                            )
                      : AutoSizeText(
                          widget.data,
                          maxLines: 1,
                          style: TextStyle(
                              color: widget.informationColor,
                              fontSize: textSize * 50,
                              fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ),
            Positioned(
              top: height * 0.01,
              child: Container(
                width: height * 0.2,
                child: Center(
                  child: Text(widget.descriptorText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: textSize * 17,
                          color: widget.informationColor,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
      style: NeumorphicStyle(
          border: NeumorphicBorder(color: widget.informationColor, width: 4),
          depth: -10,
          boxShape: NeumorphicBoxShape.roundRect(
              const BorderRadius.all(Radius.circular(25)))),
    );
  }
}

/**/
// Neumorphic Text Field

// search result widget

class SearchWidget extends StatefulWidget {
  searchingPlace option;
  Color? currentColor;
  String category;
  Function onTapFunction;
  SearchWidget(
      this.option, this.currentColor, this.category, this.onTapFunction);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    double textSize = MediaQuery.of(context).textScaleFactor;

    Widget iconWidget = Icon(
      categoryToIcon[widget.category],
      size: textSize * 60,
      color: widget.currentColor,
    );
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        widget.onTapFunction(widget.option);
      },
      child: Container(
        width: width * 0.5,
        height: height * 0.11,
        padding: EdgeInsets.symmetric(horizontal: height * 0.022),
        margin: EdgeInsets.only(bottom: height * 0.015),
        child: Neumorphic(
          padding: EdgeInsets.symmetric(horizontal: width * 0.025),
          child: Row(
            children: [
              iconWidget,
              SizedBox(width: width * 0.02),
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Container(
                        height: height * 0.05,
                        child: AutoSizeText(
                          widget.option.formattedAddress,
                          maxLines: 2,
                          style: TextStyle(
                              color: widget.currentColor,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        height: height * 0.03,
                        child: AutoSizeText(
                          widget.option.city + "," + widget.option.state,
                          maxLines: 1,
                          style: TextStyle(
                              color: widget.currentColor,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          style: NeumorphicStyle(
              color: Colors.grey.shade200,
              border: NeumorphicBorder(color: widget.currentColor, width: 5),
              boxShape: NeumorphicBoxShape.roundRect(
                  const BorderRadius.all(Radius.circular(25)))),
        ),
      ),
    );
  }
}

class NeumorphicTextField extends StatefulWidget {
  double width;
  Function onCancellFunction;
  TextEditingController textEditingController;
  double height;
  double textSize;
  Function onSearchFunction;
  NeumorphicTextField(this.width, this.textEditingController, this.height,
      this.textSize, this.onSearchFunction, this.onCancellFunction);

  @override
  _NeumorphicTextFieldState createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Container(
      width: widget.width * 0.95,
      height: widget.height * 0.0,
      child: Neumorphic(
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
              fontSize: textSize * 30,
              fontWeight: FontWeight.w700,
              color: Colors.blue),
          textAlign: TextAlign.left,
          decoration: InputDecoration(
              prefixIcon: IconButton(
                padding: EdgeInsets.only(left: width * 0.01),
                icon: Icon(
                  CupertinoIcons.search,
                  color: Colors.blue,
                  size: widget.textSize * 35,
                ),
                onPressed: () async {
                  widget.onSearchFunction(widget.textEditingController.text);
                },
              ),
              suffixIcon: IconButton(
                  padding: EdgeInsets.only(right: width * 0.02),
                  onPressed: () {
                    widget.onCancellFunction();
                  },
                  icon: Icon(CupertinoIcons.down_arrow,
                      color: Colors.red, size: widget.textSize * 35)),
              isDense: true,
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100))),
              contentPadding: EdgeInsets.only(
                  bottom: height * 0.03,
                  left: width * 0.03,
                  right: width * 0.03)),
          controller: widget.textEditingController,
        ),
        style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(
                const BorderRadius.all(Radius.circular(100))),
            depth: -15,
            color: Colors.grey.shade300,
            border: NeumorphicBorder(color: Colors.blue, width: 3),
            lightSource: LightSource.topLeft,
            shape: NeumorphicShape.concave),
      ),
    );
  }
}
// search result widget

// search result widget

class WeatherWidget extends StatefulWidget {
  Color mainColor;
  Function theFunction;
  String assetLink;
  WeatherWidget(this.mainColor, this.theFunction, this.assetLink);
  @override
  State<WeatherWidget> createState() => WeatherWidgetState();
}

class WeatherWidgetState extends State<WeatherWidget> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        widget.theFunction();
      },
      child: Container(
        height: height * 0.05,
        width: height * 0.05,
        padding: EdgeInsets.all(5),
        child: Image.asset(widget.assetLink),
        decoration: BoxDecoration(
            color: widget.mainColor,
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(100))),
      ),
    );
  }
}
