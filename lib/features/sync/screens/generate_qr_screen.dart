import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/data/models/sync_payload_model.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  Future<SyncPayload>? _payloadFuture;

  @override
  void initState() {
    super.initState();
    _payloadFuture = _createPayload();
  }

  Future<SyncPayload> _createPayload() async {
    final repo = sl<FocusSessionRepository>();
    final auth = sl<AuthService>();

    // Get the user data first.
    final user = await auth.getCurrentUserSession();
    if (user == null) {
      throw Exception('Cannot generate sync data: User is not logged in.');
    }

    // Get the data payload (sessions, events) from the repository.
    final dataPayload = await repo.getFullSyncPayload();

    // Combine the real user data with the rest of the payload,
    // replacing the placeholder.
    return SyncPayload(
      user: user,
      sessions: dataPayload.sessions,
      events: dataPayload.events,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Source Device')),
      body: Center(
        child: FutureBuilder<SyncPayload>(
          future: _payloadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error generating data: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Text('No data to sync.');
            }

            final jsonString = snapshot.data!.toRawJson();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Have your other device scan this code.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: jsonString,
                    version: QrVersions.auto,
                    size: 280.0,
                    backgroundColor: Colors.white,
                    gapless: false,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
