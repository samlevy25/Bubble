import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class BubblesMap extends StatefulWidget {
  const BubblesMap({super.key});

  @override
  State<BubblesMap> createState() => _BubblesMapState();
}

class _BubblesMapState extends State<BubblesMap> {
  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Expanded(
      child: FlutterMap(
        options: MapOptions(
          zoom: 16,
          center: LatLng(32.0853, 34.7818),
        ),
        children: [
          TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png')
        ],
      ),
    );
  }
}
