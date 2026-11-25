import 'package:flutter_test/flutter_test.dart';
import 'package:pruebatecnica/app.dart';
import 'package:pruebatecnica/core/di/injection.dart';
import 'package:pruebatecnica/core/notifications/local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await init(otpNotifier: _NoopNotifier());
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('pide el celular al abrir', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.text('Entra con tu celular'), findsOneWidget);
    expect(find.text('Enviar código'), findsOneWidget);
  });
}

class _NoopNotifier implements OtpNotifier {
  @override
  Future<bool> showCode(String code) async => true;
}
