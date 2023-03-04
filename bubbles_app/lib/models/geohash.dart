import 'package:flutter_geo_hash/geohash.dart';

class GeoHash {
  late String hash;

  GeoHash(double latitude, double longitude, int range) {
    hash = MyGeoHash().geoHashForLocation(
      GeoPoint(latitude, longitude),
      precision: range,
    );
  }

  GeoHash.fromHash(this.hash);

  @override
  String toString() {
    return hash;
  }

  String getHash(int range) {
    return hash;
  }
}
