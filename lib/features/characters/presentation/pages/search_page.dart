import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';
import 'package:pruebatecnica/features/characters/presentation/bloc/saved_characters_bloc.dart';
import 'package:pruebatecnica/features/characters/presentation/bloc/search_bloc.dart';
import 'package:pruebatecnica/features/characters/presentation/pages/character_detail_page.dart';
import 'package:pruebatecnica/features/characters/presentation/widgets/character_tile.dart';
import 'package:pruebatecnica/features/characters/presentation/widgets/empty_ripple.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.phone});

  final String phone;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _query = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _query.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<SearchBloc>().add(const SearchNextPage());
    }
  }

  void _submit() {
    context.read<SearchBloc>().add(SearchSubmitted(_query.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchBloc, SearchState>(
      listenWhen: (previous, current) => previous.query != current.query,
      listener: (context, state) {
        if (_query.text != state.query) {
          _query.text = state.query;
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Nombre del personaje',
                prefixIcon: const Icon(Icons.search, color: AppTheme.muted),
                suffixIcon: IconButton(
                  tooltip: 'Buscar',
                  onPressed: _submit,
                  icon: const Icon(Icons.arrow_forward, color: AppTheme.accent),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state.status == SearchStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == SearchStatus.failure) {
                  return EmptyRipple(
                    icon: Icons.wifi_off,
                    message:
                        state.error ?? 'No pudimos consultar los personajes.',
                    action: 'Reintentar',
                    onPressed: _submit,
                  );
                }
                if (state.status == SearchStatus.empty) {
                  return const EmptyRipple(
                    icon: Icons.search_off,
                    message: 'No hay personajes con ese nombre.',
                  );
                }
                if (state.characters.isEmpty) {
                  return EmptyRipple(
                    message: state.error ?? 'Busca un personaje por su nombre.',
                  );
                }
                return ListView.separated(
                  controller: _scroll,
                  itemCount:
                      state.characters.length + (state.loadingMore ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    if (index >= state.characters.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final character = state.characters[index];
                    return CharacterTile(
                      character: character,
                      saved: state.savedIds.contains(character.id),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CharacterDetailPage(
                              phone: widget.phone,
                              character: character,
                            ),
                          ),
                        );
                        if (!context.mounted) return;
                        context.read<SavedCharactersBloc>().add(
                          const SavedRefreshed(),
                        );
                        context.read<SearchBloc>().add(
                          const SearchMarksRefresh(),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
