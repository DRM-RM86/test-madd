import 'package:dartz/dartz.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/core/notifications/local_notifications.dart';
import 'package:pruebatecnica/features/auth/data/code_generator.dart';
import 'package:pruebatecnica/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pruebatecnica/features/auth/domain/entities/phone_number.dart';
import 'package:pruebatecnica/features/auth/domain/entities/session.dart';
import 'package:pruebatecnica/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.local,
    required this.notifier,
    required this.codes,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final AuthLocalDataSource local;
  final OtpNotifier notifier;
  final CodeGenerator codes;
  final DateTime Function() now;

  static const codeTtl = Duration(minutes: 3);

  @override
  Future<Either<Failure, String>> requestCode(String rawPhone) async {
    final phone = PhoneNumber.tryParse(rawPhone);
    if (phone == null) {
      return const Left(ValidationFailure('Escribe un celular de 10 dígitos.'));
    }

    final code = codes.generate();
    await local.savePending(
      phone: phone.value,
      code: code,
      expiresAt: now().add(codeTtl),
    );

    final shown = await notifier.showCode(code);
    if (!shown) {
      await local.clearPending();
      return const Left(
        NotificationFailure(
          'No pudimos mostrar la notificación. Activa las notificaciones e inténtalo de nuevo.',
        ),
      );
    }

    return Right(phone.value);
  }

  @override
  Future<Either<Failure, Session>> verifyCode({
    required String phone,
    required String code,
  }) async {
    final entered = code.replaceAll(RegExp(r'\D'), '');
    if (entered.length != 4) {
      return const Left(ValidationFailure('Escribe los 4 dígitos del código.'));
    }

    final normalized = PhoneNumber.tryParse(phone);
    final pending = await local.readPending();
    if (normalized == null ||
        pending == null ||
        pending.phone != normalized.value) {
      return const Left(ValidationFailure('Pide un código primero.'));
    }

    if (!pending.expiresAt.isAfter(now())) {
      await local.clearPending();
      return const Left(ValidationFailure('El código venció. Pide uno nuevo.'));
    }

    if (pending.code != entered) {
      return const Left(ValidationFailure('El código no coincide.'));
    }

    await local.saveSession(normalized.value);
    await local.clearPending();
    return Right(Session(phone: normalized.value));
  }

  @override
  Future<Either<Failure, Session?>> currentSession() async {
    final phone = await local.readSession();
    if (phone == null) return const Right(null);
    return Right(Session(phone: phone));
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    await local.clearSession();
    await local.clearPending();
    return const Right(unit);
  }
}
