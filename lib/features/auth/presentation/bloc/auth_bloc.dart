import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pruebatecnica/core/usecases/usecase.dart';
import 'package:pruebatecnica/features/auth/domain/usecases/get_session.dart';
import 'package:pruebatecnica/features/auth/domain/usecases/request_verification_code.dart';
import 'package:pruebatecnica/features/auth/domain/usecases/sign_out.dart';
import 'package:pruebatecnica/features/auth/domain/usecases/verify_code.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_event.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.requestVerificationCode,
    required this.verifyCode,
    required this.getSession,
    required this.signOut,
  }) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<PhoneSubmitted>(_onPhoneSubmitted);
    on<CodeSubmitted>(_onCodeSubmitted);
    on<ChangePhoneRequested>(_onChangePhone);
    on<SignOutRequested>(_onSignOut);
  }

  final RequestVerificationCode requestVerificationCode;
  final VerifyCode verifyCode;
  final GetSession getSession;
  final SignOut signOut;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final result = await getSession(const NoParams());
    result.fold(
      (failure) =>
          emit(AuthState(step: AuthStep.phone, error: failure.message)),
      (session) {
        if (session == null) {
          emit(const AuthState(step: AuthStep.phone));
          return;
        }
        emit(AuthState(step: AuthStep.session, phone: session.phone));
      },
    );
  }

  Future<void> _onPhoneSubmitted(
    PhoneSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final backToCode = state.step == AuthStep.code;
    emit(state.copyWith(submitting: true, error: null));
    final result = await requestVerificationCode(event.phone);
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitting: false,
          step: backToCode ? AuthStep.code : AuthStep.phone,
          error: failure.message,
        ),
      ),
      (phone) => emit(
        state.copyWith(
          submitting: false,
          step: AuthStep.code,
          phone: phone,
          error: null,
        ),
      ),
    );
  }

  Future<void> _onCodeSubmitted(
    CodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(submitting: true, error: null));
    final result = await verifyCode(
      VerifyCodeParams(phone: state.phone, code: event.code),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(submitting: false, error: failure.message)),
      (session) => emit(
        state.copyWith(
          submitting: false,
          step: AuthStep.session,
          phone: session.phone,
          error: null,
        ),
      ),
    );
  }

  void _onChangePhone(ChangePhoneRequested event, Emitter<AuthState> emit) {
    emit(state.copyWith(step: AuthStep.phone, submitting: false, error: null));
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await signOut(const NoParams());
    emit(const AuthState(step: AuthStep.phone));
  }
}
