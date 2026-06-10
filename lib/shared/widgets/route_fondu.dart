import 'package:flutter/material.dart';

import '../../core/constants/rythme_animations.dart';

/// Route qui fait apparaître l'écran suivant en fondu lent,
/// sans glissement brusque. Transition par défaut dans Flow.
class RouteFondu<T> extends PageRouteBuilder<T> {
  RouteFondu({required Widget ecran})
      : super(
          transitionDuration: RythmeAnimations.transition,
          reverseTransitionDuration: RythmeAnimations.transition,
          opaque: false,
          pageBuilder: (context, animation, secondaire) => ecran,
          transitionsBuilder: (context, animation, secondaire, enfant) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: RythmeAnimations.courbe,
              ),
              child: enfant,
            );
          },
        );
}
