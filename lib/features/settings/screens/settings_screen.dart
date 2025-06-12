import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smodi/core/di/injection_container.dart';
import 'package:smodi/core/services/auth_service.dart';

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
              // TODO: Navigate to VoiceMotivatorScreen
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
          // --- THIS IS THE FIX ---
          // The Sign Out button was missing and is now restored.
          ListTile(
            leading:
                Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Sign Out',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () async {
              // Show a confirmation dialog before signing out.
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
