import 'package:flutter/material.dart';

import '../../../core/services/haptique_service.dart';
import '../../../shared/widgets/fond_anime.dart';
import '../../../shared/widgets/pile_fondue.dart';
import '../../breathing/presentation/ecran_respiration.dart';
import '../../sessions/presentation/ecran_seances.dart';
import '../../sounds/presentation/ecran_sons.dart';
import '../../tracking/presentation/ecran_suivi.dart';
import 'ecran_accueil.dart';

/// Structure principale : cinq onglets qui se succèdent en fondu,
/// au-dessus du fond animé commun.
class EcranPrincipal extends StatefulWidget {
  const EcranPrincipal({super.key});

  @override
  State<EcranPrincipal> createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  int _index = 0;

  static const List<(IconData, String)> _onglets = [
    (Icons.spa_outlined, 'Accueil'),
    (Icons.air_rounded, 'Respirer'),
    (Icons.headphones_outlined, 'Séances'),
    (Icons.graphic_eq_rounded, 'Sons'),
    (Icons.eco_outlined, 'Suivi'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondAnime(
        enfant: SafeArea(
          bottom: false,
          child: PileFondue(
            index: _index,
            enfants: const [
              EcranAccueil(),
              EcranRespiration(),
              EcranSeances(),
              EcranSons(),
              EcranSuivi(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BarreNavigation(
        index: _index,
        onglets: _onglets,
        onChoix: (i) {
          if (i == _index) return;
          HaptiqueService.selection();
          setState(() => _index = i);
        },
      ),
    );
  }
}

/// Barre de navigation basse, entièrement personnalisée :
/// des icônes sobres, un point qui glisse sous l'onglet actif.
class _BarreNavigation extends StatelessWidget {
  const _BarreNavigation({
    required this.index,
    required this.onglets,
    required this.onChoix,
  });

  final int index;
  final List<(IconData, String)> onglets;
  final ValueChanged<int> onChoix;

  @override
  Widget build(BuildContext context) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    final TextTheme typo = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: schema.surfaceContainerLow.withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(color: schema.outlineVariant, width: 0.7),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: List.generate(onglets.length, (i) {
              final bool actif = i == index;
              final (IconData icone, String libelle) = onglets[i];
              return Expanded(
                child: InkWell(
                  onTap: () => onChoix(i),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutSine,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: actif
                              ? schema.primary.withValues(alpha: 0.13)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          icone,
                          size: 23,
                          color: actif
                              ? schema.primary
                              : schema.onSurfaceVariant
                                  .withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutSine,
                        style: typo.labelSmall!.copyWith(
                          color: actif
                              ? schema.primary
                              : schema.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                          letterSpacing: 0.6,
                        ),
                        child: Text(libelle),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
