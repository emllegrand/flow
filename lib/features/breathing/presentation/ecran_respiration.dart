import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptique_service.dart';
import '../../../shared/widgets/apparition.dart';
import '../../../shared/widgets/carte_zen.dart';
import '../../../shared/widgets/en_tete_ecran.dart';
import '../../../shared/widgets/route_fondu.dart';
import '../../settings/logic/reglages_provider.dart';
import '../data/rythme_respiration.dart';
import '../logic/moteur_respiration.dart';
import '../logic/rythme_perso_provider.dart';
import 'ecran_seance_respiration.dart';

/// Écran « Respirer » : choix du rythme, de la durée, départ de séance.
class EcranRespiration extends ConsumerWidget {
  const EcranRespiration({super.key});

  static const List<int> _dureesMinutes = [3, 5, 10, 15];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EtatRespiration etat = ref.watch(moteurRespirationProvider);
    final RythmeRespiration perso = ref.watch(rythmePersoProvider);
    final bool persoChoisi = etat.rythme.id == RythmesPredefinis.personnalise.id;

    return ListView(
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        const EnTeteEcran(
          titre: 'Respirer',
          sousTitre: 'Choisissez votre souffle, le reste suivra.',
        ),
        const SizedBox(height: 16),
        // — Choix du rythme
        ...List.generate(RythmesPredefinis.tous.length, (i) {
          final RythmeRespiration rythme = RythmesPredefinis.tous[i];
          final bool estPerso = rythme.id == RythmesPredefinis.personnalise.id;
          final RythmeRespiration effectif = estPerso ? perso : rythme;
          return Apparition.cascade(
            rang: i + 1,
            enfant: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: _CarteRythme(
                rythme: effectif,
                choisi: etat.rythme.id == rythme.id,
                onTap: () {
                  HaptiqueService.selection();
                  ref
                      .read(moteurRespirationProvider.notifier)
                      .configurer(rythme: effectif);
                },
              ),
            ),
          );
        }),
        // — Réglage du rythme personnalisé
        AnimatedSize(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutSine,
          child: persoChoisi
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
                  child: _ReglagesRythmePerso(perso: perso),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 18),
        // — Durée de séance
        Apparition.cascade(
          rang: 5,
          enfant: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'DURÉE DE LA SÉANCE',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Apparition.cascade(
          rang: 6,
          enfant: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 10,
              children: _dureesMinutes.map((minutes) {
                final bool choisie =
                    etat.dureeCibleSecondes == minutes * 60;
                return ChoiceChip(
                  label: Text('$minutes min'),
                  selected: choisie,
                  onSelected: (_) {
                    HaptiqueService.selection();
                    ref
                        .read(moteurRespirationProvider.notifier)
                        .configurer(dureeMinutes: minutes);
                  },
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 36),
        // — Départ
        Apparition.cascade(
          rang: 7,
          enfant: Center(
            child: FilledButton(
              onPressed: () {
                if (ref.read(reglagesProvider).haptiqueActive) {
                  HaptiqueService.selection();
                }
                ref.read(moteurRespirationProvider.notifier).demarrer();
                Navigator.of(context).push(
                  RouteFondu<void>(ecran: const EcranSeanceRespiration()),
                );
              },
              child: const Text('Commencer'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte de sélection d'un rythme respiratoire.
class _CarteRythme extends StatelessWidget {
  const _CarteRythme({
    required this.rythme,
    required this.choisi,
    required this.onTap,
  });

  final RythmeRespiration rythme;
  final bool choisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    final TextTheme typo = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutSine,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: choisi ? schema.primary : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: CarteZen(
        onTap: onTap,
        enfant: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rythme.nom, style: typo.titleMedium),
                  const SizedBox(height: 6),
                  Text(rythme.description, style: typo.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              rythme.motif,
              style: typo.titleSmall!.copyWith(
                color: choisi ? schema.primary : schema.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Curseurs du rythme personnalisé (durées de chaque phase).
class _ReglagesRythmePerso extends ConsumerWidget {
  const _ReglagesRythmePerso({required this.perso});

  final RythmeRespiration perso;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RythmePersoNotifier notifier = ref.read(rythmePersoProvider.notifier);

    void appliquer() {
      // Le moteur suit le rythme personnalisé à mesure qu'il change.
      ref
          .read(moteurRespirationProvider.notifier)
          .configurer(rythme: ref.read(rythmePersoProvider));
    }

    return CarteZen(
      enfant: Column(
        children: [
          _Curseur(
            libelle: 'Inspiration',
            valeur: perso.inspiration,
            min: 2,
            max: 10,
            onChanged: (v) {
              notifier.modifier(inspiration: v);
              appliquer();
            },
          ),
          _Curseur(
            libelle: 'Rétention pleine',
            valeur: perso.retentionHaute,
            min: 0,
            max: 10,
            onChanged: (v) {
              notifier.modifier(retentionHaute: v);
              appliquer();
            },
          ),
          _Curseur(
            libelle: 'Expiration',
            valeur: perso.expiration,
            min: 2,
            max: 12,
            onChanged: (v) {
              notifier.modifier(expiration: v);
              appliquer();
            },
          ),
          _Curseur(
            libelle: 'Rétention vide',
            valeur: perso.retentionBasse,
            min: 0,
            max: 10,
            onChanged: (v) {
              notifier.modifier(retentionBasse: v);
              appliquer();
            },
          ),
        ],
      ),
    );
  }
}

class _Curseur extends StatelessWidget {
  const _Curseur({
    required this.libelle,
    required this.valeur,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String libelle;
  final double valeur;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextTheme typo = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(libelle, style: typo.bodyMedium),
        ),
        Expanded(
          child: Slider(
            value: valeur.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) * 2).round(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            valeur == valeur.roundToDouble()
                ? '${valeur.toInt()} s'
                : '$valeur s',
            style: typo.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
