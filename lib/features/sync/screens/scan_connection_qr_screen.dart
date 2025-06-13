import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/core/services/logging_service.dart';
import 'package:smodi/data/models/sync_payload_model.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';

class ScanConnectionQrScreen extends StatefulWidget {
  const ScanConnectionQrScreen({super.key});

  @override
  State<ScanConnectionQrScreen> createState() => _ScanConnectionQrScreenState();
}

class _ScanConnectionQrScreenState extends State<ScanConnectionQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  Future<void> _handleScannedUrl(String url) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final authService = sl<AuthService>();
      final repo = sl<FocusSessionRepository>();
      final user = await authService.getCurrentUserSession();
      if (user == null) {
        throw Exception('You must be logged in to authorize a new device.');
      }

      final dataPayload = await repo.getFullSyncPayload();
      final fullPayload = SyncPayload(
          user: user,
          sessions: dataPayload.sessions,
          events: dataPayload.events);

      LoggingService.info('Sending payload to $url/sync');
      final response = await http.post(
        Uri.parse('$url/sync'),
        headers: {'Content-Type': 'application/json'},
        body: fullPayload.toRawJson(),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Authorization successful!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      } else {
        throw Exception(
            'Authorization failed on target device: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
        setState(() => _isProcessing = false);
        _scannerController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Device Code')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final String? url = capture.barcodes.firstOrNull?.rawValue;
              if (url != null && url.startsWith('http')) {
                _scannerController.stop();
                _handleScannedUrl(url);
              }
            },
          ),
          if (_isProcessing) const CircularProgressIndicator(),
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
