import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptique_service.dart';
import '../../../shared/widgets/apparition.dart';
import '../../../shared/widgets/carte_zen.dart';
import '../../../shared/widgets/en_tete_ecran.dart';
import '../data/catalogue_sons.dart';
import '../logic/mixeur_sons_provider.dart';

/// Écran « Sons » : le mixeur d'ambiances. Chaque son s'active d'un
/// toucher et dévoile son curseur de volume ; plusieurs sons se
/// superposent librement, seuls ou pendant un exercice.
class EcranSons extends ConsumerWidget {
  const EcranSons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, PisteAmbiance> pistes = ref.watch(mixeurSonsProvider);
    final int actives = pistes.values.where((p) => p.active).length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        EnTeteEcran(
          titre: 'Sons',
          sousTitre: 'Composez votre paysage sonore.',
          action: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: actives > 0 ? 1 : 0,
            child: TextButton(
              onPressed: actives > 0
                  ? () => ref.read(mixeurSonsProvider.notifier).toutCouper()
                  : null,
              child: const Text('Tout couper'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(CatalogueSons.tous.length, (i) {
          final SonAmbiance son = CatalogueSons.tous[i];
          final PisteAmbiance piste = pistes[son.id] ?? const PisteAmbiance();
          return Apparition.cascade(
            rang: i + 1,
            enfant: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: _CarteSon(son: son, piste: piste),
            ),
          );
        }),
        const SizedBox(height: 12),
        Apparition.cascade(
          rang: CatalogueSons.tous.length + 1,
          enfant: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Les sons continuent en arrière-plan : laissez-les '
              'vous accompagner pendant une séance ou un exercice.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte d'un son : icône, nom, interrupteur ; le volume se dévoile
/// en douceur quand la piste est active.
class _CarteSon extends ConsumerWidget {
  const _CarteSon({required this.son, required this.piste});

  final SonAmbiance son;
  final PisteAmbiance piste;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    final TextTheme typo = Theme.of(context).textTheme;
    final MixeurSonsNotifier mixeur = ref.read(mixeurSonsProvider.notifier);

    return CarteZen(
      onTap: () {
        HaptiqueService.selection();
        mixeur.basculer(son.id);
      },
      enfant: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutSine,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: piste.active
                      ? schema.primary.withValues(alpha: 0.18)
                      : schema.surfaceContainerHigh.withValues(alpha: 0.6),
                ),
                child: Icon(
                  son.icone,
                  color: piste.active ? schema.primary : schema.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(son.nom, style: typo.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      piste.disponible
                          ? son.description
                          : 'Fichier audio à déposer — voir le dossier assets',
                      style: typo.bodySmall!.copyWith(
                        color: piste.disponible
                            ? null
                            : schema.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: piste.active,
                onChanged: (_) {
                  HaptiqueService.selection();
                  mixeur.basculer(son.id);
                },
              ),
            ],
          ),
          // Le curseur de volume apparaît sans hâte quand le son joue.
          AnimatedSize(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutSine,
            child: piste.active
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.volume_down_rounded,
                          size: 20,
                          color: schema.onSurfaceVariant,
                        ),
                        Expanded(
                          child: Slider(
                            value: piste.volume,
                            onChanged: (v) =>
                                mixeur.reglerVolume(son.id, v),
                          ),
                        ),
                        Icon(
                          Icons.volume_up_rounded,
                          size: 20,
                          color: schema.onSurfaceVariant,
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
