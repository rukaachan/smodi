import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as r;
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/core/services/logging_service.dart';
import 'package:smodi/data/models/sync_payload_model.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:smodi/features/shell_navigator/shell_navigator_screen.dart';

class DisplayConnectionQrScreen extends StatefulWidget {
  const DisplayConnectionQrScreen({super.key});

  @override
  State<DisplayConnectionQrScreen> createState() =>
      _DisplayConnectionQrScreenState();
}

class _DisplayConnectionQrScreenState extends State<DisplayConnectionQrScreen> {
  HttpServer? _server;
  String? _qrData;
  String _statusMessage = 'Initializing local server...';

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    final router = r.Router();
    router.post('/sync', (shelf.Request request) async {
      final payloadString = await request.readAsString();
      try {
        final payload = SyncPayload.fromRawJson(payloadString);
        await sl<FocusSessionRepository>().mergeSyncPayload(payload);
        await sl<AuthService>().cacheSession(payload.user);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ShellNavigatorScreen()),
            (route) => false,
          );
        }
        return shelf.Response.ok('Sync successful!');
      } catch (e) {
        return shelf.Response.internalServerError(
            body: 'Failed to process payload: $e');
      }
    });

    try {
      final ip = await NetworkInfo().getWifiIP();
      if (ip == null) {
        throw Exception(
            'Could not get Wi-Fi IP address. Ensure you are connected to a Wi-Fi network.');
      }
      _server = await io.serve(router.call, ip, 0, shared: false);

      if (mounted) {
        setState(() {
          _qrData = 'http://${_server!.address.host}:${_server!.port}';
          _statusMessage = 'Scan this QR code with your trusted device.';
          LoggingService.info('✅ Local server listening on _qrData');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Device Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_qrData != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(data: _qrData!, size: 250.0),
                )
              else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
