import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';
import 'package:pruebatecnica/features/characters/domain/entities/character.dart';
import 'package:pruebatecnica/features/characters/presentation/widgets/character_image.dart';

class CharacterTile extends StatelessWidget {
  const CharacterTile({
    super.key,
    required this.character,
    required this.onTap,
    this.saved = false,
  });

  final Character character;
  final VoidCallback onTap;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final tone = statusColor(character.status);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.line),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(19),
                  ),
                  child: SizedBox(
                    width: 92,
                    height: 112,
                    child: CharacterImage(
                      imageUrl: character.imageUrl,
                      localImagePath: character.localImagePath,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                character.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (saved)
                              const Icon(
                                Icons.bookmark,
                                color: AppTheme.accent,
                                size: 18,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          character.species,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.muted),
                        ),
                        const SizedBox(height: 10),
                        StatusChip(status: character.status),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 4,
                  height: 112,
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(19),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusLabel(status),
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

String statusLabel(String status) {
  return switch (status.toLowerCase()) {
    'alive' => 'Vivo',
    'dead' => 'Muerto',
    _ => 'Desconocido',
  };
}

Color statusColor(String status) {
  return switch (status.toLowerCase()) {
    'alive' => AppTheme.alive,
    'dead' => AppTheme.dead,
    _ => AppTheme.unknown,
  };
}
