import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatelessWidget {
  const ScanQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? qrData = barcodes.first.rawValue;
            if (qrData != null) {
              print('QR Code detected!');
              // Stop scanning
              Navigator.of(context).pop();
              // TODO: Deserialize the qrData JSON and merge it into the local DB.
              // Show a success dialog.
            }
          }
        },
      ),
    );
  }
}
