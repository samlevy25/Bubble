import 'dart:math';

import 'package:bubbles_app/constants/bubble_key_types.dart';
import 'package:bubbles_app/constants/bubble_sizes.dart';
import 'package:bubbles_app/models/bubble.dart';
import 'package:bubbles_app/networks/gps.dart';
import 'package:bubbles_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Timer? _timer;
  late LatLng _currentLatLng;
  bool _isLoading = false;

  final DatabaseService _db = GetIt.instance.get<DatabaseService>();

  List<Map<String, dynamic>> _bubblesMarks = [];

  @override
  void initState() {
    super.initState();
    _updateLocationAndFetchBubbles();

    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _updateLocationAndFetchBubbles();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("MapPage build called");
    return Scaffold(
      body: _isLoading ? _buildLoadingIndicator() : _buildMap(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        zoom: 18,
        center: _currentLatLng,
        maxZoom: 18,
        minZoom: 18,
      ),
      children: [
        _buildTileLayer(),
        _buildMarkerLayer(),
      ],
    );
  }

  TileLayer _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
  }

  MarkerLayer _buildMarkerLayer() {
    List<Marker> markers = [];

    for (var bubble in _bubblesMarks) {
      GeoPoint geoPoint = bubble['geoPoint'];
      int keyTypeindex = bubble['keyType'];
      int size = bubble['size'];

      Color bubbleColor = BubbleKeyType.getColorByIndex(keyTypeindex)!;
      double markSize = BubbleSize.getSizeMarkByIndex(size)!;
      LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

      markers.add(
        Marker(
          width: markSize,
          height: markSize,
          point: latLng,
          builder: (ctx) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bubbleColor.withOpacity(0.25),
                  ),
                ),
                Text(
                  bubble['name'],
                  style: TextStyle(
                    color: bubbleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Add current location marker
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: _currentLatLng,
        builder: (ctx) => const Icon(
          Icons.location_on,
          color: Colors.red,
        ),
      ),
    );

    return MarkerLayer(markers: markers);
  }

  Future<void> _updateLocationAndFetchBubbles() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      GeoPoint geoPoint = await getCurrentGeoPoint(22);
      print("Latitude: ${geoPoint.latitude}, Longitude: ${geoPoint.longitude}");

      List<Map<String, dynamic>> bubbles = await _db.getBubblesFormarks();
      print("Fetched bubbles");

      setState(() {
        _currentLatLng = LatLng(geoPoint.latitude, geoPoint.longitude);
        _bubblesMarks = bubbles;
        _isLoading = false;
      });
    } catch (error) {
      print("Error: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }
}
