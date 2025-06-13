import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/data/models/sync_payload_model.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  Future<void> _handleQrCode(String qrData) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      if (qrData.startsWith('smodi_auth_request::')) {
        await _authorizeNewDevice(qrData);
      } else {
        await _mergeFullDataPayload(qrData);
      }
    } catch (e) {
      _showErrorAndRestart('Failed to process QR code: ${e.toString()}');
    }
  }

  Future<void> _authorizeNewDevice(String qrData) async {
    final parts = qrData.split('::');
    if (parts.length != 3) throw Exception('Invalid auth QR format.');

    final pairingToken = parts[1];
    final manualCodeFromQr = parts[2];
    final enteredCode = await _showManualCodeDialog();

    if (enteredCode == null) {
      _showErrorAndRestart('Authorization cancelled.');
      return;
    }
    if (enteredCode != manualCodeFromQr) {
      _showErrorAndRestart('Incorrect code entered. Please try again.');
      return;
    }

    final authService = sl<AuthService>();
    final supabase = sl<SupabaseClient>();
    final repo = sl<FocusSessionRepository>();

    final user = await authService.getCurrentUserSession();
    if (user == null) throw Exception('You must be logged in.');

    final dataPayload = await repo.getFullSyncPayload();
    final fullPayload = SyncPayload(
      user: user,
      sessions: dataPayload.sessions,
      events: dataPayload.events,
    );

    final channelName = 'pairing-channel-$pairingToken';
    final channel = supabase.channel(channelName).subscribe();

    // 🔄 Correct way to send broadcast
    await channel.sendBroadcastMessage(
      event: 'auth-data',
      payload: {'session': fullPayload.user.toJson()},
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authorization sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _mergeFullDataPayload(String qrData) async {
    final payload = SyncPayload.fromRawJson(qrData);
    await sl<FocusSessionRepository>().mergeSyncPayload(payload);
    if (payload.user.userId.isNotEmpty) {
      await sl<AuthService>().cacheSession(payload.user);
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Data Sync Successful!')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<String?> _showManualCodeDialog() {
    final codeController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter the 6-digit code displayed on your other device.'),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(counterText: ""),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(codeController.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showErrorAndRestart(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    setState(() => _isProcessing = false);
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (_isProcessing) return;
              final qrData = capture.barcodes.firstOrNull?.rawValue;
              if (qrData != null) {
                _scannerController.stop();
                _handleQrCode(qrData);
              }
            },
          ),
          if (_isProcessing)
            const Center(
              child: Card(
                color: Colors.black54,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Processing...',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}
