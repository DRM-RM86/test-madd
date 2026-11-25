import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/core/usecases/usecase.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character_page.dart';
import 'package:pruebatecnica/features/characters/domain/repositories/character_repository.dart';

class SearchCharactersParams extends Equatable {
  const SearchCharactersParams({required this.name, required this.page});

  final String name;
  final int page;

  @override
  List<Object> get props => [name, page];
}

class SearchCharacters
    implements UseCase<CharacterPage, SearchCharactersParams> {
  SearchCharacters(this.repository);

  final CharacterRepository repository;

  @override
  Future<Either<Failure, CharacterPage>> call(SearchCharactersParams params) {
    return repository.search(name: params.name, page: params.page);
  }
}
