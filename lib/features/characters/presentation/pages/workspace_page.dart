import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/di/injection.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';
import 'package:pruebatecnica/features/auth/domain/entities/phone_number.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pruebatecnica/features/auth/presentation/bloc/auth_event.dart';
import 'package:pruebatecnica/features/characters/data/datasources/workspace_store.dart';
import 'package:pruebatecnica/features/characters/presentation/bloc/saved_characters_bloc.dart';
import 'package:pruebatecnica/features/characters/presentation/bloc/search_bloc.dart';
import 'package:pruebatecnica/features/characters/presentation/pages/saved_page.dart';
import 'package:pruebatecnica/features/characters/presentation/pages/search_page.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = context.select((AuthBloc bloc) => bloc.state.phone);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<SearchBloc>(param1: phone)..add(const SearchStarted()),
        ),
        BlocProvider(
          create: (_) =>
              getIt<SavedCharactersBloc>(param1: phone)
                ..add(const SavedStarted()),
        ),
      ],
      child: _WorkspaceView(phone: phone),
    );
  }
}

class _WorkspaceView extends StatefulWidget {
  const _WorkspaceView({required this.phone});

  final String phone;

  @override
  State<_WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<_WorkspaceView> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    getIt<WorkspaceStore>().readTab(widget.phone).then((tab) {
      if (mounted) setState(() => _tab = tab);
    });
  }

  Future<void> _select(int tab) async {
    setState(() => _tab = tab);
    await getIt<WorkspaceStore>().saveTab(widget.phone, tab);
    if (tab == 1 && mounted) {
      context.read<SavedCharactersBloc>().add(const SavedRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted =
        PhoneNumber.tryParse(widget.phone)?.formatted ?? widget.phone;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EXPLORADORES',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.accent,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              formatted,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () =>
                context.read<AuthBloc>().add(const SignOutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          SearchPage(phone: widget.phone),
          SavedPage(phone: widget.phone),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            label: 'Guardados',
          ),
        ],
      ),
    );
  }
}
