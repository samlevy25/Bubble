import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';

class NFCReader {
  static Future<void> readNfc() async {
    // Check availability
    bool isAvailable = await NfcManager.instance.isAvailable();

// Start Session
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // Do something with an NfcTag instance.
      },
    );

// Stop Session
    NfcManager.instance.stopSession();
  }
}
