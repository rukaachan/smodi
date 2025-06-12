import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:smodi/core/services/auth_service.dart';
import 'package:smodi/core/services/database_service.dart';
import 'package:smodi/data/repositories/focus_session_repository.dart';
import 'package:smodi/data/services/sqflite_database_service.dart';
import 'package:smodi/data/services/supabase_auth_service.dart';
import 'package:smodi/features/focus_session/bloc/focus_session_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smodi/features/insights/bloc/insights_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- External ---
  // Initialize Supabase and register its client instance.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  sl.registerLazySingleton(() => Supabase.instance.client);

  sl.registerFactory(
    () => InsightsBloc(focusSessionRepository: sl()),
  );

  // --- BLoCs ---
  sl.registerFactory(
    () => FocusSessionBloc(
      initialDuration: 25 * 60,
      focusSessionRepository: sl(),
    ),
  );

  // --- Repositories ---
  sl.registerLazySingleton(() => FocusSessionRepository(
        databaseService: sl<DatabaseService>(),
        supabaseClient: sl<SupabaseClient>(),
        connectivity: sl(),
      ));

  // --- Services ---
  sl.registerLazySingleton<DatabaseService>(() => SqfliteDatabaseService());
  sl.registerLazySingleton<AuthService>(() => SupabaseAuthService(sl()));

  // --- External Packages ---
  // Register the Connectivity package as a lazy singleton.
  sl.registerLazySingleton(() => Connectivity());

  // Initialize the local database service.
  await sl<DatabaseService>().init();
}
