import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCReader {
  static Future<String> readNfc(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/nfc_loading.gif', // Replace with the path to your GIF image
                width: 100,
                height: 100,
              ),
            ),
          ),
        );
      },
    );

    Completer<String> completer = Completer<String>();

    try {
      // Check availability
      bool isAvailable = await NfcManager.instance.isAvailable();
      print('Is NFC available? $isAvailable');

      if (isAvailable) {
        print('Starting NFC session...');
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            print('NFC tag discovered');
            print(tag.data);

            Uint8List? uid;

            if (tag.data != null) {
              if (tag.data['nfca'] != null &&
                  tag.data['nfca']['identifier'] != null) {
                uid = Uint8List.fromList(tag.data['nfca']['identifier']);
              } else if (tag.data['isodep'] != null &&
                  tag.data['isodep']['identifier'] != null) {
                uid = Uint8List.fromList(tag.data['isodep']['identifier']);
              }
            }

            if (uid != null) {
              String uidHex = _convertBytesToHexString(uid);
              print('NFC Tag UID: $uidHex');
              completer.complete(uidHex);
            } else {
              print('No UID available for this tag');
              completer.completeError('No UID available for this tag');
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
        completer.completeError('NFC is not available');
      }
    } catch (e) {
      print('Error reading NFC: $e');
      // Hide loading indicator
      Navigator.pop(context);
      print('Loading indicator hidden');
      completer.completeError('Error reading NFC: $e');
    }

    return completer.future;
  }

  static String _convertBytesToHexString(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }
}
