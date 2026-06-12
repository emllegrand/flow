import 'package:flutter/material.dart';

/// Tokens de la marque Flow — planche « La goutte-feuille ».
///
/// Couleurs officielles du logo, des verrouillages et de l'icône d'app.
/// Elles vivent à côté de [PaletteFlow] (palette d'interface) : la marque
/// a ses propres appariements précis (fond / corps du repère / nervure),
/// à ne pas mélanger avec les couleurs d'écran.
abstract final class MarqueFlow {
  // — Couleurs de marque
  /// Fond principal de la marque, tuile de l'icône du store.
  static const Color nuit = Color(0xFF0D1A2B);

  /// Repère sur fond clair, titres de marque.
  static const Color nuitEncre = Color(0xFF152234);

  /// Surface élevée (panneau du verrouillage empilé).
  static const Color nuitCarte = Color(0xFF16273B);

  /// Accent, remplissage principal du repère.
  static const Color sauge = Color(0xFFA6BD86);

  /// Sauge profonde (sur-titres, survol).
  static const Color saugeProfonde = Color(0xFF8AA66A);

  /// Texte clair, tuile claire, repère inversé.
  static const Color creme = Color(0xFFECE7DA);

  /// Tagline et textes discrets de marque.
  static const Color ardoise = Color(0xFF8493A3);

  /// Corps de texte sur fond clair.
  static const Color corpsClair = Color(0xFF5D6A78);

  // — Géométrie du repère (viewBox canonique 0 0 104 120)
  /// Largeur du viewBox du repère.
  static const double largeurRepere = 104;

  /// Hauteur du viewBox du repère.
  static const double hauteurRepere = 120;

  /// Épaisseur de la nervure, dans le repère 104 × 120.
  static const double epaisseurNervure = 3.5;

  /// Taille minimale du repère (hauteur en px logiques).
  static const double tailleMiniRepere = 24;

  // — Mot-typographié
  /// Interlettrage du mot « Flow » (em).
  static const double interlettrageMot = 0.01;

  /// Interlettrage de la tagline, en majuscules (em).
  static const double interlettrageTagline = 0.42;
}
