import 'dart:io';

import 'package:flow/core/services/sons_respiration.dart';
import 'package:flow/features/breathing/data/rythme_respiration.dart';
import 'package:flow/features/breathing/logic/moteur_respiration.dart';
import 'package:flow/features/tracking/logic/historique_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Tests du moteur de respiration : enchaînement des phases,
/// compteur de cycles, minuteur de séance, enregistrement.
/// Le temps est piloté à la main via `avancer` (pas de minuteur réel).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer conteneur;

  setUpAll(() async {
    final Directory dossier = Directory.systemTemp.createTempSync('flow_test');
    Hive.init(dossier.path);
    await Hive.openBox<dynamic>('reglages');
    await Hive.openBox<dynamic>('historique');
  });

  setUp(() async {
    await Hive.box<dynamic>('reglages').clear();
    await Hive.box<dynamic>('historique').clear();
    // Pas de plateforme audio dans les tests : service de sons inerte.
    conteneur = ProviderContainer(
      overrides: [
        sonsRespirationProvider
            .overrideWithValue(SonsRespirationService.desactive()),
      ],
    );
  });

  tearDown(() {
    conteneur.read(moteurRespirationProvider.notifier).arreter();
    conteneur.dispose();
  });

  MoteurRespirationNotifier moteur() =>
      conteneur.read(moteurRespirationProvider.notifier);
  EtatRespiration etat() => conteneur.read(moteurRespirationProvider);

  test('la préparation précède le premier cycle', () {
    moteur().demarrer();
    expect(etat().statut, StatutRespiration.preparation);

    moteur().avancer(MoteurRespirationNotifier.dureePreparation);
    expect(etat().statut, StatutRespiration.enCours);
    expect(etat().phase, PhaseRespiration.inspiration);
  });

  test('le rythme 4-7-8 enchaîne ses trois phases puis boucle', () {
    moteur().configurer(rythme: RythmesPredefinis.quatreSeptHuit);
    moteur().demarrer();
    moteur().avancer(MoteurRespirationNotifier.dureePreparation);

    moteur().avancer(4);
    expect(etat().phase, PhaseRespiration.retentionHaute);
    moteur().avancer(7);
    expect(etat().phase, PhaseRespiration.expiration);
    moteur().avancer(8);
    expect(etat().phase, PhaseRespiration.inspiration);
    expect(etat().cyclesEffectues, 1);
  });

  test('la cohérence cardiaque saute les rétentions (durée nulle)', () {
    moteur().configurer(rythme: RythmesPredefinis.coherence);
    moteur().demarrer();
    moteur().avancer(MoteurRespirationNotifier.dureePreparation);

    moteur().avancer(5);
    expect(etat().phase, PhaseRespiration.expiration);
    moteur().avancer(5);
    expect(etat().phase, PhaseRespiration.inspiration);
    expect(etat().cyclesEffectues, 1);
  });

  test('la pause suspend le temps, la reprise le relance', () {
    moteur().demarrer();
    moteur().avancer(MoteurRespirationNotifier.dureePreparation);
    moteur().avancer(2);

    moteur().mettreEnPause();
    final double tempsAvant = etat().tempsDansPhase;
    moteur().avancer(3); // ignoré pendant la pause
    expect(etat().tempsDansPhase, tempsAvant);

    moteur().reprendre();
    moteur().avancer(1);
    expect(etat().tempsDansPhase, closeTo(tempsAvant + 1, 0.001));
  });

  test('la séance se termine à la fin d\'un cycle complet, '
      'jamais au milieu', () async {
    // Cohérence cardiaque (cycle de 10 s), minuteur d'une minute.
    moteur().configurer(
      rythme: RythmesPredefinis.coherence,
      dureeMinutes: 1,
    );
    moteur().demarrer();
    moteur().avancer(MoteurRespirationNotifier.dureePreparation);

    // 60 secondes pile : six cycles complets.
    for (int i = 0; i < 120; i++) {
      moteur().avancer(0.5);
    }
    expect(etat().statut, StatutRespiration.terminee);
    expect(etat().cyclesEffectues, 6);

    // La pratique est enregistrée dans l'historique.
    await Future<void>.delayed(Duration.zero);
    final historique = conteneur.read(historiqueProvider);
    expect(historique, hasLength(1));
    expect(historique.first.cycles, 6);
    expect(historique.first.dureeSecondes, 60);
  });

  test('un arrêt avant une minute de pratique n\'est pas enregistré',
      () async {
    moteur().demarrer();
    moteur().avancer(MoteurRespirationNotifier.dureePreparation);
    moteur().avancer(30);

    moteur().arreter();
    await Future<void>.delayed(Duration.zero);
    expect(conteneur.read(historiqueProvider), isEmpty);
    expect(etat().statut, StatutRespiration.reposee);
  });
}
