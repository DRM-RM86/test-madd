import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class PhoneSubmitted extends AuthEvent {
  const PhoneSubmitted(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class CodeSubmitted extends AuthEvent {
  const CodeSubmitted(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class ChangePhoneRequested extends AuthEvent {
  const ChangePhoneRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
