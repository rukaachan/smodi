import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/features/sync/screens/scan_connection_qr_screen.dart';
// import 'package:smodi/features/sync/screens/display_auth_qr_screen.dart';
import 'package:smodi/features/sync/screens/manual_data_transfer_screen.dart';
import 'package:smodi/features/sync/screens/scan_qr_screen.dart';
// import 'package:smodi/features/settings/screens/voice_motivator_screen.dart';
// import 'package:smodi/features/sync/screens/generate_auth_qr_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = sl<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Personalization'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(CupertinoIcons.speaker_2_fill),
            title: const Text('Voice Motivators'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            onTap: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (_) => const VoiceMotivatorScreen()),
              // );
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.shield_fill),
            title: const Text('Focus Shield Rules'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            onTap: () {
              // TODO: Navigate to ShieldRulesScreen (for a later phase)
            },
          ),
          const Divider(),
          // --- NEW, SEPARATED QR FEATURES ---
          ListTile(
            leading: const Icon(CupertinoIcons.qrcode_viewfinder),
            title: const Text('Authorize New Device'),
            subtitle: const Text('Scan another device to log it in'),
            onTap: () {
              // The trusted device always opens its scanner.
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ScanConnectionQrScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync_alt),
            title: const Text('Manual Data Transfer'),
            subtitle: const Text('Transfer all data to/from another device'),
            onTap: () {
              // This navigates to a screen for the full DATA transfer flow.
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ManualDataTransferScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(CupertinoIcons.question_circle_fill),
            title: const Text('Help & FAQ'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            onTap: () {
              // TODO: Navigate to HelpScreen
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.info_circle_fill),
            title: const Text('About Smodi'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            onTap: () {
              // TODO: Navigate to AboutScreen
            },
          ),
          const Divider(),
          ListTile(
            leading:
                Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Sign Out',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () async {
              final didRequestSignOut = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out?'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (didRequestSignOut ?? false) {
                await authService.signOut();
                // The AuthGate will handle navigation automatically.
              }
            },
          ),
        ],
      ),
    );
  }
}
