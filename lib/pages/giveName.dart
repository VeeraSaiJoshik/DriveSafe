import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class GiveNameScreen extends StatefulWidget {
  List submitData;
  String phoneNumber;

  GiveNameScreen(this.submitData, this.phoneNumber);
  @override
  State<GiveNameScreen> createState() => _GiveNameScreenState();
}

class _GiveNameScreenState extends State<GiveNameScreen> {
  @override
  int destinationType = 0;
  TextEditingController textEditingController = new TextEditingController();

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: SingleChildScrollView(
          child: Container(
            height: height,
            width: width,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: height * 0.04,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(width * 0.04, 0, width * 0.04, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: height * 0.08,
                      width: height * 0.08,
                      child: NeumorphicButton(
                          onPressed: () {
                            Navigator.of(context).pop();
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
                                  color: Colors.blue.shade500,
                                ),
                              ]),
                          style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: 50,
                              color: Colors.grey.shade300,
                              lightSource: LightSource.topLeft,
                              shape: NeumorphicShape.concave)),
                    ),
                    Text(
                      "Save Location",
                      style: TextStyle(
                        fontSize: textSize * 30,
                        fontFamily: "Nunito",
                        fontWeight: FontWeight.w700,
                        shadows: [
                          const Shadow(
                              offset: Offset(2, 2),
                              color: Colors.black38,
                              blurRadius: 10),
                          Shadow(
                              offset: Offset(-2, -2),
                              color: Colors.white.withOpacity(0.85),
                              blurRadius: 10)
                        ],
                        color: Colors.blue,
                      ),
                    ),
                    Container(
                      height: height * 0.08,
                      width: height * 0.08,
                      child: NeumorphicButton(
                          onPressed: () {
                            widget.submitData[widget.submitData.length - 1]
                                ["GeneralData"] = {
                              "name": textEditingController.value.text,
                              "id": destinationType
                            };

                            FirebaseDatabase.instance
                                .ref("User")
                                .child(widget.phoneNumber)
                                .child("shortCuts")
                                .set(widget.submitData);
                            int count = 0;
                            Navigator.popUntil(context, (route) {
                              return count++ == 2;
                            });
                          },
                          padding: EdgeInsets.fromLTRB(
                              width * 0, height * 0, width * 0, height * 0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save,
                                  size: textSize * 25,
                                  color: Colors.blue.shade500,
                                ),
                              ]),
                          style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: 50,
                              color: Colors.grey.shade300,
                              lightSource: LightSource.topLeft,
                              shape: NeumorphicShape.concave)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: Text("Fill out the following information to save.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: textSize * 25,
                            fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: height * 0.05),
                  Text("Location Nickname",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: textSize * 20,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: height * 0.02),
                  Container(
                    child: NeumorphicTextField1(
                        width * 0.8,
                        textEditingController,
                        height * 0.2,
                        textSize,
                        () {},
                        () {}),
                  ),
                  SizedBox(height: height * 0.02),
                  Text("choose location category",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: textSize * 20,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: height * 0.015),
                  Container(
                      width: width * 0.9,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    destinationType = 1;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        width: width * 0.16,
                                        height: width * 0.16,
                                        padding: EdgeInsets.all(10),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.school,
                                            color: destinationType != 1
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: destinationType == 1
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                                color: Colors.blue, width: 3))),
                                    Text(
                                      "School",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: destinationType == 1
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: textSize * 15),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    destinationType = 2;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        width: width * 0.16,
                                        height: width * 0.16,
                                        padding: EdgeInsets.all(10),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.shopping_bag,
                                            color: destinationType != 2
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: destinationType == 2
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                                color: Colors.blue, width: 3))),
                                    Text(
                                      "Shopping",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: destinationType == 2
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: textSize * 15),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    destinationType = 3;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        width: width * 0.16,
                                        height: width * 0.16,
                                        padding: EdgeInsets.all(10),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.sports_soccer,
                                            color: destinationType != 3
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: destinationType == 3
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                                color: Colors.blue, width: 3))),
                                    Text(
                                      "Sports",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: destinationType == 3
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: textSize * 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    destinationType = 4;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        width: width * 0.16,
                                        height: width * 0.16,
                                        padding: EdgeInsets.all(10),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.movie,
                                            color: destinationType != 4
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: destinationType == 4
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                                color: Colors.blue, width: 3))),
                                    Text(
                                      "Movie",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: destinationType == 4
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: textSize * 15),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    destinationType = 5;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        width: width * 0.16,
                                        height: width * 0.16,
                                        padding: EdgeInsets.all(10),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.local_hospital,
                                            color: destinationType != 5
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: destinationType == 5
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                                color: Colors.blue, width: 3))),
                                    Text(
                                      "Hospital",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: destinationType == 5
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: textSize * 15),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    destinationType = 6;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        width: width * 0.16,
                                        height: width * 0.16,
                                        padding: EdgeInsets.all(10),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.house,
                                            color: destinationType != 6
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: destinationType == 6
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                                color: Colors.blue, width: 3))),
                                    Text(
                                      "House",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: destinationType == 6
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: textSize * 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    destinationType = 7;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        width: width * 0.16,
                                        height: width * 0.16,
                                        padding: EdgeInsets.all(10),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.park_rounded,
                                            color: destinationType != 7
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: destinationType == 7
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                                color: Colors.blue, width: 3))),
                                    Text(
                                      "Park",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: destinationType == 7
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: textSize * 15),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    destinationType = 8;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        width: width * 0.16,
                                        height: width * 0.16,
                                        padding: EdgeInsets.all(10),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.fastfood,
                                            color: destinationType != 8
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: destinationType == 8
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                                color: Colors.blue, width: 3))),
                                    Text(
                                      "Food",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: destinationType == 8
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: textSize * 15),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    destinationType = 9;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        width: width * 0.16,
                                        height: width * 0.16,
                                        padding: EdgeInsets.all(10),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(
                                            Icons.add,
                                            color: destinationType != 9
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: destinationType == 9
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                                color: Colors.blue, width: 3))),
                                    Text(
                                      "Other",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: destinationType == 9
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                          fontSize: textSize * 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.01)
                        ],
                      ))
                ],
              )
            ]),
          ),
        ));
  }
}

class NeumorphicTextField1 extends StatefulWidget {
  double width;
  Function onCancellFunction;
  TextEditingController textEditingController;
  double height;
  double textSize;
  Function onSearchFunction;
  NeumorphicTextField1(this.width, this.textEditingController, this.height,
      this.textSize, this.onSearchFunction, this.onCancellFunction);

  @override
  NeumorphicTextField1State createState() => NeumorphicTextField1State();
}

class NeumorphicTextField1State extends State<NeumorphicTextField1> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double textSize = MediaQuery.of(context).textScaleFactor;
    return Container(
      width: widget.width,
      child: Neumorphic(
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
              fontSize: textSize * 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100))),
              contentPadding: EdgeInsets.only(
                  left: width * 0.03, right: width * 0.03, top: 0, bottom: 0)),
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
