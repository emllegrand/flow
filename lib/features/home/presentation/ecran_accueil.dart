import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptique_service.dart';
import '../../../core/utils/formats.dart';
import '../../../shared/widgets/apparition.dart';
import '../../../shared/widgets/carte_zen.dart';
import '../../../shared/widgets/route_fondu.dart';
import '../../breathing/data/rythme_respiration.dart';
import '../../breathing/logic/moteur_respiration.dart';
import '../../breathing/presentation/ecran_seance_respiration.dart';
import '../../settings/presentation/ecran_reglages.dart';
import '../../themes/data/catalogue_parcours.dart';
import '../../themes/presentation/ecran_parcours.dart';
import '../../tracking/logic/statistiques.dart';

/// Écran d'accueil : une salutation, un départ immédiat,
/// et les parcours par besoin.
class EcranAccueil extends ConsumerWidget {
  const EcranAccueil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme typo = Theme.of(context).textTheme;
    final ColorScheme schema = Theme.of(context).colorScheme;
    final int serie = ref.watch(statistiquesProvider).serieActuelle;
    final DateTime maintenant = DateTime.now();

    return ListView(
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        // — Salutation et accès aux réglages
        Apparition(
          enfant: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salutationDuMoment(maintenant),
                        style: typo.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        invitationDuMoment(maintenant),
                        style: typo.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    RouteFondu<void>(ecran: const EcranReglages()),
                  ),
                  icon: Icon(
                    Icons.tune_rounded,
                    color: schema.onSurfaceVariant,
                  ),
                  tooltip: 'Réglages',
                ),
              ],
            ),
          ),
        ),
        // — Série en cours, mention discrète
        if (serie > 0)
          Apparition.cascade(
            rang: 1,
            enfant: Padding(
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
              child: Row(
                children: [
                  Icon(Icons.eco_rounded, size: 16, color: schema.primary),
                  const SizedBox(width: 6),
                  Text(
                    '$serie ${serie > 1 ? "jours" : "jour"} de pratique '
                    'de suite',
                    style: typo.bodySmall!.copyWith(color: schema.primary),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 28),
        // — Départ immédiat : cohérence cardiaque
        Apparition.cascade(
          rang: 2,
          enfant: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CarteZen(
              couleur: schema.primary.withValues(alpha: 0.12),
              onTap: () {
                HaptiqueService.selection();
                final moteur = ref.read(moteurRespirationProvider.notifier);
                moteur.configurer(
                  rythme: RythmesPredefinis.coherence,
                  dureeMinutes: 5,
                );
                moteur.demarrer();
                Navigator.of(context).push(
                  RouteFondu<void>(ecran: const EcranSeanceRespiration()),
                );
              },
              rembourrage: const EdgeInsets.all(28),
              enfant: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Respirer, maintenant', style: typo.titleLarge),
                        const SizedBox(height: 6),
                        Text(
                          'Cinq minutes de cohérence cardiaque, '
                          'sans rien décider.',
                          style: typo.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: schema.primary,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: schema.onPrimary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        // — Parcours par besoin
        Apparition.cascade(
          rang: 3,
          enfant: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text('SELON VOTRE BESOIN', style: typo.labelMedium),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(CatalogueParcours.tous.length, (i) {
          final ParcoursBesoin parcours = CatalogueParcours.tous[i];
          return Apparition.cascade(
            rang: 4 + i,
            enfant: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: CarteZen(
                onTap: () {
                  HaptiqueService.selection();
                  Navigator.of(context).push(
                    RouteFondu<void>(
                      ecran: EcranParcours(parcours: parcours),
                    ),
                  );
                },
                enfant: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: parcours.couleur.withValues(alpha: 0.16),
                      ),
                      child: Icon(
                        parcours.icone,
                        color: parcours.couleur,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(parcours.nom, style: typo.titleMedium),
                          const SizedBox(height: 3),
                          Text(parcours.invitation, style: typo.bodySmall),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: schema.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
