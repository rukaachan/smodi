import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smodi/core/services/database_service.dart';
import 'package:smodi/data/models/focus_session_model.dart';

/// The SQLite implementation of the DatabaseService.
///
/// This class handles all direct interactions with the local SQLite database,
/// including opening the connection, creating tables, and executing CRUD queries.
class SqfliteDatabaseService implements DatabaseService {
  Database? _database;

  /// The name of the database file.
  static const String _dbName = 'smodi.db';

  /// SQL command to create the `focus_sessions` table.
  /// This schema is a direct translation from the provided database design document.
  static const String _createFocusSessionsTable = '''
    CREATE TABLE focus_sessions (
      session_id TEXT PRIMARY KEY,
      user_id TEXT,
      preset_id TEXT,
      start_time TEXT NOT NULL,
      end_time TEXT,
      type TEXT NOT NULL,
      planned_focus_duration_sec INTEGER NOT NULL,
      planned_break_duration_sec INTEGER NOT NULL,
      status TEXT NOT NULL,
      last_modified_at TEXT NOT NULL
    )
  ''';

  // NOTE: Other tables from the schema will be added here in later phases.
  // static const String _createFocusEventsTable = ...
  // static const String _createUsersTable = ...

  @override
  Future<void> init() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Execute all table creation commands when the DB is first created.
        await db.execute(_createFocusSessionsTable);
        // await db.execute(_createFocusEventsTable);
      },
    );
  }

  /// A helper to ensure the database is initialized before use.
  Future<Database> get _db async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  @override
  Future<void> saveFocusSession(FocusSession session) async {
    final database = await _db;
    // Using `insert` with `conflictAlgorithm: .replace` is an "upsert" operation.
    // It will INSERT a new row if the primary key doesn't exist, or
    // UPDATE the existing row if it does. This is perfect for our needs.
    await database.insert(
      'focus_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Session ${session.sessionId} saved to local DB.');
  }
}
