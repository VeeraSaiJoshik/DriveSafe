import '../pages/drivingScreen.dart';

class DrivingHistory {
  String starting = "";
  String ending = "";
  String distanceTraveled = "";
  String startingTime = "";
  String timeTaked = "";
  String endingTime = "";
  List<speedingHistoryVal> speeding = [];
  List<blinkSession> drowsy = [];
  List<blinkSession> blinking = [];
  List hardBreak = [];
  int callsBlocked = 0;
  int messagesBlocked = 0;
  int warningsGiven = 0;
  DrivingHistory();
  Map drivingToJson() {
    List speedingMap = [];
    List blinkingMap = [];
    List drowsyMap = [];
    for (int i = 0; i < speeding.length; i++) {
      speedingHistoryVal curVal = speeding[i];
      speedingMap.add({
        "speed": curVal.speed,
        "speedLimit": curVal.speedLimit,
        "time": curVal.time.toString(),
        "state": curVal.state,
        "address": curVal.address,
        "latitude": curVal.latitude,
        "longitude": curVal.longitude
      });
    }
    for (int i = 0; i < drowsy.length; i++) {
      blinkSession curVal = drowsy[i];
      drowsyMap.add({
        "start": curVal.timeStarted.toString(),
        "end": curVal.timeEnded.toString(),
        "continue": curVal.contintuing,
        "lat": curVal.latitude,
        "lon": curVal.longitude,
        "address": curVal.address
      });
    }
    for (int i = 0; i < blinking.length; i++) {
      blinkSession curVal = blinking[i];
      blinkingMap.add({
        "start": curVal.timeStarted.toString(),
        "end": curVal.timeEnded.toString(),
        "continue": curVal.contintuing,
        "lat": curVal.latitude,
        "lon": curVal.longitude,
        "address": curVal.address
      });
    }
    return {
      "starting": starting,
      "ending": ending,
      "distanceTraveled": distanceTraveled.toString(),
      "timeTaked": timeTaked,
      "endingTime": endingTime,
      "callsBlocked": callsBlocked,
      "messagesBlocked": messagesBlocked,
      "warningsGiven": warningsGiven,
      "speedingHis": speedingMap,
      "drowsy": drowsyMap,
      "blinking": blinkingMap,
      "hardBreak": hardBreak,
      "startingTime": startingTime,
    };
  }

  void jsonToDriving(Map data) {
    if (data.containsKey("starting")) {
      starting = data["starting"];
    }
    if (data.containsKey("ending")) {
      ending = data["ending"];
    }
    if (data.containsKey("distanceTraveled")) {
      distanceTraveled = data["distanceTraveled"].toString();
    }
    if (data.containsKey("timeTaked")) {
      timeTaked = data["timeTaked"];
    }
    if (data.containsKey("endingTime")) {
      endingTime = data["endingTime"];
    }
    if (data.containsKey("startingTime")) {
      startingTime = data["startingTime"];
    }
    if (data.containsKey("callsBlocked")) {
      callsBlocked = data["callsBlocked"];
    }
    if (data.containsKey("messagesBlocked")) {
      messagesBlocked = data["messagesBlocked"];
    }
    if (data.containsKey("warningsGiven")) {
      warningsGiven = data["warningsGiven"];
    }
    if (data.containsKey("speedingHis")) {
      List speedingHis = data["speedingHis"];
      for (int i = 0; i < speedingHis.length; i++) {
        speeding.add(speedingHistoryVal(
            speedingHis[i]["speed"].toDouble(),
            speedingHis[i]["speedLimit"].toDouble(),
            DateTime.parse(speedingHis[i]["time"]),
            speedingHis[i]["state"],
            speedingHis[i]["address"],
            speedingHis[i]["latitude"],
            speedingHis[i]["longitude"]));
      }
    }
    if (data.containsKey("drowsy")) {
      List drowsyHis = data["drowsy"];
      for (int i = 0; i < drowsyHis.length; i++) {
        drowsy.add(blinkSession(
            DateTime.parse(drowsyHis[i]['start']),
            DateTime.parse(drowsyHis[i]['end']),
            drowsyHis[i]['continue'],
            drowsyHis[i]['lat'],
            drowsyHis[i]['long'],
            drowsyHis[i]['address']));
      }
    }
    if (data.containsKey("blinking")) {
      List blinkingHis = data["blinking"];
      for (int i = 0; i < blinkingHis.length; i++) {
        blinking.add(blinkSession(
            DateTime.parse(blinkingHis[i]['start']),
            DateTime.parse(blinkingHis[i]['end']),
            blinkingHis[i]['continue'],
            blinkingHis[i]['lat'],
            blinkingHis[i]['long'],
            blinkingHis[i]['address']));
      }
    }
    if (data.containsKey("hardBreak")) {
      hardBreak.addAll(data["hardBreak"]);
    }
  }
}
