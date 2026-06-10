import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptique_service.dart';
import '../../../shared/widgets/apparition.dart';
import '../../../shared/widgets/carte_zen.dart';
import '../../../shared/widgets/fond_anime.dart';
import '../../../shared/widgets/route_fondu.dart';
import '../../breathing/data/rythme_respiration.dart';
import '../../breathing/logic/moteur_respiration.dart';
import '../../breathing/presentation/ecran_seance_respiration.dart';
import '../../sessions/data/catalogue_seances.dart';
import '../../sessions/logic/lecteur_seance_provider.dart';
import '../../sessions/presentation/ecran_lecture_seance.dart';
import '../../sounds/logic/mixeur_sons_provider.dart';
import '../data/catalogue_parcours.dart';

/// Détail d'un parcours : ses étapes, chacune menant directement
/// à l'exercice, la séance ou les sons correspondants.
class EcranParcours extends ConsumerWidget {
  const EcranParcours({super.key, required this.parcours});

  final ParcoursBesoin parcours;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme typo = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FondAnime(
        enfant: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
            children: [
              Apparition(
                enfant: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: parcours.couleur.withValues(alpha: 0.16),
                      ),
                      child: Icon(
                        parcours.icone,
                        color: parcours.couleur,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(parcours.nom, style: typo.displaySmall),
                    const SizedBox(height: 10),
                    Text(parcours.description, style: typo.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ...List.generate(parcours.etapes.length, (i) {
                final EtapeParcours etape = parcours.etapes[i];
                return Apparition.cascade(
                  rang: i + 2,
                  enfant: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CarteEtape(
                      etape: etape,
                      numero: i + 1,
                      couleur: parcours.couleur,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Une étape du parcours, prête à être vécue d'un toucher.
class _CarteEtape extends ConsumerWidget {
  const _CarteEtape({
    required this.etape,
    required this.numero,
    required this.couleur,
  });

  final EtapeParcours etape;
  final int numero;
  final Color couleur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme typo = Theme.of(context).textTheme;
    final ColorScheme schema = Theme.of(context).colorScheme;

    final String sousTitre = switch (etape.type) {
      TypeEtape.respiration => 'Exercice de respiration',
      TypeEtape.seance => 'Séance guidée',
      TypeEtape.sons => 'Sons d\'ambiance',
    };

    return CarteZen(
      onTap: () => _ouvrir(context, ref),
      enfant: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: couleur.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Text(
              '$numero',
              style: typo.titleMedium!.copyWith(color: couleur),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etape.libelle, style: typo.titleMedium),
                const SizedBox(height: 3),
                Text(sousTitre, style: typo.bodySmall),
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
    );
  }

  void _ouvrir(BuildContext context, WidgetRef ref) {
    HaptiqueService.selection();
    switch (etape.type) {
      case TypeEtape.respiration:
        final moteur = ref.read(moteurRespirationProvider.notifier);
        moteur.configurer(
          rythme: RythmesPredefinis.parId(etape.rythmeId!),
          dureeMinutes: etape.dureeMinutes,
        );
        moteur.demarrer();
        Navigator.of(context).push(
          RouteFondu<void>(ecran: const EcranSeanceRespiration()),
        );
      case TypeEtape.seance:
        final SeanceGuidee? seance = CatalogueSeances.parId(etape.seanceId!);
        if (seance == null) return;
        ref.read(lecteurSeanceProvider.notifier).ouvrir(seance);
        Navigator.of(context).push(
          RouteFondu<void>(ecran: const EcranLectureSeance()),
        );
      case TypeEtape.sons:
        final mixeur = ref.read(mixeurSonsProvider.notifier);
        final pistes = ref.read(mixeurSonsProvider);
        for (final String id in etape.sonsIds) {
          if (!(pistes[id]?.active ?? false)) mixeur.basculer(id);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: const StadiumBorder(),
            content: const Text('Le paysage sonore s\'installe…'),
            duration: const Duration(seconds: 3),
            backgroundColor:
                Theme.of(context).colorScheme.inverseSurface,
          ),
        );
    }
  }
}
