import 'dart:io';

import 'package:material_ui/material_ui.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({
    super.key,
    required this.imageUrl,
    this.localImagePath,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final String? localImagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final path = localImagePath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return Image.file(
        File(path),
        width: double.infinity,
        height: double.infinity,
        fit: fit,
      );
    }
    if (imageUrl.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFE0E0E0),
        child: Icon(Icons.person),
      );
    }
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(
          color: Color(0xFFE0E0E0),
          child: Icon(Icons.person),
        );
      },
    );
  }
}
