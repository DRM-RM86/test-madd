import 'package:equatable/equatable.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';

class CharacterPage extends Equatable {
  const CharacterPage({
    required this.characters,
    required this.page,
    required this.hasMore,
  });

  final List<Character> characters;
  final int page;
  final bool hasMore;

  @override
  List<Object> get props => [characters, page, hasMore];
}
