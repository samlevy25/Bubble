import 'dart:math';

import 'package:bubbles_app/constants/bubble_key_types.dart';
import 'package:bubbles_app/constants/bubble_sizes.dart';
import 'package:bubbles_app/models/bubble.dart';
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
  late Timer _timer;
  final LatLng _currentLatLng = LatLng(31.808700, 34.654860);

  final DatabaseService _db = GetIt.instance.get<DatabaseService>();

  List<Map<String, dynamic>> _bubblesMarks = [];

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _fetchBubbles();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMap(),
    );
  }

  Widget _buildMap() {
    var x = _currentLatLng.latitude;
    var y = _currentLatLng.longitude;
    return FlutterMap(
      options:
          MapOptions(zoom: 18, center: LatLng(x, y), maxZoom: 18, minZoom: 18),
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

  Future<void> _fetchBubbles() async {
    List<Map<String, dynamic>> bubbles = await _db.getBubblesFormarks();
    setState(() {
      _bubblesMarks = bubbles;
    });
  }
}
