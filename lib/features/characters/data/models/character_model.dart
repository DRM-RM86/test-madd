import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/entities/episode_info.dart';
import 'package:pruebatecnica/features/characters/domain/entities/place.dart';

class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.name,
    required super.status,
    required super.species,
    required super.gender,
    required super.origin,
    required super.location,
    required super.imageUrl,
    required super.episodeCount,
    super.episodeIds,
    super.episodes,
    super.localImagePath,
    this.savedAt,
  });

  final int? savedAt;

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    final ids = _episodeIds(json['episode']);
    return CharacterModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      species: json['species'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      origin: _place(json['origin']),
      location: _place(json['location']),
      imageUrl: json['image'] as String? ?? '',
      episodeCount: ids.length,
      episodeIds: ids,
    );
  }

  factory CharacterModel.fromRow(
    Map<String, Object?> row, {
    List<EpisodeInfo> episodes = const [],
  }) {
    return CharacterModel(
      id: row['id']! as int,
      name: row['name']! as String,
      status: row['status']! as String,
      species: row['species']! as String,
      gender: row['gender']! as String,
      origin: Place(
        name: row['origin'] as String? ?? '',
        url: row['origin_url'] as String? ?? '',
        type: row['origin_type'] as String? ?? '',
        dimension: row['origin_dimension'] as String? ?? '',
        residentCount: row['origin_residents'] as int? ?? 0,
      ),
      location: Place(
        name: row['location'] as String? ?? '',
        url: row['location_url'] as String? ?? '',
        type: row['location_type'] as String? ?? '',
        dimension: row['location_dimension'] as String? ?? '',
        residentCount: row['location_residents'] as int? ?? 0,
      ),
      imageUrl: row['image_url']! as String,
      episodeCount: row['episode_count']! as int,
      episodeIds: _parseIds(row['episode_ids'] as String?),
      episodes: episodes,
      localImagePath: row['image_path'] as String?,
      savedAt: row['saved_at'] as int?,
    );
  }

  Map<String, Object?> toRow(String phone, {String? imagePath}) {
    return {
      'phone': phone,
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'gender': gender,
      'origin': origin.name,
      'origin_url': origin.url,
      'origin_type': origin.type,
      'origin_dimension': origin.dimension,
      'origin_residents': origin.residentCount,
      'location': location.name,
      'location_url': location.url,
      'location_type': location.type,
      'location_dimension': location.dimension,
      'location_residents': location.residentCount,
      'image_url': imageUrl,
      'image_path': imagePath ?? localImagePath,
      'episode_count': episodes.isEmpty ? episodeCount : episodes.length,
      'episode_ids': episodeIds.join(','),
      'saved_at': savedAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Place _place(Object? value) {
    if (value is Map) {
      return Place(
        name: value['name'] as String? ?? '',
        url: value['url'] as String? ?? '',
      );
    }
    return const Place(name: '');
  }

  static List<int> _episodeIds(Object? value) {
    if (value is! List) return const [];
    final ids = <int>[];
    for (final item in value) {
      if (item is! String) continue;
      final id = int.tryParse(item.split('/').last);
      if (id != null) ids.add(id);
    }
    return ids;
  }

  static List<int> _parseIds(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return [
      for (final part in raw.split(','))
        if (int.tryParse(part) != null) int.parse(part),
    ];
  }
}
