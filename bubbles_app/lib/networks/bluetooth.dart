import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class Bluetooth {
  static Future<void> ensurePermissionsGranted() async {
    // Request the BLUETOOTH_CONNECT and BLUETOOTH_SCAN permissions
    Map<Permission, PermissionStatus> permissionStatuses =
        await [Permission.bluetoothConnect, Permission.bluetoothScan].request();

    // Check if the permissions were granted
    if (permissionStatuses[Permission.bluetoothConnect]!.isDenied ||
        permissionStatuses[Permission.bluetoothScan]!.isDenied) {
      // The permission was denied, show an error message
      throw Exception('Bluetooth connect or scan permission denied');
    }
  }

  static Future<String?> scanAndConnect(BuildContext context) async {
    // Ensure the necessary permissions are granted before starting
    await ensurePermissionsGranted();

    FlutterBlue flutterBlue = FlutterBlue.instance;
    List<ScanResult> deviceList = [];

    // Start scanning
    flutterBlue.startScan(timeout: const Duration(seconds: 5));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Scanning...', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Image.asset('assets/images/bluetooth_loading.gif'),
              ],
            ),
          ),
        );
      },
    );

    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        // Check if deviceList already contains a device with the same name
        if (r.device.name.isNotEmpty &&
            !deviceList.any((device) => device.device.name == r.device.name)) {
          deviceList.add(r);
        }
      }
    });

    // Wait for scanning to complete
    await Future.delayed(const Duration(seconds: 5));

    // Stop scanning and dispose the subscription
    flutterBlue.stopScan();
    subscription.cancel();

    Navigator.of(context).pop(); // dismiss the dialog

    // Show dialog and return user selection
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a device'),
          content: SizedBox(
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
