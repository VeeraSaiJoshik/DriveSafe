import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'settingOptionWidget.dart';
import 'package:drivesafev2/models/settings.dart';

class phoneNumberWidget extends StatefulWidget {
  double height;
  double width;
  double textScaleFactor;
  Settings setting;
  Function functionSendSMS;
  Function functionOffline;
  Function functionAllFriends;
  Function functionSelecteFriends;
  Function functionPhoneNumber;
  Function functionSendReplySMS;
  TextEditingController textEditingController;
  TextEditingController replySMS;
  Function functionIncludeEndTime;
  phoneNumberWidget(
      this.height,
      this.width,
      this.textScaleFactor,
      this.setting,
      this.functionSendSMS,
      this.functionOffline,
      this.functionAllFriends,
      this.functionSelecteFriends,
      this.functionPhoneNumber,
      this.textEditingController,
      this.functionSendReplySMS,
      this.functionIncludeEndTime,
      this.replySMS);
  @override
  _phoneNumberWidgetState createState() => _phoneNumberWidgetState();
}

class _phoneNumberWidgetState extends State<phoneNumberWidget> {
  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      child: Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          height: widget.height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: widget.height * 0.02,
              ),
              Text(
                "Driving Data",
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
                  child: Column(
                    children: [
                      settingOptionWidget(
                          widget.width,
                          widget.height,
                          widget.textScaleFactor,
                          widget.setting,
                          widget.setting.sendSMS,
                          widget.functionSendSMS,
                          "Share Through SMS",
                          1),
                      settingOptionWidget(
                          widget.width,
                          widget.height,
                          widget.textScaleFactor,
                          widget.setting,
                          widget.setting.offlineMode,
                          widget.functionOffline,
                          "Offline",
                          1),
                      widget.setting.sendSMS == true
                          ? Row(
                              children: [
                                Container(
                                    width: widget.width * 0.85 / 4 * 3,
                                    height: widget.height * 0.4 / 6,
                                    alignment: Alignment.centerLeft,
                                    child: Text("Time (Min)",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize:
                                                widget.textScaleFactor * 30,
                                            fontWeight: FontWeight.w700))),
                                Container(
                                  width: widget.width * 0.85 / 4,
                                  height: widget.height * 0.4 / 6,
                                  child: Center(
                                    child: Neumorphic(
                                      child: Container(
                                          width:
                                              widget.width * (0.85 / 4 - 0.02),
                                          height:
                                              widget.height * (0.4 / 6 - 0.02),
                                          child: TextField(
                                            keyboardType: TextInputType.phone,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            style: TextStyle(
                                                fontSize:
                                                    widget.textScaleFactor * 25,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.blue),
                                            textAlign: TextAlign.center,
                                            onChanged: (text) {
                                              if (int.parse(text).isNaN ==
                                                  false) {
                                                widget.setting
                                                        .sendMessageEverXMinutes =
                                                    int.parse(text.trim());
                                                setState(() {
                                                  widget.setting;
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                                border:
                                                    const OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    100))),
                                                contentPadding: EdgeInsets.only(
                                                    bottom:
                                                        widget.height * 0.01,
                                                    left: widget.width * 0.03,
                                                    right:
                                                        widget.width * 0.03)),
                                            controller:
                                                widget.textEditingController,
                                          )),
                                      style: NeumorphicStyle(
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                  const BorderRadius.all(
                                                      Radius.circular(100))),
                                          depth: -15,
                                          color: Colors.grey.shade300,
                                          border: NeumorphicBorder(
                                              color: Colors.blue, width: 2.5),
                                          lightSource: LightSource.topLeft,
                                          shape: NeumorphicShape.concave),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                    width: widget.width * 0.85 / 4 * 3,
                                    height: widget.height * 0.4 / 6,
                                    alignment: Alignment.centerLeft,
                                    child: Text("Time (Min)",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                widget.textScaleFactor * 30,
                                            fontWeight: FontWeight.w700))),
                                Container(
                                  width: widget.width * 0.85 / 4,
                                  height: widget.height * 0.4 / 6,
                                  child: Center(
                                    child: Neumorphic(
                                      child: Container(
                                          width:
                                              widget.width * (0.85 / 4 - 0.02),
                                          height:
                                              widget.height * (0.4 / 6 - 0.02),
                                          child: TextField(
                                            enabled: false,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            style: TextStyle(
                                                fontSize:
                                                    widget.textScaleFactor * 25,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey),
                                            textAlign: TextAlign.center,
                                            onChanged: (text) {
                                              if (int.parse(text).isNaN ==
                                                  false) {
                                                widget.setting
                                                        .sendMessageEverXMinutes =
                                                    int.parse(text);
                                              }
                                            },
                                            decoration: InputDecoration(
                                                border:
                                                    const OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    100))),
                                                contentPadding: EdgeInsets.only(
                                                    bottom:
                                                        widget.height * 0.01,
                                                    left: widget.width * 0.03,
                                                    right:
                                                        widget.width * 0.03)),
                                            controller:
                                                widget.textEditingController,
                                          )),
                                      style: NeumorphicStyle(
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                  const BorderRadius.all(
                                                      Radius.circular(100))),
                                          depth: -15,
                                          color: Colors.grey.shade300,
                                          border: NeumorphicBorder(
                                              color: Colors.grey, width: 2.5),
                                          lightSource: LightSource.topLeft,
                                          shape: NeumorphicShape.concave),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      settingOptionWidget(
                          widget.width,
                          widget.height,
                          widget.textScaleFactor,
                          widget.setting,
                          widget.setting.replyToIncomingSMS,
                          widget.functionSendReplySMS,
                          "Auto Reply",
                          1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: widget.width * 0.04),
                          Text(
                            "Reply Text",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize:
                                  MediaQuery.of(context).textScaleFactor * 20,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      Container(
                        width: widget.width * 0.9,
                        height: widget.height * 0.4 / 6,
                        child: Center(
                          child: Neumorphic(
                            child: Center(
                              child: Container(
                                  width: widget.width * 0.9,
                                  height: widget.height * 0.5 / 6,
                                  child: Center(
                                    child: TextField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      style: TextStyle(
                                          fontSize: widget.textScaleFactor * 25,
                                          fontWeight: FontWeight.w700,
                                          color: widget.setting.sendSMS ==
                                                      false ||
                                                  widget.setting
                                                          .replyToIncomingSMS ==
                                                      false
                                              ? Colors.grey
                                              : Colors.blue),
                                      textAlign: TextAlign.left,
                                      onChanged: (text) {
                                        widget.setting.messageReplyString =
                                            text;
                                      },
                                      decoration: InputDecoration(
                                          hintText: "Enter Message",
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(100))),
                                          contentPadding: EdgeInsets.only(
                                              left: widget.width * 0.03,
                                              right: widget.width * 0.03)),
                                      controller: widget.replySMS,
                                    ),
                                  )),
                            ),
                            style: NeumorphicStyle(
                                boxShape: NeumorphicBoxShape.roundRect(
                                    const BorderRadius.all(
                                        Radius.circular(100))),
                                depth: -15,
                                color: Colors.grey.shade300,
                                border: NeumorphicBorder(
                                    color: widget.setting.sendSMS == false ||
                                            widget.setting.replyToIncomingSMS ==
                                                false
                                        ? Colors.grey
                                        : Colors.blue,
                                    width: 2.5),
                                lightSource: LightSource.topLeft,
                                shape: NeumorphicShape.concave),
                          ),
                        ),
                      ),
                      settingOptionWidget(
                          widget.width,
                          widget.height,
                          widget.textScaleFactor,
                          widget.setting,
                          widget.setting.includeEndTime,
                          widget.functionIncludeEndTime,
                          "Include Time",
                          1),
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
