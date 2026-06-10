import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formats.dart';
import '../data/entree_historique.dart';
import 'historique_provider.dart';

/// Statistiques simples calculées à partir de l'historique.
class StatistiquesPratique {
  const StatistiquesPratique({
    required this.totalPratiques,
    required this.totalSecondes,
    required this.serieActuelle,
    required this.meilleureSerie,
    required this.minutesParJourSemaine,
  });

  final int totalPratiques;
  final int totalSecondes;

  /// Jours consécutifs de pratique se terminant aujourd'hui (ou hier
  /// si la journée n'a pas encore eu de pratique).
  final int serieActuelle;
  final int meilleureSerie;

  /// Minutes pratiquées pour chacun des 7 derniers jours
  /// (index 0 = il y a 6 jours, index 6 = aujourd'hui).
  final List<int> minutesParJourSemaine;
}

/// Calcule les statistiques — fonction pure, testée unitairement.
StatistiquesPratique calculerStatistiques(
  List<EntreeHistorique> historique,
  DateTime maintenant,
) {
  final int totalSecondes =
      historique.fold(0, (somme, e) => somme + e.dureeSecondes);

  // Jours distincts de pratique, du plus récent au plus ancien.
  final List<DateTime> jours = historique
      .map((e) => jourDe(e.date))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  // — Série actuelle : on remonte jour par jour depuis aujourd'hui (ou hier).
  final DateTime aujourdHui = jourDe(maintenant);
  int serieActuelle = 0;
  if (jours.isNotEmpty) {
    DateTime curseur = jours.first == aujourdHui
        ? aujourdHui
        : aujourdHui.subtract(const Duration(days: 1));
    final Set<DateTime> ensembleJours = jours.toSet();
    while (ensembleJours.contains(curseur)) {
      serieActuelle++;
      curseur = curseur.subtract(const Duration(days: 1));
    }
  }

  // — Meilleure série : plus longue suite de jours consécutifs.
  int meilleureSerie = 0;
  int serieEnCours = 0;
  DateTime? precedent;
  for (final DateTime jour in jours.reversed) {
    if (precedent != null && jour.difference(precedent).inDays == 1) {
      serieEnCours++;
    } else {
      serieEnCours = 1;
    }
    if (serieEnCours > meilleureSerie) meilleureSerie = serieEnCours;
    precedent = jour;
  }

  // — Minutes par jour sur les 7 derniers jours.
  final List<int> minutesParJour = List<int>.filled(7, 0);
  for (final EntreeHistorique entree in historique) {
    final int ecart = aujourdHui.difference(jourDe(entree.date)).inDays;
    if (ecart >= 0 && ecart < 7) {
      minutesParJour[6 - ecart] += entree.dureeSecondes ~/ 60;
    }
  }

  return StatistiquesPratique(
    totalPratiques: historique.length,
    totalSecondes: totalSecondes,
    serieActuelle: serieActuelle,
    meilleureSerie: meilleureSerie,
    minutesParJourSemaine: minutesParJour,
  );
}

/// Statistiques dérivées de l'historique courant.
final statistiquesProvider = Provider<StatistiquesPratique>((ref) {
  final historique = ref.watch(historiqueProvider);
  return calculerStatistiques(historique, DateTime.now());
});
