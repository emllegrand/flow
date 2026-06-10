import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Mixeur audio de Flow, branché sur `audio_service` pour continuer
/// la lecture en arrière-plan (service de premier plan Android).
///
/// Deux familles de pistes mixées librement :
///  - les **sons d'ambiance** : un lecteur par son actif, en boucle,
///    chacun avec son volume indépendant ;
///  - la **séance guidée** : un lecteur unique avec position/contrôles,
///    reflété dans la notification média.
///
/// Fallback gracieux : si un fichier audio est absent des assets
/// (ils sont fournis séparément), la méthode renvoie `false` et
/// l'interface l'indique calmement — aucun plantage.
class MixeurAudioHandler extends BaseAudioHandler {
  MixeurAudioHandler() {
    _ecouterLecteurSeance();
  }

  /// Lecteurs d'ambiance actifs, indexés par identifiant de son.
  final Map<String, AudioPlayer> _ambiances = {};

  /// Lecteur de la séance guidée en cours.
  final AudioPlayer _lecteurSeance = AudioPlayer();

  /// Position de lecture de la séance.
  Stream<Duration> get positionSeance => _lecteurSeance.positionStream;

  /// Durée totale de la séance chargée (nulle tant que rien n'est chargé).
  Duration? get dureeSeance => _lecteurSeance.duration;

  /// État du lecteur de séance (lecture, pause, terminé…).
  Stream<PlayerState> get etatSeance => _lecteurSeance.playerStateStream;

  /// Vérifie qu'un asset existe réellement dans le bundle.
  static Future<bool> assetExiste(String chemin) async {
    try {
      await rootBundle.load(chemin);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ———————————————————————————————— Sons d'ambiance ————————————————————————————————

  /// Lance un son d'ambiance en boucle. Renvoie `false` si le fichier
  /// est absent des assets.
  Future<bool> activerAmbiance(
    String id,
    String chemin, {
    double volume = 0.7,
  }) async {
    if (!await assetExiste(chemin)) return false;
    try {
      final AudioPlayer lecteur = _ambiances.putIfAbsent(id, AudioPlayer.new);
      await lecteur.setAsset(chemin);
      await lecteur.setLoopMode(LoopMode.one);
      await lecteur.setVolume(volume);
      lecteur.play();
      _diffuserEtat();
      return true;
    } catch (_) {
      await desactiverAmbiance(id);
      return false;
    }
  }

  /// Arrête et libère un son d'ambiance.
  Future<void> desactiverAmbiance(String id) async {
    final AudioPlayer? lecteur = _ambiances.remove(id);
    await lecteur?.stop();
    await lecteur?.dispose();
    _diffuserEtat();
  }

  /// Ajuste le volume d'un son d'ambiance actif (0.0 à 1.0).
  Future<void> reglerVolumeAmbiance(String id, double volume) async {
    await _ambiances[id]?.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Identifiants des ambiances actuellement actives.
  Set<String> get ambiancesActives => _ambiances.keys.toSet();

  /// Coupe toutes les ambiances.
  Future<void> arreterAmbiances() async {
    for (final String id in _ambiances.keys.toList()) {
      await desactiverAmbiance(id);
    }
  }

  // ———————————————————————————————— Séance guidée ————————————————————————————————

  /// Charge une séance guidée. Renvoie `false` si le fichier est absent.
  Future<bool> chargerSeance(String chemin, MediaItem element) async {
    if (!await assetExiste(chemin)) return false;
    try {
      await _lecteurSeance.setAsset(chemin);
      mediaItem.add(
        element.copyWith(duration: _lecteurSeance.duration),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Arrête la séance en cours et libère le titre de la notification.
  Future<void> arreterSeance() async {
    await _lecteurSeance.stop();
    mediaItem.add(null);
    _diffuserEtat();
  }

  @override
  Future<void> play() async {
    _lecteurSeance.play();
  }

  @override
  Future<void> pause() async {
    await _lecteurSeance.pause();
  }

  @override
  Future<void> seek(Duration position) => _lecteurSeance.seek(position);

  @override
  Future<void> stop() async {
    await arreterSeance();
    await arreterAmbiances();
    await super.stop();
  }

  /// Relaie l'état de just_audio vers audio_service (notification média).
  void _ecouterLecteurSeance() {
    _lecteurSeance.playbackEventStream.listen((_) => _diffuserEtat());
  }

  void _diffuserEtat() {
    final bool seanceJoue = _lecteurSeance.playing &&
        _lecteurSeance.processingState != ProcessingState.completed &&
        _lecteurSeance.processingState != ProcessingState.idle;
    final bool ambianceJoue = _ambiances.isNotEmpty;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          if (seanceJoue) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        systemActions: const {MediaAction.seek},
        processingState: switch (_lecteurSeance.processingState) {
          ProcessingState.idle => ambianceJoue
              ? AudioProcessingState.ready
              : AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: seanceJoue || ambianceJoue,
        updatePosition: _lecteurSeance.position,
        speed: _lecteurSeance.speed,
      ),
    );
  }
}

/// Initialise la session audio puis le handler global (à appeler dans `main`).
Future<MixeurAudioHandler> initialiserAudio() async {
  final AudioSession session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  return AudioService.init(
    builder: MixeurAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.flow.flow.audio',
      androidNotificationChannelName: 'Lecture Flow',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

/// Handler audio global, injecté depuis `main` via `overrideWithValue`.
final mixeurAudioProvider = Provider<MixeurAudioHandler>(
  (ref) => throw UnimplementedError('Injecté au démarrage dans main.dart'),
);
