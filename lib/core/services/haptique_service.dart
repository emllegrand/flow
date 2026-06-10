import 'package:flutter/services.dart';

/// Retour haptique de Flow — toujours léger, jamais intrusif.
///
/// L'activation est décidée par l'appelant (réglage utilisateur) :
/// ces fonctions restent de purs utilitaires.
abstract final class HaptiqueService {
  /// Impulsion très légère, pour les transitions de respiration.
  static Future<void> souffle() => HapticFeedback.lightImpact();

  /// Clic discret de sélection, pour les interactions.
  static Future<void> selection() => HapticFeedback.selectionClick();
}
