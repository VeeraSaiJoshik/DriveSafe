import 'package:flutter_latlong/flutter_latlong.dart';

num? findDistance(lat1, long1, lat2, long2) {
  final Distance distance = new Distance();

  final num? km = distance.as(
      LengthUnit.Kilometer, LatLng(lat1, long1), LatLng(lat2, long2));
  return km! * 0.62137;
}
num? findDistance1(lat1, long1, lat2, long2) {
  final Distance distance = new Distance();

  final num? km = distance.as(
      LengthUnit.Kilometer, LatLng(lat1, long1), LatLng(lat2, long2));
  return km!;
}
