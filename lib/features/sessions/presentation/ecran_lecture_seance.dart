import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/services/mixeur_audio.dart';
import '../../../core/utils/formats.dart';
import '../../../shared/widgets/apparition.dart';
import '../../../shared/widgets/fond_anime.dart';
import '../data/catalogue_seances.dart';
import '../logic/lecteur_seance_provider.dart';

/// Écran de lecture d'une séance guidée : titre, progression, contrôles.
class EcranLectureSeance extends ConsumerWidget {
  const EcranLectureSeance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EtatLecteurSeance etat = ref.watch(lecteurSeanceProvider);
    final SeanceGuidee? seance = etat.seance;
    final TextTheme typo = Theme.of(context).textTheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(lecteurSeanceProvider.notifier).fermer();
      },
      child: Scaffold(
        body: FondAnime(
          enfant: SafeArea(
            child: seance == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const Spacer(),
                        // — Titre et objectif
                        Apparition(
                          enfant: Column(
                            children: [
                              Text(
                                seance.objectif.libelle.toUpperCase(),
                                style: typo.labelMedium,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                seance.titre,
                                style: typo.displaySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                seance.description,
                                style: typo.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // — Corps : selon la disponibilité du fichier
                        switch (etat.statut) {
                          StatutLecteur.chargement => const Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          StatutLecteur.indisponible =>
                            const _MessageIndisponible(),
                          _ => const _ControlesLecture(),
                        },
                        const Spacer(),
                        // — Fermeture, discrète en bas
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Fermer'),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Message calme quand le fichier audio n'a pas encore été déposé.
class _MessageIndisponible extends StatelessWidget {
  const _MessageIndisponible();

  @override
  Widget build(BuildContext context) {
    final TextTheme typo = Theme.of(context).textTheme;
    final ColorScheme schema = Theme.of(context).colorScheme;
    return Apparition(
      enfant: Column(
        children: [
          Icon(
            Icons.music_off_rounded,
            size: 36,
            color: schema.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'La voix de cette séance n\'est pas encore là.',
            style: typo.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Déposez le fichier audio dans assets/audio/sessions/ '
            '(voir le README de ce dossier), puis relancez l\'application.',
            style: typo.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Progression et contrôles de lecture.
class _ControlesLecture extends ConsumerWidget {
  const _ControlesLecture();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    final TextTheme typo = Theme.of(context).textTheme;
    final MixeurAudioHandler mixeur = ref.watch(mixeurAudioProvider);
    final LecteurSeanceNotifier lecteur =
        ref.read(lecteurSeanceProvider.notifier);

    final Duration position =
        ref.watch(positionSeanceProvider).value ?? Duration.zero;
    final PlayerState? etatLecture =
        ref.watch(etatLectureSeanceProvider).value;
    final Duration duree = mixeur.dureeSeance ?? Duration.zero;
    final bool termine =
        etatLecture?.processingState == ProcessingState.completed;
    final bool enLecture = (etatLecture?.playing ?? false) && !termine;

    return Apparition(
      enfant: Column(
        children: [
          // — Barre de progression, fine et douce
          Slider(
            value: duree.inMilliseconds == 0
                ? 0
                : (position.inMilliseconds / duree.inMilliseconds)
                    .clamp(0.0, 1.0),
            onChanged: duree.inMilliseconds == 0
                ? null
                : (v) => lecteur.chercher(
                      Duration(
                        milliseconds: (duree.inMilliseconds * v).round(),
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatChrono(position.inSeconds), style: typo.bodySmall),
                Text(formatChrono(duree.inSeconds), style: typo.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (termine)
            Column(
              children: [
                Text('Séance terminée.', style: typo.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Prenez le temps de revenir doucement.',
                  style: typo.bodySmall,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () =>
                      lecteur.decaler(const Duration(seconds: -15)),
                  icon: const Icon(Icons.replay_rounded),
                  iconSize: 30,
                  color: schema.onSurfaceVariant,
                  tooltip: 'Reculer de 15 secondes',
                ),
                const SizedBox(width: 24),
                // — Bouton lecture/pause principal
                Material(
                  color: schema.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: lecteur.basculerLecture,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        child: Icon(
                          enLecture
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          key: ValueKey<bool>(enLecture),
                          size: 40,
                          color: schema.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: () =>
                      lecteur.decaler(const Duration(seconds: 15)),
                  icon: const Icon(Icons.forward_rounded),
                  iconSize: 30,
                  color: schema.onSurfaceVariant,
                  tooltip: 'Avancer de 15 secondes',
                ),
              ],
            ),
        ],
      ),
    );
  }
}
