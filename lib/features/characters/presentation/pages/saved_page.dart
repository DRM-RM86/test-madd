import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/features/characters/presentation/bloc/saved_characters_bloc.dart';
import 'package:pruebatecnica/features/characters/presentation/pages/character_detail_page.dart';
import 'package:pruebatecnica/features/characters/presentation/widgets/character_tile.dart';
import 'package:pruebatecnica/features/characters/presentation/widgets/empty_ripple.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedCharactersBloc, SavedCharactersState>(
      builder: (context, state) {
        if (state.status == SavedStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == SavedStatus.failure) {
          return EmptyRipple(
            icon: Icons.wifi_off,
            message: state.error ?? 'No pudimos leer los guardados.',
          );
        }
        if (state.characters.isEmpty) {
          return const EmptyRipple(
            icon: Icons.bookmark_border,
            message: 'Todavía no guardas personajes. Los que marques quedan en este teléfono aunque no haya señal.',
          );
        }
        return ListView.separated(
          itemCount: state.characters.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final character = state.characters[index];
            return CharacterTile(
              character: character,
              saved: true,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CharacterDetailPage(phone: phone, character: character),
                  ),
                );
                if (context.mounted) {
                  context.read<SavedCharactersBloc>().add(
                    const SavedRefreshed(),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
