import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';
import 'package:pruebatecnica/features/characters/domain/entities/place.dart';

class PlacePage extends StatelessWidget {
  const PlacePage({super.key, required this.label, required this.place});

  final String label;
  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(place.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _Line(label: 'Tipo', value: place.type),
          _Line(label: 'Dimensión', value: place.dimension),
          _Line(
            label: 'Residentes',
            value: place.residentCount == 0 ? '' : '${place.residentCount}',
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.line),
      ),
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
            value.isEmpty ? 'Sin dato' : value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
