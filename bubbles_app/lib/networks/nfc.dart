import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';

class NFCReader {
  static Future<void> readNfc() async {
    // Check availability
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (isAvailable) {
      // Start Session
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var payload =
              tag.data['ndef']['cachedMessage']['records'][0]['payload'];
          print("Payload: $payload");
        },
      );

      // Stop Session
      NfcManager.instance.stopSession();
    } else {
      print("NFC is not available.");
    }
  }
}
