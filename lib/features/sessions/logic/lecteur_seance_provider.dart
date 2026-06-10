import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/services/mixeur_audio.dart';
import '../../tracking/data/entree_historique.dart';
import '../../tracking/logic/historique_provider.dart';
import '../data/catalogue_seances.dart';

/// Statut du lecteur de séance guidée.
enum StatutLecteur {
  inactif,
  chargement,

  /// Le fichier audio n'est pas présent dans les assets.
  indisponible,

  pret,
}

/// État du lecteur de séance.
class EtatLecteurSeance {
  const EtatLecteurSeance({
    this.statut = StatutLecteur.inactif,
    this.seance,
  });

  final StatutLecteur statut;
  final SeanceGuidee? seance;

  EtatLecteurSeance copyWith({StatutLecteur? statut, SeanceGuidee? seance}) {
    return EtatLecteurSeance(
      statut: statut ?? this.statut,
      seance: seance ?? this.seance,
    );
  }
}

/// Pilote la lecture d'une séance guidée via le mixeur audio global
/// (lecture en arrière-plan, notification média) et enregistre la
/// pratique dans l'historique.
class LecteurSeanceNotifier extends Notifier<EtatLecteurSeance> {
  StreamSubscription<PlayerState>? _abonnement;
  bool _pratiqueEnregistree = false;

  @override
  EtatLecteurSeance build() {
    ref.onDispose(() => _abonnement?.cancel());
    return const EtatLecteurSeance();
  }

  MixeurAudioHandler get _mixeur => ref.read(mixeurAudioProvider);

  /// Charge la séance et lance la lecture. Si le fichier audio est
  /// absent, l'état passe à `indisponible` (l'écran l'indique calmement).
  Future<void> ouvrir(SeanceGuidee seance) async {
    _pratiqueEnregistree = false;
    state = EtatLecteurSeance(statut: StatutLecteur.chargement, seance: seance);

    final bool ok = await _mixeur.chargerSeance(
      seance.fichier,
      MediaItem(
        id: seance.id,
        title: seance.titre,
        album: 'Flow — ${seance.objectif.libelle}',
      ),
    );
    if (!ok) {
      state = state.copyWith(statut: StatutLecteur.indisponible);
      return;
    }

    // À la fin du fichier, la pratique est comptée une seule fois.
    await _abonnement?.cancel();
    _abonnement = _mixeur.etatSeance.listen((etat) {
      if (etat.processingState == ProcessingState.completed) {
        _enregistrerPratique(complete: true);
      }
    });

    state = state.copyWith(statut: StatutLecteur.pret);
    await _mixeur.play();
  }

  Future<void> basculerLecture() async {
    final bool joue = _mixeur.playbackState.value.playing;
    if (joue) {
      await _mixeur.pause();
    } else {
      await _mixeur.play();
    }
  }

  Future<void> chercher(Duration position) => _mixeur.seek(position);

  /// Recule ou avance de quelques secondes.
  Future<void> decaler(Duration delta) async {
    final Duration duree = _mixeur.dureeSeance ?? Duration.zero;
    Duration cible = (await _mixeur.positionSeance.first) + delta;
    if (cible < Duration.zero) cible = Duration.zero;
    if (duree > Duration.zero && cible > duree) cible = duree;
    await _mixeur.seek(cible);
  }

  /// Ferme le lecteur. Une écoute d'au moins une minute est
  /// enregistrée comme pratique, même incomplète.
  Future<void> fermer() async {
    final Duration position = await _mixeur.positionSeance.first;
    if (position.inSeconds >= 60) {
      _enregistrerPratique(complete: false, ecoute: position);
    }
    await _abonnement?.cancel();
    _abonnement = null;
    await _mixeur.arreterSeance();
    state = const EtatLecteurSeance();
  }

  void _enregistrerPratique({required bool complete, Duration? ecoute}) {
    final SeanceGuidee? seance = state.seance;
    if (seance == null || _pratiqueEnregistree) return;
    _pratiqueEnregistree = true;
    final int secondes = complete
        ? (_mixeur.dureeSeance?.inSeconds ?? seance.dureeMinutes * 60)
        : (ecoute?.inSeconds ?? 0);
    ref.read(historiqueProvider.notifier).ajouter(
          EntreeHistorique(
            id: 'seance_${DateTime.now().microsecondsSinceEpoch}',
            type: TypePratique.seance,
            titre: seance.titre,
            dureeSecondes: secondes,
            date: DateTime.now(),
          ),
        );
  }
}

final lecteurSeanceProvider =
    NotifierProvider<LecteurSeanceNotifier, EtatLecteurSeance>(
  LecteurSeanceNotifier.new,
);

/// Position de lecture de la séance en cours.
final positionSeanceProvider = StreamProvider<Duration>(
  (ref) => ref.watch(mixeurAudioProvider).positionSeance,
);

/// État (lecture/pause/terminé) du lecteur de séance.
final etatLectureSeanceProvider = StreamProvider<PlayerState>(
  (ref) => ref.watch(mixeurAudioProvider).etatSeance,
);
