import 'package:flutter/material.dart';
import 'package:smodi/features/sync/screens/generate_qr_screen.dart';
import 'package:smodi/features/sync/screens/scan_qr_screen.dart';

/// This screen allows the user to choose whether this device will be the
/// source or target for a full, manual data transfer.
class ManualDataTransferScreen extends StatelessWidget {
  const ManualDataTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Data Transfer')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Which role will this device play?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_2),
                label: const Text('SOURCE (Show Full Data QR)'),
                onPressed: () {
                  // This screen generates the QR code with the ENTIRE database.
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GenerateQrScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('TARGET (Scan Data QR)'),
                onPressed: () {
                  // The scanner screen can handle both auth and data QRs.
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScanQrScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
