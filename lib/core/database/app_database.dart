import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    return _database ??= await openDatabase(
      '${await getDatabasesPath()}/pruebatecnica.db',
      version: 2,
      onCreate: (db, version) async {
        await _create(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE saved_characters ADD COLUMN origin_url TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE saved_characters ADD COLUMN origin_type TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE saved_characters ADD COLUMN origin_dimension TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'ALTER TABLE saved_characters ADD COLUMN origin_residents INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            "ALTER TABLE saved_characters ADD COLUMN location_url TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE saved_characters ADD COLUMN location_type TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE saved_characters ADD COLUMN location_dimension TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'ALTER TABLE saved_characters ADD COLUMN location_residents INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            "ALTER TABLE saved_characters ADD COLUMN episode_ids TEXT NOT NULL DEFAULT ''",
          );
          await _episodes(db);
        }
      },
    );
  }

  Future<void> _create(Database db) async {
    await db.execute('''
      CREATE TABLE saved_characters (
        phone TEXT NOT NULL,
        id INTEGER NOT NULL,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        species TEXT NOT NULL,
        gender TEXT NOT NULL,
        origin TEXT NOT NULL,
        origin_url TEXT NOT NULL DEFAULT '',
        origin_type TEXT NOT NULL DEFAULT '',
        origin_dimension TEXT NOT NULL DEFAULT '',
        origin_residents INTEGER NOT NULL DEFAULT 0,
        location TEXT NOT NULL,
        location_url TEXT NOT NULL DEFAULT '',
        location_type TEXT NOT NULL DEFAULT '',
        location_dimension TEXT NOT NULL DEFAULT '',
        location_residents INTEGER NOT NULL DEFAULT 0,
        image_url TEXT NOT NULL,
        image_path TEXT,
        episode_count INTEGER NOT NULL,
        episode_ids TEXT NOT NULL DEFAULT '',
        saved_at INTEGER NOT NULL,
        PRIMARY KEY (phone, id)
      )
    ''');
    await _episodes(db);
  }

  Future<void> _episodes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_episodes (
        phone TEXT NOT NULL,
        character_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        PRIMARY KEY (phone, character_id, position)
      )
    ''');
  }
}
