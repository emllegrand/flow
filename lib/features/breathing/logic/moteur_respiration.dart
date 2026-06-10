import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptique_service.dart';
import '../../settings/logic/reglages_provider.dart';
import '../../tracking/data/entree_historique.dart';
import '../../tracking/logic/historique_provider.dart';
import '../data/rythme_respiration.dart';

/// Statut d'une séance de respiration.
enum StatutRespiration {
  /// Aucun exercice en cours : écran de préparation.
  reposee,

  /// Court temps d'installation avant le premier cycle.
  preparation,

  enCours,
  enPause,
  terminee,
}

/// État complet d'une séance de respiration, immuable.
class EtatRespiration {
  const EtatRespiration({
    required this.statut,
    required this.rythme,
    required this.dureeCibleSecondes,
    this.phase = PhaseRespiration.inspiration,
    this.tempsDansPhase = 0,
    this.cyclesEffectues = 0,
    this.secondesEcoulees = 0,
  });

  final StatutRespiration statut;
  final RythmeRespiration rythme;

  /// Durée de séance visée (minuteur), en secondes.
  final int dureeCibleSecondes;

  final PhaseRespiration phase;

  /// Temps écoulé dans la phase courante, en secondes.
  final double tempsDansPhase;

  final int cyclesEffectues;

  /// Temps total de pratique écoulé, en secondes.
  final double secondesEcoulees;

  /// Durée de la phase courante selon le rythme.
  double get dureePhase => switch (phase) {
        PhaseRespiration.inspiration => rythme.inspiration,
        PhaseRespiration.retentionHaute => rythme.retentionHaute,
        PhaseRespiration.expiration => rythme.expiration,
        PhaseRespiration.retentionBasse => rythme.retentionBasse,
      };

  /// Avancement dans la phase courante, de 0 à 1.
  double get progressionPhase =>
      dureePhase <= 0 ? 1 : (tempsDansPhase / dureePhase).clamp(0.0, 1.0);

  /// Secondes restantes dans la phase, pour le compte à rebours.
  int get resteDansPhase => (dureePhase - tempsDansPhase).ceil().clamp(0, 99);

  EtatRespiration copyWith({
    StatutRespiration? statut,
    RythmeRespiration? rythme,
    int? dureeCibleSecondes,
    PhaseRespiration? phase,
    double? tempsDansPhase,
    int? cyclesEffectues,
    double? secondesEcoulees,
  }) {
    return EtatRespiration(
      statut: statut ?? this.statut,
      rythme: rythme ?? this.rythme,
      dureeCibleSecondes: dureeCibleSecondes ?? this.dureeCibleSecondes,
      phase: phase ?? this.phase,
      tempsDansPhase: tempsDansPhase ?? this.tempsDansPhase,
      cyclesEffectues: cyclesEffectues ?? this.cyclesEffectues,
      secondesEcoulees: secondesEcoulees ?? this.secondesEcoulees,
    );
  }
}

/// Moteur de la séance de respiration.
///
/// Toute la logique vit ici (pas dans les widgets) : enchaînement des
/// phases, compteur de cycles, minuteur, haptique, enregistrement dans
/// l'historique. La progression du temps passe par [avancer], appelée
/// par un minuteur interne — et directement par les tests unitaires.
class MoteurRespirationNotifier extends Notifier<EtatRespiration> {
  Timer? _minuteur;

  /// Pas de temps du minuteur interne.
  static const Duration _pas = Duration(milliseconds: 100);

  /// Temps d'installation avant le premier cycle, en secondes.
  static const double dureePreparation = 4;

  @override
  EtatRespiration build() {
    ref.onDispose(_arreterMinuteur);
    return const EtatRespiration(
      statut: StatutRespiration.reposee,
      rythme: RythmesPredefinis.coherence,
      dureeCibleSecondes: 5 * 60,
    );
  }

  /// Choisit le rythme et la durée avant de commencer.
  void configurer({RythmeRespiration? rythme, int? dureeMinutes}) {
    if (state.statut != StatutRespiration.reposee &&
        state.statut != StatutRespiration.terminee) {
      return; // pas de changement pendant une séance
    }
    state = EtatRespiration(
      statut: StatutRespiration.reposee,
      rythme: rythme ?? state.rythme,
      dureeCibleSecondes:
          dureeMinutes != null ? dureeMinutes * 60 : state.dureeCibleSecondes,
    );
  }

  /// Lance la séance, après un court temps d'installation.
  void demarrer() {
    state = EtatRespiration(
      statut: StatutRespiration.preparation,
      rythme: state.rythme,
      dureeCibleSecondes: state.dureeCibleSecondes,
    );
    _lancerMinuteur();
  }

  void mettreEnPause() {
    if (state.statut != StatutRespiration.enCours) return;
    _arreterMinuteur();
    state = state.copyWith(statut: StatutRespiration.enPause);
  }

  void reprendre() {
    if (state.statut != StatutRespiration.enPause) return;
    state = state.copyWith(statut: StatutRespiration.enCours);
    _lancerMinuteur();
  }

  /// Interrompt la séance. La pratique est tout de même enregistrée
  /// si elle a duré au moins une minute.
  void arreter() {
    _arreterMinuteur();
    if (state.secondesEcoulees >= 60) _enregistrerPratique();
    state = EtatRespiration(
      statut: StatutRespiration.reposee,
      rythme: state.rythme,
      dureeCibleSecondes: state.dureeCibleSecondes,
    );
  }

  /// Revient à l'écran de préparation après une séance terminée.
  void recommencer() {
    state = EtatRespiration(
      statut: StatutRespiration.reposee,
      rythme: state.rythme,
      dureeCibleSecondes: state.dureeCibleSecondes,
    );
  }

  /// Fait avancer le temps de [dt] secondes. Public pour les tests.
  void avancer(double dt) {
    switch (state.statut) {
      case StatutRespiration.preparation:
        _avancerPreparation(dt);
      case StatutRespiration.enCours:
        _avancerSeance(dt);
      case StatutRespiration.reposee:
      case StatutRespiration.enPause:
      case StatutRespiration.terminee:
        break;
    }
  }

  void _avancerPreparation(double dt) {
    final double temps = state.tempsDansPhase + dt;
    if (temps >= dureePreparation) {
      // Premier cycle : on entre dans l'inspiration.
      state = state.copyWith(
        statut: StatutRespiration.enCours,
        phase: PhaseRespiration.inspiration,
        tempsDansPhase: 0,
      );
      _haptique();
    } else {
      state = state.copyWith(tempsDansPhase: temps);
    }
  }

  void _avancerSeance(double dt) {
    double tempsPhase = state.tempsDansPhase + dt;
    final double ecoule = state.secondesEcoulees + dt;
    PhaseRespiration phase = state.phase;
    int cycles = state.cyclesEffectues;

    // Passage de phase (en sautant les phases de durée nulle).
    // Garde-fou : jamais plus de quelques passages par tick (rythme dégénéré).
    int passages = 0;
    while (tempsPhase >= _dureeDe(phase) && passages++ < 8) {
      tempsPhase -= _dureeDe(phase);
      final PhaseRespiration suivante = _phaseSuivante(phase);
      // Fin d'un cycle quand on boucle vers l'inspiration.
      if (suivante == PhaseRespiration.inspiration) {
        cycles++;
        // Le minuteur de séance s'arrête à la fin d'un cycle complet,
        // jamais au milieu d'une respiration.
        if (ecoule >= state.dureeCibleSecondes) {
          _terminer(cycles, ecoule);
          return;
        }
      }
      phase = suivante;
      _haptique();
    }

    state = state.copyWith(
      phase: phase,
      tempsDansPhase: tempsPhase,
      cyclesEffectues: cycles,
      secondesEcoulees: ecoule,
    );
  }

  void _terminer(int cycles, double ecoule) {
    _arreterMinuteur();
    state = state.copyWith(
      statut: StatutRespiration.terminee,
      cyclesEffectues: cycles,
      secondesEcoulees: ecoule,
      tempsDansPhase: 0,
      phase: PhaseRespiration.inspiration,
    );
    _enregistrerPratique();
  }

  void _enregistrerPratique() {
    ref.read(historiqueProvider.notifier).ajouter(
          EntreeHistorique(
            id: 'resp_${DateTime.now().microsecondsSinceEpoch}',
            type: TypePratique.respiration,
            titre: state.rythme.nom,
            dureeSecondes: state.secondesEcoulees.round(),
            date: DateTime.now(),
            cycles: state.cyclesEffectues,
          ),
        );
  }

  double _dureeDe(PhaseRespiration phase) => switch (phase) {
        PhaseRespiration.inspiration => state.rythme.inspiration,
        PhaseRespiration.retentionHaute => state.rythme.retentionHaute,
        PhaseRespiration.expiration => state.rythme.expiration,
        PhaseRespiration.retentionBasse => state.rythme.retentionBasse,
      };

  PhaseRespiration _phaseSuivante(PhaseRespiration phase) {
    PhaseRespiration suivante = PhaseRespiration
        .values[(phase.index + 1) % PhaseRespiration.values.length];
    // Saute les phases de durée nulle (ex. rétentions en cohérence cardiaque).
    while (_dureeDe(suivante) <= 0) {
      suivante = PhaseRespiration
          .values[(suivante.index + 1) % PhaseRespiration.values.length];
      if (suivante == phase) break; // garde-fou : rythme entièrement nul
    }
    return suivante;
  }

  void _haptique() {
    if (ref.read(reglagesProvider).haptiqueActive) {
      HaptiqueService.souffle();
    }
  }

  void _lancerMinuteur() {
    _arreterMinuteur();
    _minuteur = Timer.periodic(
      _pas,
      (_) => avancer(_pas.inMilliseconds / 1000),
    );
  }

  void _arreterMinuteur() {
    _minuteur?.cancel();
    _minuteur = null;
  }
}

final moteurRespirationProvider =
    NotifierProvider<MoteurRespirationNotifier, EtatRespiration>(
  MoteurRespirationNotifier.new,
);
