import 'package:network_info_plus/network_info_plus.dart';

Future<String?> getWifiName() async {
  final info =  NetworkInfo();
  final wifiName = await info.getWifiName(); // "FooNetwork"
  return wifiName;
}

Future<String?> getWifiBSSID() async {
  final info = NetworkInfo();
  final wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66
  return wifiBSSID;
}
