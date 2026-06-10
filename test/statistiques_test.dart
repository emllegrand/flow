import 'package:flow/features/tracking/data/entree_historique.dart';
import 'package:flow/features/tracking/logic/statistiques.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests du calcul des séries (streaks) et des statistiques.
void main() {
  final DateTime maintenant = DateTime(2026, 6, 10, 18); // mercredi soir

  EntreeHistorique pratique(DateTime date, {int minutes = 5}) {
    return EntreeHistorique(
      id: 'p_${date.microsecondsSinceEpoch}',
      type: TypePratique.respiration,
      titre: 'Cohérence cardiaque',
      dureeSecondes: minutes * 60,
      date: date,
    );
  }

  test('historique vide : tout à zéro', () {
    final stats = calculerStatistiques(const [], maintenant);
    expect(stats.totalPratiques, 0);
    expect(stats.serieActuelle, 0);
    expect(stats.meilleureSerie, 0);
    expect(stats.minutesParJourSemaine, everyElement(0));
  });

  test('série en cours : trois jours consécutifs jusqu\'à aujourd\'hui', () {
    final stats = calculerStatistiques([
      pratique(DateTime(2026, 6, 10, 8)),
      pratique(DateTime(2026, 6, 9, 21)),
      pratique(DateTime(2026, 6, 8, 7)),
    ], maintenant);
    expect(stats.serieActuelle, 3);
    expect(stats.meilleureSerie, 3);
  });

  test('la série tient encore si la pratique du jour n\'a pas eu lieu', () {
    final stats = calculerStatistiques([
      pratique(DateTime(2026, 6, 9)),
      pratique(DateTime(2026, 6, 8)),
    ], maintenant);
    expect(stats.serieActuelle, 2);
  });

  test('un jour manqué casse la série actuelle, pas la meilleure', () {
    final stats = calculerStatistiques([
      pratique(DateTime(2026, 6, 10)),
      // 9 juin manqué
      pratique(DateTime(2026, 6, 8)),
      pratique(DateTime(2026, 6, 7)),
      pratique(DateTime(2026, 6, 6)),
    ], maintenant);
    expect(stats.serieActuelle, 1);
    expect(stats.meilleureSerie, 3);
  });

  test('plusieurs pratiques le même jour comptent pour un seul jour', () {
    final stats = calculerStatistiques([
      pratique(DateTime(2026, 6, 10, 8)),
      pratique(DateTime(2026, 6, 10, 20)),
    ], maintenant);
    expect(stats.serieActuelle, 1);
    expect(stats.totalPratiques, 2);
  });

  test('les minutes de la semaine tombent dans les bonnes cases', () {
    final stats = calculerStatistiques([
      pratique(DateTime(2026, 6, 10), minutes: 10), // aujourd'hui → case 6
      pratique(DateTime(2026, 6, 7), minutes: 5), // il y a 3 jours → case 3
      pratique(DateTime(2026, 6, 1), minutes: 20), // hors fenêtre
    ], maintenant);
    expect(stats.minutesParJourSemaine[6], 10);
    expect(stats.minutesParJourSemaine[3], 5);
    expect(stats.minutesParJourSemaine.fold<int>(0, (a, b) => a + b), 15);
    expect(stats.totalSecondes, 35 * 60);
  });
}
