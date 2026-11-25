import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/di/injection.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/presentation/bloc/character_detail_bloc.dart';
import 'package:pruebatecnica/features/characters/presentation/pages/place_page.dart';
import 'package:pruebatecnica/features/characters/presentation/widgets/character_image.dart';
import 'package:pruebatecnica/features/characters/presentation/widgets/character_tile.dart';

class CharacterDetailPage extends StatelessWidget {
  const CharacterDetailPage({
    super.key,
    required this.phone,
    required this.character,
  });

  final String phone;
  final Character character;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CharacterDetailBloc>(param1: character, param2: phone)
            ..add(const DetailStarted()),
      child: const _CharacterDetailView(),
    );
  }
}

class _CharacterDetailView extends StatelessWidget {
  const _CharacterDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterDetailBloc, CharacterDetailState>(
      builder: (context, state) {
        final character = state.character;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 460,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CharacterImage(
                      imageUrl: character.imageUrl,
                      localImagePath: character.localImagePath,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xAA07090F),
                            Color(0x0007090F),
                            AppTheme.background,
                          ],
                          stops: [0, 0.42, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusChip(status: character.status),
                          const SizedBox(height: 10),
                          Text(
                            character.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${character.species} · ${character.gender}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.loadingDetails) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),
                    _PlaceTile(
                      label: 'Origen',
                      name: character.origin.name,
                      enabled:
                          character.origin.canOpen && !state.loadingDetails,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PlacePage(
                              label: 'Origen',
                              place: character.origin,
                            ),
                          ),
                        );
                      },
                    ),
                    _PlaceTile(
                      label: 'Ubicación',
                      name: character.location.name,
                      enabled:
                          character.location.canOpen && !state.loadingDetails,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PlacePage(
                              label: 'Ubicación',
                              place: character.location,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Episodios',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (character.episodes.isEmpty)
                      Text(
                        state.loadingDetails
                            ? 'Consultando episodios...'
                            : '${character.episodeCount} episodios',
                      )
                    else
                      for (final episode in character.episodes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  episode.code,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(episode.name)),
                            ],
                          ),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.saving
                            ? null
                            : () => context.read<CharacterDetailBloc>().add(
                                const SaveToggled(),
                              ),
                        child: state.saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.accentInk,
                                ),
                              )
                            : Text(
                                state.saved
                                    ? 'Quitar de guardados'
                                    : 'Guardar para revisar',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({
    required this.label,
    required this.name,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String name;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.accent,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name.isEmpty ? 'Sin dato' : name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                if (enabled)
                  const Icon(Icons.chevron_right, color: AppTheme.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
