import 'package:flutter/material.dart';

import '../../core/constants/rythme_animations.dart';

/// Fait apparaître son enfant en fondu, avec une légère élévation,
/// après un délai optionnel. Utilisé partout pour que les écrans
/// se composent progressivement plutôt que d'apparaître d'un bloc.
class Apparition extends StatefulWidget {
  const Apparition({
    super.key,
    required this.enfant,
    this.delai = Duration.zero,
    this.glissement = 18,
  });

  /// Crée une apparition décalée selon la position dans une cascade.
  // ignore: prefer_const_constructors_in_immutables
  Apparition.cascade({
    super.key,
    required this.enfant,
    required int rang,
    this.glissement = 18,
  }) : delai = RythmeAnimations.cascade * rang;

  final Widget enfant;
  final Duration delai;

  /// Distance du léger glissement vertical (en pixels).
  final double glissement;

  @override
  State<Apparition> createState() => _ApparitionState();
}

class _ApparitionState extends State<Apparition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur;
  late final CurvedAnimation _courbe;

  @override
  void initState() {
    super.initState();
    _controleur = AnimationController(
      vsync: this,
      duration: RythmeAnimations.apparition,
    );
    _courbe = CurvedAnimation(
      parent: _controleur,
      curve: RythmeAnimations.courbeApparition,
    );
    if (widget.delai == Duration.zero) {
      _controleur.forward();
    } else {
      Future<void>.delayed(widget.delai, () {
        if (mounted) _controleur.forward();
      });
    }
  }

  @override
  void dispose() {
    _courbe.dispose();
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _courbe,
      builder: (context, enfant) => Opacity(
        opacity: _courbe.value,
        child: Transform.translate(
          offset: Offset(0, widget.glissement * (1 - _courbe.value)),
          child: enfant,
        ),
      ),
      child: widget.enfant,
    );
  }
}
