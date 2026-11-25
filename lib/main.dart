import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/app.dart';
import 'package:pruebatecnica/core/bloc/app_bloc_observer.dart';
import 'package:pruebatecnica/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EquatableConfig.stringify = true;
  Bloc.observer = const AppBlocObserver();
  await init();
  runApp(const App());
}
