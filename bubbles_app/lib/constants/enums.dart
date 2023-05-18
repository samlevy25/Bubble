import 'package:flutter/material.dart';

class BubbleKeyType {
  final String name;
  final IconData icon;
  final int index;

  const BubbleKeyType._(this.name, this.icon, this.index);

  static const BubbleKeyType gps = BubbleKeyType._('GPS', Icons.gps_fixed, 0);
  static const BubbleKeyType wifi = BubbleKeyType._('WiFi', Icons.wifi, 1);
  static const BubbleKeyType nfc = BubbleKeyType._('NFC', Icons.nfc, 2);
  static const BubbleKeyType password =
      BubbleKeyType._('Password', Icons.vpn_key, 3);
  static const BubbleKeyType bluetooth =
      BubbleKeyType._('Bluetooth', Icons.bluetooth, 4);

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
