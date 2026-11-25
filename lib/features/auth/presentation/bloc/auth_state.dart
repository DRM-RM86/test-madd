import 'package:equatable/equatable.dart';

enum AuthStep { checking, phone, code, session }

class AuthState extends Equatable {
  const AuthState({
    this.step = AuthStep.checking,
    this.phone = '',
    this.submitting = false,
    this.error,
  });

  final AuthStep step;
  final String phone;
  final bool submitting;
  final String? error;

  AuthState copyWith({
    AuthStep? step,
    String? phone,
    bool? submitting,
    Object? error = _keep,
  }) {
    return AuthState(
      step: step ?? this.step,
      phone: phone ?? this.phone,
      submitting: submitting ?? this.submitting,
      error: identical(error, _keep) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [step, phone, submitting, error];
}

const _keep = Object();
