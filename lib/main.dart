import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smodi/app.dart';
import 'package:smodi/core/di/injection_container.dart' as di;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  //
  // --- BOOTSTRAPPING ---
  //

  // --- THIS IS THE CRUCIAL FIX FOR DESKTOP ---
  // The sqflite package requires a specific database factory implementation
  // for desktop platforms (Windows, macOS, Linux) that uses FFI.
  // We must initialize it before any sqflite-related code is called.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Ensure that Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file.
  await dotenv.load(fileName: ".env");

  // Initialize dependencies, including the database which now knows
  // to use the FFI factory on desktop.
  await di.init();

  // Run the main application widget.
  runApp(const SmodiApp());
}
