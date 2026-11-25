import 'package:equatable/equatable.dart';
import 'package:pruebatecnica/features/characters/domain/entities/episode_info.dart';
import 'package:pruebatecnica/features/characters/domain/entities/place.dart';

class Character extends Equatable {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.origin,
    required this.location,
    required this.imageUrl,
    required this.episodeCount,
    this.episodeIds = const [],
    this.episodes = const [],
    this.localImagePath,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final Place origin;
  final Place location;
  final String imageUrl;
  final int episodeCount;
  final List<int> episodeIds;
  final List<EpisodeInfo> episodes;
  final String? localImagePath;

  Character copyWith({
    Place? origin,
    Place? location,
    int? episodeCount,
    List<int>? episodeIds,
    List<EpisodeInfo>? episodes,
    String? localImagePath,
  }) {
    return Character(
      id: id,
      name: name,
      status: status,
      species: species,
      gender: gender,
      origin: origin ?? this.origin,
      location: location ?? this.location,
      imageUrl: imageUrl,
      episodeCount: episodeCount ?? this.episodeCount,
      episodeIds: episodeIds ?? this.episodeIds,
      episodes: episodes ?? this.episodes,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    species,
    gender,
    origin,
    location,
    imageUrl,
    episodeCount,
    episodeIds,
    episodes,
    localImagePath,
  ];
}
