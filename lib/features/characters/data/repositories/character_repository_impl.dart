import 'package:dartz/dartz.dart';
import 'package:pruebatecnica/core/error/exceptions.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/features/characters/data/datasources/character_image_store.dart';
import 'package:pruebatecnica/features/characters/data/datasources/character_local_data_source.dart';
import 'package:pruebatecnica/features/characters/data/datasources/character_remote_data_source.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character_page.dart';
import 'package:pruebatecnica/features/characters/domain/repositories/character_repository.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  CharacterRepositoryImpl({
    required this.remote,
    required this.local,
    required this.images,
  });

  final CharacterRemoteDataSource remote;
  final CharacterLocalDataSource local;
  final CharacterImageStore images;

  @override
  Future<Either<Failure, CharacterPage>> search({
    required String name,
    required int page,
  }) async {
    final query = name.trim();
    if (query.isEmpty) {
      return const Left(ValidationFailure('Escribe un nombre.'));
    }
    try {
      return Right(await remote.search(name: query, page: page));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, List<Character>>> savedCharacters(String phone) async {
    return Right(await local.list(phone));
  }

  @override
  Future<Either<Failure, bool>> isSaved({
    required String phone,
    required int id,
  }) async {
    final character = await local.find(phone: phone, id: id);
    return Right(character != null);
  }

  @override
  Future<Either<Failure, List<int>>> savedIds(String phone) async {
    return Right(await local.savedIds(phone));
  }

  @override
  Future<Either<Failure, Character>> profile({
    required String phone,
    required Character character,
  }) async {
    final stored = await local.find(phone: phone, id: character.id);
    if (stored != null && stored.episodes.isNotEmpty) {
      return Right(stored);
    }
    try {
      return Right(await remote.loadProfile(stored ?? character));
    } on NetworkException catch (error) {
      if (stored != null) return Right(stored);
      return Left(NetworkFailure(error.message));
    } on ServerException catch (error) {
      if (stored != null) return Right(stored);
      return Left(ServerFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> save({
    required String phone,
    required Character character,
  }) async {
    final current = await local.find(phone: phone, id: character.id);
    final path = await images.save(
      phone: phone,
      id: character.id,
      url: character.imageUrl,
    );
    await local.upsert(
      phone,
      character,
      imagePath: path ?? current?.localImagePath,
    );
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> remove({
    required String phone,
    required int id,
  }) async {
    final path = await local.delete(phone: phone, id: id);
    await images.delete(path);
    return const Right(unit);
  }
}
