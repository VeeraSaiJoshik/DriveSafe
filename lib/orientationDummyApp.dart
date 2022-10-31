import 'package:drivesafev2/pages/chooseCurrentLocation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class OrienationApp extends StatefulWidget {
  const OrienationApp({Key? key}) : super(key: key);

  @override
  State<OrienationApp> createState() => _OrienationAppState();
}

class _OrienationAppState extends State<OrienationApp> {
  @override
  double angleZ = 0.0;
  double angleX = 0.0;
  double angleY = 0.0;
  int ax = 0;
  int ay = 0;
  int az = 0;
  double calc(double angle) {
    if (angle < 0) {
      angle = angle + 30;
    } else if (angle > 30) {
      angle = angle - 30;
    }
    return angle;
  }

  void initState() {
    gyroscopeEvents.listen((GyroscopeEvent event) {
      double z = roundDouble(event.z, 2);
      double x = roundDouble(event.x, 2);
      double y = roundDouble(event.y, 1);
      angleZ = angleZ - z;
      angleX = angleX - x;
      angleY = angleY - y;
      angleZ = calc(angleZ);
      angleX = calc(angleX);
      angleY = calc(angleY);
      print(x.toString() +
          " " +
          y.toString() +
          " " +
          z.toString());
      setState(() {
        angleX;
        angleY;
        angleZ;
      });
    });
    accelerometerEvents.listen((event2) {
      print(event2.x.toString() + " " + event2.y.toString() + " " + event2.z.toString() + " ");
      setState(() {
        ax = event2.x.toInt();
        ay = event2.y.toInt();
        az = event2.z.toInt();
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: Column(children: [
          Container(
            width: width * 0.5,
            height: width * 0.5,
            color: Colors.blue,
            child: Center(
              child: RotationTransition(
                turns: AlwaysStoppedAnimation(angleX / 30),
                child: Container(
                  width: width * 0.2,
                  height: width * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.purple[200]!, Colors.amber],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                ),
              ),
            ),
          ),
          Text(ax.toString()),
          Container(
            width: width * 0.5,
            height: width * 0.5,
            color: Colors.blue,
            child: Center(
              child: RotationTransition(
                turns: AlwaysStoppedAnimation(angleY / 30),
                child: Container(
                  width: width * 0.2,
                  height: width * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.purple[200]!, Colors.amber],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                ),
              ),
            ),
          ),
          Text(ay.toString()),
          Container(
            width: width * 0.5,
            height: width * 0.5,
            color: Colors.blue,
            child: Center(
              child: RotationTransition(
                turns: AlwaysStoppedAnimation(angleZ / 30),
                child: Container(
                  width: width * 0.2,
                  height: width * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.purple[200]!, Colors.amber],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                ),
              ),
            ),
          ),
          Text(az.toString()),
        ]),
      ),
    );
  }
}
