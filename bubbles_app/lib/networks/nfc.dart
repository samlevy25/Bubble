import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';

class NFCReader {
  static Future<void> readNfc() async {
    // Check availability
    bool isAvailable = await NfcManager.instance.isAvailable();

// Start Session
    if (isAvailable) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print(tag.data);
        },
      );
    }

// Stop Session
    NfcManager.instance.stopSession();
  }
}
