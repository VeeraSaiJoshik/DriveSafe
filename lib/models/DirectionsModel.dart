
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polyLinePoints;
  final String totalDistance;
  final String totalDuration;
  final String pollyLine;
  final String totalTime;
  Directions(
      this.bounds, this.polyLinePoints, this.totalDistance, this.totalDuration, this.pollyLine, this.totalTime);
}
