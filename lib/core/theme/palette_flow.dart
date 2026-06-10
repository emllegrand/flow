import 'package:flutter/material.dart';

/// Palette de Flow — tons naturels inspirés du wabi-sabi.
///
/// Quatre familles : sable, vert mousse, indigo profond, terracotta.
/// Les couleurs sont volontairement désaturées et douces.
abstract final class PaletteFlow {
  // — Sable (fonds clairs, textes sur fond sombre)
  static const Color sableClair = Color(0xFFF6F1E8);
  static const Color sable = Color(0xFFEDE5D6);
  static const Color sableProfond = Color(0xFFDDD2BD);

  // — Vert mousse (couleur principale, apaisante)
  static const Color mousse = Color(0xFF7D8B6A);
  static const Color mousseSombre = Color(0xFF5C6B4F);
  static const Color mousseClaire = Color(0xFFA9B594);
  static const Color mousseBrume = Color(0xFFC9D0BA);

  // — Indigo profond (nuit, encre)
  static const Color indigo = Color(0xFF3D4A6B);
  static const Color indigoProfond = Color(0xFF1F2A44);
  static const Color nuit = Color(0xFF121826);
  static const Color nuitSurface = Color(0xFF1A2334);
  static const Color nuitSurfaceHaute = Color(0xFF222D42);

  // — Terracotta léger (accents chaleureux, rares)
  static const Color terracotta = Color(0xFFC8836B);
  static const Color terracottaClair = Color(0xFFDDA68F);
  static const Color terracottaBrume = Color(0xFFEAC9B9);

  // — Encres (textes)
  static const Color encre = Color(0xFF2C2F33);
  static const Color encreDouce = Color(0xFF6B6E66);
  static const Color encreNuit = Color(0xFFE7E2D6);
  static const Color encreNuitDouce = Color(0xFF9AA1B0);

  // — Lignes et contours discrets
  static const Color ligneClair = Color(0xFFD8CDB9);
  static const Color ligneNuit = Color(0xFF333E58);
}
