import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/marque_flow.dart';

/// Appariements officiels du repère (fond / corps / nervure).
///
/// La nervure reprend toujours la couleur du fond, légèrement voilée,
/// pour rester subtilement visible. Les monochromes omettent la nervure.
enum VarianteLogo {
  /// Sauge sur fond nuit — l'appariement principal (icône du store).
  surNuit(MarqueFlow.sauge, MarqueFlow.nuit, 0.55),

  /// Nuit sur fond sauge.
  surSauge(MarqueFlow.nuitEncre, MarqueFlow.sauge, 0.65),

  /// Sauge sur fond crème.
  surCreme(MarqueFlow.sauge, MarqueFlow.creme, 0.85),

  /// Monochrome crème, pour fond sombre — sans nervure.
  monoSombre(MarqueFlow.creme, null, 0),

  /// Monochrome nuit, pour fond clair — sans nervure.
  monoClair(MarqueFlow.nuitEncre, null, 0);

  const VarianteLogo(this.corps, this.nervure, this.opaciteNervure);

  /// Remplissage du corps du repère.
  final Color corps;

  /// Couleur de la nervure (nulle pour les monochromes).
  final Color? nervure;

  /// Opacité de la nervure.
  final double opaciteNervure;
}

/// Le repère de Flow — « la goutte-feuille ».
///
/// L'eau et la feuille en une seule forme ; une nervure courbe trace
/// le souffle à l'intérieur. Géométrie canonique : viewBox 0 0 104 120.
/// Taille minimale recommandée : 24 px de hauteur.
class LogoFlow extends StatelessWidget {
  const LogoFlow({
    super.key,
    this.hauteur = MarqueFlow.tailleMiniRepere,
    this.variante = VarianteLogo.surNuit,
  });

  /// Hauteur du repère ; la largeur suit le ratio 104/120.
  final double hauteur;

  /// Appariement de couleurs, à choisir selon le fond.
  final VarianteLogo variante;

  @override
  Widget build(BuildContext context) {
    final double largeur =
        hauteur * MarqueFlow.largeurRepere / MarqueFlow.hauteurRepere;
    return CustomPaint(
      size: Size(largeur, hauteur),
      painter: _PeintreGoutteFeuille(variante),
    );
  }
}

/// Trace la goutte-feuille à partir de sa géométrie SVG canonique :
/// corps `M52 8 C24 40 14 64 14 80 a38 38 0 0 0 76 0 C90 64 80 40 52 8 Z`,
/// nervure `M52 34 C40 52 36 68 36 84` (épaisseur 3.5, bouts ronds).
class _PeintreGoutteFeuille extends CustomPainter {
  const _PeintreGoutteFeuille(this.variante);

  final VarianteLogo variante;

  @override
  void paint(Canvas canvas, Size size) {
    final double echelle = size.height / MarqueFlow.hauteurRepere;
    canvas.scale(echelle);

    final Path corps = Path()
      ..moveTo(52, 8)
      ..cubicTo(24, 40, 14, 64, 14, 80)
      ..arcToPoint(
        const Offset(90, 80),
        radius: const Radius.circular(38),
        clockwise: false,
      )
      ..cubicTo(90, 64, 80, 40, 52, 8)
      ..close();
    canvas.drawPath(corps, Paint()..color = variante.corps);

    final Color? nervure = variante.nervure;
    if (nervure != null) {
      final Path souffle = Path()
        ..moveTo(52, 34)
        ..cubicTo(40, 52, 36, 68, 36, 84);
      canvas.drawPath(
        souffle,
        Paint()
          ..color = nervure.withValues(alpha: variante.opaciteNervure)
          ..style = PaintingStyle.stroke
          ..strokeWidth = MarqueFlow.epaisseurNervure
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_PeintreGoutteFeuille ancien) =>
      ancien.variante != variante;
}

/// Verrouillage horizontal : repère à gauche, mot « Flow » et tagline
/// « Respirer · Méditer » à droite. Échelle de référence : repère 74 px,
/// mot 60 px, tagline 12,5 px — le paramètre [echelle] réduit le tout.
class LockupFlowHorizontal extends StatelessWidget {
  const LockupFlowHorizontal({
    super.key,
    this.echelle = 1,
    this.variante = VarianteLogo.surNuit,
    this.couleurMot = MarqueFlow.creme,
  });

  /// Facteur d'échelle appliqué aux dimensions de référence.
  final double echelle;

  /// Appariement du repère, selon le fond.
  final VarianteLogo variante;

  /// Couleur du mot « Flow » (crème sur nuit, encre nuit sur clair).
  final Color couleurMot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoFlow(hauteur: 74 * echelle, variante: variante),
        SizedBox(width: 28 * echelle),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Flow',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 60 * echelle,
                fontWeight: FontWeight.w600,
                height: 0.9,
                letterSpacing: 60 * echelle * MarqueFlow.interlettrageMot,
                color: couleurMot,
              ),
            ),
            SizedBox(height: 10 * echelle),
            Padding(
              padding: EdgeInsets.only(left: 3 * echelle),
              child: Text(
                'RESPIRER · MÉDITER',
                style: GoogleFonts.outfit(
                  fontSize: 12.5 * echelle,
                  fontWeight: FontWeight.w400,
                  letterSpacing:
                      12.5 * echelle * MarqueFlow.interlettrageTagline,
                  color: MarqueFlow.ardoise,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Verrouillage empilé : repère, mot « Flow », tagline « Méditation »,
/// centrés. Échelle de référence : repère 60 px, mot 46 px, tagline 11 px.
class LockupFlowEmpile extends StatelessWidget {
  const LockupFlowEmpile({
    super.key,
    this.echelle = 1,
    this.variante = VarianteLogo.surNuit,
    this.couleurMot = MarqueFlow.creme,
  });

  /// Facteur d'échelle appliqué aux dimensions de référence.
  final double echelle;

  /// Appariement du repère, selon le fond.
  final VarianteLogo variante;

  /// Couleur du mot « Flow ».
  final Color couleurMot;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoFlow(hauteur: 60 * echelle, variante: variante),
        SizedBox(height: 16 * echelle),
        Text(
          'Flow',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 46 * echelle,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: 46 * echelle * MarqueFlow.interlettrageMot,
            color: couleurMot,
          ),
        ),
        SizedBox(height: 16 * echelle),
        Text(
          'MÉDITATION',
          style: GoogleFonts.outfit(
            fontSize: 11 * echelle,
            fontWeight: FontWeight.w400,
            letterSpacing: 11 * echelle * 0.4,
            color: MarqueFlow.ardoise,
          ),
        ),
      ],
    );
  }
}
