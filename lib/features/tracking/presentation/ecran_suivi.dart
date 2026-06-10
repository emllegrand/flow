import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formats.dart';
import '../../../shared/widgets/apparition.dart';
import '../../../shared/widgets/carte_zen.dart';
import '../../../shared/widgets/en_tete_ecran.dart';
import '../data/entree_historique.dart';
import '../logic/historique_provider.dart';
import '../logic/statistiques.dart';
import 'graphique_semaine.dart';

/// Écran « Suivi » : série en cours, statistiques simples,
/// minutes de la semaine et historique des pratiques.
class EcranSuivi extends ConsumerWidget {
  const EcranSuivi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<EntreeHistorique> historique = ref.watch(historiqueProvider);
    final StatistiquesPratique stats = ref.watch(statistiquesProvider);
    final TextTheme typo = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        const EnTeteEcran(
          titre: 'Suivi',
          sousTitre: 'Le chemin parcouru, pas à pas.',
        ),
        const SizedBox(height: 16),
        // — Série en cours, mise en avant
        Apparition.cascade(
          rang: 1,
          enfant: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _CarteSerie(stats: stats),
          ),
        ),
        const SizedBox(height: 14),
        // — Chiffres simples
        Apparition.cascade(
          rang: 2,
          enfant: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _CarteChiffre(
                    valeur: '${stats.totalPratiques}',
                    libelle: stats.totalPratiques > 1
                        ? 'pratiques'
                        : 'pratique',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _CarteChiffre(
                    valeur: formatMinutes(stats.totalSecondes),
                    libelle: 'en tout',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _CarteChiffre(
                    valeur: '${stats.meilleureSerie}',
                    libelle: stats.meilleureSerie > 1
                        ? 'jours au mieux'
                        : 'jour au mieux',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // — La semaine en minutes
        Apparition.cascade(
          rang: 3,
          enfant: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CarteZen(
              enfant: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CETTE SEMAINE', style: typo.labelMedium),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 120,
                    child: GraphiqueSemaine(
                      minutesParJour: stats.minutesParJourSemaine,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        // — Historique
        if (historique.isNotEmpty) ...[
          Apparition.cascade(
            rang: 4,
            enfant: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text('HISTORIQUE', style: typo.labelMedium),
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(
            historique.length.clamp(0, 30),
            (i) => Apparition.cascade(
              rang: 5 + i.clamp(0, 6), // la cascade s'arrête vite : calme
              enfant: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                child: _LigneHistorique(entree: historique[i]),
              ),
            ),
          ),
        ] else
          Apparition.cascade(
            rang: 4,
            enfant: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'Votre première pratique trouvera sa place ici.\n'
                'Commencez par quelques respirations.',
                style: typo.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// La série de jours consécutifs, à l'honneur.
class _CarteSerie extends StatelessWidget {
  const _CarteSerie({required this.stats});

  final StatistiquesPratique stats;

  @override
  Widget build(BuildContext context) {
    final TextTheme typo = Theme.of(context).textTheme;
    final ColorScheme schema = Theme.of(context).colorScheme;
    final int serie = stats.serieActuelle;

    return CarteZen(
      enfant: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: schema.primary.withValues(alpha: 0.14),
            ),
            child: Icon(
              Icons.eco_rounded,
              color: schema.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serie == 0
                      ? 'La série commence aujourd\'hui'
                      : '$serie ${serie > 1 ? "jours" : "jour"} de suite',
                  style: typo.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  serie == 0
                      ? 'Une pratique, même brève, suffit à planter la graine.'
                      : 'Chaque jour de pratique fait pousser la série.',
                  style: typo.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Petit chiffre clé dans une carte sobre.
class _CarteChiffre extends StatelessWidget {
  const _CarteChiffre({required this.valeur, required this.libelle});

  final String valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    final TextTheme typo = Theme.of(context).textTheme;
    return CarteZen(
      rembourrage: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      enfant: Column(
        children: [
          Text(valeur, style: typo.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(libelle, style: typo.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Une pratique passée, sur une ligne discrète.
class _LigneHistorique extends StatelessWidget {
  const _LigneHistorique({required this.entree});

  final EntreeHistorique entree;

  @override
  Widget build(BuildContext context) {
    final TextTheme typo = Theme.of(context).textTheme;
    final ColorScheme schema = Theme.of(context).colorScheme;
    final String date =
        DateFormat('EEEE d MMMM', 'fr_FR').format(entree.date);

    return CarteZen(
      rembourrage: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enfant: Row(
        children: [
          Icon(
            entree.type == TypePratique.respiration
                ? Icons.air_rounded
                : Icons.headphones_rounded,
            size: 20,
            color: schema.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entree.titre, style: typo.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '$date${entree.cycles != null ? " · ${entree.cycles} cycles" : ""}',
                  style: typo.bodySmall,
                ),
              ],
            ),
          ),
          Text(formatMinutes(entree.dureeSecondes), style: typo.bodyMedium),
        ],
      ),
    );
  }
}
