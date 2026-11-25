import 'package:flutter_test/flutter_test.dart';
import 'package:pruebatecnica/core/error/exceptions.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/features/characters/data/datasources/character_image_store.dart';
import 'package:pruebatecnica/features/characters/data/datasources/character_local_data_source.dart';
import 'package:pruebatecnica/features/characters/data/datasources/character_remote_data_source.dart';
import 'package:pruebatecnica/features/characters/data/models/character_model.dart';
import 'package:pruebatecnica/features/characters/data/repositories/character_repository_impl.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character_page.dart';
import 'package:pruebatecnica/features/characters/domain/entities/place.dart';

void main() {
  late _Remote remote;
  late _Local local;
  late CharacterRepositoryImpl repository;

  const rick = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: 'Alive',
    species: 'Human',
    gender: 'Male',
    origin: Place(name: 'Earth (C-137)'),
    location: Place(name: 'Citadel of Ricks'),
    imageUrl: 'https://example.com/rick.jpeg',
    episodeCount: 2,
  );

  setUp(() {
    remote = _Remote();
    local = _Local();
    repository = CharacterRepositoryImpl(
      remote: remote,
      local: local,
      images: _Images(),
    );
  });

  test('lee el nombre, el origen y los episodios', () {
    final model = CharacterModel.fromJson({
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'gender': 'Male',
      'origin': {'name': 'Earth (C-137)'},
      'location': {'name': 'Citadel of Ricks'},
      'image': 'https://example.com/rick.jpeg',
      'episode': [
        'https://rickandmortyapi.com/api/episode/1',
        'https://rickandmortyapi.com/api/episode/2',
      ],
    });

    expect(model.name, 'Rick Sanchez');
    expect(model.origin.name, 'Earth (C-137)');
    expect(model.episodeIds, [1, 2]);
  });

  test('un nombre sin resultados no es un error', () async {
    remote.page = const CharacterPage(characters: [], page: 1, hasMore: false);

    final result = await repository.search(name: 'zzz', page: 1);

    expect(
      result.getOrElse(() => throw StateError('falló')).characters,
      isEmpty,
    );
  });

  test('sin red avisa y no borra lo guardado', () async {
    remote.error = const NetworkException('Sin conexión.');

    final result = await repository.search(name: 'rick', page: 1);

    expect(
      result.fold((failure) => failure, (_) => null),
      isA<NetworkFailure>(),
    );
  });

  test('lo guardado de un celular no aparece en otro', () async {
    await repository.save(phone: '5511111111', character: rick);

    final mine = await repository.savedCharacters('5511111111');
    final other = await repository.savedCharacters('5522222222');

    expect(mine.getOrElse(() => []).map((item) => item.id), [1]);
    expect(other.getOrElse(() => []), isEmpty);
  });
}

class _Remote implements CharacterRemoteDataSource {
  CharacterPage page = const CharacterPage(
    characters: [],
    page: 1,
    hasMore: false,
  );
  Exception? error;

  @override
  Future<CharacterPage> search({
    required String name,
    required int page,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    return this.page;
  }

  @override
  Future<Character> loadProfile(Character character) async => character;
}

class _Images implements CharacterImageStore {
  @override
  Future<String?> save({
    required String phone,
    required int id,
    required String url,
  }) async {
    return '/tmp/$phone-$id.jpg';
  }

  @override
  Future<void> delete(String? path) async {}
}

class _Local implements CharacterLocalDataSource {
  final rows = <String, Character>{};

  String _key(String phone, int id) => '$phone:$id';

  @override
  Future<List<Character>> list(String phone) async {
    return [
      for (final entry in rows.entries)
        if (entry.key.startsWith('$phone:')) entry.value,
    ];
  }

  @override
  Future<Character?> find({required String phone, required int id}) async {
    return rows[_key(phone, id)];
  }

  @override
  Future<List<int>> savedIds(String phone) async {
    return [
      for (final entry in rows.entries)
        if (entry.key.startsWith('$phone:')) entry.value.id,
    ];
  }

  @override
  Future<void> upsert(
    String phone,
    Character character, {
    String? imagePath,
  }) async {
    rows[_key(phone, character.id)] = character.copyWith(
      localImagePath: imagePath ?? character.localImagePath,
    );
  }

  @override
  Future<String?> delete({required String phone, required int id}) async {
    final current = rows.remove(_key(phone, id));
    return current?.localImagePath;
  }
}
