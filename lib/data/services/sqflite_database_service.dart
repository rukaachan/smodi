import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smodi/core/services/database_service.dart';
import 'package:smodi/data/models/focus_event_model.dart';
import 'package:smodi/data/models/focus_session_model.dart';
import 'package:smodi/data/models/sync_payload_model.dart';

class SqfliteDatabaseService implements DatabaseService {
  Database? _database;
  static const String _dbName = 'smodi.db';

  static const int _dbVersion = 3;

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

  static const String _createFocusEventsTable = '''
    CREATE TABLE focus_events (
      event_id TEXT PRIMARY KEY,
      session_id TEXT,
      event_type TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      duration_sec INTEGER,
      details TEXT
    )
  ''';

  static const String _createVoiceMotivatorsTable = '''
    CREATE TABLE voice_motivators (
      voice_id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      file_path TEXT NOT NULL,
      is_default INTEGER NOT NULL,
      user_id TEXT,
      last_modified_at TEXT NOT NULL
    )
  ''';

  @override
  Future<void> init() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion, // Use the new version number
      onCreate: (db, version) async {
        // This runs only if the DB doesn't exist at all.
        print('Database onCreate: Creating all tables for version $version...');
        await db.execute(_createFocusSessionsTable);
        await db.execute(_createFocusEventsTable);
      },
      // --- THIS IS THE FIX: Add the onUpgrade method ---
      onUpgrade: (db, oldVersion, newVersion) async {
        print(
            'Database onUpgrade: Upgrading from version $oldVersion to $newVersion...');
        if (oldVersion < 2) {
          await db.execute(_createFocusEventsTable);
        }
        // --- THIS IS THE FIX: Add the new migration step ---
        if (oldVersion < 3) {
          await db.execute(_createVoiceMotivatorsTable);
          print('Upgraded database by creating voice_motivators table.');
        }
      },
    );
  }

  // ... rest of the file remains the same ...
  Future<Database> get _db async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  @override
  Future<void> saveFocusSession(FocusSession session) async {
    final database = await _db;
    await database.insert(
      'focus_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Session ${session.sessionId} saved to local DB.');
  }

  @override
  Future<void> saveFocusEvent(FocusEvent event) async {
    final database = await _db;
    await database.insert(
      'focus_events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Event ${event.eventId} saved to local DB.');
  }

  @override
  Future<List<FocusEvent>> getAllFocusEvents() async {
    final database = await _db;
    final List<Map<String, dynamic>> maps = await database.query(
      'focus_events',
      orderBy: 'timestamp DESC',
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return FocusEvent.fromMap(maps[i]);
    });
  }

  @override
  Future<List<FocusSession>> getAllFocusSessions() async {
    final database = await _db;
    final List<Map<String, dynamic>> maps =
        await database.query('focus_sessions');
    return List.generate(maps.length, (i) => FocusSession.fromMap(maps[i]));
  }

  @override
  Future<void> mergeSyncPayload(SyncPayload payload) async {
    final database = await _db;
    await database.transaction((txn) async {
      // Use a batch for efficient bulk operations
      final batch = txn.batch();

      // Merge sessions
      for (final session in payload.sessions) {
        batch.insert('focus_sessions', session.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Merge events
      for (final event in payload.events) {
        batch.insert('focus_events', event.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    });
    print('✅ Sync payload merged into local DB.');
  }
}
