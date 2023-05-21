import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: _buildMap(),
    );
  }

  Widget _buildMap() {
    var x = 32.0853, y = 34.7818;
    return FlutterMap(
      options: MapOptions(
        zoom: 18,
        center: LatLng(x, y),
        bounds: LatLngBounds(LatLng(x, y), LatLng(x, y)),
      ),
      children: [
        TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        MarkerLayer(markers: [
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(x, y),
            builder: (ctx) => Container(
                child: const Icon(
              Icons.location_on,
              color: Colors.red,
            )),
          ),
        ])
      ],
    );
  }
}
