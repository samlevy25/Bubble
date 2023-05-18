// import 'dart:async';
// import 'package:nfc_manager/nfc_manager.dart';

// Future<String> readNfc() async {
//   NfcManager manager = NfcManager.instance;
//   String data;

//   try {
//     await manager.startSession(
//       onDiscovered: (NfcTag tag) {
//         data = tag.data as String;
//       },
//       onError: (Object error) {
//         print('Error reading NFC: $error');
//       },
//     );
//   } catch (e) {
//     print('Error initializing NFC: $e');
//     return null;
//   }

//   return data;
// }
