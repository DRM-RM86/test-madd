import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

class AppTheme {
  const AppTheme._();

  static const background = Color(0xFF07090F);
  static const surface = Color(0xFF141824);
  static const line = Color(0xFF2C3448);
  static const accent = Color(0xFFD6FF4A);
  static const accentInk = Color(0xFF172000);
  static const text = Color(0xFFF3F6EF);
  static const muted = Color(0xFF93A0B5);
  static const alive = Color(0xFF7DFFB3);
  static const dead = Color(0xFFFF6B6B);
  static const unknown = Color(0xFFC7B8FF);

  static ThemeData get dark {
    final textTheme =
        GoogleFonts.manropeTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            )
            .apply(bodyColor: text, displayColor: text)
            .copyWith(
              displaySmall: GoogleFonts.syne(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                height: 0.95,
                color: text,
              ),
              headlineMedium: GoogleFonts.syne(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                height: 1,
                color: text,
              ),
              headlineSmall: GoogleFonts.syne(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: text,
              ),
              titleLarge: GoogleFonts.syne(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: text,
              ),
              titleMedium: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            );

    const scheme = ColorScheme.dark(
      primary: accent,
      onPrimary: accentInk,
      secondary: unknown,
      surface: surface,
      onSurface: text,
      error: dead,
      onError: text,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: textTheme.bodyLarge?.copyWith(color: muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: _border(line),
        enabledBorder: _border(line),
        focusedBorder: _border(accent),
        errorBorder: _border(dead),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentInk,
          disabledBackgroundColor: accent.withValues(alpha: 0.35),
          disabledForegroundColor: accentInk.withValues(alpha: 0.6),
          minimumSize: const Size.fromHeight(56),
          textStyle: GoogleFonts.syne(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? accent : muted,
            fontWeight: FontWeight.w700,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? accentInk : muted);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: accent),
      dividerTheme: const DividerThemeData(color: line),
    );
  }

  static OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
  }
}
