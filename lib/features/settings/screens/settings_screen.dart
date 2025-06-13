import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/core/services/database_service.dart';
// import 'package:smodi/features/settings/screens/voice_motivator_screen.dart';
// import 'package:smodi/features/sync/screens/discover_devices_screen.dart';
import 'package:smodi/features/sync/screens/manual_data_transfer_screen.dart';

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
            onTap: () {
              // Navigator.of(context).push(
              //     MaterialPageRoute(builder: (_) => const VoiceMotivatorScreen()),
              //     );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(CupertinoIcons.device_laptop),
            title: const Text('Authorize New Device'),
            subtitle: const Text('Log in on another device on your network'),
            onTap: () {
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (_) => const DiscoverDevicesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync_alt),
            title: const Text('Manual Data Transfer'),
            subtitle: const Text('Force sync all data to/from another device'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ManualDataTransferScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orangeAccent),
            title: const Text('Debug: Print Local DB'),
            subtitle: const Text('Shows DB contents in the debug console'),
            onTap: () {
              sl<DatabaseService>().debugPrintAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Database contents printed to debug console.')),
              );
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
                  content: const Text(
                      'This will delete all local data on this device. It will be re-synced from the cloud the next time you log in.'),
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
              }
            },
          ),
        ],
      ),
    );
  }
}
