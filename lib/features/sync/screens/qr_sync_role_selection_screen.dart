import 'package:flutter/material.dart';
// TODO: Import the new Generate and Scan screens once they are created.

class QrSyncRoleSelectionScreen extends StatelessWidget {
  const QrSyncRoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Device Sync')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Which device is this?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_2),
                label: const Text('This is the SOURCE device (Show QR Code)'),
                onPressed: () {
                  // TODO: Navigate to GenerateQrScreen
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('This is the TARGET device (Scan QR Code)'),
                onPressed: () {
                  // TODO: Navigate to ScanQrScreen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
