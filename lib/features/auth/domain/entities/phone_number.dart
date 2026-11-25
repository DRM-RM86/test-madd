import 'package:equatable/equatable.dart';

class PhoneNumber extends Equatable {
  const PhoneNumber._(this.value);

  final String value;

  static final _nonDigits = RegExp(r'\D');

  static PhoneNumber? tryParse(String raw) {
    final digits = raw.replaceAll(_nonDigits, '');
    if (digits.length != 10) return null;
    return PhoneNumber._(digits);
  }

  String get formatted {
    return '${value.substring(0, 3)} ${value.substring(3, 6)} ${value.substring(6)}';
  }

  @override
  List<Object> get props => [value];
}
