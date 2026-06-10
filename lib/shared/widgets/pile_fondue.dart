import 'package:flutter/material.dart';

import '../../core/constants/rythme_animations.dart';

/// Comme un `IndexedStack` (l'état de chaque onglet est conservé),
/// mais le passage d'un onglet à l'autre se fait en fondu lent.
class PileFondue extends StatelessWidget {
  const PileFondue({super.key, required this.index, required this.enfants});

  final int index;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List.generate(enfants.length, (i) {
        final bool visible = i == index;
        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: RythmeAnimations.transition,
            curve: RythmeAnimations.courbe,
            child: ExcludeSemantics(
              excluding: !visible,
              child: enfants[i],
            ),
          ),
        );
      }),
    );
  }
}
