import 'package:pruebatecnica/core/database/app_database.dart';
import 'package:pruebatecnica/features/characters/data/models/character_model.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/entities/episode_info.dart';
import 'package:sqflite/sqflite.dart';

abstract class CharacterLocalDataSource {
  Future<List<Character>> list(String phone);

  Future<Character?> find({required String phone, required int id});

  Future<List<int>> savedIds(String phone);

  Future<void> upsert(String phone, Character character, {String? imagePath});

  Future<String?> delete({required String phone, required int id});
}

class CharacterLocalDataSourceImpl implements CharacterLocalDataSource {
  CharacterLocalDataSourceImpl(this.database);

  final AppDatabase database;

  @override
  Future<List<Character>> list(String phone) async {
    final db = await database.database;
    final rows = await db.query(
      'saved_characters',
      where: 'phone = ?',
      whereArgs: [phone],
      orderBy: 'saved_at DESC',
    );
    return rows.map(CharacterModel.fromRow).toList();
  }

  @override
  Future<Character?> find({required String phone, required int id}) async {
    final db = await database.database;
    final rows = await db.query(
      'saved_characters',
      where: 'phone = ? AND id = ?',
      whereArgs: [phone, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final episodes = await _episodes(db, phone, id);
    return CharacterModel.fromRow(rows.first, episodes: episodes);
  }

  @override
  Future<List<int>> savedIds(String phone) async {
    final db = await database.database;
    final rows = await db.query(
      'saved_characters',
      columns: ['id'],
      where: 'phone = ?',
      whereArgs: [phone],
    );
    return [for (final row in rows) row['id']! as int];
  }

  @override
  Future<void> upsert(
    String phone,
    Character character, {
    String? imagePath,
  }) async {
    final db = await database.database;
    final model = character is CharacterModel
        ? character
        : CharacterModel(
            id: character.id,
            name: character.name,
            status: character.status,
            species: character.species,
            gender: character.gender,
            origin: character.origin,
            location: character.location,
            imageUrl: character.imageUrl,
            episodeCount: character.episodeCount,
            episodeIds: character.episodeIds,
            episodes: character.episodes,
            localImagePath: character.localImagePath,
          );
    await db.transaction((txn) async {
      await txn.insert(
        'saved_characters',
        model.toRow(phone, imagePath: imagePath),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        'saved_episodes',
        where: 'phone = ? AND character_id = ?',
        whereArgs: [phone, character.id],
      );
      for (var index = 0; index < character.episodes.length; index++) {
        final episode = character.episodes[index];
        await txn.insert('saved_episodes', {
          'phone': phone,
          'character_id': character.id,
          'position': index,
          'code': episode.code,
          'name': episode.name,
        });
      }
    });
  }

  @override
  Future<String?> delete({required String phone, required int id}) async {
    final current = await find(phone: phone, id: id);
    final db = await database.database;
    await db.transaction((txn) async {
      await txn.delete(
        'saved_episodes',
        where: 'phone = ? AND character_id = ?',
        whereArgs: [phone, id],
      );
      await txn.delete(
        'saved_characters',
        where: 'phone = ? AND id = ?',
        whereArgs: [phone, id],
      );
    });
    return current?.localImagePath;
  }

  Future<List<EpisodeInfo>> _episodes(Database db, String phone, int id) async {
    final rows = await db.query(
      'saved_episodes',
      where: 'phone = ? AND character_id = ?',
      whereArgs: [phone, id],
      orderBy: 'position ASC',
    );
    return [
      for (final row in rows)
        EpisodeInfo(code: row['code']! as String, name: row['name']! as String),
    ];
  }
}
