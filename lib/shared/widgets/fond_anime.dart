import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/palette_flow.dart';

/// Fond de l'application : dégradés radiaux qui dérivent très lentement,
/// comme des nappes de brume. Le mouvement est à peine perceptible —
/// c'est voulu, il installe le calme sans attirer l'attention.
class FondAnime extends StatefulWidget {
  const FondAnime({super.key, required this.enfant});

  final Widget enfant;

  @override
  State<FondAnime> createState() => _FondAnimeState();
}

class _FondAnimeState extends State<FondAnime>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur;

  @override
  void initState() {
    super.initState();
    // Un cycle complet dure une minute : la dérive est imperceptible.
    _controleur = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool sombre = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controleur,
            builder: (context, _) => CustomPaint(
              painter: _PeintreBrume(
                avancement: _controleur.value,
                sombre: sombre,
              ),
            ),
          ),
        ),
        widget.enfant,
      ],
    );
  }
}

/// Peint trois nappes radiales aux couleurs de la palette, en dérive lente.
class _PeintreBrume extends CustomPainter {
  _PeintreBrume({required this.avancement, required this.sombre});

  final double avancement;
  final bool sombre;

  @override
  void paint(Canvas canvas, Size size) {
    // Fond uni de base.
    final Color fond = sombre ? PaletteFlow.nuit : PaletteFlow.sableClair;
    canvas.drawRect(Offset.zero & size, Paint()..color = fond);

    final double t = avancement * 2 * math.pi;

    // Chaque nappe dérive selon sa propre fréquence, très lentement.
    _nappe(
      canvas,
      size,
      centre: Offset(
        size.width * (0.25 + 0.10 * math.sin(t)),
        size.height * (0.20 + 0.06 * math.cos(t * 0.7)),
      ),
      rayon: size.width * 0.85,
      couleur: (sombre ? PaletteFlow.indigo : PaletteFlow.mousseBrume)
          .withValues(alpha: sombre ? 0.22 : 0.35),
    );
    _nappe(
      canvas,
      size,
      centre: Offset(
        size.width * (0.80 + 0.08 * math.cos(t * 0.9 + 2)),
        size.height * (0.55 + 0.08 * math.sin(t * 0.6 + 1)),
      ),
      rayon: size.width * 0.75,
      couleur: (sombre ? PaletteFlow.mousseSombre : PaletteFlow.terracottaBrume)
          .withValues(alpha: sombre ? 0.14 : 0.28),
    );
    _nappe(
      canvas,
      size,
      centre: Offset(
        size.width * (0.45 + 0.09 * math.sin(t * 0.5 + 4)),
        size.height * (0.92 + 0.05 * math.cos(t * 0.8 + 3)),
      ),
      rayon: size.width * 0.9,
      couleur: (sombre ? PaletteFlow.indigoProfond : PaletteFlow.sable)
          .withValues(alpha: sombre ? 0.45 : 0.55),
    );
  }

  void _nappe(
    Canvas canvas,
    Size size, {
    required Offset centre,
    required double rayon,
    required Color couleur,
  }) {
    final Paint pinceau = Paint()
      ..shader = RadialGradient(
        colors: [couleur, couleur.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: centre, radius: rayon));
    canvas.drawCircle(centre, rayon, pinceau);
  }

  @override
  bool shouldRepaint(_PeintreBrume ancien) =>
      ancien.avancement != avancement || ancien.sombre != sombre;
}
