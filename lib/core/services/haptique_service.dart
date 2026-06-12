import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Retour haptique de Flow — toujours léger, jamais intrusif.
///
/// L'activation est décidée par l'appelant (réglage utilisateur) :
/// ces fonctions restent de purs utilitaires.
///
/// On pilote le vibreur directement (package `vibration`) plutôt que
/// `HapticFeedback` : sur Android, ce dernier passe par
/// `performHapticFeedback`, que le système ignore quand le réglage
/// « vibration au toucher » du téléphone est désactivé. Le réglage de
/// Flow doit suffire. Repli gracieux sur `HapticFeedback` sans vibreur.
abstract final class HaptiqueService {
  /// Mémorise la présence d'un vibreur (interrogée une seule fois).
  static Future<bool>? _aUnVibreur;

  static Future<bool> _vibreurDisponible() =>
      _aUnVibreur ??= Vibration.hasVibrator().catchError((_) => false);

  /// Impulsion très légère, pour les transitions de respiration.
  static Future<void> souffle() => _impulsion(
        dureeMs: 35,
        amplitude: 64,
        repli: HapticFeedback.lightImpact,
      );

  /// Clic discret de sélection, pour les interactions.
  static Future<void> selection() => _impulsion(
        dureeMs: 18,
        amplitude: 48,
        repli: HapticFeedback.selectionClick,
      );

  static Future<void> _impulsion({
    required int dureeMs,
    required int amplitude,
    required Future<void> Function() repli,
  }) async {
    try {
      if (await _vibreurDisponible()) {
        // L'amplitude n'est appliquée que si l'appareil la gère ;
        // sinon le vibreur utilise son intensité par défaut.
        await Vibration.vibrate(duration: dureeMs, amplitude: amplitude);
        return;
      }
    } catch (_) {
      // Plateforme sans plugin (tests, desktop…) : on tente le repli.
    }
    try {
      await repli();
    } catch (_) {
      // Aucun retour haptique possible : on reste silencieux.
    }
  }
}
