import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/palette_flow.dart';
import '../data/rythme_respiration.dart';
import '../logic/moteur_respiration.dart';

/// La bulle de respiration — pièce maîtresse de Flow.
///
/// Elle gonfle à l'inspiration, se suspend pendant les rétentions et
/// se vide lentement à l'expiration, en suivant exactement les durées
/// du rythme choisi. Une très légère ondulation permanente lui donne
/// la vie d'une vraie respiration ; rien n'est jamais brusque.
class BulleRespiration extends ConsumerStatefulWidget {
  const BulleRespiration({super.key});

  @override
  ConsumerState<BulleRespiration> createState() => _BulleRespirationState();
}

class _BulleRespirationState extends ConsumerState<BulleRespiration>
    with TickerProviderStateMixin {
  /// Remplissage de la bulle : 0 = poumons vides, 1 = pleins.
  late final AnimationController _souffle;

  /// Ondulation permanente, à peine perceptible.
  late final AnimationController _ondulation;

  /// Amplitude au repos (la bulle « respire » doucement en attendant).
  static const double _reposBas = 0.16;

  @override
  void initState() {
    super.initState();
    _souffle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      value: _reposBas,
    );
    _ondulation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _souffle.dispose();
    _ondulation.dispose();
    super.dispose();
  }

  /// Recale l'animation de la bulle sur la phase respiratoire courante.
  void _suivreEtat(EtatRespiration? precedent, EtatRespiration etat) {
    switch (etat.statut) {
      case StatutRespiration.preparation:
        // On se dépose : la bulle descend doucement vers le repos.
        _souffle.animateTo(
          _reposBas,
          duration: const Duration(seconds: 3),
          curve: Curves.easeInOutSine,
        );
      case StatutRespiration.enCours:
        final bool nouvellePhase = precedent?.phase != etat.phase ||
            precedent?.statut != StatutRespiration.enCours;
        if (!nouvellePhase) return;
        // Temps restant réel de la phase (utile après une pause).
        final double reste =
            (etat.dureePhase - etat.tempsDansPhase).clamp(0.1, 30.0);
        final Duration duree =
            Duration(milliseconds: (reste * 1000).round());
        switch (etat.phase) {
          case PhaseRespiration.inspiration:
            _souffle.animateTo(1, duration: duree, curve: Curves.easeInOutSine);
          case PhaseRespiration.expiration:
            _souffle.animateTo(
              _reposBas,
              duration: duree,
              curve: Curves.easeInOutSine,
            );
          case PhaseRespiration.retentionHaute:
          case PhaseRespiration.retentionBasse:
            _souffle.stop(); // la bulle se suspend, l'ondulation continue
        }
      case StatutRespiration.enPause:
        _souffle.stop();
      case StatutRespiration.reposee:
      case StatutRespiration.terminee:
        _souffle.animateTo(
          _reposBas,
          duration: const Duration(seconds: 3),
          curve: Curves.easeInOutSine,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EtatRespiration>(moteurRespirationProvider, _suivreEtat);
    final EtatRespiration etat = ref.watch(moteurRespirationProvider);
    final bool sombre = Theme.of(context).brightness == Brightness.dark;

    final Color coeur =
        sombre ? PaletteFlow.mousseClaire : PaletteFlow.mousse;
    final Color coeurDoux =
        sombre ? PaletteFlow.mousseSombre : PaletteFlow.mousseClaire;

    return LayoutBuilder(
      builder: (context, contraintes) {
        final double base =
            contraintes.biggest.shortestSide.clamp(0.0, 420.0);
        return AnimatedBuilder(
          animation: Listenable.merge([_souffle, _ondulation]),
          builder: (context, _) {
            // Légère ondulation organique superposée au souffle.
            final double vague = 0.012 *
                Curves.easeInOutSine.transform(_ondulation.value);
            final double v = (_souffle.value + vague).clamp(0.0, 1.0);
            final double echelle = 0.46 + 0.54 * v;
            final double diametre = base * 0.66;

            return SizedBox(
              width: base,
              height: base,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Halo extérieur, très diffus.
                  _cercle(
                    diametre * echelle * 1.55,
                    RadialGradient(
                      colors: [
                        coeur.withValues(alpha: 0.20),
                        coeur.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  // Anneaux d'ondulation, comme des ronds dans l'eau.
                  _anneau(diametre * echelle * 1.30,
                      coeur.withValues(alpha: 0.14)),
                  _anneau(diametre * echelle * 1.16,
                      coeur.withValues(alpha: 0.22)),
                  // Cœur de la bulle.
                  _cercle(
                    diametre * echelle,
                    RadialGradient(
                      center: const Alignment(-0.25, -0.35),
                      colors: [
                        coeurDoux.withValues(alpha: sombre ? 0.85 : 0.95),
                        coeur,
                      ],
                    ),
                  ),
                  // Consigne et compte à rebours, au centre.
                  _ConsigneCentrale(etat: etat, sombre: sombre),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _cercle(double diametre, Gradient degrade) {
    return Container(
      width: diametre,
      height: diametre,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: degrade),
    );
  }

  Widget _anneau(double diametre, Color couleur) {
    return Container(
      width: diametre,
      height: diametre,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: couleur, width: 1.2),
      ),
    );
  }
}

/// Texte au centre de la bulle : consigne de phase et compte à rebours,
/// qui se succèdent en fondu lent.
class _ConsigneCentrale extends StatelessWidget {
  const _ConsigneCentrale({required this.etat, required this.sombre});

  final EtatRespiration etat;
  final bool sombre;

  @override
  Widget build(BuildContext context) {
    final TextTheme typo = Theme.of(context).textTheme;
    final Color encre =
        sombre ? PaletteFlow.nuit : PaletteFlow.sableClair;

    final (String consigne, String? detail) = switch (etat.statut) {
      StatutRespiration.preparation => ('Installez-vous', null),
      StatutRespiration.enCours => (
          etat.phase.consigne,
          '${etat.resteDansPhase}',
        ),
      StatutRespiration.enPause => ('En pause', null),
      StatutRespiration.terminee => ('Merci', null),
      StatutRespiration.reposee => ('', null),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      switchInCurve: Curves.easeInOutSine,
      switchOutCurve: Curves.easeInOutSine,
      child: Column(
        key: ValueKey<String>('$consigne${etat.statut}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            consigne,
            style: typo.headlineSmall!.copyWith(color: encre),
            textAlign: TextAlign.center,
          ),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(
              detail,
              style: typo.bodyMedium!
                  .copyWith(color: encre.withValues(alpha: 0.75)),
            ),
          ],
        ],
      ),
    );
  }
}
