import 'package:shared_preferences/shared_preferences.dart';

class PendingCode {
  const PendingCode({
    required this.phone,
    required this.code,
    required this.expiresAt,
  });

  final String phone;
  final String code;
  final DateTime expiresAt;
}

abstract class AuthLocalDataSource {
  Future<void> savePending({
    required String phone,
    required String code,
    required DateTime expiresAt,
  });

  Future<PendingCode?> readPending();

  Future<void> clearPending();

  Future<void> saveSession(String phone);

  Future<String?> readSession();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this.preferences);

  final SharedPreferences preferences;

  static const _sessionPhone = 'auth_session_phone';
  static const _pendingPhone = 'auth_pending_phone';
  static const _pendingCode = 'auth_pending_code';
  static const _pendingExpiresAt = 'auth_pending_expires_at';

  @override
  Future<void> savePending({
    required String phone,
    required String code,
    required DateTime expiresAt,
  }) async {
    await preferences.setString(_pendingPhone, phone);
    await preferences.setString(_pendingCode, code);
    await preferences.setInt(
      _pendingExpiresAt,
      expiresAt.millisecondsSinceEpoch,
    );
  }

  @override
  Future<PendingCode?> readPending() async {
    final phone = preferences.getString(_pendingPhone);
    final code = preferences.getString(_pendingCode);
    final expiresAt = preferences.getInt(_pendingExpiresAt);
    if (phone == null || code == null || expiresAt == null) return null;
    return PendingCode(
      phone: phone,
      code: code,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAt),
    );
  }

  @override
  Future<void> clearPending() async {
    await preferences.remove(_pendingPhone);
    await preferences.remove(_pendingCode);
    await preferences.remove(_pendingExpiresAt);
  }

  @override
  Future<void> saveSession(String phone) async {
    await preferences.setString(_sessionPhone, phone);
  }

  @override
  Future<String?> readSession() async {
    final phone = preferences.getString(_sessionPhone);
    if (phone == null || phone.isEmpty) return null;
    return phone;
  }

  @override
  Future<void> clearSession() async {
    await preferences.remove(_sessionPhone);
  }
}
