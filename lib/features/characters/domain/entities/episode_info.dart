import 'package:equatable/equatable.dart';

class EpisodeInfo extends Equatable {
  const EpisodeInfo({required this.code, required this.name});

  final String code;
  final String name;

  @override
  List<Object> get props => [code, name];
}
