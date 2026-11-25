import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/di/injection.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_event.dart';
import 'package:pruebatecnica/features/auth/presentation/pages/auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthStarted()),
      child: MaterialApp(
        title: 'Exploradores',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AuthGate(),
      ),
    );
  }
}
