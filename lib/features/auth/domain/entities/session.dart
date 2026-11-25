import 'package:equatable/equatable.dart';

class Session extends Equatable {
  const Session({required this.phone});

  final String phone;

  @override
  List<Object> get props => [phone];
}
