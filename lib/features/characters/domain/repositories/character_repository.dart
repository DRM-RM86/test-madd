import 'package:dartz/dartz.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character_page.dart';

abstract class CharacterRepository {
  Future<Either<Failure, CharacterPage>> search({
    required String name,
    required int page,
  });

  Future<Either<Failure, List<Character>>> savedCharacters(String phone);

  Future<Either<Failure, bool>> isSaved({
    required String phone,
    required int id,
  });

  Future<Either<Failure, List<int>>> savedIds(String phone);

  Future<Either<Failure, Character>> profile({
    required String phone,
    required Character character,
  });

  Future<Either<Failure, Unit>> save({
    required String phone,
    required Character character,
  });

  Future<Either<Failure, Unit>> remove({
    required String phone,
    required int id,
  });
}
