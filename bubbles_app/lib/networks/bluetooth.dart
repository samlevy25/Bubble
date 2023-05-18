import 'package:flutter_blue/flutter_blue.dart';

Future<List<BluetoothDevice>> getConnectedDevices() async {
  List<BluetoothDevice> connectedDevices = [];

  try {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
    print("we here?");
    connectedDevices = devices.toList();
  } catch (e) {
    print('Error retrieving connected devices: $e');
  }

  return connectedDevices;
}
