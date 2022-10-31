import 'package:drivesafev2/models/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class ColorCodeWidget extends StatelessWidget {
  double height;
  double width;
  double textScaleFactor;
  ColorCodeWidget(this.height, this.width, this.textScaleFactor);
  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      child: Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          height: height * 0.37,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.017,
              ),
              Text(
                "Color Code",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: textScaleFactor * 35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: height * 0.007),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.025),
                  width: width * 0.95,
                  height: height * 0.28,
                  child: Column(
                    children: [
                      Row(children: [
                        SizedBox(
                          width: width * 0.03,
                        ),
                        CircleAvatar(
                            radius: height * 0.023,
                            backgroundColor: Colors.blue),
                        Text(
                          " : Existing User in App",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: textScaleFactor * 25,
                              color: Colors.blue),
                        )
                      ]),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Row(children: [
                        SizedBox(
                          width: width * 0.03,
                        ),
                        CircleAvatar(
                            radius: height * 0.023,
                            backgroundColor: Colors.green),
                        Text(
                          " : Friend",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: textScaleFactor * 25,
                              color: Colors.green),
                        ),
                        SizedBox(
                          width: width * 0.04,
                        ),
                        CircleAvatar(
                            radius: height * 0.023,
                            backgroundColor: Colors.orange),
                        Text(
                          " : Pending",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: textScaleFactor * 25,
                              color: Colors.orange),
                        )
                      ]),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Row(children: [
                        SizedBox(
                          width: width * 0.03,
                        ),
                        CircleAvatar(
                            radius: height * 0.023,
                            backgroundColor: Colors.red),
                        Text(
                          " : ",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: textScaleFactor * 25,
                              color: Colors.red),
                        ),
                        Text(
                          "Rejected",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: textScaleFactor * 20,
                              color: Colors.red),
                        ),
                        SizedBox(
                          width: width * 0.02,
                        ),
                        CircleAvatar(
                            radius: height * 0.023,
                            backgroundColor: Colors.cyan),
                        Text(
                          " : ",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: textScaleFactor * 25,
                              color: Colors.cyan),
                        ),
                        Text("Foreign Phone\nNumber",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: textScaleFactor * 15,
                                color: Colors.cyan))
                      ]),
                      SizedBox(height: height * 0.014),
                      Row(
                        children: [
                          SizedBox(
                            width: width * 0.01,
                          ),
                          Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: textScaleFactor * 50,
                          ),
                          Text(
                            ": ",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: textScaleFactor * 25,
                                color: Colors.green),
                          ),
                          Text("Location\nSharing",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: textScaleFactor * 17,
                                  color: Colors.green)),
                          SizedBox(
                            width: width * 0.03,
                          ),
                          Icon(
                            Icons.location_off,
                            color: Colors.red,
                            size: textScaleFactor * 50,
                          ),
                          Text(
                            ": ",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: textScaleFactor * 25,
                                color: Colors.red),
                          ),
                          Text("Location Not\nSharing",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: textScaleFactor * 17,
                                  color: Colors.red))
                        ],
                      )
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
      margin: EdgeInsets.only(bottom: height * 0.02),
    );
  }
}

class settingOptionWidget extends StatefulWidget {
  @override
  double width;
  double height;
  double textScaleFactor;
  bool permissionVariable;
  Settings setting;
  String label;
  Function onChangeFunction;
  int type;
  settingOptionWidget(
      this.width,
      this.height,
      this.textScaleFactor,
      this.setting,
      this.permissionVariable,
      this.onChangeFunction,
      this.label,
      this.type);
  _settingOptionWidgetState createState() => _settingOptionWidgetState();
}

/*
The contacts screen allows drivers to manage who will receive their driving info.
Family and Friends with a Drivesafe account can be added their UserId on this screen.
Family members or friends without one can be added with their phone number, allowing them to receive data via sms.
Drivers can choose which added contacts will receive driving info on this screen.
 */
/*
then we have the Settings which provides account information and allow Drivers to customize verbal driving alert and data-sharing preferences.
They can also view, add, and delete Saved Locations.
 */
class _settingOptionWidgetState extends State<settingOptionWidget> {
  @override
  Widget build(BuildContext context) {
    if ((widget.label != "Share Through SMS" && widget.type == 1) ||
        (widget.label != "Auto Reply" && widget.type == 20)) {
      if (widget.setting.sendSMS == false) {
        return Row(
          children: [
            Container(
                width: widget.width * 0.85 / 4 * 3,
                height: widget.height * 0.4 / 6,
                alignment: Alignment.centerLeft,
                child: Text(widget.label,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: widget.textScaleFactor * 30,
                        fontWeight: FontWeight.w700))),
            Container(
                width: widget.width * 0.85 / 4,
                height: widget.height * 0.4 / 6,
                child: Center(
                  child: Container(
                    width: widget.width * (0.85 / 4 - 0.02),
                    height: widget.height * (0.4 / 6 - 0.02),
                    child: NeumorphicSwitch(
                      onChanged: (condition) {},
                      value: false,
                      style: NeumorphicSwitchStyle(
                        trackBorder:
                            NeumorphicBorder(color: Colors.grey, width: 3),
                        activeThumbColor: Colors.grey,
                        inactiveThumbColor: Colors.grey,
                        activeTrackColor: Colors.grey.shade300,
                        thumbShape: NeumorphicShape.concave,
                      ),
                      height: widget.height * 0.4 / 6 - 0.1,
                    ),
                  ),
                ))
          ],
        );
      } else if (widget.setting.replyToIncomingSMS == false &&
          widget.label == "Include Time") {
        return Row(
          children: [
            Container(
                width: widget.width * 0.85 / 4 * 3,
                height: widget.height * 0.4 / 6,
                alignment: Alignment.centerLeft,
                child: Text(widget.label,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: widget.textScaleFactor * 30,
                        fontWeight: FontWeight.w700))),
            Container(
                width: widget.width * 0.85 / 4,
                height: widget.height * 0.4 / 6,
                child: Center(
                  child: Container(
                    width: widget.width * (0.85 / 4 - 0.02),
                    height: widget.height * (0.4 / 6 - 0.02),
                    child: NeumorphicSwitch(
                      onChanged: (condition) {},
                      value: false,
                      style: NeumorphicSwitchStyle(
                        trackBorder:
                            NeumorphicBorder(color: Colors.grey, width: 3),
                        activeThumbColor: Colors.grey,
                        inactiveThumbColor: Colors.grey,
                        activeTrackColor: Colors.grey.shade300,
                        thumbShape: NeumorphicShape.concave,
                      ),
                      height: widget.height * 0.4 / 6 - 0.1,
                    ),
                  ),
                ))
          ],
        );
      } else {
        return Row(
          children: [
            Container(
                width: widget.width * 0.85 / 4 * 3,
                height: widget.height * 0.4 / 6,
                alignment: Alignment.centerLeft,
                child: Text(widget.label,
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: widget.textScaleFactor * 30,
                        fontWeight: FontWeight.w700))),
            Container(
                width: widget.width * 0.85 / 4,
                height: widget.height * 0.4 / 6,
                child: Center(
                  child: Container(
                    width: widget.width * (0.85 / 4 - 0.02),
                    height: widget.height * (0.4 / 6 - 0.02),
                    child: widget.permissionVariable == true
                        ? NeumorphicSwitch(
                            onChanged: (condition) {
                              setState(() {
                                widget.onChangeFunction(condition);
                              });
                            },
                            value: widget.permissionVariable,
                            style: NeumorphicSwitchStyle(
                              trackBorder: NeumorphicBorder(
                                  color: Colors.green, width: 3),
                              activeThumbColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              activeTrackColor: Colors.grey.shade300,
                              thumbShape: NeumorphicShape.concave,
                            ),
                            height: widget.height * 0.4 / 6 - 0.1,
                          )
                        : NeumorphicSwitch(
                            onChanged: (condition) {
                              setState(() {
                                widget.onChangeFunction(condition);
                              });
                            },
                            value: widget.permissionVariable,
                            style: NeumorphicSwitchStyle(
                              trackBorder:
                                  NeumorphicBorder(color: Colors.red, width: 3),
                              activeThumbColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              activeTrackColor: Colors.grey.shade300,
                              thumbShape: NeumorphicShape.concave,
                            ),
                            height: widget.height * 0.4 / 6 - 0.1,
                          ),
                  ),
                ))
          ],
        );
      }
    } else {
      return Row(
        children: [
          Container(
              width: widget.width * 0.85 / 4 * 3,
              height: widget.height * 0.4 / 6,
              alignment: Alignment.centerLeft,
              child: Text(widget.label,
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: widget.textScaleFactor * 30,
                      fontWeight: FontWeight.w700))),
          Container(
              width: widget.width * 0.85 / 4,
              height: widget.height * 0.4 / 6,
              child: Center(
                child: Container(
                  width: widget.width * (0.85 / 4 - 0.02),
                  height: widget.height * (0.4 / 6 - 0.02),
                  child: widget.permissionVariable == true
                      ? NeumorphicSwitch(
                          onChanged: (condition) {
                            setState(() {
                              widget.onChangeFunction(condition);
                            });
                          },
                          value: widget.permissionVariable,
                          style: NeumorphicSwitchStyle(
                            trackBorder:
                                NeumorphicBorder(color: Colors.green, width: 3),
                            activeThumbColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            activeTrackColor: Colors.grey.shade300,
                            thumbShape: NeumorphicShape.concave,
                          ),
                          height: widget.height * 0.4 / 6 - 0.1,
                        )
                      : NeumorphicSwitch(
                          onChanged: (condition) {
                            setState(() {
                              widget.onChangeFunction(condition);
                            });
                          },
                          value: widget.permissionVariable,
                          style: NeumorphicSwitchStyle(
                            trackBorder:
                                NeumorphicBorder(color: Colors.red, width: 3),
                            activeThumbColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            activeTrackColor: Colors.grey.shade300,
                            thumbShape: NeumorphicShape.concave,
                          ),
                          height: widget.height * 0.4 / 6 - 0.1,
                        ),
                ),
              ))
        ],
      );
    }
  }
}
