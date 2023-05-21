import 'package:flutter/material.dart';

class BubbleKeyType {
  final String name;
  final IconData icon;
  final int index;
  final LinearGradient gradient;

  const BubbleKeyType._(this.name, this.icon, this.index, this.gradient);

  static const BubbleKeyType gps = BubbleKeyType._(
    'GPS',
    Icons.gps_fixed,
    0,
    LinearGradient(
      colors: [Colors.green, Colors.greenAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
  static const BubbleKeyType wifi = BubbleKeyType._(
    'WiFi',
    Icons.wifi,
    1,
    LinearGradient(
      colors: [Colors.lightBlue, Colors.lightBlueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
  static const BubbleKeyType nfc = BubbleKeyType._(
    'NFC',
    Icons.nfc,
    2,
    LinearGradient(
      colors: [Colors.purple, Colors.purpleAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
  static const BubbleKeyType password = BubbleKeyType._(
    'Password',
    Icons.vpn_key,
    3,
    LinearGradient(
      colors: [Colors.red, Colors.redAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
  static const BubbleKeyType bluetooth = BubbleKeyType._(
    'Bluetooth',
    Icons.bluetooth,
    4,
    LinearGradient(
      colors: [Colors.blue, Colors.blueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static List<BubbleKeyType> get values =>
      [gps, wifi, nfc, password, bluetooth];

  static BubbleKeyType getKeyTypeByIndex(int index) {
    for (BubbleKeyType keyType in BubbleKeyType.values) {
      if (keyType.index == index) {
        return keyType;
      }
    }

    throw Exception('Index does not correspond to a valid BubbleKeyType');
  }
}
