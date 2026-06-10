import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptique_service.dart';
import '../../../shared/widgets/apparition.dart';
import '../../../shared/widgets/carte_zen.dart';
import '../../../shared/widgets/en_tete_ecran.dart';
import '../../../shared/widgets/route_fondu.dart';
import '../data/catalogue_seances.dart';
import '../logic/lecteur_seance_provider.dart';
import 'ecran_lecture_seance.dart';

/// Filtre d'objectif sélectionné dans la bibliothèque (null = toutes).
class FiltreObjectifNotifier extends Notifier<ObjectifSeance?> {
  @override
  ObjectifSeance? build() => null;

  void choisir(ObjectifSeance? objectif) =>
      state = state == objectif ? null : objectif;
}

final filtreObjectifProvider =
    NotifierProvider<FiltreObjectifNotifier, ObjectifSeance?>(
  FiltreObjectifNotifier.new,
);

/// Écran « Séances » : bibliothèque classée par durée, filtrable
/// par objectif.
class EcranSeances extends ConsumerWidget {
  const EcranSeances({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ObjectifSeance? filtre = ref.watch(filtreObjectifProvider);

    final List<SeanceGuidee> seances = CatalogueSeances.toutes
        .where((s) => filtre == null || s.objectif == filtre)
        .toList()
      ..sort((a, b) => a.dureeMinutes.compareTo(b.dureeMinutes));

    return ListView(
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        const EnTeteEcran(
          titre: 'Séances',
          sousTitre: 'Des voix pour vous accompagner.',
        ),
        const SizedBox(height: 12),
        // — Filtres par objectif
        Apparition(
          enfant: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: ObjectifSeance.values.map((objectif) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(objectif.libelle),
                    selected: filtre == objectif,
                    onSelected: (_) {
                      HaptiqueService.selection();
                      ref
                          .read(filtreObjectifProvider.notifier)
                          .choisir(objectif);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 22),
        // — Liste des séances, des plus courtes aux plus longues
        ...List.generate(seances.length, (i) {
          final SeanceGuidee seance = seances[i];
          return Apparition.cascade(
            rang: i + 1,
            enfant: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: _CarteSeance(seance: seance),
            ),
          );
        }),
        if (seances.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              'Aucune séance pour cet objectif pour le moment.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

/// Carte d'une séance dans la bibliothèque.
class _CarteSeance extends ConsumerWidget {
  const _CarteSeance({required this.seance});

  final SeanceGuidee seance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    final TextTheme typo = Theme.of(context).textTheme;

    return CarteZen(
      onTap: () {
        HaptiqueService.selection();
        ref.read(lecteurSeanceProvider.notifier).ouvrir(seance);
        Navigator.of(context).push(
          RouteFondu<void>(ecran: const EcranLectureSeance()),
        );
      },
      enfant: Row(
        children: [
          // Pastille de durée — l'information de tri, mise en avant.
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: schema.primary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${seance.dureeMinutes}′',
              style: typo.titleMedium!.copyWith(color: schema.primary),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seance.titre, style: typo.titleMedium),
                const SizedBox(height: 4),
                Text(seance.description, style: typo.bodySmall),
                const SizedBox(height: 8),
                Text(
                  seance.objectif.libelle.toUpperCase(),
                  style: typo.labelSmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.play_arrow_rounded,
            color: schema.onSurfaceVariant,
            size: 28,
          ),
        ],
      ),
    );
  }
}
