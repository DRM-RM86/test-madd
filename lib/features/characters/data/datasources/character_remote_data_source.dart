import 'package:dio/dio.dart';
import 'package:pruebatecnica/core/error/exceptions.dart';
import 'package:pruebatecnica/features/characters/data/models/character_model.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character_page.dart';
import 'package:pruebatecnica/features/characters/domain/entities/episode_info.dart';
import 'package:pruebatecnica/features/characters/domain/entities/place.dart';

abstract class CharacterRemoteDataSource {
  Future<CharacterPage> search({required String name, required int page});

  Future<Character> loadProfile(Character character);
}

class CharacterRemoteDataSourceImpl implements CharacterRemoteDataSource {
  CharacterRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<CharacterPage> search({
    required String name,
    required int page,
  }) async {
    try {
      final response = await dio.get<dynamic>(
        '/character',
        queryParameters: {'name': name, 'page': page},
      );
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : const <String, dynamic>{};
      final info = data['info'] is Map
          ? Map<String, dynamic>.from(data['info'] as Map)
          : const <String, dynamic>{};
      final results = data['results'] as List<dynamic>? ?? const [];
      return CharacterPage(
        page: page,
        hasMore: info['next'] != null,
        characters: [
          for (final item in results)
            if (item is Map)
              CharacterModel.fromJson(Map<String, dynamic>.from(item)),
        ],
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return CharacterPage(characters: const [], page: page, hasMore: false);
      }
      if (_isOffline(error)) {
        throw const NetworkException(
          'Sin conexión. Lo que guardaste sigue en Guardados.',
        );
      }
      throw const ServerException('No pudimos consultar los personajes.');
    }
  }

  @override
  Future<Character> loadProfile(Character character) async {
    if (character.episodes.isNotEmpty &&
        _hasPlaceDetails(character.origin) &&
        _hasPlaceDetails(character.location)) {
      return character;
    }
    try {
      final episodes = character.episodes.isNotEmpty
          ? character.episodes
          : await _episodes(character.episodeIds);
      final origin = await _place(character.origin);
      final location = await _place(character.location);
      return character.copyWith(
        origin: origin,
        location: location,
        episodes: episodes,
        episodeCount: episodes.isEmpty
            ? character.episodeCount
            : episodes.length,
      );
    } on DioException catch (error) {
      if (_isOffline(error)) {
        throw const NetworkException(
          'Sin conexión. Los episodios y el lugar no se pudieron consultar.',
        );
      }
      throw const ServerException(
        'No pudimos consultar los episodios ni la ubicación.',
      );
    }
  }

  bool _hasPlaceDetails(Place place) {
    return place.url.isEmpty ||
        place.type.isNotEmpty ||
        place.residentCount > 0;
  }

  Future<List<EpisodeInfo>> _episodes(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final episodes = <EpisodeInfo>[];
    for (var start = 0; start < ids.length; start += 20) {
      final end = start + 20 > ids.length ? ids.length : start + 20;
      final chunk = ids.sublist(start, end);
      final response = await dio.get<dynamic>('/episode/${chunk.join(',')}');
      final data = response.data;
      final items = data is List ? data : [data];
      for (final item in items) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        episodes.add(
          EpisodeInfo(
            code: map['episode'] as String? ?? '',
            name: map['name'] as String? ?? '',
          ),
        );
      }
    }
    return episodes;
  }

  Future<Place> _place(Place place) async {
    if (place.url.isEmpty || place.type.isNotEmpty || place.residentCount > 0) {
      return place;
    }
    final response = await dio.get<dynamic>(place.url);
    if (response.data is! Map) return place;
    final map = Map<String, dynamic>.from(response.data as Map);
    final residents = map['residents'];
    return Place(
      name: map['name'] as String? ?? place.name,
      url: map['url'] as String? ?? place.url,
      type: map['type'] as String? ?? '',
      dimension: map['dimension'] as String? ?? '',
      residentCount: residents is List ? residents.length : 0,
    );
  }

  bool _isOffline(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }
}
