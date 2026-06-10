import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette_flow.dart';

/// Thèmes de Flow — Material 3 entièrement personnalisé.
///
/// Le mode sombre est conçu à part (indigo profond, encres sable),
/// ce n'est pas une inversion du mode clair.
abstract final class ThemeFlow {
  /// Typographie : Cormorant Garamond pour les titres (élégance calligraphique),
  /// Karla pour le corps (lisibilité épurée).
  static TextTheme _typographie(Color encre, Color encreDouce) {
    final TextTheme corps = GoogleFonts.karlaTextTheme();
    final TextTheme titres = GoogleFonts.cormorantGaramondTextTheme();
    return TextTheme(
      displayLarge: titres.displayLarge!.copyWith(
        color: encre,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      displayMedium: titres.displayMedium!.copyWith(
        color: encre,
        fontWeight: FontWeight.w500,
      ),
      displaySmall: titres.displaySmall!.copyWith(
        color: encre,
        fontWeight: FontWeight.w500,
      ),
      headlineLarge: titres.headlineLarge!.copyWith(
        color: encre,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: titres.headlineMedium!.copyWith(
        color: encre,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: titres.headlineSmall!.copyWith(
        color: encre,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: corps.titleLarge!.copyWith(
        color: encre,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      titleMedium: corps.titleMedium!.copyWith(
        color: encre,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      titleSmall: corps.titleSmall!.copyWith(
        color: encreDouce,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
      ),
      bodyLarge: corps.bodyLarge!.copyWith(color: encre, height: 1.6),
      bodyMedium: corps.bodyMedium!.copyWith(color: encreDouce, height: 1.55),
      bodySmall: corps.bodySmall!.copyWith(color: encreDouce, height: 1.5),
      labelLarge: corps.labelLarge!.copyWith(
        color: encre,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
      labelMedium: corps.labelMedium!.copyWith(
        color: encreDouce,
        letterSpacing: 1.2,
      ),
      labelSmall: corps.labelSmall!.copyWith(
        color: encreDouce,
        letterSpacing: 1.4,
      ),
    );
  }

  /// Réglages communs aux deux thèmes (formes amples, aucune ombre dure).
  static ThemeData _base(ColorScheme schema, TextTheme typo) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: schema,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: typo,
      splashFactory: NoSplash.splashFactory,
      highlightColor: schema.primary.withValues(alpha: 0.06),
      hoverColor: Colors.transparent,
      dividerTheme: DividerThemeData(
        color: schema.outlineVariant,
        thickness: 0.7,
        space: 32,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: schema.onSurface,
        titleTextStyle: typo.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: schema.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: schema.primary,
          foregroundColor: schema.onPrimary,
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          shape: const StadiumBorder(),
          textStyle: typo.labelLarge,
          animationDuration: const Duration(milliseconds: 450),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: schema.onSurface,
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          side: BorderSide(color: schema.outline, width: 1),
          shape: const StadiumBorder(),
          textStyle: typo.labelLarge,
          animationDuration: const Duration(milliseconds: 450),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: schema.onSurfaceVariant,
          textStyle: typo.labelLarge,
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: schema.primary,
        inactiveTrackColor: schema.outlineVariant,
        thumbColor: schema.primary,
        overlayColor: schema.primary.withValues(alpha: 0.08),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? schema.onPrimary
              : schema.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? schema.primary
              : schema.surfaceContainerHighest,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: schema.primary.withValues(alpha: 0.14),
        side: BorderSide(color: schema.outlineVariant),
        labelStyle: typo.labelLarge!.copyWith(letterSpacing: 0.4),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        showCheckmark: false,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: schema.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Thème clair — papier de riz, lumière du matin.
  static ThemeData clair() {
    const ColorScheme schema = ColorScheme(
      brightness: Brightness.light,
      primary: PaletteFlow.mousseSombre,
      onPrimary: PaletteFlow.sableClair,
      primaryContainer: PaletteFlow.mousseBrume,
      onPrimaryContainer: PaletteFlow.mousseSombre,
      secondary: PaletteFlow.terracotta,
      onSecondary: PaletteFlow.sableClair,
      secondaryContainer: PaletteFlow.terracottaBrume,
      onSecondaryContainer: Color(0xFF7A4A38),
      tertiary: PaletteFlow.indigo,
      onTertiary: PaletteFlow.sableClair,
      tertiaryContainer: Color(0xFFD4D9E6),
      onTertiaryContainer: PaletteFlow.indigoProfond,
      error: Color(0xFFA85B4B),
      onError: PaletteFlow.sableClair,
      surface: PaletteFlow.sableClair,
      onSurface: PaletteFlow.encre,
      onSurfaceVariant: PaletteFlow.encreDouce,
      surfaceContainerLowest: Color(0xFFFBF8F2),
      surfaceContainerLow: Color(0xFFF1EADD),
      surfaceContainer: PaletteFlow.sable,
      surfaceContainerHigh: Color(0xFFE5DBC8),
      surfaceContainerHighest: PaletteFlow.sableProfond,
      outline: Color(0xFFB5AA94),
      outlineVariant: PaletteFlow.ligneClair,
      shadow: Color(0x14000000),
      scrim: Color(0x66000000),
      inverseSurface: PaletteFlow.indigoProfond,
      onInverseSurface: PaletteFlow.sableClair,
      inversePrimary: PaletteFlow.mousseClaire,
    );
    return _base(
      schema,
      _typographie(PaletteFlow.encre, PaletteFlow.encreDouce),
    );
  }

  /// Thème sombre — nuit d'indigo, conçu pour lui-même.
  static ThemeData sombre() {
    const ColorScheme schema = ColorScheme(
      brightness: Brightness.dark,
      primary: PaletteFlow.mousseClaire,
      onPrimary: Color(0xFF20281A),
      primaryContainer: PaletteFlow.mousseSombre,
      onPrimaryContainer: PaletteFlow.mousseBrume,
      secondary: PaletteFlow.terracottaClair,
      onSecondary: Color(0xFF3F2A20),
      secondaryContainer: Color(0xFF6E4534),
      onSecondaryContainer: PaletteFlow.terracottaBrume,
      tertiary: Color(0xFF9FAECB),
      onTertiary: PaletteFlow.indigoProfond,
      tertiaryContainer: PaletteFlow.indigo,
      onTertiaryContainer: Color(0xFFD4D9E6),
      error: Color(0xFFD89A8C),
      onError: Color(0xFF44241B),
      surface: PaletteFlow.nuit,
      onSurface: PaletteFlow.encreNuit,
      onSurfaceVariant: PaletteFlow.encreNuitDouce,
      surfaceContainerLowest: Color(0xFF0D1320),
      surfaceContainerLow: PaletteFlow.nuitSurface,
      surfaceContainer: Color(0xFF1E283C),
      surfaceContainerHigh: PaletteFlow.nuitSurfaceHaute,
      surfaceContainerHighest: Color(0xFF2A3650),
      outline: Color(0xFF5A6580),
      outlineVariant: PaletteFlow.ligneNuit,
      shadow: Color(0x33000000),
      scrim: Color(0x99000000),
      inverseSurface: PaletteFlow.sableClair,
      onInverseSurface: PaletteFlow.encre,
      inversePrimary: PaletteFlow.mousseSombre,
    );
    return _base(
      schema,
      _typographie(PaletteFlow.encreNuit, PaletteFlow.encreNuitDouce),
    );
  }
}
