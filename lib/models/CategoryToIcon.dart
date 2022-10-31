import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
Map<String, IconData> categoryToIcon = {
  "accommodation": Icons.local_hotel_rounded,
  "commercial": Icons.shopping_cart_rounded,
  "catering": Icons.fastfood_outlined,
  "education": Icons.school,
  "childcare": Icons.child_care,
  "entertainment": Icons.movie,
  "healthcare": Icons.local_hospital,
  "man_made": CupertinoIcons.hammer_fill,
  "natural": Icons.emoji_nature,
  "office": Icons.work,
  "parking": Icons.local_parking,
  "pet": Icons.pets,
  "rental": Icons.car_rental,
  "service": Icons.home_repair_service_rounded,
  "tourism": Icons.tour_outlined,
  "camping": Icons.fireplace,
  "beach": Icons.beach_access,
  "airport": Icons.local_airport,
  "building": Icons.location_city,
  "ski": Icons.snowboarding_outlined,
  "sport": Icons.sports_soccer,
  "public_transport": Icons.emoji_transportation,
  "nothing" : Icons.add_road_sharp
};
Map<String, Color> categoryToColor = {
  "accommodation": Colors.red.shade400,
  "commercial": Colors.orange.shade400,
  "catering": Colors.teal,
  "education": Colors.blue,
  "childcare": Colors.pink,
  "entertainment": Colors.green,
  "healthcare": Colors.purple,
  "man_made": Colors.amber,
  "natural": Colors.lightGreen,
  "office": Colors.brown,
  "parking": Colors.green.shade600,
  "pet": Colors.brown.shade300,
  "rental": Colors.redAccent,
  "service": Colors.cyan,
  "tourism": Colors.indigo,
  "camping": Colors.deepOrange,
  "beach": Colors.yellow.shade700,
  "airport": Colors.grey.shade700,
  "building": Colors.lightBlueAccent,
  "ski": Colors.lightBlue,
  "sport": Colors.pinkAccent,
  "public_transport": Colors.deepPurple,
  "nothing" : Colors.grey
};
 
