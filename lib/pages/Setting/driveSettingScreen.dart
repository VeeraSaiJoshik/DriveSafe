import 'package:drivesafev2/pages/Setting/settingOptionWidget.dart';
import 'package:flutter/material.dart';
import 'package:drivesafev2/models/settings.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class DriveSettingScreen extends StatefulWidget {
  double height;
  double width;
  double textScaleFactor;
  Settings setting;
  Function crashAlerts;
  Function sendNotification;
  Function speeding;
  Function sleepDetection;
  Function trafficInfo;
  DriveSettingScreen(
      this.height,
      this.width,
      this.textScaleFactor,
      this.setting,
      this.crashAlerts,
      this.sendNotification,
      this.speeding,
      this.sleepDetection,
      this.trafficInfo);
  @override
  _DriveSettingScreenState createState() => _DriveSettingScreenState();
}

class _DriveSettingScreenState extends State<DriveSettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      child: Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          height: widget.height * 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: widget.height * 0.017,
              ),
              Text(
                "Verbal Alerts",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: widget.textScaleFactor * 35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: widget.height * 0.007),
              Container(
                  // color: Colors.blue,
                  width: widget.width * 0.85,
                  height: widget.height * 0.34,
                  child: Column(
                    children: [
                      settingOptionWidget(
                          widget.width,
                          widget.height,
                          widget.textScaleFactor,
                          widget.setting,
                          widget.setting.crashAlerts,
                          widget.crashAlerts,
                          "Crash Alerts",
                          2),
                      settingOptionWidget(
                          widget.width,
                          widget.height,
                          widget.textScaleFactor,
                          widget.setting,
                          widget.setting.sendNotification,
                          widget.sendNotification,
                          "Town/City Enter Alert",
                          2),
                      settingOptionWidget(
                          widget.width,
                          widget.height,
                          widget.textScaleFactor,
                          widget.setting,
                          widget.setting.alertSpeeding,
                          widget.speeding,
                          "Speeding Alerts",
                          2),
                      settingOptionWidget(
                          widget.width,
                          widget.height,
                          widget.textScaleFactor,
                          widget.setting,
                          widget.setting.sleepDetection,
                          widget.sleepDetection,
                          "Sleep Detection",
                          2),
                      settingOptionWidget(
                          widget.width,
                          widget.height,
                          widget.textScaleFactor,
                          widget.setting,
                          widget.setting.trafficInfo,
                          widget.trafficInfo,
                          "Traffic Info",
                          2),
                    ],
                  ))
            ],
          )),
      style: NeumorphicStyle(
          border: const NeumorphicBorder(color: Colors.blue, width: 5),
          color: Colors.grey.shade300,
          shadowLightColor: Colors.transparent,
          depth: -20,
          boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.all(Radius.circular(40)))),
      margin: EdgeInsets.only(bottom: widget.height * 0.02),
    );
  }
}
