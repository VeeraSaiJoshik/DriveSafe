import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class place {
  String country;
  String city;
  String state;
  String zipCode;
  String street;
  String subDivision = "";
  String formattedAddress;
  String placeName = "";
  place(this.country, this.city, this.state, this.zipCode, this.street,
      this.formattedAddress);
}

class searchingPlace {
  String name;
  String housenumber;
  String street;
  String city;
  String county;
  String state;
  String postcode;
  String country;
  double Latitude;
  double Longitude;
  String formattedAddress;
  String category;
  searchingPlace(
      this.name,
      this.housenumber,
      this.street,
      this.city,
      this.county,
      this.state,
      this.postcode,
      this.country,
      this.Latitude,
      this.Longitude,
      this.formattedAddress,
      this.category);
  void formatAddress(String CountryCode) {
    int index = -1;
    if (formattedAddress.contains("Southwest")) {
      formattedAddress = formattedAddress.replaceAll("Southwest", "SW");
    } else if (formattedAddress.contains("Northwest")) {
      formattedAddress = formattedAddress.replaceAll("Northwest", "NW");
    } else if (formattedAddress.contains("Southeast")) {
      formattedAddress = formattedAddress.replaceAll("Southeast", "SE");
    } else if (formattedAddress.contains("Northeast")) {
      formattedAddress = formattedAddress.replaceAll("Northeast", "NE");
    }
    if (formattedAddress.contains("Road")) {
      formattedAddress = formattedAddress.replaceAll("Road", "RD.");
    } else if (formattedAddress.contains("Street")) {
      formattedAddress = formattedAddress.replaceAll("Street", "St.");
    } else if (formattedAddress.contains("Avenue")) {
      formattedAddress = formattedAddress.replaceAll("Avenue", "Av.");
    } else if (formattedAddress.contains("Boulevard")) {
      formattedAddress = formattedAddress.replaceAll("Boulevard", "Blvd.");
    }
    for (int i = 0; i < formattedAddress.length; i++) {
      if (formattedAddress[i] == ",") {
        index = i + 1;
      }
    }
    print(index);

    formattedAddress =
        formattedAddress.substring(0, index) + " " + CountryCode.toUpperCase();
  }
}

class recentPlaces {
  bool isSaved;
  int timesUsed;
  LatLng location;
  place placeName;
  String placeNickName;
  String placeCategory;
  String placeColor;
  recentPlaces(this.isSaved, this.timesUsed, this.location, this.placeName,
      this.placeNickName, this.placeCategory, this.placeColor);
}

Future<List<List<recentPlaces>>> jsonToPlaces(
    Map jsonData, String phoneNumber) async {
  List<recentPlaces> recentLocations = [];
  List<recentPlaces> savedLocation = [];
  final Datasnapshot = await FirebaseDatabase.instance
      .ref("User")
      .child(phoneNumber)
      .child("locationShortCut")
      .get();
  List Data = Datasnapshot.value as List;
  for (int i = 0; i < Data.length; i++) {
    Map currentData = Data[i];
    late place tempPlace = place("", "", "", "", "", "");
    tempPlace.formattedAddress = currentData["formattedAddress"];
    if (currentData.containsKey("country")) {
      tempPlace.country = currentData["country"];
    }
    if (currentData.containsKey("city")) {
      tempPlace.country = currentData["city"];
    }
    if (currentData.containsKey("state")) {
      tempPlace.country = currentData["state"];
    }
    if (currentData.containsKey("zipCode")) {
      tempPlace.country = currentData["zipCode"];
    }
    if (currentData.containsKey("street")) {
      tempPlace.country = currentData["street"];
    }
    savedLocation.add(recentPlaces(
        currentData["isSaved"], //
        currentData["timesUsed"], //
        currentData["location,"], //
        currentData["placeName"], //
        currentData["placeNickName"],
        currentData["placeCategory"], //
        currentData["placeColor"]));
  }
  return [
    recentLocations,
    savedLocation,
  ];
}

void updateRecentPlaces(recentPlaces newPlace, String phoneNumber) async {
  DataSnapshot dataSnapshot = await FirebaseDatabase.instance
      .ref("User")
      .child(phoneNumber)
      .child("locationShortCut")
      .get();
  List data = dataSnapshot.value as List;
  data.add({
    "isSaved": newPlace.isSaved,
    "timesUsed": newPlace.timesUsed,
    "location": newPlace.location,
    "placeName": newPlace.placeName,
    "placeCategory": newPlace.placeCategory,
    "placeNickName": newPlace.placeNickName,
    "placeColor": newPlace.placeColor
  });
  FirebaseDatabase.instance
      .ref("User")
      .child(phoneNumber)
      .child("locationShortCut")
      .set(data);
}

class suggestionItem {}
