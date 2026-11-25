import 'package:equatable/equatable.dart';

class Place extends Equatable {
  const Place({
    required this.name,
    this.url = '',
    this.type = '',
    this.dimension = '',
    this.residentCount = 0,
  });

  final String name;
  final String url;
  final String type;
  final String dimension;
  final int residentCount;

  bool get canOpen => url.isNotEmpty || type.isNotEmpty || dimension.isNotEmpty;

  @override
  List<Object> get props => [name, url, type, dimension, residentCount];
}
