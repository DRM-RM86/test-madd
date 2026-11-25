import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:pruebatecnica/core/theme/app_theme.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class EmptyRipple extends StatelessWidget {
  const EmptyRipple({
    super.key,
    required this.message,
    this.icon = Icons.sensors,
    this.action,
    this.onPressed,
  });

  final String message;
  final IconData icon;
  final String? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final reach = math.min(width, height) * 0.42;

        return ClipRect(
          child: SizedBox(
            width: width,
            height: height,
            child: RippleAnimation(
              color: AppTheme.accent,
              delay: const Duration(milliseconds: 160),
              repeat: true,
              minRadius: 64,
              maxRadius: reach.clamp(140, 240).toDouble(),
              ripplesCount: 3,
              duration: const Duration(milliseconds: 3200),
              child: SizedBox.expand(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _Core(icon: icon),
                    Positioned(
                      top: height / 2 + 76,
                      left: 32,
                      right: 32,
                      child: Column(
                        children: [
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppTheme.text, height: 1.25),
                          ),
                          if (action != null) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: onPressed,
                              child: Text(action!),
                            ),
                          ],
                        ],
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

class _Core extends StatelessWidget {
  const _Core({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.background,
        border: Border.all(color: AppTheme.accent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.28),
            blurRadius: 36,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: AppTheme.accent, size: 42),
    );
  }
}
