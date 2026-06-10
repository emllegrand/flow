import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Graphique en barres des minutes pratiquées sur les 7 derniers jours.
/// Dessiné à la main : barres arrondies, montée en douceur à l'apparition.
class GraphiqueSemaine extends StatefulWidget {
  const GraphiqueSemaine({super.key, required this.minutesParJour});

  /// Index 0 = il y a 6 jours, index 6 = aujourd'hui.
  final List<int> minutesParJour;

  @override
  State<GraphiqueSemaine> createState() => _GraphiqueSemaineState();
}

class _GraphiqueSemaineState extends State<GraphiqueSemaine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pousse;

  @override
  void initState() {
    super.initState();
    // Les barres poussent lentement, comme des tiges.
    _pousse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _pousse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme schema = Theme.of(context).colorScheme;
    final TextTheme typo = Theme.of(context).textTheme;
    final DateTime aujourdHui = DateTime.now();

    return AnimatedBuilder(
      animation: _pousse,
      builder: (context, _) {
        final double avancement =
            Curves.easeInOutSine.transform(_pousse.value);
        return Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _PeintreBarres(
                  valeurs: widget.minutesParJour,
                  avancement: avancement,
                  couleur: schema.primary,
                  couleurVide: schema.outlineVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Initiales des jours, sous chaque barre.
            Row(
              children: List.generate(7, (i) {
                final DateTime jour =
                    aujourdHui.subtract(Duration(days: 6 - i));
                final String initiale = DateFormat('E', 'fr_FR')
                    .format(jour)
                    .substring(0, 1)
                    .toUpperCase();
                return Expanded(
                  child: Text(
                    initiale,
                    textAlign: TextAlign.center,
                    style: typo.labelSmall,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _PeintreBarres extends CustomPainter {
  _PeintreBarres({
    required this.valeurs,
    required this.avancement,
    required this.couleur,
    required this.couleurVide,
  });

  final List<int> valeurs;
  final double avancement;
  final Color couleur;
  final Color couleurVide;

  @override
  void paint(Canvas canvas, Size size) {
    final int maximum =
        valeurs.fold(0, (m, v) => v > m ? v : m).clamp(1, 1 << 31);
    final double largeurCase = size.width / valeurs.length;
    final double largeurBarre = largeurCase * 0.34;

    for (int i = 0; i < valeurs.length; i++) {
      final double x = largeurCase * i + largeurCase / 2;
      final double hauteurPleine =
          (valeurs[i] / maximum) * (size.height - 8);
      final double hauteur = hauteurPleine * avancement;

      final Paint pinceau = Paint()
        ..color = valeurs[i] == 0
            ? couleurVide.withValues(alpha: 0.5)
            : couleur.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      // Jour sans pratique : un simple point posé sur la ligne de base.
      if (valeurs[i] == 0) {
        canvas.drawCircle(Offset(x, size.height - 3), 2.5, pinceau);
        continue;
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - largeurBarre / 2,
            size.height - hauteur,
            largeurBarre,
            hauteur,
          ),
          Radius.circular(largeurBarre / 2),
        ),
        pinceau,
      );
    }
  }

  @override
  bool shouldRepaint(_PeintreBarres ancien) =>
      ancien.avancement != avancement || ancien.valeurs != valeurs;
}
