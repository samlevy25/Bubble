import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Bluetooth {
  static Future<String?> scanAndConnect(BuildContext context) async {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    List<ScanResult> deviceList = [];

    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Scanning...', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Image.asset('assets/images/bluetooth_loading.gif'),
                ],
              ),
            ),
          );
        });

    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        // Check if deviceList already contains a device with the same name
        if (r.device.name != '' &&
            !deviceList.any((device) => device.device.name == r.device.name)) {
          deviceList.add(r);
        }
      }
    });

    // Stop scanning
    flutterBlue.stopScan();

    // Wait a bit to collect devices
    await Future.delayed(Duration(seconds: 5));

    Navigator.of(context).pop(); // dismiss the dialog

    // Show dialog and return user selection
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a device'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              children: deviceList.map((ScanResult result) {
                return ListTile(
                  title: Text(result.device.name),
                  onTap: () {
                    Navigator.of(context).pop(result.device.id.id);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
