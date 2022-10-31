import 'package:flutter/material.dart';

class viewSavedLocations extends StatefulWidget {
  const viewSavedLocations({Key? key}) : super(key: key);

  @override
  State<viewSavedLocations> createState() => _viewSavedLocationsState();
}

class _viewSavedLocationsState extends State<viewSavedLocations> {
  @override
  
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Container(
        width : width, 
        height: height,
        decoration: BoxDecoration(
          color : Colors.grey.shade300
        ),

      ),
    );
  }
}