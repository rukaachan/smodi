import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrScreen extends StatelessWidget {
  const GenerateQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example JSON data to be encoded in the QR code.
    const String syncDataJson =
        '{"user_id":"...","sessions":[...],"events":[...]}';

    return Scaffold(
      appBar: AppBar(title: const Text('Source Device')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Have your other device scan this code.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: syncDataJson,
              version: QrVersions.auto,
              size: 280.0,
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
