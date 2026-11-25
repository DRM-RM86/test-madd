import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';
import 'package:pruebatecnica/core/theme/glow_backdrop.dart';
import 'package:pruebatecnica/features/auth/domain/entities/phone_number.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_event.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_state.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthBloc>().add(CodeSubmitted(_code.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final phone =
            PhoneNumber.tryParse(state.phone)?.formatted ?? state.phone;
        return Scaffold(
          body: GlowBackdrop(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CÓDIGO',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.accent,
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Revisa tus notificaciones',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enviamos un código al $phone. Ábrelo en la barra de notificaciones.',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.muted),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _code,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      enabled: !state.submitting,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(letterSpacing: 12),
                      decoration: const InputDecoration(labelText: 'Código'),
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
                            : const Text('Verificar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: state.submitting
                            ? null
                            : () => context.read<AuthBloc>().add(
                                PhoneSubmitted(state.phone),
                              ),
                        child: const Text('Reenviar código'),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: state.submitting
                            ? null
                            : () => context.read<AuthBloc>().add(
                                const ChangePhoneRequested(),
                              ),
                        child: const Text('Usar otro celular'),
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
