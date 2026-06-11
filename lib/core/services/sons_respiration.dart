import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/breathing/data/rythme_respiration.dart';
import 'mixeur_audio.dart';

/// Sons qui accompagnent la bulle de respiration : un souffle doux qui
/// monte à l'inspiration, qui redescend à l'expiration, et un son
/// cristallin discret à chaque changement de phase.
///
/// Les souffles durent 6 s avec une enveloppe qui revient à zéro ; la
/// vitesse de lecture est ajustée à la durée de la phase (sans changer
/// la hauteur : ExoPlayer étire le temps). Si la phase est plus longue
/// que le souffle étiré, le son s'éteint simplement avant la fin — un
/// souffle réel fait pareil.
///
/// Fallback gracieux : si les fichiers sont absents ou que la plateforme
/// audio est indisponible (tests), le service se désactive en silence.
class SonsRespirationService {
  SonsRespirationService();

  /// Service inerte : aucun lecteur n'est jamais créé. Pour les tests,
  /// où la plateforme audio n'existe pas.
  SonsRespirationService.desactive()
      : _initialisation = Future<bool>.value(false);

  static const String _dossier = 'assets/audio/respiration';

  /// Durée des fichiers de souffle, en secondes (voir le générateur).
  static const double _dureeSouffleS = 6.0;

  // Volumes discrets : les sons soutiennent la bulle, ils ne dominent
  // jamais une ambiance ou une voix de séance.
  static const double _volumeSouffle = 0.38;
  static const double _volumeCloche = 0.5;

  AudioPlayer? _souffleMontant;
  AudioPlayer? _souffleDescendant;
  AudioPlayer? _cloche;

  /// Initialisation paresseuse, une seule tentative mémorisée.
  Future<bool>? _initialisation;

  Future<bool> _initialiser() => _initialisation ??= _charger();

  Future<bool> _charger() async {
    try {
      const chemins = [
        '$_dossier/souffle_inspiration.mp3',
        '$_dossier/souffle_expiration.mp3',
        '$_dossier/inversion.mp3',
      ];
      for (final String chemin in chemins) {
        if (!await MixeurAudioHandler.assetExiste(chemin)) return false;
      }
      _souffleMontant = AudioPlayer();
      _souffleDescendant = AudioPlayer();
      _cloche = AudioPlayer();
      await _souffleMontant!.setAsset(chemins[0]);
      await _souffleDescendant!.setAsset(chemins[1]);
      await _cloche!.setAsset(chemins[2]);
      await _souffleMontant!.setVolume(_volumeSouffle);
      await _souffleDescendant!.setVolume(_volumeSouffle);
      await _cloche!.setVolume(_volumeCloche);
      return true;
    } catch (_) {
      return false; // plateforme audio absente (tests) ou fichier illisible
    }
  }

  /// Accompagne l'entrée dans une nouvelle phase : le souffle en cours
  /// s'estompe, le son cristallin marque l'inversion, puis le souffle
  /// de la phase démarre (rien pendant les rétentions — c'est le vide).
  Future<void> jouerTransition(PhaseRespiration phase, double dureePhase) async {
    if (!await _initialiser()) return;
    try {
      unawaited(_estomper(_souffleMontant));
      unawaited(_estomper(_souffleDescendant));
      unawaited(_sonner());
      switch (phase) {
        case PhaseRespiration.inspiration:
          await _souffler(_souffleMontant!, dureePhase);
        case PhaseRespiration.expiration:
          await _souffler(_souffleDescendant!, dureePhase);
        case PhaseRespiration.retentionHaute:
        case PhaseRespiration.retentionBasse:
          break;
      }
    } catch (_) {
      // Jamais d'erreur audible : la séance continue sans sons.
    }
  }

  /// Son cristallin seul, pour saluer la fin d'une séance.
  Future<void> jouerFin() async {
    if (!await _initialiser()) return;
    try {
      unawaited(_estomper(_souffleMontant));
      unawaited(_estomper(_souffleDescendant));
      await _sonner();
    } catch (_) {}
  }

  /// Estompe tout, pour une pause ou un arrêt de séance.
  Future<void> couper() async {
    // Rien à couper si les sons n'ont jamais été chargés.
    if (_initialisation == null || !await _initialisation!) return;
    try {
      await Future.wait([
        _estomper(_souffleMontant),
        _estomper(_souffleDescendant),
        _estomper(_cloche, volumeRepos: _volumeCloche),
      ]);
    } catch (_) {}
  }

  Future<void> _souffler(AudioPlayer lecteur, double dureePhase) async {
    // Étire le souffle vers la durée de la phase, dans des limites
    // où il reste naturel (au-delà, il s'éteint avant la fin).
    final double vitesse =
        (_dureeSouffleS / dureePhase.clamp(1.0, 60.0)).clamp(0.5, 1.6);
    await lecteur.setSpeed(vitesse);
    await lecteur.setVolume(_volumeSouffle);
    await lecteur.seek(Duration.zero);
    lecteur.play();
  }

  Future<void> _sonner() async {
    final AudioPlayer? cloche = _cloche;
    if (cloche == null) return;
    await cloche.setVolume(_volumeCloche);
    await cloche.seek(Duration.zero);
    cloche.play();
  }

  /// Fondu de sortie court : jamais de coupure sèche.
  Future<void> _estomper(
    AudioPlayer? lecteur, {
    double volumeRepos = _volumeSouffle,
  }) async {
    if (lecteur == null || !lecteur.playing) return;
    for (int pas = 4; pas >= 1; pas--) {
      await lecteur.setVolume(volumeRepos * pas / 5);
      await Future<void>.delayed(const Duration(milliseconds: 45));
    }
    await lecteur.pause();
    await lecteur.setVolume(volumeRepos);
  }

  Future<void> liberer() async {
    await _souffleMontant?.dispose();
    await _souffleDescendant?.dispose();
    await _cloche?.dispose();
  }
}

/// Service des sons de respiration, créé à la première utilisation.
final sonsRespirationProvider = Provider<SonsRespirationService>((ref) {
  final SonsRespirationService service = SonsRespirationService();
  ref.onDispose(service.liberer);
  return service;
});
