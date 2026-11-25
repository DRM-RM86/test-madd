import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class OtpNotifier {
  Future<bool> showCode(String code);
}

class LocalNotifications implements OtpNotifier {
  LocalNotifications(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  var _ready = false;

  Future<void> initialize() async {
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_stat_notify'),
      iOS: darwin,
      macOS: darwin,
    );
    try {
      await _plugin.initialize(settings: settings);
      _ready = true;
    } on MissingPluginException {
      _ready = false;
    } on PlatformException {
      _ready = false;
    }
  }

  @override
  Future<bool> showCode(String code) async {
    if (!_ready) return false;
    if (!await _requestPermission()) return false;

    await _plugin.show(
      id: _notificationId,
      title: 'Código de verificación',
      body: 'Tu código es $code. Vence en 3 minutos.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'verification_codes',
          'Verificación',
          channelDescription: 'Códigos para entrar a la aplicación',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(
            'Tu código es $code',
            contentTitle: 'Código de verificación',
            summaryText: 'Vence en 3 minutos',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      payload: 'otp',
    );
    return true;
  }

  Future<bool> _requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? true;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }

    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macos != null) {
      return await macos.requestPermissions(alert: true, sound: true) ?? false;
    }

    return true;
  }
}

const _notificationId = 1001;
