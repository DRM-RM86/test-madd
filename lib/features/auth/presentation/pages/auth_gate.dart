import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_state.dart';
import 'package:pruebatecnica/features/auth/presentation/pages/phone_page.dart';
import 'package:pruebatecnica/features/auth/presentation/pages/verify_code_page.dart';
import 'package:pruebatecnica/features/characters/presentation/pages/workspace_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.step != current.step,
      builder: (context, state) {
        return switch (state.step) {
          AuthStep.checking => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          AuthStep.phone => const PhonePage(),
          AuthStep.code => const VerifyCodePage(),
          AuthStep.session => const WorkspacePage(),
        };
      },
    );
  }
}
