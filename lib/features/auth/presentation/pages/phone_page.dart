import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';
import 'package:pruebatecnica/core/theme/glow_backdrop.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_event.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_state.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: context.read<AuthBloc>().state.phone);
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthBloc>().add(PhoneSubmitted(_phone.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          body: GlowBackdrop(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPLORADORES',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.accent,
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Entra con tu celular',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Te enviamos el código en una notificación de este teléfono. No es un SMS.',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.muted),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      enabled: !state.submitting,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Celular',
                        hintText: '10 dígitos',
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.submitting ? null : _submit,
                        child: state.submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.accentInk,
                                ),
                              )
                            : const Text('Enviar código'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
