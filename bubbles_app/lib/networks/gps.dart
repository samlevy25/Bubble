import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:flutter/foundation.dart';
import 'package:flutter_geo_hash/geohash.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geocoding/geocoding.dart';

Future<cf.GeoPoint> getCurrentGeoPoint(int range) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }

  Position position;
  try {
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  } catch (e) {
    return Future.error('Failed to retrieve the current location.');
  }

  if (position == null) {
    return Future.error('Failed to retrieve the current location.');
  }

  return cf.GeoPoint(position.latitude, position.longitude);
}

Future<String> getCurrentGeoHash(int range) async {
  cf.GeoPoint p = await getCurrentGeoPoint(range);
  return MyGeoHash().geoHashForLocation(
    GeoPoint(p.latitude, p.longitude),
    precision: range,
  );
}

Future<String> getCurrentLocationName() async {
  try {
    cf.GeoPoint g = await getCurrentGeoPoint(22);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(g.latitude, g.longitude);

    Placemark p = placemarks[0];
    if (kDebugMode) {
      print(p.name);
    }

    return "${p.street}, ${p.country}";
  } catch (e) {
    return "Unknown";
  }
}
