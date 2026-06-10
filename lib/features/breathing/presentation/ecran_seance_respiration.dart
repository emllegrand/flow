import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formats.dart';
import '../../../shared/widgets/apparition.dart';
import '../../../shared/widgets/fond_anime.dart';
import '../logic/moteur_respiration.dart';
import 'bulle_respiration.dart';

/// Séance de respiration en plein écran : la bulle, rien d'autre.
class EcranSeanceRespiration extends ConsumerWidget {
  const EcranSeanceRespiration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EtatRespiration etat = ref.watch(moteurRespirationProvider);
    final MoteurRespirationNotifier moteur =
        ref.read(moteurRespirationProvider.notifier);
    final TextTheme typo = Theme.of(context).textTheme;
    final ColorScheme schema = Theme.of(context).colorScheme;

    final bool terminee = etat.statut == StatutRespiration.terminee;

    return PopScope(
      // En sortant, la séance s'interrompt proprement (et s'enregistre
      // si elle a duré au moins une minute).
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !terminee) moteur.arreter();
      },
      child: Scaffold(
        body: FondAnime(
          enfant: SafeArea(
            child: Column(
              children: [
                // — Rythme en cours, discret en haut.
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Apparition(
                    enfant: Text(
                      etat.rythme.nom,
                      style: typo.titleSmall,
                    ),
                  ),
                ),
                const Spacer(),
                const BulleRespiration(),
                const Spacer(),
                // — Compteurs : cycles et temps.
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 700),
                  opacity:
                      etat.statut == StatutRespiration.preparation ? 0 : 1,
                  child: Text(
                    terminee
                        ? '${etat.cyclesEffectues} cycles · '
                            '${formatMinutes(etat.secondesEcoulees.round())} '
                            'de pratique'
                        : '${etat.cyclesEffectues} '
                            '${etat.cyclesEffectues > 1 ? "cycles" : "cycle"}'
                            ' · ${formatChrono(etat.secondesEcoulees.round())}'
                            ' / ${formatChrono(etat.dureeCibleSecondes)}',
                    style: typo.bodyMedium,
                  ),
                ),
                const SizedBox(height: 28),
                // — Contrôles, volontairement discrets.
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: terminee
                      ? FilledButton(
                          onPressed: () {
                            moteur.recommencer();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Revenir'),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _BoutonRond(
                              icone: etat.statut == StatutRespiration.enPause
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              onTap: () {
                                if (etat.statut ==
                                    StatutRespiration.enPause) {
                                  moteur.reprendre();
                                } else {
                                  moteur.mettreEnPause();
                                }
                              },
                            ),
                            const SizedBox(width: 20),
                            _BoutonRond(
                              icone: Icons.stop_rounded,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                ),
                if (terminee)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Prenez encore un instant avant de repartir.',
                      style: typo.bodySmall!.copyWith(
                        color: schema.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton circulaire discret pour les contrôles de séance.
class _BoutonRond extends StatelessWidget {
  const _BoutonRond({required this.icone, required this.onTap});

  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    return Material(
      color: schema.surfaceContainerLow.withValues(alpha: 0.7),
      shape: CircleBorder(
        side: BorderSide(color: schema.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Icon(icone, size: 28, color: schema.onSurface),
        ),
      ),
    );
  }
}
