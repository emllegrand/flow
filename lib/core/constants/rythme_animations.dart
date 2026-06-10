import 'package:flutter/animation.dart';

/// Rythme global des animations de Flow.
///
/// Règle d'or : rien ne doit jamais sembler pressé. Toutes les durées sont
/// volontairement longues et toutes les courbes organiques.
abstract final class RythmeAnimations {
  /// Micro-interactions (pression d'un bouton…)
  static const Duration douce = Duration(milliseconds: 450);

  /// Apparition d'un élément à l'écran.
  static const Duration apparition = Duration(milliseconds: 900);

  /// Transition entre écrans (fondu).
  static const Duration transition = Duration(milliseconds: 700);

  /// Mouvements amples (vagues de fond, ondulations).
  static const Duration ample = Duration(milliseconds: 2400);

  /// Décalage entre deux éléments d'une apparition en cascade.
  static const Duration cascade = Duration(milliseconds: 140);

  /// Courbe organique par défaut — accélérations imperceptibles.
  static const Curve courbe = Curves.easeInOutSine;

  /// Courbe d'apparition (départ doux, arrivée posée).
  static const Curve courbeApparition = Curves.easeOutCubic;
}
