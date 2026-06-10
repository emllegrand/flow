import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptique_service.dart';
import '../../../shared/widgets/apparition.dart';
import '../../../shared/widgets/carte_zen.dart';
import '../../../shared/widgets/fond_anime.dart';
import '../../tracking/logic/historique_provider.dart';
import '../data/reglages_app.dart';
import '../logic/reglages_provider.dart';

/// Écran des réglages : apparence, haptique, rappels, données.
class EcranReglages extends ConsumerWidget {
  const EcranReglages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReglagesApp reglages = ref.watch(reglagesProvider);
    final ReglagesNotifier notifier = ref.read(reglagesProvider.notifier);
    final TextTheme typo = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FondAnime(
        enfant: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
            children: [
              // — Apparence
              Apparition.cascade(
                rang: 1,
                enfant: _Section(
                  titre: 'APPARENCE',
                  enfant: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Thème', style: typo.titleMedium),
                      const SizedBox(height: 14),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Clair'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('Système'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Sombre'),
                          ),
                        ],
                        selected: {reglages.modeTheme},
                        onSelectionChanged: (choix) {
                          HaptiqueService.selection();
                          notifier.changerTheme(choix.first);
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.comfortable,
                          side: WidgetStatePropertyAll(
                            BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        showSelectedIcon: false,
                      ),
                    ],
                  ),
                ),
              ),
              // — Pratique
              Apparition.cascade(
                rang: 2,
                enfant: _Section(
                  titre: 'PRATIQUE',
                  enfant: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Retour haptique', style: typo.titleMedium),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Une impulsion légère à chaque changement de phase '
                        'respiratoire.',
                        style: typo.bodySmall,
                      ),
                    ),
                    value: reglages.haptiqueActive,
                    onChanged: (v) {
                      if (v) HaptiqueService.selection();
                      notifier.changerHaptique(v);
                    },
                  ),
                ),
              ),
              // — Rappels
              Apparition.cascade(
                rang: 3,
                enfant: _Section(
                  titre: 'RAPPELS',
                  enfant: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Rappel quotidien',
                          style: typo.titleMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Une invitation douce à pratiquer, chaque jour.',
                            style: typo.bodySmall,
                          ),
                        ),
                        value: reglages.rappelActif,
                        onChanged: (v) async {
                          HaptiqueService.selection();
                          final bool ok = await notifier.changerRappel(v);
                          if (v && !ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: StadiumBorder(),
                                content: Text(
                                  'Les notifications sont désactivées '
                                  'pour Flow dans les réglages Android.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutSine,
                        child: reglages.rappelActif
                            ? ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Heure du rappel',
                                  style: typo.titleMedium,
                                ),
                                trailing: Text(
                                  reglages.rappelHeure.format(context),
                                  style: typo.titleMedium!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                                onTap: () async {
                                  final TimeOfDay? heure =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: reglages.rappelHeure,
                                    helpText: 'Heure du rappel',
                                  );
                                  if (heure != null) {
                                    await notifier.changerHeureRappel(heure);
                                  }
                                },
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
              ),
              // — Données
              Apparition.cascade(
                rang: 4,
                enfant: _Section(
                  titre: 'DONNÉES',
                  enfant: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Effacer l\'historique',
                      style: typo.titleMedium,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Repartir d\'une page blanche. Cette action est '
                        'définitive.',
                        style: typo.bodySmall,
                      ),
                    ),
                    onTap: () => _confirmerEffacement(context, ref),
                  ),
                ),
              ),
              // — À propos
              Apparition.cascade(
                rang: 5,
                enfant: _Section(
                  titre: 'À PROPOS',
                  enfant: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Flow', style: typo.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Méditation et respiration, dans le calme.\n'
                        'Les sons d\'ambiance et les voix des séances sont '
                        'des fichiers à déposer dans assets/audio/ — '
                        'voir le README du projet.',
                        style: typo.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmerEffacement(BuildContext context, WidgetRef ref) async {
    final bool? confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Effacer l\'historique ?'),
        content: const Text(
          'Toutes les pratiques enregistrées et les séries seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Garder'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
    if (confirme ?? false) {
      await ref.read(historiqueProvider.notifier).toutEffacer();
    }
  }
}

/// Section de réglages : un libellé discret au-dessus d'une carte.
class _Section extends StatelessWidget {
  const _Section({required this.titre, required this.enfant});

  final String titre;
  final Widget enfant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 10),
            child: Text(
              titre,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          CarteZen(enfant: enfant),
        ],
      ),
    );
  }
}
