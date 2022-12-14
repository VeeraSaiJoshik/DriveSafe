import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:background_sms/background_sms.dart';
import 'package:camera/camera.dart';
import 'package:drivesafev2/pages/sendNotification.dart';
import 'package:drivesafev2/pages/weatherDataWidget.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:dio/dio.dart' as theDio;
import 'package:drivesafev2/models/DirectionsModel.dart';
import 'package:drivesafev2/python/distanceAlgorithm.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:drivesafev2/pages/drivingScreen.dart' as DS;
import 'package:time/time.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:drivesafev2/models/CategoryToIcon.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gMap;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:drivesafev2/models/Place.dart';
import 'package:http_requests/http_requests.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:shimmer/shimmer.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../models/settings.dart';

import 'package:drivesafev2/pages/chooseCurrentLocation.dart';

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}
class accidentData {}
class chooseCurrentLocationScreen1 extends StatefulWidget {
  @override
  Location location;
  User user;
  LatLng currentLocation;
  bool isChooseScreen;
  gMap.LatLng destiantionLocation;
  Settings userSettings;
  chooseCurrentLocationScreen1(this.location, this.user, this.currentLocation,
      this.isChooseScreen, this.destiantionLocation,this.userSettings);

  State<chooseCurrentLocationScreen1> createState() =>
      _chooseCurrentLocationScreen1State();
}

class _chooseCurrentLocationScreen1State
    extends State<chooseCurrentLocationScreen1>
    with SingleTickerProviderStateMixin {
  SearchingData searchByTextStatus = SearchingData.isSearching;
  int chosenId = -1;
  bool calAccident = false;
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
  Color brokenCar = Colors.grey.shade300;
  Color carCrash = Colors.grey.shade300;
  Color cautious = Colors.grey.shade300;
  Color closedLane = Colors.grey.shade300;
  Color flood = Colors.grey.shade300;
  Color fog = Colors.grey.shade300;
  Color icyRoad = Colors.grey.shade300;
  Color rain = Colors.grey.shade300;
  Color roadBlock = Colors.grey.shade300;
  Color trafficJam = Colors.grey.shade300;
  Color unkown = Colors.grey.shade300;
  List roadAccidentId = [];
  late gMap.LatLng mod;
  List<accident> roadAccidentList = [];
  Color windy = Colors.grey.shade300;
  int accidentq = 0;
  void reset() {
    roadAccidentId = [];
    setState(() {
      raining = Colors.grey.shade300;
      thunder = Colors.grey.shade300;
      brokenCar = Colors.grey.shade300;
      carCrash = Colors.grey.shade300;
      cautious = Colors.grey.shade300;
      closedLane = Colors.grey.shade300;
      flood = Colors.grey.shade300;
      fog = Colors.grey.shade300;
      icyRoad = Colors.grey.shade300;
      rain = Colors.grey.shade300;
      roadBlock = Colors.grey.shade300;
      trafficJam = Colors.grey.shade300;
      roadAccidentId;
    });
  }

  void cleanUp() {
    count = 0;
    for (int i = 0; i < roadAccidentList.length; i++) {
      if (roadAccidentId.contains(roadAccidentList[i].icon)) {
        count++;
      }
    }
    setState(() {
      numberOfAccidents = count.toString();
    });
    if (roadAccidentId.length == 0) {
      chosenId = -1;
      numberOfAccidents = "Please Choose";
    }
  }

  void rainyF() {
    if (raining == Colors.blue) {
      raining = Colors.grey.shade300;
      roadAccidentId.add(4);
    } else {
      raining = Colors.blue;
      roadAccidentId.remove(4);
    }
    setState(() {
      setState(() {
        raining;
        roadAccidentId;
      });
    });
  }

  void thunderyF() {
    if (thunder == Colors.blue) {
      thunder = Colors.grey.shade300;
      roadAccidentId.add(8);
    } else {
      thunder = Colors.blue;
      roadAccidentId.remove(8);
    }
    setState(() {
      setState(() {
        thunder;
        roadAccidentId;
      });
    });
  }

  void brokenCarF() {
    if (brokenCar == Colors.blue) {
      brokenCar = Colors.grey.shade300;
      roadAccidentId.remove(14);
    } else {
      brokenCar = Colors.blue;
      roadAccidentId.add(14);
    }
    setState(() {
      setState(() {
        brokenCar;
        roadAccidentId;
      });
    });
  }
  String tomTomApiKey = "tomTomApiKey";
  String geoApifyApi = "geoApifyApi";
  String googleMapsApi = "GoogleMapApi";
  String openWeatherMapApi = "OpenWeatherMapApi";
  void carCrashF() {
    if (carCrash == Colors.blue) {
      carCrash = Colors.grey.shade300;
      roadAccidentId.remove(1);
    } else {
      carCrash = Colors.blue;
      roadAccidentId.add(1);
    }
    setState(() {
      setState(() {
        carCrash;
        roadAccidentId;
      });
    });
  }

  void cautiousF() {
    if (cautious == Colors.blue) {
      cautious = Colors.grey.shade300;
      roadAccidentId.remove(3);
    } else {
      cautious = Colors.blue;
      roadAccidentId.add(3);
    }
    setState(() {
      setState(() {
        cautious;
        roadAccidentId;
      });
    });
  }

  void closedLaneF() {
    if (closedLane == Colors.blue) {
      closedLane = Colors.grey.shade300;
      roadAccidentId.remove(7);
      roadAccidentId.remove(8);
    } else {
      closedLane = Colors.blue;
      roadAccidentId.add(7);
      roadAccidentId.add(8);
    }
    setState(() {
      setState(() {
        closedLane;
        roadAccidentId;
      });
    });
  }

  void floodF() {
    if (flood == Colors.blue) {
      flood = Colors.grey.shade300;
      roadAccidentId.remove(11);
    } else {
      flood = Colors.blue;
      roadAccidentId.add(11);
    }
    setState(() {
      setState(() {
        flood;
        roadAccidentId;
      });
    });
  }

  void fogF() {
    if (fog == Colors.blue) {
      fog = Colors.grey.shade300;
      roadAccidentId.remove(10);
    } else {
      fog = Colors.blue;
      roadAccidentId.add(10);
    }
    setState(() {
      setState(() {
        fog;
        roadAccidentId;
      });
    });
  }

  void icyRoadF() {
    if (icyRoad == Colors.blue) {
      icyRoad = Colors.grey.shade300;
      roadAccidentId.remove(5);
    } else {
      icyRoad = Colors.blue;
      roadAccidentId.add(5);
    }
    setState(() {
      setState(() {
        icyRoad;
        roadAccidentId;
      });
    });
  }

  void rainF() {
    if (rain == Colors.blue) {
      rain = Colors.grey.shade300;
      roadAccidentId.remove(4);
    } else {
      rain = Colors.blue;
      roadAccidentId.add(4);
    }
    setState(() {
      setState(() {
        rain;
        roadAccidentId;
      });
    });
  }

  void roadBlockF() {
    if (roadBlock == Colors.blue) {
      roadBlock = Colors.grey.shade300;
      roadAccidentId.remove(9);
    } else {
      roadBlock = Colors.blue;
      roadAccidentId.add(9);
    }
    setState(() {
      setState(() {
        roadBlock;
        roadAccidentId;
      });
    });
  }

  void trafficJamF() {
    if (trafficJam == Colors.blue) {
      trafficJam = Colors.grey.shade300;
      roadAccidentId.remove(6);
    } else {
      trafficJam = Colors.blue;
      roadAccidentId.add(6);
    }
    setState(() {
      setState(() {
        trafficJam;
        roadAccidentId;
      });
    });
  }

  void unkownF() {
    if (unkown == Colors.blue) {
      unkown = Colors.grey.shade300;
      roadAccidentId.remove(0);
    } else {
      unkown = Colors.blue;
      roadAccidentId.add(0);
    }
    setState(() {
      setState(() {
        unkown;
        roadAccidentId;
      });
    });
  }

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

  void clearF() {
    if (clear == Colors.blue) {
      clear = Colors.grey.shade300;
      authourizedNumbers.add(8);
    } else {
      clear = Colors.blue;
      authourizedNumbers.remove(8);
    }
    setState(() {
      setState(() {
        clear;
        authourizedNumbers;
      });
    });
  }

  void cloudyF() {
    if (cloudy == Colors.blue) {
      cloudy = Colors.grey.shade300;
      authourizedNumbers.add(10);
    } else {
      cloudy = Colors.blue;
      authourizedNumbers.remove(10);
    }
    setState(() {
      setState(() {
        cloudy;
        authourizedNumbers;
      });
    });
  }

  void mild_cloudyF() {
    if (mild_cloudy == Colors.blue) {
      mild_cloudy = Colors.grey.shade300;
      authourizedNumbers.add(9);
    } else {
      mild_cloudy = Colors.blue;
      authourizedNumbers.remove(9);
    }
    setState(() {
      setState(() {
        mild_cloudy;
        authourizedNumbers;
      });
    });
  }

  void rainingF() {
    if (raining == Colors.blue) {
      raining = Colors.grey.shade300;
      authourizedNumbers.add(2);
      authourizedNumbers.add(5);
    } else {
      raining = Colors.blue;
      authourizedNumbers.remove(2);
      authourizedNumbers.remove(5);
    }
    setState(() {
      setState(() {
        raining;
        authourizedNumbers;
      });
    });
  }

  void thunderF() {
    if (thunder == Colors.blue) {
      thunder = Colors.grey.shade300;
      authourizedNumbers.add(2);
    } else {
      thunder = Colors.blue;
      authourizedNumbers.remove(2);
    }
    setState(() {
      setState(() {
        thunder;
        authourizedNumbers;
      });
    });
  }

  void windyF() {
    if (windy == Colors.blue) {
      windy = Colors.grey.shade300;
      authourizedNumbers.add(7);
    } else {
      windy = Colors.blue;
      authourizedNumbers.add(7);
    }
    setState(() {
      setState(() {
        authourizedNumbers;
        windy;
      });
    });
  }

  List<Marker> markerList = [];
  int resultsLength = 0;
  Marker? startingLocation;
  double suggestionsHeight = 0.1;
  Map weatherData = {};
  late gMap.LatLngBounds bounds;
  List<weatherLocation> weatherList = [];
  List<weatherLocation> weatherDisplaceList = [];
  int totalTimeSeconds = 0;
  double distance = 0;
  late List<PointLatLng> pollyLinePoints;
  late String totalDistance;
  late String totalDuration;
  Map openweatherData = {};
  double suggestionsWidth = 0.95;
  Marker? destinationLocation = null;

  late DateTime destinationTime;
  late StreamSubscription<LocationData> locationChangeController;
  late BitmapDescriptor destinationDescriptor;
  List<searchingPlace> suggestions = [];
  animationStatus searchAnimation = animationStatus.done;
  bool firstPolylLineSearch = false;
  late bool gatherCurrentLocationGeoCodingData = true,
      gatherDestinationLocationGeoCodingData = false;
  TextEditingController currentLocationController = new TextEditingController();
  bool searchingUsingText = false;
  double? latitude = 0;
  double? longitude = 0;
  void calculationAccidnets() async {
        bounds.southwest.longitude.toString() +
        "," +
        bounds.southwest.latitude.toString() +
        "," +
        bounds.northeast.longitude.toString() +
        "," +
        bounds.northeast.latitude.toString();
    calAccident = true;
    setState(() {
      calAccident;
    });
    mod = bounds.southwest;
    gMap.LatLng mod2;
    num? width = findDistance1(
        bounds.southwest.latitude,
        bounds.southwest.longitude,
        bounds.southwest.latitude,
        bounds.northeast.longitude);
    double widthF = width!.toDouble();
    double wantedHeight = 10000 / widthF;
    gMap.LatLng northWest =
        gMap.LatLng(bounds.northeast.latitude, bounds.southwest.longitude);
    late Response thing;
  
    markers = {};
    setState(() {
      markers;
    });
    markers.add(gMap.Marker(
        markerId: gMap.MarkerId(mod.latitude.toString()),
        zIndex: 100,
        position: northWest,
        icon: gMap.BitmapDescriptor.defaultMarkerWithHue(
            gMap.BitmapDescriptor.hueGreen)));
    markers.add(gMap.Marker(
        markerId: gMap.MarkerId(mod.longitude.toString()),
        position: mod,
        icon: gMap.BitmapDescriptor.defaultMarkerWithHue(
            gMap.BitmapDescriptor.hueGreen)));
    setState(() {
      markers;
    });
    int i = 0;
    roadAccidentList = []; 
    while (true) {
      if (i > 10) {
        setState(() {
          markers;
        });
        break;
      }
      i++;
      if (findDistance1(northWest.latitude, northWest.longitude, mod.latitude,
              mod.longitude)! <=
          wantedHeight) {
        thing = await HttpRequests.get(
            "https://api.tomtom.com/traffic/services/5/incidentDetails?bbox=" +
                mod.longitude.toString() +
                "%2C" +
                mod.latitude.toString() +
                "%2C" +
                bounds.northeast.longitude.toString() +
                "%2C" +
                bounds.northeast.latitude.toString() +
                "&fields=%7Bincidents%7Btype%2Cgeometry%7Btype%2Ccoordinates%7D%2Cproperties%7Bid%2CiconCategory%2CmagnitudeOfDelay%2Cevents%7Bdescription%2Ccode%2CiconCategory%7D%2CstartTime%2CendTime%2Cfrom%2Cto%2Clength%2Cdelay%2CroadNumbers%2CtimeValidity%2CprobabilityOfOccurrence%2CnumberOfReports%2ClastReportTime%7D%7D%7D&language=en-GB&categoryFilter=0%2C1%2C2%2C3%2C4%2C5%2C6%2C7%2C8%2C9%2C10%2C11%2C14&timeValidityFilter=present&key=" + tomTomApiKey);
        List data = thing.json["incidents"];
        for (int i = 0; i < data.length; i++) {
          Map curData = data[i];
          List<LatLng> coords = [];
          if (curData.containsKey("geometry")) {
            if (curData["geometry"].containsKey("coordinates")) {
              for (int i = 0;
                  i < curData["geometry"]["coordinates"].length;
                  i++) {
                coords.add(LatLng(curData["geometry"]["coordinates"][i][1],
                    curData["geometry"]["coordinates"][i][0]));
              }
            }
          }
          String from;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("from")) {
              from = curData["properties"]["from"];
            } else {
              from = "";
            }
          } else {
            from = "";
          }
          String to;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("to")) {
              to = curData["properties"]["to"];
            } else {
              to = "";
            }
          } else {
            to = "";
          }
          double length;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("length")) {
              length = curData["properties"]["length"];
            } else {
              length = 0.0;
            }
          } else {
            length = 0.0;
          }
          String startTime;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("startTime")) {
              startTime = curData["properties"]["startTime"];
            } else {
              startTime = "";
            }
          } else {
            startTime = "";
          }
          String endTime;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("endTime")) {
              endTime = curData["properties"]["endTime"];
            } else {
              endTime = "";
            }
          } else {
            endTime = "";
          }
          int icon;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("iconCategory")) {
              icon = curData["properties"]["iconCategory"];
            } else {
              icon = 0;
            }
          } else {
            icon = 0;
          }
          int magnitude;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("magnitudeOfDelay")) {
              magnitude = curData["properties"]["magnitudeOfDelay"];
            } else {
              magnitude = 0;
            }
          } else {
            magnitude = 0;
          }
          String probability;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("from")) {
              probability = curData["properties"]["from"];
            } else {
              probability = "";
            }
          } else {
            probability = "";
          }
          int numberOfReports;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("numberOfReports")) {
              if (curData["properties"]["numberOfReports"] != null) {
                numberOfReports = curData["properties"]["numberOfReports"];
              } else {
                numberOfReports = 0;
              }
            } else {
              numberOfReports = 0;
            }
          } else {
            numberOfReports = 0;
          }
          String description;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("description")) {
              description = curData["properties"]["events"]["description"];
            } else {
              description = "";
            }
          } else {
            description = "";
          }
          String pollyLine = "";

          roadAccidentList.add(accident(
              pollyLine,
              coords,
              from,
              to,
              length,
              startTime,
              endTime,
              icon,
              magnitude,
              probability,
              numberOfReports,
              description));
        }
        setState(() {
          roadAccidentList;
        });
        print("please work");
        break;
      } else {
        print(wantedHeight.toInt());
        mod2 =
            getGPSPoints(mod.latitude, mod.longitude, wantedHeight.toInt(), 0);
        thing = await HttpRequests.get(
            "https://api.tomtom.com/traffic/services/5/incidentDetails?bbox=" +
                mod.longitude.toString() +
                "%2C" +
                mod.latitude.toString() +
                "%2C" +
                bounds.northeast.longitude.toString() +
                "%2C" +
                mod2.latitude.toString() +
                "&fields=%7Bincidents%7Btype%2Cgeometry%7Btype%2Ccoordinates%7D%2Cproperties%7Bid%2CiconCategory%2CmagnitudeOfDelay%2Cevents%7Bdescription%2Ccode%2CiconCategory%7D%2CstartTime%2CendTime%2Cfrom%2Cto%2Clength%2Cdelay%2CroadNumbers%2CtimeValidity%2CprobabilityOfOccurrence%2CnumberOfReports%2ClastReportTime%7D%7D%7D&language=en-GB&categoryFilter=0%2C1%2C2%2C3%2C4%2C5%2C6%2C7%2C8%2C9%2C10%2C11%2C14&timeValidityFilter=present&key=" + tomTomApiKey);
  
        List data = thing.json["incidents"];
        for (int i = 0; i < data.length; i++) {
          Map curData = data[i];
          List<LatLng> coords = [];
          if (curData.containsKey("geometry")) {
            if (curData["geometry"].containsKey("coordinates")) {
              for (int i = 0;
                  i < curData["geometry"]["coordinates"].length;
                  i++) {
                coords.add(LatLng(curData["geometry"]["coordinates"][i][1],
                    curData["geometry"]["coordinates"][i][0]));
              }
            }
          }
          String from;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("from")) {
              from = curData["properties"]["from"];
            } else {
              from = "";
            }
          } else {
            from = "";
          }
          String to;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("to")) {
              to = curData["properties"]["to"];
            } else {
              to = "";
            }
          } else {
            to = "";
          }
          double length;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("length")) {
              length = curData["properties"]["length"];
            } else {
              length = 0.0;
            }
          } else {
            length = 0.0;
          }
          String startTime;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("startTime")) {
              startTime = curData["properties"]["startTime"];
            } else {
              startTime = "";
            }
          } else {
            startTime = "";
          }
          String endTime;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("endTime")) {
              endTime = curData["properties"]["endTime"];
            } else {
              endTime = "";
            }
          } else {
            endTime = "";
          }
          int icon;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("iconCategory")) {
              icon = curData["properties"]["iconCategory"];
            } else {
              icon = 0;
            }
          } else {
            icon = 0;
          }
          int magnitude;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("magnitudeOfDelay")) {
              magnitude = curData["properties"]["magnitudeOfDelay"];
            } else {
              magnitude = 0;
            }
          } else {
            magnitude = 0;
          }
          String probability;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("from")) {
              probability = curData["properties"]["from"];
            } else {
              probability = "";
            }
          } else {
            probability = "";
          }
          int numberOfReports;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("numberOfReports")) {
              if (curData["properties"]["numberOfReports"] != null) {
                numberOfReports = curData["properties"]["numberOfReports"];
              } else {
                numberOfReports = 0;
              }
            } else {
              numberOfReports = 0;
            }
          } else {
            numberOfReports = 0;
          }
          String description;
          if (curData.containsKey("properties")) {
            if (curData["properties"].containsKey("description")) {
              description = curData["properties"]["events"]["description"];
            } else {
              description = "";
            }
          } else {
            description = "";
          }
          String pollyLine = "";

          roadAccidentList.add(accident(
              pollyLine,
              coords,
              from,
              to,
              length,
              startTime,
              endTime,
              icon,
              magnitude,
              probability,
              numberOfReports,
              description));
        }
        setState(() {
          roadAccidentList;
        });
        mod = mod2;
        markers.add(gMap.Marker(
            markerId: gMap.MarkerId(mod2.latitude.toString()),
            position: mod2,
            zIndex: 200,
            icon: gMap.BitmapDescriptor.defaultMarkerWithHue(
                gMap.BitmapDescriptor.hueOrange)));
      }
    }
    gMap.LatLng initialPoints =
        gMap.LatLng(bounds.southwest.latitude, bounds.southwest.longitude);
    setState(() {
      markers;
    });
    calAccident = false;
    setState(() {
      calAccident;
      roadAccidentList;
    });
  }

  void calculationWeather(List<PointLatLng> stopPoints) async {
    setState(() {
      processingWeatherData = true;
    });
    authourizedNumbers = [];
    clearF();
    cloudyF();
    mild_cloudyF();
    thunderF();
    rainingF();
    fogF();
    List<LatLng> weatherWorthyPoints = [];
    num? distance = -1;
    LatLng currentLocation = LatLng(0, 0);
    searchingPlace temp;
    String city = "";
    for (int i = 0; i < stopPoints.length; i++) {
      if (distance == -1) {
        currentLocation =
            LatLng(stopPoints[i].latitude, stopPoints[i].longitude);
        weatherWorthyPoints
            .add(LatLng(stopPoints[i].latitude, stopPoints[i].longitude));
        distance = findDistance(
            currentLocation.latitude,
            currentLocation.longitude,
            stopPoints[i].latitude,
            stopPoints[i].longitude)!;
      } else {
        distance = findDistance(
            currentLocation.latitude,
            currentLocation.longitude,
            stopPoints[i].latitude,
            stopPoints[i].longitude)!;
        if (distance > 25) {
          distance = 0;
          currentLocation =
              LatLng(stopPoints[i].latitude, stopPoints[i].longitude);
          weatherWorthyPoints.add(currentLocation);
        } else {
          continue;
        }
      }
    }
    String currentApi = "";
    List<String> googleAPI = [];
    Iterable<LatLng> thing = weatherWorthyPoints.reversed;
    weatherWorthyPoints = [];
    weatherWorthyPoints.addAll(thing);
    for (int i = 0; i < weatherWorthyPoints.length; i++) {
      if (i > 0 && i % 25 == 0) {
        googleAPI.add(currentApi);
        currentApi = "";
        currentApi = currentApi +
            weatherWorthyPoints[i].latitude.toString() +
            "%2c" +
            weatherWorthyPoints[i].longitude.toString() +
            "%7c";
      } else {
        currentApi = currentApi +
            weatherWorthyPoints[i].latitude.toString() +
            "%2c" +
            weatherWorthyPoints[i].longitude.toString() +
            "%7c";
      }
    }
    if (currentApi.isNotEmpty) {
      googleAPI.add(currentApi);
    }
    thing = weatherWorthyPoints.reversed;
    weatherWorthyPoints = [];
    weatherWorthyPoints.addAll(thing);
    arrivalsTimes = [];
    for (int j = 0; j < googleAPI.length; j++) {
      Response data = await HttpRequests.get(
          "https://maps.googleapis.com/maps/api/distancematrix/json?origins=" +
              currentLocation.latitude.toString() +
              "%2c" +
              currentLocation.longitude.toString() +
              "&destinations=" +
              googleAPI[j] +
              "&key=AIzaSyDtj9GVjhkfqL2Gg1EB6LFyBUW5q2xopqc");
      weatherData = data.json;
      for (int i = 0; i < weatherData["rows"][0]["elements"].length; i++) {
        ArivalTime appendObject = ArivalTime(
          LatLng(weatherWorthyPoints[j * 25 + i].latitude,
              weatherWorthyPoints[j * 25 + i].longitude),
          weatherData["rows"][0]["elements"][i]["duration"]["text"],
        );
        appendObject.formatedTime();
        arrivalsTimes.add(appendObject);
      }
    }
    weatherList = [];
    for (int j = 0; j < arrivalsTimes.length; j++) {
      DateTime offsetTime = DateTime.now().toUtc();
      DateTime destinationTime = offsetTime +
          arrivalsTimes[j].hour.hours +
          arrivalsTimes[j].minute.minutes +
          arrivalsTimes[j].day.days;
      String dateAsString = "";
      dateAsString = dateAsString + destinationTime.date.toString();
      dateAsString = dateAsString.replaceAll("-", ":");
      dateAsString = dateAsString.substring(0, 10);
      dateAsString = dateAsString.trim();

      Response data2 = await HttpRequests.get(
          "http://api.openweathermap.org/data/2.5/forecast?lat=" +
              arrivalsTimes[j].location.latitude.toString().trim() +
              "&lon=" +
              arrivalsTimes[j].location.longitude.toString().trim() +
              "&APPID=" + openWeatherMapApi);

      openweatherData = data2.json;
      List timeList = openweatherData["list"];
      for (int i = 0; i < timeList.length; i++) {
        final Map<String, String> queryParameters = {
          'key': tomTomApiKey
        };
        DateTime currentDateTime =
            DateTime.parse(timeList[i]["dt_txt"] + ".000Z").toUtc();
        Uri tomTomURL = await Uri.https(
          "api.tomtom.com",
          "/search/2/reverseGeocode/" +
              arrivalsTimes[j].location.latitude.toString() +
              "," +
              arrivalsTimes[j].location.longitude.toString() +
              ".json",
          queryParameters,
        );
        var tomTomJsonData = await http.get(tomTomURL);
        Map data = jsonDecode(tomTomJsonData.body);
        Duration difference = currentDateTime.difference(destinationTime);
        if (difference.inHours <= 3.0 && difference.inHours >= 0.0) {
          int rawID = timeList[i]["weather"][0]["id"];
          int id = 0;
          if ((rawID >= 200 && rawID <= 212) ||
              (rawID >= 221 && rawID <= 232)) {
            id = 2;
          } else if ((rawID >= 300 && rawID <= 310) ||
              (rawID >= 311 && rawID <= 321)) {
            id = 3;
          } else if ((rawID >= 500 && rawID <= 504) ||
              (rawID >= 511 && rawID <= 531)) {
            id = 5;
          } else if (rawID >= 600 && rawID < 700) {
            id = 6;
          } else if (rawID >= 701 && rawID < 781) {
            id = 7;
          } else if (rawID == 800) {
            id = 8;
          } else if (rawID >= 801 && rawID <= 803) {
            id = 9;
          } else {
            id = 10;
          }
          double temp = 0.0;
          double feels_like = 0.0;
          double humidity = 0.0;
          double speed = 0.0;
          double deg = 0.0;
          double gust = 0.0;
          double visibility = 0.0;
          double grnd_level = 0.0;
          if (timeList[i]["main"].containsKey("temp")) {
            temp = (1.8 * (timeList[i]["main"]["temp"] - 273) + 32).toDouble();

            temp.round();
          }
          if (timeList[i]["main"].containsKey("feels_like")) {
            feels_like = (1.8 * (timeList[i]["main"]["feels_like"] - 273) + 32)
                .toDouble();
            feels_like.round();
          }
          if (timeList[i]["main"].containsKey("humidity")) {
            humidity = timeList[i]["main"]["humidity"].toDouble();
          }
          if (timeList[i]["main"].containsKey("grnd_level")) {
            grnd_level = timeList[i]["main"]["grnd_level"].toDouble();
          }
          if (timeList[i]["wind"].containsKey("speed")) {
            speed = timeList[i]["wind"]["speed"].toDouble();
          }
          if (timeList[i]["wind"].containsKey("deg")) {
            deg = timeList[i]["wind"]["deg"].toDouble();
          }
          if (timeList[i]["wind"].containsKey("gust")) {
            gust = timeList[i]["wind"]["gust"].toDouble();
          }
          if (timeList[i].containsKey("visibility")) {
            visibility = timeList[i]["visibility"].toDouble();
          }

          weatherList.add(weatherLocation(
              arrivalsTimes[j].location,
              weather(
                  timeList[i]["dt_txt"] + ".000Z",
                  temp.toDouble(),
                  feels_like.toDouble(),
                  humidity.toDouble(),
                  id,
                  timeList[i]["weather"][0]["main"],
                  timeList[i]["weather"][0]["description"],
                  speed.toDouble(),
                  deg.toDouble(),
                  gust.toDouble(),
                  visibility.toDouble(),
                  data["addresses"][0]["address"]["municipality"] +
                      ", " +
                      data["addresses"][0]["address"]["countrySubdivision"],
                  grnd_level,
                  destinationTime.toString()),
              ""));
          break;
        } else {
          continue;
        }
      }
    }
    setState(() {
      weatherList;
      processingWeatherData = false;
    });
  }

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
  final theDio.Dio dio = theDio.Dio();
  double bottomPositionedHeight = 10;
  late CameraPosition initialCameraPosition;
  Set<Marker> markers = {};
  IconData buttonIcon = CupertinoIcons.lock_fill;
  ProcessingStatus isProcessing = ProcessingStatus.unLocked;
  Color infomrationColor = Colors.grey;
  Color staringAdressColor = Colors.grey;
  Color destinationAdressColor = Colors.grey;
  bool isLocked = false;
  late double containerHeight = 0.47;
  List colors = [Colors.blue, Colors.grey.shade300, Colors.grey.shade300];
  int decisionListIndex = 0;
  late BitmapDescriptor suvDescriptor;
  late BitmapDescriptor cloudyDescriptor;
  late BitmapDescriptor mcloudyDescriptor;
  late BitmapDescriptor sunDescriptor;
  late BitmapDescriptor rainingDescriptor;
  late BitmapDescriptor thunderDescriptor;
  late BitmapDescriptor windyDescriptor;
  bool shortContianer = false;
  late TabController tabController;
  late TabController tabController1;
  List returnDestinationTime(String time) {
    time = time.toLowerCase();
    time = time.replaceAll("days", "d");
    time = time.replaceAll("hours", "h");
    time = time.replaceAll("mins", "m");
    time = time + " ";
    int days = 0;
    int hours = 0;
    int minutes = 0;
    String parsedString = "";
    int? parsedInt = 0;
    for (int i = 0; i < time.length; i++) {
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
    DateTime answer = DateTime.now();
    answer = answer + days.days + hours.hours + minutes.minutes;
    return [time, answer, days, minutes, hours];
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

      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: destination, bearing: 0, zoom: 13)));
      setState(() {
        destinationLocationName = chosenAddress;
        destinationLocationData.formattedAddress =
            destinationLocationName.formattedAddress;
        destinationLocationData.accidents = 0;
        gatherDestinationLocationGeoCodingData = false;
        first = false;
      });

      setState(() {
        destinationLocation = Marker(
            position: destination,
            markerId: MarkerId("Destination"),
            icon: destinationDescriptor);
        destinationLocationName;
      });
    }
  }

  void searching(String text) async {
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
    List JsonDataList1 = data["features"];
    suggestions = [];
    for (int i = 0; i < JsonDataList1.length; i++) {
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
      subAnswer.formatAddress(countryCode);
      suggestions.add(subAnswer);
    }
    List tempSuggestions = [];
    tempSuggestions.addAll(suggestions);
    distanceList.sort();
    for (int i = 0; i < distanceList.length; i++) {
      suggestions[i] = tempSuggestions[latLongToIndexMap[distanceList[i]]];
    }
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
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: location, bearing: 0, zoom: 13)));
  }

  String numberOfAccidents = "Please Choose";
  int count = 0;
  Future<searchingPlace> reverseGeoCoding(
      double longitude, double latitude) async {
    Response jsonData = await HttpRequests.get(
        "https://api.geoapify.com/v1/geocode/reverse?lat=" +
            latitude.toString() +
            "&lon=" +
            longitude.toString() +
            "&apiKey=" + geoApifyApi,
        headers: {"Accept": "application/json"});
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
    getSettings();
    destinationTime = DateTime.now();
    DirectionsService.init('AIzaSyDtj9GVjhkfqL2Gg1EB6LFyBUW5q2xopqc');
    suvDescriptor = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/suv-car.png",
    );
    destinationDescriptor = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/pin-map.png",
    );

    sunDescriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/small_images/day/sun.png");
    cloudyDescriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/small_images/day/cloudy.png");
    mcloudyDescriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/small_images/day/mild_cloudy.png");
    rainingDescriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/small_images/day/raining.png");
    thunderDescriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/images/small_images/day/thunder.png");
    windyDescriptor = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/images/small_images/day/windy.png");
    latitude = widget.currentLocation.latitude;
    longitude = widget.currentLocation.longitude;
    current = widget.currentLocation;
    initialCameraPosition =
        CameraPosition(target: LatLng(latitude!, longitude!), zoom: 13);
    startingLocation = Marker(
        markerId: const MarkerId("FromMarker"),
        icon: suvDescriptor,
        position: LatLng(latitude!, longitude!),
        onTap: () {});
    setState(() {
      gatheringData = false;
    });
    startingLocationName = await reverseGeoCoding(longitude!, latitude!)
        .whenComplete(() => setState(() {
              startingLocationName;
              gatherCurrentLocationGeoCodingData = false;
            }));
    if (!isLocked) {
      destination = LatLng(widget.destiantionLocation.latitude,
          widget.destiantionLocation.longitude);
      destinationAdressColor = Colors.blue;
      setState(() {
        gatherDestinationLocationGeoCodingData = true;
        first = false;
      });

      reverseGeoCoding(widget.destiantionLocation.longitude,
              widget.destiantionLocation.latitude)
          .then((value) {
        setState(() {
          destinationLocationName = value;
          destinationLocationData.formattedAddress =
              destinationLocationName.formattedAddress;
          gatherDestinationLocationGeoCodingData = false;
        });
      });

      setState(() {
        destinationLocation = Marker(
            position: gMap.LatLng(widget.destiantionLocation.latitude,
                widget.destiantionLocation.longitude),
            markerId: MarkerId("Destination"),
            icon: destinationDescriptor);
        destinationLocationName;
      });

      setState(() {
        weatherList = [];
        buttonIcon = CupertinoIcons.car_detailed;
        isProcessing = ProcessingStatus.isProcessing;

        setState(() {
          isProcessing = ProcessingStatus.dataAvaible;
        });
        isLocked = true;
        infomrationColor = Colors.blue;
      });
      Response answer = await HttpRequests.get(
        "https://maps.googleapis.com/maps/api/directions/json?origin=" +
            startingLocation!.position.latitude.toString() +
            "," +
            startingLocation!.position.longitude.toString() +
            "&destination=" +
            destinationLocation!.position.latitude.toString() +
            "," +
            destinationLocation!.position.longitude.toString() +
            "&key=" + googleMapsApi,
      );
      directionsData = answer.json;
      setState(() {
        directionsData;
      });
      var data = directionsData["routes"][0];

      if (data != null) {
        final northeast = data["bounds"]["northeast"];
        final southwest = data["bounds"]["southwest"];
        bounds = gMap.LatLngBounds(
            southwest: gMap.LatLng(southwest["lat"], southwest["lng"]),
            northeast: gMap.LatLng(northeast["lat"], northeast["lng"]));
        controller
            .animateCamera(gMap.CameraUpdate.newLatLngBounds(bounds, 100));
        if ((data["legs"] as List).isNotEmpty) {
          final leg = data["legs"][0];
          totalDistance = leg["distance"]["text"];
          totalDuration = leg["duration"]["text"];
        } else {
          totalDistance = "0";
          totalDuration = "0";
        }
        pollyLinePoints = PolylinePoints()
            .decodePolyline(data["overview_polyline"]["points"]);
        answers = returnDestinationTime(totalDuration);
        destinationTime = answers[1] as DateTime;
        if (destinationTime.hour > 12) {
          totalDuration = (destinationTime.hour - 12).toString() +
              ":" +
              destinationTime.minute.toString() +
              " PM";
        } else {
          totalDuration = destinationTime.hour.toString() +
              ":" +
              destinationTime.minute.toString() +
              " AM";
        }
        Duration totalTime = DateTime.now().difference(destinationTime);
        destinationLocationData.directionsData = Directions(
            bounds,
            pollyLinePoints,
            totalDistance,
            totalDuration,
            data["overview_polyline"]["points"],
            answers[0]);
      }
      calculationWeather(pollyLinePoints);
      setState(() {
        destinationLocationData;
        isProcessing = ProcessingStatus.dataAvaible;
      });
    }
  }
  void initState() {
    setState(() {
      tabController = TabController(length: 3, vsync: this);
    });
    initStateFunction();
    super.initState();
  }
  late GoogleMapController controller;
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
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    target: LatLng(latitude!, longitude!),
                                    bearing: 0,
                                    zoom: 13)));
                          } else {
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    target: LatLng(destination.latitude,
                                        destination.longitude),
                                    bearing: 0,
                                    zoom: 12)));
                          }
                        }
                      },
                      child: GoogleMap(
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
                                destinationLocation = Marker(
                                    position: latLong,
                                    markerId: MarkerId("Destination"),
                                    icon: destinationDescriptor);
                                destinationLocationName;
                              });
                            }
                          },
                          markers: {
                            if (startingLocation != null) startingLocation!,
                            if (destinationLocation != null)
                              destinationLocation!,
                            ...weatherList.map((e) {
                              late BitmapDescriptor tempIcon;
                              bool flag = false;
                              if (e.weatherData.id == 2) {
                                tempIcon = thunderDescriptor;
                              } else if (e.weatherData.id == 3) {
                                tempIcon = rainingDescriptor;
                              } else if (e.weatherData.id == 5) {
                                tempIcon = rainingDescriptor;
                              } else if (e.weatherData.id == 6) {
                                tempIcon = thunderDescriptor;
                              } else if (e.weatherData.id == 7) {
                                tempIcon = windyDescriptor;
                              } else if (e.weatherData.id == 8) {
                                tempIcon = sunDescriptor;
                              } else if (e.weatherData.id == 9) {
                                tempIcon = mcloudyDescriptor;
                              } else {
                                tempIcon = cloudyDescriptor;
                              }
                              for (int i = 0;
                                  i < authourizedNumbers.length;
                                  i++) {
                                if (authourizedNumbers[i] == e.weatherData.id) {
                                  flag = true;
                                  break;
                                }
                              }
                              if (!flag) {
                                return Marker(
                                  markerId:
                                      MarkerId(e.location.latitude.toString()),
                                  position: e.location,
                                  icon: tempIcon,
                                );
                              } else {
                                return Marker(
                                  markerId:
                                      MarkerId(e.location.latitude.toString()),
                                );
                              }
                            }).toList()
                          },
                          polylines: {
                            gMap.Polyline(
                                polylineId: const gMap.PolylineId("Directions"),
                                color: Colors.blue,
                                width: 10,
                                points: destinationLocationData
                                    .directionsData.polyLinePoints
                                    .map((e) => LatLng(e.latitude, e.longitude))
                                    .toList()),
                            ...roadAccidentList.map((e) {
                              print(e.icon);
                              print(roadAccidentId);

                              if (roadAccidentId.contains(e.icon)) {
                                return gMap.Polyline(
                                    polylineId: gMap.PolylineId(
                                        e.coords[0].latitude.toString()),
                                    zIndex: 100,
                                    color: Colors.red,
                                    width: 20000,
                                    points: e.coords
                                        .map((e) =>
                                            LatLng(e.latitude, e.longitude))
                                        .toList());
                              } else {
                                return gMap.Polyline(
                                  polylineId: gMap.PolylineId(
                                      e.coords[0].latitude.toString()),
                                );
                              }
                            })
                          },
                          compassEnabled: false,
                          mapToolbarEnabled: false,
                          mapType: MapType.hybrid,
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
                                if (buttonIcon == CupertinoIcons.car_detailed) {
                                  setState(() {
                                    weatherList = [];
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
                                if (buttonIcon == CupertinoIcons.lock_fill) {
                                  setState(() {
                                    weatherList = [];
                                    buttonIcon = CupertinoIcons.car_detailed;
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
                                    pollyLinePoints = PolylinePoints()
                                        .decodePolyline(
                                            data["overview_polyline"]
                                                ["points"]);
                                    print(data);
                                    answers =
                                        returnDestinationTime(totalDuration);
                                    destinationTime = answers[1] as DateTime;
                                    String tempDistance =
                                        data["legs"][0]["distance"]["text"];
                                    tempDistance = tempDistance.substring(
                                        0, tempDistance.indexOf(' '));
                                    distance = double.parse(tempDistance);
                                    totalTimeSeconds = answers[4] * 60 * 60 +
                                        answers[3] * 60 +
                                        answers[2] * 25 * 60 * 60;
                                    print(totalTimeSeconds);
                                    print("the lengtdh ting");
                                    if (destinationTime.hour > 12) {
                                      totalDuration =
                                          (destinationTime.hour - 12)
                                              .toString();
                                      if (destinationTime.minute < 10) {
                                        totalDuration = totalDuration +
                                            ":0" +
                                            destinationTime.minute.toString() +
                                            " PM";
                                      } else {
                                        totalDuration = totalDuration +
                                            ":" +
                                            destinationTime.minute.toString() +
                                            " PM";
                                      }
                                    } else {
                                      totalDuration =
                                          destinationTime.hour.toString();
                                      if (destinationTime.minute < 10) {
                                        totalDuration = totalDuration +
                                            ":0" +
                                            destinationTime.minute.toString() +
                                            " AM";
                                      } else {
                                        totalDuration = totalDuration +
                                            ":" +
                                            destinationTime.minute.toString() +
                                            " AM";
                                      }
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
                                  print("here123");
                                  calculationWeather(pollyLinePoints);
                                  print("here123");
                                  if (setting.trafficInfo) {
                                    calculationAccidnets();
                                  }
                                  setState(() {
                                    destinationLocationData;
                                    isProcessing = ProcessingStatus.dataAvaible;
                                  });
                                } else {
                                  print("here");
                                  FirebaseDatabase.instance
                                      .ref("location")
                                      .child(widget.user.phoneNumber)
                                      .child("settings")
                                      .set({
                                    "replyToIncom???ingSMS":
                                        widget.userSettings.replyToIncomingSMS,
                                    "alertSPeeding":
                                        widget.userSettings.alertSpeeding,
                                    "sleepDetection":
                                        widget.userSettings.sleepDetection,
                                    "offlineMode":
                                        widget.userSettings.offlineMode,
                                    "sendSMS": widget.userSettings.sendSMS,
                                    "sendMessageEverXMinutes": widget
                                        .userSettings.sendMessageEverXMinutes,
                                  });
                                  FirebaseDatabase.instance
                                      .ref("location")
                                      .child(widget.user.phoneNumber)
                                      .child("startingLocation")
                                      .set({
                                    "Latitude":
                                        startingLocation!.position.latitude,
                                    "Longitude":
                                        startingLocation!.position.longitude,
                                    "Country": startingLocationName.country,
                                    "State": startingLocationName.state,
                                    "City": startingLocationName.city,
                                    "Street": startingLocationName.street,
                                    "PostalCode": startingLocationName.postcode,
                                    "Formatted":
                                        startingLocationName.formattedAddress
                                  });
                                  FirebaseDatabase.instance
                                      .ref("location")
                                      .child(widget.user.phoneNumber)
                                      .child("destinationLocation")
                                      .set({
                                    "Latitude":
                                        destinationLocation!.position.latitude,
                                    "Longitude":
                                        destinationLocation!.position.longitude,
                                    "Country": destinationLocationName.country,
                                    "State": destinationLocationName.state,
                                    "City": destinationLocationName.city,
                                    "Street": destinationLocationName.street,
                                    "PostalCode":
                                        destinationLocationName.postcode,
                                    "Formatted":
                                        destinationLocationName.formattedAddress
                                  });
                                  FirebaseDatabase.instance
                                      .ref("location")
                                      .child(widget.user.phoneNumber)
                                      .child("travelData")
                                      .set({
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
                                  });
                                  List<Map> firebaseWeatherData = [];
                                  for (int k = 0; k < weatherList.length; k++) {
                                    weatherLocation e = weatherList[k];
                                    firebaseWeatherData.add({
                                      "imageId": e.imageID,
                                      "locationLat": e.location.latitude,
                                      "locationLon": e.location.longitude,
                                      "time": e.weatherData.time,
                                      "temp": e.weatherData.temp,
                                      "feel_like": e.weatherData.feel_like,
                                      "humidity": e.weatherData.humidity,
                                      "id": e.weatherData.id,
                                      "type": e.weatherData.type,
                                      "description": e.weatherData.description,
                                      "windSpeed": e.weatherData.windSpeed,
                                      "windDeg": e.weatherData.windDeg,
                                      "gust": e.weatherData.gust,
                                      "visibility": e.weatherData.visibility,
                                      "cityName": e.weatherData.cityName,
                                      "groundLevel": e.weatherData.groundLevel,
                                    });
                                  }
                                  FirebaseDatabase.instance
                                      .ref("location")
                                      .child(widget.user.phoneNumber)
                                      .child("weather")
                                      .set(firebaseWeatherData);
                                  DataSnapshot edata = await FirebaseDatabase
                                      .instance
                                      .ref("User")
                                      .get();
                                  Map userData = edata.value as Map;
                                  print("stich");
                                  List<String> tokenList = [];
                                  List<String> parentTokenList = [];
                                  for (int i = 0;
                                      i <
                                          widget.user.LocationSharingPeople
                                              .length;
                                      i++) {
                                    if (userData.containsKey(
                                        widget.user.LocationSharingPeople[i])) {
                                      Map curDate = userData[widget.user
                                          .LocationSharingPeople[i]] as Map;
                                      if (curDate.containsKey("FCM")) {
                                        tokenList.add(curDate["FCM"]);
                                        if (curDate.containsKey("Children")) {
                                          if ((curDate["Children"] as List)
                                              .contains(
                                                  widget.user.phoneNumber)) {
                                            parentTokenList.add(curDate["FCM"]);
                                          }
                                        }
                                      }
                                    }
                                  }
                                  for (int i = 0;
                                      i < widget.user.numberList.length;
                                      i++) {
                                    print(widget.user.numberList[i][2]);
                                    print(
                                        userData[widget.user.numberList[i][2]]);
                                    print("message sneder");
                                    BackgroundSms.sendMessage(
                                        phoneNumber: widget
                                            .user.numberList[i][2]
                                            .toString()
                                            .substring(2),
                                        message:
                                            "Dear Recipient, we are sending you this SMS to tell you " +
                                                widget.user.firstName +
                                                " " +
                                                widget.user.lastName +
                                                " has started a journey. Kindly look at the information below for more information.");
                                    if (("starting address : " +
                                                startingLocationName
                                                    .formattedAddress +
                                                "\ndesitnation address : " +
                                                destinationLocationData
                                                    .formattedAddress)
                                            .length >
                                        160) {
                                      BackgroundSms.sendMessage(
                                          phoneNumber: widget
                                              .user.numberList[i][2]
                                              .toString()
                                              .substring(2),
                                          message: "starting address : " +
                                              startingLocationName
                                                  .formattedAddress);
                                      BackgroundSms.sendMessage(
                                          phoneNumber: widget
                                              .user.numberList[i][2]
                                              .toString()
                                              .substring(2),
                                          message: "desitnation address : " +
                                              destinationLocationData
                                                  .formattedAddress);
                                    } else {
                                      BackgroundSms.sendMessage(
                                          phoneNumber: widget
                                              .user.numberList[i][2]
                                              .toString()
                                              .substring(2),
                                          message: "starting address : " +
                                              startingLocationName
                                                  .formattedAddress +
                                              "\ndesitnation address : " +
                                              destinationLocationData
                                                  .formattedAddress);
                                    }

                                    BackgroundSms.sendMessage(
                                        phoneNumber: widget
                                            .user.numberList[i][2]
                                            .toString()
                                            .substring(2),
                                        message: "\ntotal time : " +
                                            destinationLocationData
                                                .directionsData.totalTime +
                                            "\ntotal distance : " +
                                            destinationLocationData
                                                .directionsData.totalDistance);
                                  }
                                  print("i send noptification");
                                  print(tokenList);
                                  sendNotification(
                                      "Trip Started",
                                      tokenList,
                                      widget.user.firstName +
                                          " " +
                                          widget.user.lastName +
                                          " has started on a trip from " +
                                          startingLocationName
                                              .formattedAddress +
                                          " to " +
                                          destinationLocationName
                                              .formattedAddress +
                                          ". Find more data about there location in the map page. do you want to be redirected ?");
                                  await availableCameras().then((value) async {
                                    Uri tomTomURL = await Uri.https(
                                        "api.tomtom.com",
                                        "/search/2/reverseGeocode/" +
                                            latitude.toString() +
                                            "," +
                                            longitude.toString() +
                                            ".json?returnSpeedLimit=true",
                                        {
                                          'key':
                                              tomTomApiKey,
                                          "returnSpeedLimit": true.toString()
                                        });
                                    var tomTomJsonData =
                                        await http.get(tomTomURL);
                                    Map data = jsonDecode(tomTomJsonData.body);
                                    print(data);
                                    DS.drivingData location = DS.drivingData(
                                        latitude!,
                                        longitude!,
                                        "",
                                        "",
                                        "",
                                        "",
                                        "",
                                        0,
                                        0.0,
                                        0.0,
                                        0.0,
                                        0.0);
                                    if (data["addresses"][0]["address"]
                                            ["speedLimit"] !=
                                        null) {
                                      location.speedLimit = double.parse((data[
                                                  "addresses"][0]["address"]
                                              ["speedLimit"] as String)
                                          .substring(
                                              0,
                                              (data["addresses"][0]["address"]
                                                              ["speedLimit"]
                                                          as String)
                                                      .length -
                                                  3));
                                    } else {
                                      location.speedLimit = 25;
                                    }
                                    if (data["addresses"][0]["address"]
                                            ["street"] !=
                                        null) {
                                      location.street = data["addresses"][0]
                                          ["address"]["street"];
                                    }
                                    if (data["addresses"][0]["address"]
                                            ["municipality"] !=
                                        null) {
                                      location.city = data["addresses"][0]
                                          ["address"]["municipality"];
                                    }
                                    if (data["addresses"][0]["address"]
                                            ["countrySubdivisionName"] !=
                                        null) {
                                      location.state = data["addresses"][0]
                                          ["address"]["countrySubdivisionName"];
                                    }
                                    if (data["addresses"][0]["address"]
                                            ["country"] !=
                                        null) {
                                      location.country = data["addresses"][0]
                                          ["address"]["country"];
                                    }
                                    if (data["addresses"][0]["address"]
                                            ["freeformAddress"] !=
                                        null) {
                                      location.formattedAddress =
                                          data["addresses"][0]["address"]
                                              ["freeformAddress"];
                                    }
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => DS.DrivingScreen(
                                                startingLocation!
                                                    .position.latitude,
                                                startingLocation!
                                                    .position.longitude,
                                                destinationLocation!
                                                    .position.latitude,
                                                destinationLocation!
                                                    .position.longitude,
                                                widget.user,
                                                widget.location,
                                                widget.currentLocation,
                                                setting,
                                                value,
                                                location,
                                                destinationLocationData,
                                                startingLocationName
                                                    .formattedAddress,
                                                tokenList,
                                                parentTokenList,
                                                pollyLinePoints,
                                                distance,
                                                totalTimeSeconds)));
                                  });
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
                                                isScrollable: false,
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
                                                    controller.animateCamera(CameraUpdate
                                                        .newCameraPosition(CameraPosition(
                                                            target: LatLng(
                                                                startingLocationName
                                                                    .Latitude,
                                                                startingLocationName
                                                                    .Longitude),
                                                            bearing: 0,
                                                            zoom: 13)));
                                                  } else if (destinationLocationName
                                                          .Latitude !=
                                                      0) {
                                                    controller.animateCamera(CameraUpdate
                                                        .newCameraPosition(CameraPosition(
                                                            target: LatLng(
                                                                destinationLocationName
                                                                    .Latitude,
                                                                destinationLocationName
                                                                    .Longitude),
                                                            bearing: 0,
                                                            zoom: 13)));
                                                  } else {
                                                    controller
                                                        .animateCamera(
                                                            CameraUpdate.zoomBy(
                                                                1))
                                                        .whenComplete(() =>
                                                            controller
                                                                .animateCamera(
                                                                    CameraUpdate
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
                                                            .sun_max_fill,
                                                        size: textSize * 30,
                                                        color:
                                                            decisionListIndex ==
                                                                    0
                                                                ? Colors.grey
                                                                    .shade300
                                                                : colors[
                                                                    decisionListIndex -
                                                                        1],
                                                      ),
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
                                                        Icons.car_crash,
                                                        size: textSize * 30,
                                                        color: colors[2 -
                                                            decisionListIndex],
                                                      ),
                                                    ],
                                                  ),
                                                  height: height * 0.07,
                                                ),
                                              ],
                                              onTap: (value) => setState(() {
                                                    decisionListIndex = value;
                                                    print(decisionListIndex);
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
                                                          ))),
                                                  Container()
                                                ],
                                              )),
                                          Container(
                                            color: Colors.grey.shade300,
                                            child: Column(
                                              children: [
                                                Container(
                                                    width: width * 0.9,
                                                    height: height * 0.08,
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade300,
                                                        border: Border.all(
                                                            color: Colors.blue,
                                                            width: 5),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    50))),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          WeatherWidget(
                                                              clear,
                                                              clearF,
                                                              "assets/images/big_images/morning/sun.png"),
                                                          WeatherWidget(
                                                              cloudy,
                                                              cloudyF,
                                                              "assets/images/big_images/morning/cloudy.png"),
                                                          WeatherWidget(
                                                              mild_cloudy,
                                                              mild_cloudyF,
                                                              "assets/images/big_images/morning/mild_cloudy.png"),
                                                          WeatherWidget(
                                                              raining,
                                                              rainingF,
                                                              "assets/images/big_images/morning/raining.png"),
                                                          WeatherWidget(
                                                              thunder,
                                                              thunderF,
                                                              "assets/images/big_images/morning/thunder.png"),
                                                          WeatherWidget(
                                                              windy,
                                                              windyF,
                                                              "assets/images/big_images/morning/windy.png"),
                                                        ])),
                                                Expanded(
                                                    child: Container(
                                                        child:
                                                            processingWeatherData
                                                                ? lottie.Lottie
                                                                    .network(
                                                                        "https://assets5.lottiefiles.com/packages/lf20_cHA3rG.json")
                                                                : ListView(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            height *
                                                                                0.02),
                                                                    children: [
                                                                      ...weatherList
                                                                          .map(
                                                                              (e) {
                                                                        String
                                                                            link =
                                                                            "";
                                                                        if (e.weatherData.id ==
                                                                            2) {
                                                                          link =
                                                                              "assets/images/big_images/morning/thunder.png";
                                                                        } else if (e.weatherData.id ==
                                                                            3) {
                                                                          link =
                                                                              "assets/images/big_images/morning/raining.png";
                                                                        } else if (e.weatherData.id ==
                                                                            5) {
                                                                          link =
                                                                              "assets/images/big_images/morning/raining.png";
                                                                        } else if (e.weatherData.id ==
                                                                            7) {
                                                                          link =
                                                                              "assets/images/big_images/morning/windy.png";
                                                                        } else if (e.weatherData.id ==
                                                                            8) {
                                                                          link =
                                                                              "assets/images/big_images/morning/sun.png";
                                                                        } else if (e.weatherData.id ==
                                                                            9) {
                                                                          link =
                                                                              "assets/images/big_images/morning/mild_cloudy.png";
                                                                        } else {
                                                                          link =
                                                                              "assets/images/big_images/morning/cloudy.png";
                                                                        }
                                                                        bool
                                                                            flag =
                                                                            false;
                                                                        for (int i =
                                                                                0;
                                                                            i < authourizedNumbers.length;
                                                                            i++) {
                                                                          if (authourizedNumbers[i] ==
                                                                              e.weatherData.id) {
                                                                            flag =
                                                                                true;
                                                                            break;
                                                                          }
                                                                        }
                                                                        String address = e
                                                                            .weatherData
                                                                            .description;
                                                                        for (int i =
                                                                                0;
                                                                            i < address.length;
                                                                            i++) {
                                                                          if (address[i] ==
                                                                              " ") {
                                                                            address.replaceRange(
                                                                                i,
                                                                                i + 1,
                                                                                address[i + 1].toUpperCase());
                                                                          }
                                                                        }
                                                                        print(
                                                                            address);
                                                                        if (!flag) {
                                                                          return weatherShowWidget(
                                                                              link,
                                                                              e.weatherData,
                                                                              e.location,
                                                                              address,
                                                                              onLongTap);
                                                                        } else {
                                                                          return Container();
                                                                        }
                                                                      }).toList()
                                                                    ],
                                                                  )))
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: Colors.grey.shade300,
                                            child: setting.trafficInfo == false
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                        Container(
                                                          height: height * 0.15,
                                                          child: lottie.Lottie
                                                              .network(
                                                                  "https://assets5.lottiefiles.com/private_files/lf30_nhg4au0e.json"),
                                                        ),
                                                        Text(
                                                            "Traffic Data is disabled ",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize:
                                                                    textSize *
                                                                        25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        Text(
                                                            "go into settings and enable\n to get data",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize:
                                                                    textSize *
                                                                        15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700))
                                                      ])
                                                : roadAccidentList.length == 0
                                                    ? calAccident == true
                                                        ? Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                                Container(
                                                                  height:
                                                                      height *
                                                                          0.15,
                                                                  child: lottie
                                                                          .Lottie
                                                                      .network(
                                                                          "https://assets5.lottiefiles.com/private_files/lf30_nhg4au0e.json"),
                                                                ),
                                                                Text(
                                                                    "We are getting the data",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            textSize *
                                                                                25,
                                                                        fontWeight:
                                                                            FontWeight.w700)),
                                                                Text(
                                                                    "please wait patiently",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            textSize *
                                                                                15,
                                                                        fontWeight:
                                                                            FontWeight.w700))
                                                              ])
                                                        : Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                                Container(
                                                                  height:
                                                                      height *
                                                                          0.15,
                                                                  child: lottie
                                                                          .Lottie
                                                                      .network(
                                                                          "https://assets9.lottiefiles.com/packages/lf20_drrpbqcu.json"),
                                                                ),
                                                                Text(
                                                                    "Choose a location",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            textSize *
                                                                                25,
                                                                        fontWeight:
                                                                            FontWeight.w700)),
                                                                Text(
                                                                    "to get further data",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            textSize *
                                                                                15,
                                                                        fontWeight:
                                                                            FontWeight.w700))
                                                              ])
                                                    : Column(children: [
                                                        Column(children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              AccidentWidget(
                                                                  brokenCar,
                                                                  brokenCarF,
                                                                  "assets/images/roadIncidents/brokenCar.png",
                                                                  reset,
                                                                  cleanUp),
                                                              AccidentWidget(
                                                                  carCrash,
                                                                  carCrashF,
                                                                  "assets/images/roadIncidents/carCrash.png",
                                                                  reset,
                                                                  cleanUp),
                                                              AccidentWidget(
                                                                  cautious,
                                                                  cautiousF,
                                                                  "assets/images/roadIncidents/cautious.png",
                                                                  reset,
                                                                  cleanUp),
                                                              AccidentWidget(
                                                                  trafficJam,
                                                                  trafficJamF,
                                                                  "assets/images/roadIncidents/trafficJam.png",
                                                                  reset,
                                                                  cleanUp),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              AccidentWidget(
                                                                  closedLane,
                                                                  closedLaneF,
                                                                  "assets/images/roadIncidents/closedLane.png",
                                                                  reset,
                                                                  cleanUp),
                                                              AccidentWidget(
                                                                  flood,
                                                                  floodF,
                                                                  "assets/images/roadIncidents/flood.png",
                                                                  reset,
                                                                  cleanUp),
                                                              AccidentWidget(
                                                                  rain,
                                                                  rainF,
                                                                  "assets/images/roadIncidents/rain.png",
                                                                  reset,
                                                                  cleanUp),
                                                              AccidentWidget(
                                                                  roadBlock,
                                                                  roadBlockF,
                                                                  "assets/images/roadIncidents/roadBlock.png",
                                                                  reset,
                                                                  cleanUp),
                                                            ],
                                                          ),
                                                        ]),
                                                        SizedBox(
                                                            height:
                                                                height * 0.005),
                                                        Container(
                                                          width: width * 0.9,
                                                          height:
                                                              height * 0.115,
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                  height: 5),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                      "Number of Accidents : ",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          fontSize:
                                                                              textSize * 15)),
                                                                ],
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      FittedBox(
                                                                    child: Text(
                                                                        numberOfAccidents,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.blue,
                                                                            fontWeight: FontWeight.w800)),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          decoration: BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .blue,
                                                                  width: 3),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          25))),
                                                        )
                                                      ]),
                                          )
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
          DateTime currentDateTime = DateTime.parse(widget.data.time).toUtc();
          return weatherDataWidget(widget.data.cityName, widget.data,
              widget.assetLink, currentDateTime, widget.data.time);
        }));
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: width * 0.01),
            Container(
              child: Image.asset(widget.assetLink),
              height: height * 0.09,
              width: height * 0.09,
              padding: EdgeInsets.all(height * 0.01),
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(100))),
            ),
            SizedBox(width: width * 0.01),
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
                              MediaQuery.of(context).textScaleFactor * 17),
                    )
                  ]),
            ),
            Expanded(child: Container()),
            Text(
              widget.data.temp.toInt().toString() + "??",
              style: TextStyle(
                  overflow: TextOverflow.fade,
                  color: Colors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: MediaQuery.of(context).textScaleFactor * 36),
            ),
            SizedBox(width: width * 0.02),
          ],
        ),
        margin: EdgeInsets.only(
            left: width * 0.05, right: width * 0.05, bottom: height * 0.01),
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

class AccidentWidget extends StatefulWidget {
  Color mainColor;
  Function theFunction;
  String assetLink;
  Function start;
  Function cleanUp;
  AccidentWidget(this.mainColor, this.theFunction, this.assetLink, this.start,
      this.cleanUp);
  @override
  State<AccidentWidget> createState() => AccidentWidgetState();
}

class AccidentWidgetState extends State<AccidentWidget> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        widget.start();
        widget.theFunction();
        widget.cleanUp();
      },
      child: Container(
        height: height * 0.1,
        width: height * 0.1,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(
            vertical: height * 0.008, horizontal: height * 0.004),
        child: Image.asset(widget.assetLink),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(
              color: Colors.blue,
              width: widget.mainColor == Colors.blue ? 4 : 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25))),
      ),
    );
  }
}
