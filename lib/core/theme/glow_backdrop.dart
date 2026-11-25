import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';

class GlowBackdrop extends StatelessWidget {
  const GlowBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(top: -120, right: -80, child: _Glow(size: 280)),
        const Positioned(
          bottom: 40,
          left: -110,
          child: _Glow(size: 220, color: Color(0xFF6E5BFF)),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, this.color = AppTheme.accent});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.16),
        ),
      ),
    );
  }
}
