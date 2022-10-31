// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';
import 'package:time/time.dart';

import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:drivesafev2/models/DrivingHistoryModel.dart';
import 'package:drivesafev2/models/IdtoFile.dart';
import 'package:drivesafev2/pages/chooseCurrentLocation.dart';
import 'package:drivesafev2/pages/driveStateScreen.dart';
import 'package:drivesafev2/pages/sendNotification.dart';
import 'package:drivesafev2/python/distanceAlgorithm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter/services.dart';
import 'package:background_sms/background_sms.dart';
import 'package:drivesafev2/models/settings.dart';
import 'package:drivesafev2/pages/weatherDataWidget.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:camera/camera.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_state_i/phone_state_i.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gMap;
import 'package:cron/cron.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:drivesafev2/models/User.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_requests/http_requests.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:telephony/telephony.dart';

class blinkSession {
  DateTime timeStarted;
  DateTime timeEnded;
  bool contintuing;
  double latitude;
  double longitude;
  String address;
  int avgBlinksPerMinute = 0;
  blinkSession(this.timeStarted, this.timeEnded, this.contintuing,
      this.latitude, this.longitude, this.address);
}

class drivingData {
  double latitude;
  double longitude;
  String city;
  String country;
  String state;
  String street;
  String formattedAddress;
  double speedLimit = 10;
  int speed;
  double directionX;
  double directionY;
  double directionZ;
  double altitude;
  drivingData(
      this.latitude,
      this.longitude,
      this.city,
      this.country,
      this.state,
      this.street,
      this.formattedAddress,
      this.speed,
      this.directionX,
      this.directionY,
      this.directionZ,
      this.altitude);
}

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
  double latitude;
  double longitude;
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
      this.groundLevel,
      this.latitude,
      this.longitude);
}

class sensorsData {
  double acX = 0;
  double acY = 0;
  double acZ = 0;
  double gyroZ = 0;
  double gryoX = 0;
  double gyroY = 0;
  double magX = 0;
  double magY = 0;
  double magZ = 0;
}

class speedingHistoryVal {
  double speed;
  double speedLimit;
  DateTime time;
  String state;
  String address;
  double latitude;
  double longitude;
  speedingHistoryVal(this.speed, this.speedLimit, this.time, this.state,
      this.address, this.latitude, this.longitude);
}

void sendSms(String number) {}

class DrivingScreen extends StatefulWidget {
  User currentUser;
  Location location;
  double lat;
  double lon;
  gMap.LatLng currentLocation;
  Settings settings;
  List<CameraDescription> cameras;
  drivingData location1;
  placeData destinationLocationData;
  double destLat;
  double destLon;
  List<String> tokens;
  List<String> parentTokens;
  String startingLocation;
  double distance;
  int secondsTime;
  List<PointLatLng> pollyPoints;
  DrivingScreen(
      this.lat,
      this.lon,
      this.destLat,
      this.destLon,
      this.currentUser,
      this.location,
      this.currentLocation,
      this.settings,
      this.cameras,
      this.location1,
      this.destinationLocationData,
      this.startingLocation,
      this.tokens,
      this.parentTokens,
      this.pollyPoints,
      this.distance,
      this.secondsTime);
  @override
  _DrivingScreenState createState() => _DrivingScreenState();
}

enum warningStatus { given, notGiven }

class _DrivingScreenState extends State<DrivingScreen> {
  Timer? timer;
  static const platform = const MethodChannel('sendSms');
  bool currentlyReading = false;
  late CameraController cameraController;
  bool CameraControllerInit = false;
  final player = AudioPlayer();
  AssetSource thingPlay = AssetSource("audio/alert.mp3");
  int polyLineIndex = 0;

  void openNewThing() {
    print("playing");
    player.play(
      thingPlay,
    );
    setState(() {
      amountOfWarningGiven++;
    });
  }

  bool eyesClosed = false;
  List<speedingHistoryVal> speedingHistoryList = [];
  Timer? timer1;
  int smsBlocked = 0;
  int averageBlinksPerMinute = 0;
  int numberOfTimesWarnedBlinks = 0;
  int numberOfTimesWarnedClose = 0;
  int blinksPerMinute = 0;
  int totalBlinkingMinutes = 1;
  DateTime currentTime = DateTime.now();
  List<blinkSession> blinkingHistory = [];
  late DateTime startingTime;
  String distanceTraveled = "";
  List<blinkSession> eyesClosedHistoyr = [];
  DateTime lastTimeEyesOpen = DateTime.now();
  DateTime lastTimeWarnedForEyeClosed = DateTime.now();
  bool blinkStatusWarned = false;
  bool sleepingWarned = false;
  late StreamSubscription gyroEvents;
  late StreamSubscription magnetEvent;
  late StreamSubscription aceloEvents;
  sensorsData userOrientation = new sensorsData();
  bool weatherAlertGiven = true;
  double ogSpeed = 0;
  DateTime lastBlinkingMinute = DateTime.now();
  int alertsGiven = 0;
  Timer? timer2;
  Timer? timer3;
  Timer? timer4;
  Timer? destinationTimeUpdateTimer;
  bool blinkWarned = false;
  int amountOfWarningGiven = 0;
  bool faceDetected = false;
  String currentCity = "";
  weather weatherData =
      weather("", 0, 0, 0, -1, "", "", 0, 0, 0, 0, "", 0, 0.0, 0.0);
  bool speedLimit = false;
  final options = FaceDetectorOptions(performanceMode: FaceDetectorMode.fast);
  final FaceDetector faceDetector = FaceDetector(
      options: FaceDetectorOptions(
          enableContours: true, enableClassification: true));
  bool canProcess = true;
  bool isBusy = false;
  CustomPaint? _customPaint;
  String? text;
  double zoomLevel = 0.0, minZoom = 0.0, maxZoom = 0.0;
  Rect thing = const Offset(1.0, 2.0) & const Size(3.0, 4.0);
  List<Face> faces = [];
  late FlutterTts flutterTTS;
  warningStatus speedLimitWarningStatus = warningStatus.notGiven;
  DateTime lastWarning = DateTime.now().toUtc();
  int currentSpeed = 0;
  int i = 0;
  int callsBlocked = 0;
  int messagesBlocked = 0;
  int warningsGiven = 0;
  bool isDisposed = false;
  double angleZ = 0.0;
  double angleX = 0.0;
  double angleY = 0.0;
  drivingData location = drivingData(0, 0, "", "", "", "", "", 0, 0, 0, 0, 0);
  String openWeatherMapApi = "Insert Open Weather Map API Key here";
  Color thingColor = Colors.blue;
  late StreamSubscription<PhoneStateCallEvent> ting;
  void collectWeatherData() async {
    print("happning");
    setState(() {
      weatherAlertGiven = false;
    });
    Response data2 = await HttpRequests.get(
        "http://api.openweathermap.org/data/2.5/forecast?lat=" +
            location.latitude.toString().trim() +
            "&lon=" +
            location.longitude.toString().trim() +
            "&APPID=" + openWeatherMapApi);

    Map openweatherData = data2.json;
    print(openweatherData);
    List timeList = openweatherData["list"];
    final Map<String, String> queryParameters = {
      'key': "FuxzjRU3KrixEryaiHVPnBhTvrAmbMc4"
    };
    int i = 0;
    DateTime currentDateTime =
        DateTime.parse(timeList[i]["dt_txt"] + ".000Z").toUtc();
    int rawID = timeList[i]["weather"][0]["id"];
    int id = 0;
    if ((rawID >= 200 && rawID <= 212) || (rawID >= 221 && rawID <= 232)) {
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
    print(timeList[i]);
    weatherData = weather(
        DateTime.now().toString(),
        timeList[i]["main"]["temp"].toDouble(),
        timeList[i]["main"]["feels_like"].toDouble(),
        timeList[i]["main"]["humidity"].toDouble(),
        id,
        timeList[i]["weather"][0]["main"],
        timeList[i]["weather"][0]["description"],
        timeList[i]["wind"]["speed"].toDouble(),
        timeList[i]["wind"]["deg"].toDouble(),
        timeList[i]["wind"]["gust"].toDouble(),
        timeList[i]["visibility"].toDouble() / 1000,
        location.city + ", " + location.state,
        timeList[i]["main"]["grnd_level"].toDouble(),
        location.latitude,
        location.longitude);
    setState(() {
      weatherData;
    });

    if (weatherData.id == 2 || weatherData.id == 3 || weatherData.id == 5) {
      print("speaking");
      flutterTTS.speak("You have entered " +
          location.city +
          ", the current temperature is " +
          (1.8 * (weatherData.temp - 273) + 32).toDouble().toInt().toString() +
          "Degrees Farenheit.currently, there is " +
          weatherData.description +
          " and there is a " +
          (weatherData.visibility.toInt() / 1).toString() +
          " Kilometer visibility reading. It is raining, so make sure that you drive slowly, and carefully. Do not talk and focus all attention on driving as 10% of accidents happened during rain. The recommended speed is " +
          (location.speedLimit / 3).toInt().toString());
      sendNotification(
          "Hazardous Weather Conditions",
          widget.tokens,
          widget.currentUser.firstName +
              " " +
              widget.currentUser.lastName +
              " is currently driving in Hazardous conditions. The driver is currently driving in " +
              weatherData.description +
              ", and is in a visility reading of " +
              weatherData.visibility.toString() +
              "KM. Please go to the Map Page Screen for more info.");
    } else if (weatherData.visibility <= 2) {
      print("speaking");
      flutterTTS.speak("You have entered " +
          location.city +
          ", the current temperature is " +
          (1.8 * (weatherData.temp - 273) + 32).toDouble().toInt().toString() +
          "Degrees Farenheit.currently, there is " +
          weatherData.description +
          " and there is a " +
          (weatherData.visibility.toInt() / 1).toString() +
          " Kilometer visibility reading. The visibility rating is very low, so remember to pay full attention to the road, turn on your dash lights, and go very slowly. The recommended speed is " +
          (location.speedLimit / 4).toInt().toString());
      sendNotification(
          "Hazardous Weather Conditions",
          widget.tokens,
          widget.currentUser.firstName +
              " " +
              widget.currentUser.lastName +
              " is currently driving in Hazardous conditions. The driver is currently driving in " +
              weatherData.description +
              ", and is in a visility reading of " +
              weatherData.visibility.toString() +
              "KM. Please go to the Map Page Screen for more info.");
    } else {
      print("speaking");
      flutterTTS.speak("You have entered " +
          location.city +
          ", the current temperature is " +
          (1.8 * (weatherData.temp - 273) + 32).toDouble().toInt().toString() +
          "Degrees Farenheit.currently, there is " +
          weatherData.description +
          " and there is a " +
          (weatherData.visibility.toInt() / 1).toString() +
          " Kilometer visibility reading.");
      sendNotification(
          "New Town",
          widget.tokens,
          widget.currentUser.firstName +
              ' ' +
              widget.currentUser.lastName +
              ' has entered a new town. The driver has entered ' +
              location.city +
              '. Visit the map page screen for more info');
    }
    for (int i = 0; i < widget.currentUser.numberList.length; i++) {
      if (widget.settings.sendSMS) {
        BackgroundSms.sendMessage(
            phoneNumber: widget.currentUser.numberList[i][2],
            message: "We are sending you this message to tell you that " +
                widget.currentUser.firstName +
                " " +
                widget.currentUser.lastName +
                " has entered " +
                location.city +
                ", " +
                location.state +
                ".");
        BackgroundSms.sendMessage(
            phoneNumber: widget.currentUser.numberList[i][2],
            message: "The weather is currently " +
                weatherData.description +
                ", and there is a visibility reading of " +
                weatherData.visibility.toInt().toString() +
                "KM.");
      }
    }
    weatherAlertGiven = true;
  }

  void getStartingLocation() async {
    var tempLocation = await widget.location.getLocation();
    location.latitude = tempLocation.latitude!;
    currentSpeed = (tempLocation.speed! * 2.23694).toInt();
    location.longitude = tempLocation.longitude!;
    widget.lat = location.latitude;
    widget.lon = location.longitude;
    location.speed = 0; //(tempLocation.speed! * 2.23694).toInt();
    location.altitude = tempLocation.altitude!;
    reverseGeoCoding(location.latitude, location.longitude);

    setState(() {
      location;
    });
  }

  void alertSpeedLimit() {
    print("giving warning");
    if (speedLimitWarningStatus == warningStatus.notGiven) {
      setState(() {
        amountOfWarningGiven++;
      });
      flutterTTS.speak("Please Slow Down, you are going " +
          (location.speed - location.speedLimit).toInt().toString() +
          "Miles per hour over the speed limit. The speed Limit is " +
          location.speedLimit.toInt().toString() +
          " Miles per hour");
      speedingHistoryList.add(speedingHistoryVal(
          location.speed.toDouble(),
          location.speedLimit.toDouble(),
          DateTime.now(),
          location.state,
          location.formattedAddress,
          location.latitude,
          location.longitude));
      setState(() {
        speedLimitWarningStatus = warningStatus.given;
        lastWarning = DateTime.now().toUtc();
      });
      for (int i = 0; i < widget.currentUser.numberList.length; i++) {
        print("We are sending this message to inform you that " +
            widget.currentUser.firstName +
            " is going above the speed limit. The speed limit is currently " +
            location.speedLimit.toString() +
            "MPH. " +
            widget.currentUser.firstName +
            " is going " +
            location.speed.toString() +
            " MPH.");
        if (widget.settings.alertSpeeding) {
          sendNotification(
              "Speeding Alert",
              widget.tokens,
              widget.currentUser.firstName +
                  " " +
                  widget.currentUser.lastName +
                  " is currently speeding. The driver is going " +
                  currentSpeed.toInt().toString() +
                  "MPH in an area with a speed limit of " +
                  location.speedLimit.toInt().toString() +
                  ". go to the map page screen for more info. Do you want to be re-directed ? ");
        } else {
          sendNotification(
              "Speeding Alert",
              widget.parentTokens,
              widget.currentUser.firstName +
                  " " +
                  widget.currentUser.lastName +
                  " is currently speeding. The driver is going " +
                  currentSpeed.toInt().toString() +
                  "MPH in an area with a speed limit of " +
                  location.speedLimit.toInt().toString() +
                  ". go to the map page screen for more info. Do you want to be re-directed ? ");
        }

        if (widget.settings.sendSMS) {
          if (widget.settings.alertSpeeding) {
            BackgroundSms.sendMessage(
                phoneNumber: widget.currentUser.numberList[i][2],
                message: "We are sending this message to inform you that " +
                    widget.currentUser.firstName +
                    " is going above the speed limit. The speed limit is currently " +
                    location.speedLimit.toString() +
                    "MPH. " +
                    widget.currentUser.firstName +
                    " is going " +
                    location.speed.toString() +
                    " MPH.");
            print(widget.currentUser.firstName +
                " " +
                widget.currentUser.lastName +
                " is currently at " +
                location.formattedAddress);
            BackgroundSms.sendMessage(
                phoneNumber: widget.currentUser.numberList[i][2],
                message: widget.currentUser.firstName +
                    " " +
                    widget.currentUser.lastName +
                    " is currently at " +
                    location.formattedAddress);
          }
        }
      }
    } else {
      if ((DateTime.now().toUtc()).difference(lastWarning).inSeconds > 60) {
        setState(() {
          amountOfWarningGiven++;
        });
        flutterTTS.speak("Please Slow Down, you are going " +
            (location.speed - location.speedLimit).toInt().toString() +
            "Miles per hour over the speed limit. The speed Limit is " +
            location.speedLimit.toInt().toString() +
            "Miles per hour");
        speedingHistoryList.add(speedingHistoryVal(
            location.speed.toDouble(),
            location.speedLimit.toDouble(),
            DateTime.now(),
            location.state,
            location.formattedAddress,
            location.latitude,
            location.longitude));
        for (int i = 0; i < widget.currentUser.numberList.length; i++) {
          print("We are sending this message to inform you that " +
              widget.currentUser.firstName +
              " is going above the speed limit. The speed limit is currently " +
              location.speedLimit.toString() +
              "MPH. " +
              widget.currentUser.firstName +
              " is going " +
              location.speed.toString() +
              " MPH.");
          if (widget.settings.sendSMS) {
            BackgroundSms.sendMessage(
                phoneNumber: widget.currentUser.numberList[i][2],
                message: "We are sending this message to inform you that " +
                    widget.currentUser.firstName +
                    " is going above the speed limit. The speed limit is currently " +
                    location.speedLimit.toString() +
                    "MPH. " +
                    widget.currentUser.firstName +
                    " is going " +
                    location.speed.toString() +
                    " MPH.");
            BackgroundSms.sendMessage(
                phoneNumber: widget.currentUser.numberList[i][2],
                message: widget.currentUser.firstName +
                    " " +
                    widget.currentUser.lastName +
                    " is currently at " +
                    location.formattedAddress);
          }
        }
        setState(() {
          lastWarning = DateTime.now().toUtc();
        });
      }
    }
  }

  String sendData1 = "";
  String sendData2 = "";
  double prevSpeed = 0;
  bool warningCareFul = false;
  List<Map> hardDeceleration = [];
  void checkForHardDeceleration(prevSpeed, curSpeed) {
    if ((prevSpeed - curSpeed).toInt() > 10) {
      if (warningCareFul == false) {
        flutterTTS.speak("Please be careful when you are decelerating");
        setState(() {
          amountOfWarningGiven++;
        });
        for (int i = 0; i < widget.currentUser.numberList.length; i++) {
          print("We are sending this message to inform you that " +
              widget.currentUser.firstName +
              " is going above the speed limit. The speed limit is currently " +
              location.speedLimit.toString() +
              "MPH. " +
              widget.currentUser.firstName +
              " is going " +
              location.speed.toString() +
              " MPH.");
          if (widget.settings.sendSMS) {
            BackgroundSms.sendMessage(
                phoneNumber: widget.currentUser.numberList[i][2],
                message: "We are sending this message to inform you that " +
                    widget.currentUser.firstName +
                    " " +
                    widget.currentUser.lastName +
                    " has participated in a harsh break.");
            BackgroundSms.sendMessage(
                phoneNumber: widget.currentUser.numberList[i][2],
                message: widget.currentUser.firstName +
                    " " +
                    widget.currentUser.lastName +
                    " is currently at " +
                    location.formattedAddress);
          }
        }
        hardDeceleration.add({
          "lat": location.latitude,
          "lon": location.longitude,
          "location": location.formattedAddress,
          "time": DateTime.now().toString(),
          "from": prevSpeed,
          "to": currentSpeed,
        });
        sendNotification(
            "Harsh Break Alert",
            widget.tokens,
            widget.currentUser.firstName +
                " " +
                widget.currentUser.lastName +
                " has participated in a harsh break. Go to the Map Page Screen for more data about the drivers trip stats.");
      }
      warningCareFul = true;
    } else {
      warningCareFul = false;
    }
  }

  bool checkForCrash() {
    if (prevSpeed - currentSpeed > 0) {
      if (currentSpeed == 0) {
        if (faces.length == 0) {
          if (angleX > 7.5 && angleX < 30 - 7.5) {
            if (angleZ > 2 && angleZ < 28) {
              setState(() {
                alertsGiven++;
              });
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  bool crashCheck = false;
  bool hasCrashed = false;
  String tomTomApiKey = "Insert API Key";
  String googleMapsApi  = "Insert API Key";
  Map crashData = {};
  @override
  late StreamSubscription<LocationData> locationChangeThing;
  void reverseGeoCoding(double longitude, double latitude) async {
    //, -
    Uri tomTomURL = await Uri.https(
        "api.tomtom.com",
        "/search/2/reverseGeocode/" +
            longitude.toString() +
            "," +
            latitude.toString() +
            ".json?returnSpeedLimit=true",
        {
          'key': tomTomApiKey,
          "returnSpeedLimit": true.toString()
        });
    var tomTomJsonData = await http.get(tomTomURL);
    Map data = jsonDecode(tomTomJsonData.body);
    print(data);
    if (data["addresses"][0]["address"]["speedLimit"] != null) {
      location.speedLimit = double.parse(
          (data["addresses"][0]["address"]["speedLimit"] as String).substring(
              0,
              (data["addresses"][0]["address"]["speedLimit"] as String).length -
                  3));
    } else {
      location.speedLimit = 50;
    }
    if (data["addresses"][0]["address"]["street"] != null) {
      location.street = data["addresses"][0]["address"]["street"];
    }
    if (data["addresses"][0]["address"]["municipality"] != null) {
      location.city = data["addresses"][0]["address"]["municipality"];
    }
    if (data["addresses"][0]["address"]["countrySubdivisionName"] != null) {
      location.state =
          data["addresses"][0]["address"]["countrySubdivisionName"];
    }
    if (data["addresses"][0]["address"]["country"] != null) {
      location.country = data["addresses"][0]["address"]["country"];
    }
    if (data["addresses"][0]["address"]["freeformAddress"] != null) {
      location.formattedAddress =
          data["addresses"][0]["address"]["freeformAddress"];
    }
    setState(() {
      location;
    });
  }

  void setUpCamera() {
    cameraController = CameraController(
        widget.cameras[1], ResolutionPreset.high,
        enableAudio: false);

    setState(() {
      cameraSetup = true;
      faceDetector;
      cameraController;
    });
    cameraController.initialize().then((value) {
      if (!mounted) return;
      cameraController.getMaxZoomLevel().then((val) {
        maxZoom = val;
      });
      cameraController.getMinZoomLevel().then((val) {
        minZoom = val;
        zoomLevel = val;
      });
      cameraController.startImageStream((image) async {
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plan in image.planes) {
          allBytes.putUint8List(plan.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();
        final camera = widget.cameras[1];
        final imageRotation =
            InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
                InputImageRotation.rotation0deg;
        final inputImageFormat =
            InputImageFormatValue.fromRawValue(image.format.raw) ??
                InputImageFormat.nv21;
        final planeData = image.planes.map((final Plane plane) {
          return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width);
        }).toList();
        final imageSize = Size(image.width.toDouble(), image.height.toDouble());
        final inputImageData = InputImageData(
            size: imageSize,
            imageRotation: imageRotation,
            inputImageFormat: inputImageFormat,
            planeData: planeData);
        final inputImage =
            InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
        if (!canProcess) {
          return;
        }
        if (isBusy) {
          return;
        }
        isBusy = true;
        final faces = await faceDetector.processImage(inputImage);

        print(faces);
        if (faces.length > 0) {
          if (faces[0].leftEyeOpenProbability! < 0.5) {
            eyesClosed = true;
            print("secs");
            print(abs(lastTimeEyesOpen.difference(DateTime.now()).inSeconds));
            if (abs(lastTimeEyesOpen.difference(DateTime.now()).inSeconds) >
                2) {
              print("here is the thing");
              if (sleepingWarned == false) {
                sleepingWarned = true;
                openNewThing();
                print("sound playing");

                eyesClosedHistoyr.add(blinkSession(
                    DateTime.now(),
                    DateTime.now(),
                    true,
                    location.latitude,
                    location.longitude,
                    location.formattedAddress));

                sendNotification(
                    "!!!Sleepy Alert!!!",
                    widget.tokens,
                    widget.currentUser.firstName +
                        " " +
                        widget.currentUser.lastName +
                        " has closed his eyes for an extended period of time. We are suspecting that he has fallen asleep behind the wheel. Check the Map Page Screen for more info.");
                setState(() {
                  alertsGiven++;
                });
                for (int i = 0; i < widget.currentUser.numberList.length; i++) {
                  if (widget.settings.sendSMS) {
                    BackgroundSms.sendMessage(
                        phoneNumber: widget.currentUser.numberList[i][2],
                        message:
                            "We are sending you this message to tell you that " +
                                widget.currentUser.firstName +
                                " " +
                                widget.currentUser.lastName +
                                " has closed his eyes for a long time");
                    BackgroundSms.sendMessage(
                        phoneNumber: widget.currentUser.numberList[i][2],
                        message: widget.currentUser.firstName +
                            " " +
                            widget.currentUser.lastName +
                            " is currently at " +
                            location.formattedAddress);
                  }
                }
                numberOfTimesWarnedClose++;
              } else {
                eyesClosedHistoyr[eyesClosedHistoyr.length - 1].timeEnded =
                    DateTime.now();
                eyesClosedHistoyr[eyesClosedHistoyr.length - 1].contintuing =
                    true;
              }
            } else {
              if (abs(DateTime.now().difference(lastBlinkingMinute).inMinutes) <
                  1) {
                if (blinksPerMinute == 0) {
                  lastBlinkingMinute = DateTime.now();
                }
              } else {
                lastBlinkingMinute = DateTime.now();
              }
            }
          } else {
            print("opejn");
            lastTimeEyesOpen = DateTime.now();

            if (eyesClosed) {
              eyesClosed = false;
              blinksPerMinute++;
            }
            if (sleepingWarned == true) {
              sleepingWarned = false;
              eyesClosedHistoyr[eyesClosedHistoyr.length - 1].timeEnded =
                  DateTime.now();
              eyesClosedHistoyr[eyesClosedHistoyr.length - 1].contintuing =
                  false;
              print("tryuing to stop");
              player.stop();
            }
          }
        } else {
          faceDetected = false;
        }
        print(eyesClosed);
        print("blinks per minute : " + blinksPerMinute.toString());
        isBusy = false;
        if (mounted) {
          setState(() {});
        }
      });
      setState(() {});
    });
  }

  void initialization() async {
    flutterTTS = FlutterTts();
    flutterTTS.setLanguage("en-US");
    flutterTTS.setPitch(1);
    FirebaseDatabase.instance
        .ref("User")
        .child(widget.currentUser.phoneNumber)
        .child("isDriving")
        .set(true);
  }

  LatLng previousLocation = LatLng(0, 0);
  bool cameraSetup = false;
  Telephony telephony = Telephony.instance;
  bool s3ndSMS = true;
  void initStateFunction() async {
    FirebaseDatabase.instance
        .ref("location")
        .child(widget.currentUser.phoneNumber)
        .child("isDriving")
        .set(true);
    startingTime = DateTime.now();
    bool? falg = await FlutterDnd.isNotificationPolicyAccessGranted;
    var now = DateTime.now();
    if (falg!) {
      await FlutterDnd.setInterruptionFilter(
          FlutterDnd.INTERRUPTION_FILTER_ALARMS);
    } else {
      FlutterDnd.gotoPolicySettings();
    }
    bool? permissionsGranted = await telephony.requestSmsPermissions;
  }

  double calc(double angle) {
    if (angle < 0) {
      angle = angle + 600;
    } else if (angle > 600) {
      angle = angle - 600;
    }
    return angle;
  }

  void initState() {
    if (widget.settings.sleepDetection) {
      setUpCamera();
    }
    if (widget.settings.replyToIncomingSMS) {
      print("listening");
      telephony.listenIncomingSms(
          onNewMessage: (SmsMessage message) {
            print("message here");
            print(s3ndSMS);
            print(widget.settings.sendSMS);
            if (s3ndSMS && widget.settings.sendSMS) {
              print("hj");
              smsBlocked++;
              setState(() {
                smsBlocked;
              });
              BackgroundSms.sendMessage(
                  phoneNumber: message.address!,
                  message:
                      "I am currently driving, i will reply to you as soon as i can");
            }
          },
          listenInBackground: false);
    }

    initStateFunction();

    ting = phoneStateCallEvent.listen((PhoneStateCallEvent event) {
      //print('Call is Incoming/Connected' + event.stateC);
      if (event.stateC == "true") {
        callsBlocked++;
      }
      //event.stateC has values "true" or "false"
    });
    setState(() {
      location = widget.location1;
    });
    getStartingLocation();
    previousLocation = LatLng(location.latitude, location.longitude);
    Permission.sms.request();
    initialization();
    super.initState();

    // [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]

    gyroEvents = gyroscopeEvents.listen((GyroscopeEvent event) {
      double z = roundDouble(event.z, 2);
      double x = roundDouble(event.x, 2);
      double y = roundDouble(event.y, 1);
      angleZ = angleZ - z;
      angleX = angleX - x;

      angleZ = calc(angleZ);
      angleX = calc(angleX);
      angleY = angleY - y;
      angleY = calc(angleY);
      setState(() {
        angleX;
        angleY;
        angleZ;
      });
    });

    destinationTimeUpdateTimer =
        Timer.periodic(const Duration(minutes: 1), (c) async {
      print("data gathered");
      if (findDistance1(location.latitude, location.longitude,
                  previousLocation.latitude, previousLocation.longitude)!
              .toDouble() <=
          0.5) {
        Response data = await HttpRequests.get(
            "https://maps.googleapis.com/maps/api/distancematrix/json?origins=" +
                location.latitude.toString() +
                "%2c" +
                location.longitude.toString() +
                "&destinations=" +
                widget.destLat.toString() +
                "%2c" +
                widget.destLon.toString() +
                "&units=imperial&key=" + googleMapsApi);
        String arrivalTimeE =
            data.json["rows"][0]["elements"][0]["duration"]["text"];
        int min = 0;
        int hours = 0;
        int days = 0;
        String parsingText = "";
        String parsedInt = "";
        for (int i = 0; i < arrivalTimeE.length; i++) {
          if (arrivalTimeE[i] == ' ') {
            if (arrivalTimeE[i] == 'mins') {
              min = int.parse(parsedInt);
            } else if (arrivalTimeE[i] == 'hours') {
              hours = int.parse(parsedInt);
            } else if (arrivalTimeE[i] == 'days') {
              days = int.parse(parsedInt);
            } else {
              parsedInt = parsingText;
            }
            parsingText = "";
          } else {
            parsingText = parsingText + arrivalTimeE[i];
          }
        }
        arrivalTimeE = arrivalTimeE.replaceAll("mins", "m");
        arrivalTimeE = arrivalTimeE.replaceAll("hours", "hr");
        arrivalTimeE = arrivalTimeE.replaceAll("days", "d");
        FirebaseDatabase.instance
            .ref("location")
            .child(widget.currentUser.phoneNumber)
            .child("travelData")
            .child("DuartionTime")
            .set(arrivalTimeE);
        DateTime finalArrivalTime =
            DateTime.now() + hours.hours + min.minutes + days.days;
        arrivalTimeE = finalArrivalTime.hour.toString();
        if (finalArrivalTime.minute < 10) {
          arrivalTimeE =
              arrivalTimeE + ":0" + finalArrivalTime.minute.toString();
        } else {
          arrivalTimeE =
              arrivalTimeE + ":" + finalArrivalTime.minute.toString();
        }
        print(arrivalTimeE);
        print("this is the arrivalTime");
        FirebaseDatabase.instance
            .ref("location")
            .child(widget.currentUser.phoneNumber)
            .child("travelData")
            .child("ArrivalsTime")
            .set(arrivalTimeE);
      }
      previousLocation = LatLng(location.latitude, location.longitude);
    });
    locationChangeThing = widget.location.onLocationChanged.listen((event) {
      location.latitude = event.latitude!;
      location.longitude = event.longitude!;
      flutterTTS.setStartHandler(() {
        setState(() {
          weatherAlertGiven = false;
        });
      });
      if (event.speed == null) {
        location.speed = 0;
      } else {
        prevSpeed = location.speed.toDouble();
        ogSpeed = location.speed.toDouble();
        location.speed = location.speed + 1;
      }
      location.altitude = event.altitude!;
    });
    timer4 = Timer.periodic(const Duration(seconds: 30), (timer) {
      reverseGeoCoding(location.latitude, location.longitude);
    });
    int crashActiveTime = 0;
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      print(ogSpeed);
      print(distanceTraveled);
      print("dis is it");
      if (checkForCrash()) {
        setState(() {
          crashCheck = true;
        });
        if (crashActiveTime > 7) {
          String time = "";
          time = DateTime.now().hour.toString() + ":";
          if (DateTime.now().minute < 10) {
            time = time + "0" + DateTime.now().minute.toString();
          } else {
            time = time + DateTime.now().minute.toString();
          }
          hasCrashed = true;
          crashData = {
            //36.35766400898095, -94.24084376818925
            "latitude": location.latitude,
            "longitude": location.longitude,
            "location": location.formattedAddress,
            "time": DateTime.now()
          };
          sendNotification(
              "!!!Crash Alert!!!",
              widget.tokens,
              widget.currentUser.firstName +
                  " " +
                  widget.currentUser.lastName +
                  " seems to have been in a crash. Please visit the Maps Page to learn about the location of the crash, and etc. Contact any authory if needed.");
          for (int i = 0; i < widget.currentUser.numberList.length; i++) {
            if (widget.settings.sendSMS) {
              BackgroundSms.sendMessage(
                  phoneNumber: widget.currentUser.numberList[i][2],
                  message: "We are sending this message to inform you that " +
                      widget.currentUser.firstName +
                      " " +
                      widget.currentUser.lastName +
                      " has been identified in a crash. Here are some important data you might need.");
              BackgroundSms.sendMessage(
                  phoneNumber: widget.currentUser.numberList[i][2],
                  message: "Address : " +
                      location.formattedAddress +
                      "\nTime : " +
                      time);
              BackgroundSms.sendMessage(
                  phoneNumber: widget.currentUser.numberList[i][2],
                  message: "Location Link : " +
                      "https://maps.google.com/?q=" +
                      location.latitude.toString() +
                      "," +
                      location.longitude.toString());
            }
          }
        } else {
          crashActiveTime++;
        }
      } else {
        crashActiveTime = 0;
        print(prevSpeed);
        print("speed ting");
        checkForHardDeceleration(prevSpeed, location.speed);
      }
      setState(() {
        averageBlinksPerMinute =
            (blinksPerMinute / totalBlinkingMinutes).toInt();
        totalBlinkingMinutes++;
        eyesClosedHistoyr;
      });
      if (blinksPerMinute < 10 &&
          abs(DateTime.now().difference(lastBlinkingMinute).inMinutes) >= 1 &&
          blinksPerMinute != 0) {
        lastBlinkingMinute = DateTime.now();
        if (blinkingHistory.length > 0) {
          if (blinkingHistory[blinkingHistory.length - 1].contintuing) {
            blinkingHistory[blinkingHistory.length - 1].timeEnded =
                DateTime.now();
            blinkingHistory[blinkingHistory.length - 1].avgBlinksPerMinute =
                blinksPerMinute;
            blinkingHistory[blinkingHistory.length - 1].contintuing = false;
          } else {
            blinkingHistory.add(blinkSession(
                DateTime.now(),
                DateTime.now(),
                true,
                location.latitude,
                location.longitude,
                location.formattedAddress));
            blinkingHistory[blinkingHistory.length - 1].avgBlinksPerMinute =
                blinksPerMinute;
          }
        } else {
          blinkingHistory.add(blinkSession(
              DateTime.now(),
              DateTime.now(),
              true,
              location.latitude,
              location.longitude,
              location.formattedAddress));
          blinkingHistory[blinkingHistory.length - 1].avgBlinksPerMinute =
              blinksPerMinute;
        }
        if (blinkStatusWarned) {
          if (abs(lastTimeWarnedForEyeClosed
                  .difference(DateTime.now())
                  .inMinutes) >
              3) {
            if (numberOfTimesWarnedBlinks > 10) {
              if (abs(lastTimeWarnedForEyeClosed
                      .difference(DateTime.now())
                      .inMinutes) >
                  (numberOfTimesWarnedBlinks / 2).toInt()) {
                lastTimeWarnedForEyeClosed = DateTime.now();
                flutterTTS.speak(
                    "According to some data that we have collected, it seems that you are drowsy. Please stop and take a break for your safetey and the safetey of the people around you");
                setState(() {
                  amountOfWarningGiven++;
                });
                sendNotification(
                    "Drowsy Alert",
                    widget.tokens,
                    widget.currentUser.firstName +
                        " " +
                        widget.currentUser.lastName +
                        " seems to be drowsy. He is blinking at " +
                        averageBlinksPerMinute.toString() +
                        ". An awake person blinks 10 or more times per minute");
              }
            } else {
              lastTimeWarnedForEyeClosed = DateTime.now();
              setState(() {
                amountOfWarningGiven++;
              });
              flutterTTS.speak(
                  "According to some data that we have collected, it seems that you are drowsy. Please stop and take a break for your safetey and the safetey of the people around you");
              sendNotification(
                  "Drowsy Alert",
                  widget.tokens,
                  widget.currentUser.firstName +
                      " " +
                      widget.currentUser.lastName +
                      " seems to be drowsy. He is blinking at " +
                      averageBlinksPerMinute.toString() +
                      ". An awake person blinks 10 or more times per minute");
            }
          }
        } else {
          lastTimeWarnedForEyeClosed = DateTime.now();
          setState(() {
            amountOfWarningGiven++;
          });
          flutterTTS.speak(
              "According to some data that we have collected, it seems that you are drowsy. Please stop and take a break for your safetey and the safetey of the people around you");
          sendNotification(
              "Drowsy Alert",
              widget.tokens,
              widget.currentUser.firstName +
                  " " +
                  widget.currentUser.lastName +
                  " seems to be drowsy. He is blinking at " +
                  averageBlinksPerMinute.toString() +
                  ". An awake person blinks 10 or more times per minute");
        }
        blinksPerMinute = 0;
      } else {
        if (abs(DateTime.now().difference(lastBlinkingMinute).inMinutes) >= 1) {
          lastBlinkingMinute = DateTime.now();
          blinkStatusWarned = false;
          if (blinkingHistory.length > 0) {
            if (blinkingHistory[blinkingHistory.length - 1].contintuing) {
              blinkingHistory[blinkingHistory.length - 1].contintuing = false;
            }
          }
        }
      }

      setState(() {
        thingColor;
      });
      print(location.speedLimit);
      print(weatherAlertGiven);
      if (currentCity == location.city) {
        if (location.speed > location.speedLimit + 3) {
          speedLimit = true;
          alertSpeedLimit();
        } else {
          speedLimit = false;
        }
        setState(() {
          speedLimit;
        });
      } else {
        collectWeatherData();
        setState(() {
          currentCity = location.city;
        });
      }
      setState(() {
        location;
        speedLimit;
      });

      FirebaseDatabase.instance
          .ref("location")
          .child(widget.currentUser.phoneNumber)
          .child("locationData")
          .set({
        "faceDetected": faceDetected,
        "blinksPerMinute": blinksPerMinute,
        "blinksWarnings": numberOfTimesWarnedBlinks,
        "averageBlinksPerMinute": averageBlinksPerMinute,
        "longBlinkWarnings": numberOfTimesWarnedClose,
        "eyesClosedWarning": eyesClosedHistoyr.length,
        "hardDecelerationList": hardDeceleration,
        "crashed": hasCrashed,
        "crashAlerts": crashData,
        "blinkProblemHistory": blinkingHistory.map((e) {
          return {
            "contitnue": e.contintuing,
            "timeEnded": e.timeEnded.toString(),
            "timeStarted": e.timeStarted.toString(),
            "latitude": e.latitude,
            "longitude": e.longitude,
            "address": e.address,
          };
        }).toList(),
        "closeProblemHistory": eyesClosedHistoyr.map((e) {
          return {
            "contitnue": e.contintuing,
            "timeEnded": e.timeEnded.toString(),
            "timeStarted": e.timeStarted.toString(),
            "latitude": e.latitude,
            "longitude": e.longitude,
            "address": e.address,
          };
        }).toList(),
        "callsBlocked": callsBlocked,
        "latitude": location.latitude,
        "longitude": location.longitude,
        "speed": location.speed,
        "altitude": location.altitude,
        "firstName": widget.currentUser.firstName,
        "lastName": widget.currentUser.lastName,
        "city": location.city,
        "country": location.country,
        "Gx": angleX,
        "Gy": angleY,
        "Gz": angleZ,
        "formattedAddress": location.formattedAddress,
        "speedLimit": location.speedLimit,
        "state": location.state,
        "description": weatherData.description,
        "time": weatherData.time,
        "temp": weatherData.temp,
        "feel_like": weatherData.feel_like,
        "humidity": weatherData.humidity,
        "id": weatherData.id,
        "windSpeed": weatherData.windSpeed,
        "windDeg": weatherData.windDeg,
        "gust": weatherData.gust,
        "visibility": weatherData.visibility,
        "cityName": weatherData.cityName,
        "groundLevel": weatherData.groundLevel,
        "smsBlocked": smsBlocked,
        "alertsGiven": alertsGiven,
        "warningsGiven": amountOfWarningGiven,
        "phoneCallsBlocked": callsBlocked,
        "weatherLastTakenLat": weatherData.latitude.toString(),
        "weatherLastTakenLon": weatherData.longitude.toString(),
        "isSpeeding": speedLimit,
        "speedingHistory": speedingHistoryList.map((e) {
          return {
            "latitude": e.latitude,
            "longitude": e.longitude,
            "speed": e.speed,
            "speedLimit": e.speedLimit,
            "DateTime": e.time.toString(),
            "state": e.state,
            "Address": e.address,
          };
        }).toList(),
      });
    });

    timer2 = Timer.periodic(
        Duration(minutes: widget.settings.sendMessageEverXMinutes), (timer) {
      for (int i = 0; i < widget.currentUser.numberList.length; i++) {
        if (widget.settings.sendSMS) {
          BackgroundSms.sendMessage(
              phoneNumber: widget.currentUser.numberList[i][2],
              message: "https://maps.google.com/?q=" +
                  location.latitude.toString() +
                  "," +
                  location.longitude.toString());
          BackgroundSms.sendMessage(
              phoneNumber: widget.currentUser.numberList[i][2],
              message: "Location Data : \n State : " +
                  location.state.toString() +
                  "\n City : " +
                  location.city.toString() +
                  "\n Street : " +
                  location.street.toString());
          BackgroundSms.sendMessage(
              phoneNumber: widget.currentUser.numberList[i][2],
              message: "General Data : \n Speed : " +
                  location.speed.toString() +
                  " MPH\n Limit : " +
                  location.speedLimit.toInt().toString() +
                  " MPH\n visibility : " +
                  weatherData.visibility.toInt().toString() +
                  "KM\n Weather Description : " +
                  weatherData.description);
        }
      }
    });
    //player.setVolume(1);
    player.setReleaseMode(ReleaseMode.loop);
  }

  void dispose() {
    timer?.cancel();
    timer2?.cancel();
    timer4?.cancel();
    canProcess = false;
    gyroEvents.cancel();
    locationChangeThing.cancel();
    ting.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: Stack(
          children: [
            Container(
              width: width,
              height: height,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: height * 0.01,
                        right: height * 0.01,
                        top: height * 0.04),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: height * 0.08,
                            width: height * 0.08,
                            child: NeumorphicButton(
                                onPressed: () async {
                                  setState(() {
                                    isDisposed = true;
                                  });
                                  locationChangeThing.cancel();
                                  gyroEvents.cancel();
                                  if (widget.settings.sleepDetection) {
                                    cameraController.stopImageStream();
                                    cameraController.dispose();
                                  }
                                  timer!.cancel();
                                  timer2!.cancel();
                                  timer4!.cancel();
                                  s3ndSMS = false;
                                  ting.cancel();
                                  // get the total distance traveled through API

                                  Response data = await HttpRequests.get(
                                      "https://maps.googleapis.com/maps/api/distancematrix/json?origins=" +
                                          widget.lat.toString() +
                                          "%2c" +
                                          widget.lon.toString() +
                                          "&destinations=" +
                                          location.latitude.toString() +
                                          "%2c" +
                                          location.longitude.toString() +
                                          "&units=imperial&key=" + googleMapsApi);
                                  distanceTraveled = data.json["rows"][0]
                                      ["elements"][0]["distance"]["text"];
                                  print(widget.lat);
                                  print(widget.lon);
                                  print(location.latitude);
                                  print(location.longitude);
                                  print(distanceTraveled);
                                  print("end data");
                                  // get the total time it took
                                  String timeTaken = "";
                                  Duration ttd =
                                      DateTime.now().difference(startingTime);
                                  if (ttd.inDays > 0) {
                                    timeTaken = timeTaken +
                                        ttd.inDays.toString() +
                                        " D ";
                                  }
                                  if (ttd.inHours > 0) {
                                    if (ttd.inHours > 24) {
                                      timeTaken = timeTaken +
                                          (ttd.inHours % 24).toString() +
                                          " H ";
                                    } else {
                                      timeTaken = timeTaken +
                                          ttd.inHours.toString() +
                                          " H ";
                                    }
                                  }
                                  if (ttd.inMinutes > 0) {
                                    if (ttd.inMinutes > 60) {
                                      timeTaken = timeTaken +
                                          (ttd.inMinutes % 60).toString() +
                                          " M ";
                                    } else {
                                      timeTaken = timeTaken +
                                          ttd.inMinutes.toString() +
                                          " M ";
                                    }
                                  } else {
                                    timeTaken = timeTaken +
                                        ttd.inSeconds.toString() +
                                        " S ";
                                  }
                                  FirebaseDatabase.instance
                                      .ref("location")
                                      .child(widget.currentUser.phoneNumber)
                                      .child("isDriving")
                                      .set(false);

                                  for (int i = 0;
                                      i < widget.currentUser.numberList.length;
                                      i++) {
                                    if (widget.settings.sendSMS) {
                                      BackgroundSms.sendMessage(
                                          phoneNumber: widget
                                              .currentUser.numberList[i][2],
                                          message:
                                              "We are sending this message to inform you that " +
                                                  widget.currentUser.firstName +
                                                  " is done with his drive" +
                                                  ". Here are some important metrics");
                                      //He is now at " +
                                      //location.formattedAddress
                                      BackgroundSms.sendMessage(
                                          phoneNumber: widget
                                              .currentUser.numberList[i][2],
                                          message: "User current location : " +
                                              location.formattedAddress);
                                      BackgroundSms.sendMessage(
                                          phoneNumber: widget
                                              .currentUser.numberList[i][2],
                                          message: "warnings given : " +
                                              amountOfWarningGiven
                                                  .toInt()
                                                  .toString() +
                                              "\n" +
                                              "distance traveled : " +
                                              distanceTraveled.toString() +
                                              "\n" +
                                              "duration : " +
                                              timeTaken +
                                              "\nspeeding alerts: " +
                                              speedingHistoryList.length
                                                  .toString());
                                    }
                                  }
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (c) {
                                    DrivingHistory thing = DrivingHistory();
                                    thing.blinking = blinkingHistory;
                                    thing.callsBlocked = callsBlocked;
                                    thing.distanceTraveled = distanceTraveled;
                                    thing.drowsy = eyesClosedHistoyr;
                                    thing.ending = location.formattedAddress;
                                    thing.endingTime =
                                        DateTime.now().toString();
                                    thing.hardBreak = hardDeceleration;
                                    thing.messagesBlocked = smsBlocked;
                                    thing.speeding = speedingHistoryList;
                                    thing.starting = widget.startingLocation;
                                    thing.startingTime =
                                        startingTime.toString();
                                    thing.timeTaked = ttd.toString();
                                    thing.warningsGiven = amountOfWarningGiven;
                                    return DriveDataScreen(
                                        thing, widget.currentUser, false);
                                  }), (Route<dynamic> route) => route.isFirst);
                                },
                                padding: EdgeInsets.fromLTRB(width * 0,
                                    height * 0, width * 0, height * 0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.car_detailed,
                                        size: MediaQuery.of(context)
                                                .textScaleFactor *
                                            25,
                                        color: Colors.blue,
                                      ),
                                    ]),
                                style: NeumorphicStyle(
                                    boxShape: NeumorphicBoxShape.circle(),
                                    border: const NeumorphicBorder(
                                        color: Colors.blue, width: 2),
                                    shadowLightColor: Colors.transparent,
                                    depth: 50,
                                    color: Colors.grey.shade300,
                                    lightSource: LightSource.topLeft,
                                    shape: NeumorphicShape.concave)),
                          ),
                        ]),
                  ),
                  Container(
                      width: width * 0.65,
                      height: width * 0.65,
                      child: Neumorphic(
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () {},
                              child: SfRadialGauge(
                                animationDuration: 500,
                                enableLoadingAnimation: true,
                                axes: <RadialAxis>[
                                  RadialAxis(
                                      minimum: 0,
                                      maximum: location.speedLimit + 10,
                                      pointers: <GaugePointer>[
                                        RangePointer(
                                          animationDuration: 500,
                                          animationType: AnimationType.linear,
                                          enableAnimation: true,
                                          value: location.speed.toDouble(),
                                          cornerStyle: CornerStyle.bothCurve,
                                          gradient: speedLimit
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
                            ),
                            Center(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  location.speed.toInt().toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        speedLimit ? Colors.red : Colors.blue,
                                    fontWeight: FontWeight.w800,
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            60,
                                  ),
                                ),
                                Text(
                                  " M/H",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color:
                                        speedLimit ? Colors.red : Colors.blue,
                                    fontWeight: FontWeight.w800,
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            10,
                                  ),
                                ),
                              ],
                            )),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: height * 0.18),
                                child: Text(
                                  location.speedLimit.toInt().toString() +
                                      "M/H",
                                  style: TextStyle(
                                    color:
                                        speedLimit ? Colors.red : Colors.blue,
                                    fontWeight: FontWeight.w800,
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            15,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        style: speedLimit
                            ? const NeumorphicStyle(
                                depth: 10,
                                shadowDarkColor: Colors.red,
                                shadowLightColor: Colors.red,
                                boxShape: NeumorphicBoxShape.circle(),
                              )
                            : const NeumorphicStyle(
                                depth: 10,
                                boxShape: NeumorphicBoxShape.circle(),
                              ),
                      )),
                  SizedBox(height: height * 0.03),
                  Row(
                    children: [
                      SizedBox(width: width * 0.05),
                      Container(
                        width: height * ((3 / 4) * 3) / 10 - 20,
                        height: height * 0.3,
                        child: Neumorphic(
                            child: cameraSetup == false || isDisposed == true
                                ? widget.settings.sleepDetection == false
                                    ? FittedBox(
                                        fit: BoxFit.contain,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: width * 0.02),
                                          child: Image.asset(
                                              "assets/images/no-pictures.png"),
                                        ),
                                      )
                                    : Container()
                                : CameraPreview(cameraController),
                            style: NeumorphicStyle(
                                depth: 10,
                                color: Colors.grey.shade300,
                                border: NeumorphicBorder(
                                    color:
                                        //speedLimit ? Colors.red : Colors.blue,
                                        thingColor,
                                    width: 3),
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.all(Radius.circular(25))))),
                      ),
                      SizedBox(width: width * 0.05),
                      Expanded(
                          child: Container(
                              child: Container(
                        height: height * 0.3,
                        child: Neumorphic(
                            child: Container(
                              height: height * 0.3,
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.025),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: height * 0.1,
                                    child: weatherData.id != -1
                                        ? Center(
                                            child: Image.asset(
                                                "assets/images/big_images/morning/" +
                                                    idToFileMorning[
                                                        weatherData.id]! +
                                                    ".png"),
                                          )
                                        : Container(),
                                  ),
                                  Text(
                                    weatherData.description.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: speedLimit
                                            ? Colors.red
                                            : Colors.blue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            20),
                                  ),
                                  Text(
                                    "Temp : " +
                                        (1.8 * (weatherData.temp - 273) + 32)
                                            .toInt()
                                            .toString(),
                                    style: TextStyle(
                                        color: speedLimit
                                            ? Colors.red
                                            : Colors.blue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            20),
                                  ),
                                  Text(
                                    "Visibility : " +
                                        weatherData.visibility
                                            .toInt()
                                            .toString(),
                                    style: TextStyle(
                                        color: speedLimit
                                            ? Colors.red
                                            : Colors.blue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            20),
                                  ),
                                ],
                              ),
                            ),
                            style: NeumorphicStyle(
                                depth: 10,
                                color: Colors.grey.shade300,
                                border: NeumorphicBorder(
                                    color:
                                        speedLimit ? Colors.red : Colors.blue,
                                    width: 3),
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.all(Radius.circular(25))))),
                      ))),
                      SizedBox(width: width * 0.05),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  Expanded(
                    child: Container(
                        width: width * 0.9,
                        child: Neumorphic(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: width * 0.03,
                              ),
                              Expanded(
                                  child: Container(
                                height: height * 0.15,
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: height * 0.09,
                                          child: Lottie.asset(
                                              "assets/animations/texting.json",
                                              repeat: false),
                                        )
                                      ],
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            smsBlocked.toString(),
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
                                width: width * 0.03,
                              ),
                              Expanded(
                                child: Container(
                                  height: height * 0.15,
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: height * 0.08,
                                            child: Lottie.asset(
                                                "assets/animations/phoneCall.json",
                                                repeat: false),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              callsBlocked.toString(),
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
                                width: width * 0.03,
                              ),
                              Expanded(
                                child: Container(
                                  height: height * 0.15,
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: height * 0.08,
                                            child: Lottie.asset(
                                                "assets/animations/warning.json",
                                                repeat: false),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              amountOfWarningGiven.toString(),
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
                                width: width * 0.03,
                              ),
                            ],
                          ),
                          style: NeumorphicStyle(
                              color: Colors.grey.shade300,
                              depth: 3,
                              border: const NeumorphicBorder(
                                color: Colors.blue,
                                width: 5,
                              ),
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.all(Radius.circular(25)))),
                        )),
                  ),
                  SizedBox(height: height * 0.02),
                ],
              ),
            ),
            if (crashCheck)
              Container(
                width: width,
                height: height,
                child: Center(
                  child: Container(
                    width: width * 0.8,
                    height: height * 0.4,
                    child: Column(
                      children: [
                        Container(
                          height: height * 0.2,
                          child: Image.asset(
                              "assets/images/roadIncidents/carCrash.png"),
                        ),
                        Text(
                          "Click to dismiss crash alert",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w800,
                              fontSize:
                                  MediaQuery.of(context).textScaleFactor * 20),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25))),
                  ),
                ),
              )
          ],
        ));
  }
}
