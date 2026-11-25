import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pruebatecnica/core/error/failures.dart';
import 'package:pruebatecnica/core/notifications/local_notifications.dart';
import 'package:pruebatecnica/features/auth/data/code_generator.dart';
import 'package:pruebatecnica/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pruebatecnica/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pruebatecnica/features/auth/domain/entities/session.dart';

void main() {
  late _MemoryAuthLocal local;
  late _FakeNotifier notifier;
  late AuthRepositoryImpl repository;

  final now = DateTime(2026, 11, 24, 12);

  setUp(() {
    local = _MemoryAuthLocal();
    notifier = _FakeNotifier();
    repository = AuthRepositoryImpl(
      local: local,
      notifier: notifier,
      codes: _FixedCode('4821'),
      now: () => now,
    );
  });

  test('rechaza un celular que no tiene 10 dígitos', () async {
    final result = await repository.requestCode('55123');

    expect(result, isA<Left<Failure, String>>());
    expect(notifier.lastCode, isNull);
    expect(local.pending, isNull);
  });

  test('guarda el código y lo manda en la notificación', () async {
    final result = await repository.requestCode('55 1234 5678');

    expect(result, const Right('5512345678'));
    expect(notifier.lastCode, '4821');
    expect(local.pending?.phone, '5512345678');
    expect(local.pending?.code, '4821');
    expect(local.pending?.expiresAt, now.add(AuthRepositoryImpl.codeTtl));
  });

  test('no deja el código guardado si la notificación no se muestra', () async {
    notifier.granted = false;

    final result = await repository.requestCode('5512345678');

    expect(result, isA<Left<Failure, String>>());
    expect(local.pending, isNull);
  });

  test('abre la sesión cuando el código coincide', () async {
    await repository.requestCode('5512345678');

    final result = await repository.verifyCode(
      phone: '5512345678',
      code: '4821',
    );

    expect(
      result.getOrElse(() => throw StateError('sin sesión')).phone,
      '5512345678',
    );
    expect(local.pending, isNull);
    expect(await local.readSession(), '5512345678');
  });

  test('rechaza un código distinto', () async {
    await repository.requestCode('5512345678');

    final result = await repository.verifyCode(
      phone: '5512345678',
      code: '0000',
    );

    expect(result, isA<Left<Failure, Session>>());
    expect(await local.readSession(), isNull);
  });

  test('rechaza un código vencido', () async {
    await repository.requestCode('5512345678');
    repository = AuthRepositoryImpl(
      local: local,
      notifier: notifier,
      codes: _FixedCode('4821'),
      now: () => now.add(const Duration(minutes: 4)),
    );

    final result = await repository.verifyCode(
      phone: '5512345678',
      code: '4821',
    );

    expect(
      result.fold((failure) => failure.message, (_) => ''),
      'El código venció. Pide uno nuevo.',
    );
    expect(local.pending, isNull);
  });
}

class _FixedCode implements CodeGenerator {
  _FixedCode(this.value);

  final String value;

  @override
  String generate() => value;
}

class _FakeNotifier implements OtpNotifier {
  String? lastCode;
  bool granted = true;

  @override
  Future<bool> showCode(String code) async {
    lastCode = code;
    return granted;
  }
}

class _MemoryAuthLocal implements AuthLocalDataSource {
  PendingCode? pending;
  String? session;

  @override
  Future<void> savePending({
    required String phone,
    required String code,
    required DateTime expiresAt,
  }) async {
    pending = PendingCode(phone: phone, code: code, expiresAt: expiresAt);
  }

  @override
  Future<PendingCode?> readPending() async => pending;

  @override
  Future<void> clearPending() async {
    pending = null;
  }

  @override
  Future<void> saveSession(String phone) async {
    session = phone;
  }

  @override
  Future<String?> readSession() async => session;

  @override
  Future<void> clearSession() async {
    session = null;
  }
}
