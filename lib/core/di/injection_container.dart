import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/core/services/database_service.dart';
import 'package:smodi/core/services/sync_service.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:smodi/data/services/sqflite_database_service.dart';
import 'package:smodi/data/services/supabase_auth_service.dart';
import 'package:smodi/features/camera_control/bloc/camera_control_bloc.dart';
import 'package:smodi/features/focus_session/bloc/focus_session_bloc.dart';
import 'package:smodi/features/insights/bloc/insights_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- External ---
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // --- Services & Repositories (Order is important) ---
  sl.registerLazySingleton<DatabaseService>(() => SqfliteDatabaseService());

  sl.registerLazySingleton(() => FocusSessionRepository(
        databaseService: sl(),
        supabaseClient: sl(),
        connectivity: sl(),
      ));

  sl.registerLazySingleton(() => SyncService(
        repository: sl(),
        connectivity: sl(),
        supabaseClient: sl(),
        prefs: sl(),
      ));

  sl.registerLazySingleton<AuthService>(
      () => SupabaseAuthService(sl(), sl(), sl(), sl(), sl()));

  // --- BLoCs ---
  sl.registerFactory(() => FocusSessionBloc(
        initialDuration: 25 * 60,
        focusSessionRepository: sl(),
      ));
  sl.registerFactory(() => CameraControlBloc(focusSessionRepository: sl()));
  sl.registerFactory(() => InsightsBloc(focusSessionRepository: sl()));

  // Initialize the local database service on app startup.
  await sl<DatabaseService>().init();
}
