import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCReader {
  static Future<void> readNfc(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Check availability
      bool isAvailable = await NfcManager.instance.isAvailable();
      print('Is NFC available? $isAvailable');

      if (isAvailable) {
        print('Starting NFC session...');
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            print('NFC tag discovered');
            Ndef? ndef = Ndef.from(tag);

            if (ndef == null) {
              print('Tag is not compatible with NDEF');
              return;
            }

            // Read NDEF message from the tag
            NdefMessage ndefMessage = await ndef.read();

            // Extract records from the NDEF message
            List<NdefRecord> records = ndefMessage.records;

            // Process each record
            for (NdefRecord record in records) {
              // Extract the payload data from the record
              Uint8List payload = record.payload;

              // Perform further processing on the payload data, such as decoding, parsing, etc.
              // ...

              // Print the payload as a UTF-8 string
              String payloadText = utf8.decode(payload);
              print('NFC Tag Payload: $payloadText');
            }

            // Stop Session
            NfcManager.instance.stopSession();
            print('NFC session stopped');

            // Hide loading indicator
            Navigator.pop(context);
            print('Loading indicator hidden');
          },
        );
        print('NFC session started');
      } else {
        print('NFC is not available');
        // Hide loading indicator
        Navigator.pop(context);
        print('Loading indicator hidden');
      }
    } catch (e) {
      print('Error reading NFC: $e');
      // Hide loading indicator
      Navigator.pop(context);
      print('Loading indicator hidden');
    }
  }
}
