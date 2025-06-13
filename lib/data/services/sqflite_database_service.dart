import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:smodi/core/services/database_service.dart';
import 'package:smodi/core/services/logging_service.dart';
import 'package:smodi/data/models/focus_event_model.dart';
import 'package:smodi/data/models/focus_session_model.dart';
import 'package:smodi/data/models/local_session_model.dart';
import 'package:smodi/data/models/sync_payload_model.dart';

class SqfliteDatabaseService implements DatabaseService {
  Database? _database;
  static const String _dbName = 'smodi.db';
  static const int _dbVersion = 4;

  static const String _createFocusSessionsTable = '''
    CREATE TABLE focus_sessions (
      session_id TEXT PRIMARY KEY,
      user_id TEXT,
      start_time TEXT NOT NULL,
      end_time TEXT,
      type TEXT NOT NULL,
      planned_focus_duration_sec INTEGER NOT NULL,
      planned_break_duration_sec INTEGER NOT NULL,
      status TEXT NOT NULL,
      last_modified_at TEXT NOT NULL,
      sync_status TEXT DEFAULT 'new'
    )
  ''';

  static const String _createFocusEventsTable = '''
    CREATE TABLE focus_events (
      event_id TEXT PRIMARY KEY,
      session_id TEXT,
      event_type TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      duration_sec INTEGER,
      details TEXT,
      sync_status TEXT DEFAULT 'new'
    )
  ''';

  @override
  Future<void> init() async {
    if (_database != null && _database!.isOpen) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    _database = await openDatabase(path, version: _dbVersion,
        onCreate: (db, version) async {
      LoggingService.info(
          'Database onCreate: Creating all tables for version $version...');
      await db.execute(_createFocusSessionsTable);
      await db.execute(_createFocusEventsTable);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      LoggingService.info(
          'Database onUpgrade: Upgrading from version $oldVersion to $newVersion...');
      if (oldVersion < 4) {
        // Use catchError to prevent crash if column already exists from a failed upgrade
        await db
            .execute(
                "ALTER TABLE focus_sessions ADD COLUMN sync_status TEXT DEFAULT 'synced'")
            .catchError((e) {
          LoggingService.warning(
              "Column sync_status may already exist in focus_sessions.");
        });
        await db
            .execute(
                "ALTER TABLE focus_events ADD COLUMN sync_status TEXT DEFAULT 'synced'")
            .catchError((e) {
          LoggingService.warning(
              "Column sync_status may already exist in focus_events.");
        });
      }
    });
  }

  Future<Database> get _db async {
    if (_database == null || !_database!.isOpen) await init();
    return _database!;
  }

  @override
  Future<void> saveFocusSession(FocusSession session) async {
    final db = await _db;
    await db.insert('focus_sessions', session.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> saveFocusEvent(FocusEvent event) async {
    final db = await _db;
    await db.insert('focus_events', event.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<FocusEvent>> getAllFocusEvents() async {
    final db = await _db;
    final maps = await db.query('focus_events', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) => FocusEvent.fromMap(maps[i]));
  }

  @override
  Future<List<FocusSession>> getAllFocusSessions() async {
    final db = await _db;
    final maps = await db.query('focus_sessions');
    return List.generate(maps.length, (i) => FocusSession.fromMap(maps[i]));
  }

  @override
  Future<void> mergeSyncPayload(SyncPayload payload) async {
    final db = await _db;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final session in payload.sessions) {
        batch.insert('focus_sessions', session.toMapForDb(isSynced: true),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final event in payload.events) {
        batch.insert('focus_events', event.toMapForDb(isSynced: true),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<void> wipeDatabase() async {
    final dbPath = join(await getDatabasesPath(), _dbName);
    if (_database != null && _database!.isOpen) await _database!.close();
    _database = null;
    if (await databaseExists(dbPath)) {
      await deleteDatabase(dbPath);
      LoggingService.info('Local database successfully wiped.');
    } else {
      LoggingService.info('Database file not found. Nothing to wipe.');
    }
  }

  @override
  Future<void> debugPrintAllData() async {
    LoggingService.debug('--- 🕵️ DEBUG: LOCAL DATABASE CONTENTS 🕵️ ---');
    try {
      final db = await _db;
      final sessions = await db.query('focus_sessions');
      LoggingService.debug('--- FOCUS SESSIONS (${sessions.length}) ---');
      for (final s in sessions) {
        LoggingService.debug(s.toString());
      }
      final events = await db.query('focus_events');
      LoggingService.debug('--- FOCUS EVENTS (${events.length}) ---');
      for (final e in events) {
        LoggingService.debug(e.toString());
      }
      LoggingService.debug('--- END OF DATABASE DUMP ---');
    } catch (e) {
      LoggingService.error('Could not read database. Error: $e');
    }
  }

  @override
  Future<SyncPayload> getLocalChanges() async {
    final db = await _db;
    final sessions =
        await db.query('focus_sessions', where: "sync_status = 'new'");
    final events = await db.query('focus_events', where: "sync_status = 'new'");
    return SyncPayload(
      user: const LocalSession(
          userId: '',
          email: '',
          refreshToken: ''), // User is a placeholder here
      sessions: List.generate(
          sessions.length, (i) => FocusSession.fromMap(sessions[i])),
      events:
          List.generate(events.length, (i) => FocusEvent.fromMap(events[i])),
    );
  }

  @override
  Future<void> markAsSynced(SyncPayload payload) async {
    final db = await _db;
    final batch = db.batch();
    for (final session in payload.sessions) {
      batch.update('focus_sessions', {'sync_status': 'synced'},
          where: 'session_id = ?', whereArgs: [session.sessionId]);
    }
    for (final event in payload.events) {
      batch.update('focus_events', {'sync_status': 'synced'},
          where: 'event_id = ?', whereArgs: [event.eventId]);
    }
    await batch.commit(noResult: true);
  }
}

// Helper extensions to add the sync_status to the map before DB insertion.
extension on FocusSession {
  Map<String, dynamic> toMapForDb({bool isSynced = false}) =>
      {...toMap(), 'sync_status': isSynced ? 'synced' : 'new'};
}

extension on FocusEvent {
  Map<String, dynamic> toMapForDb({bool isSynced = false}) =>
      {...toMap(), 'sync_status': isSynced ? 'synced' : 'new'};
}
