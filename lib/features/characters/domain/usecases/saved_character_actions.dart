import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/core/usecases/usecase.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/repositories/character_repository.dart';

class PhoneParams extends Equatable {
  const PhoneParams(this.phone);

  final String phone;

  @override
  List<Object> get props => [phone];
}

class GetSavedCharacters implements UseCase<List<Character>, PhoneParams> {
  GetSavedCharacters(this.repository);

  final CharacterRepository repository;

  @override
  Future<Either<Failure, List<Character>>> call(PhoneParams params) {
    return repository.savedCharacters(params.phone);
  }
}

class CharacterRef extends Equatable {
  const CharacterRef({required this.phone, required this.id});

  final String phone;
  final int id;

  @override
  List<Object> get props => [phone, id];
}

class IsCharacterSaved implements UseCase<bool, CharacterRef> {
  IsCharacterSaved(this.repository);

  final CharacterRepository repository;

  @override
  Future<Either<Failure, bool>> call(CharacterRef params) {
    return repository.isSaved(phone: params.phone, id: params.id);
  }
}

class SaveCharacterParams extends Equatable {
  const SaveCharacterParams({required this.phone, required this.character});

  final String phone;
  final Character character;

  @override
  List<Object> get props => [phone, character];
}

class SaveCharacter implements UseCase<Unit, SaveCharacterParams> {
  SaveCharacter(this.repository);

  final CharacterRepository repository;

  @override
  Future<Either<Failure, Unit>> call(SaveCharacterParams params) {
    return repository.save(phone: params.phone, character: params.character);
  }
}

class GetSavedIds implements UseCase<List<int>, PhoneParams> {
  GetSavedIds(this.repository);

  final CharacterRepository repository;

  @override
  Future<Either<Failure, List<int>>> call(PhoneParams params) {
    return repository.savedIds(params.phone);
  }
}

class ProfileParams extends Equatable {
  const ProfileParams({required this.phone, required this.character});

  final String phone;
  final Character character;

  @override
  List<Object> get props => [phone, character];
}

class LoadCharacterProfile implements UseCase<Character, ProfileParams> {
  LoadCharacterProfile(this.repository);

  final CharacterRepository repository;

  @override
  Future<Either<Failure, Character>> call(ProfileParams params) {
    return repository.profile(phone: params.phone, character: params.character);
  }
}

class RemoveSavedCharacter implements UseCase<Unit, CharacterRef> {
  RemoveSavedCharacter(this.repository);

  final CharacterRepository repository;

  @override
  Future<Either<Failure, Unit>> call(CharacterRef params) {
    return repository.remove(phone: params.phone, id: params.id);
  }
}
